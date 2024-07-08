import Foundation
import AVFAudio
import MultipeerConnectivity
import SwiftUI

struct Hands: Codable { // struttura dati contenente le mani dei giocatori
    let playerHand: [Card] // mano del giocatore
    let opponentHand: [Card] // mano dell'avversario
}

struct CardsTaken: Codable { // struttura dati contenente i mazzi di carte presi dai giocatori
    let playerCards: [Card] // mazzo di carte prese dal giocatore
    let opponentCards: [Card] // mazzo di carte prese dall'avversario
}

struct Points: Codable { // struttura dati contenente i mazzi di scope fatte dai giocatori
    let playerPoints: [Card] // scope fatte dal giocatore
    let opponentPoints: [Card] // scope fatte dell'avversario
}

struct Coins: Codable {
    let playerCoins: Int
    let opponentCoins: Int
}

struct Scores: Codable { // struttura dati contenente i punteggi dei giocatori
    let playerScore: Int // punteggio del giocatore
    let opponentScore: Int // punteggio dell'avversario
    let winner: String // vincitore della partita
}

struct Primera: Codable {
    let playerHasPrimera: Bool
    let opponentHasPrimera: Bool
}

struct Settebello: Codable {
    let playerHasSettebello: Bool
    let opponentHasSettebello: Bool
}

class MultiPeerManager: NSObject, ObservableObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    private let serviceType = "ScopaRoyale3"
    private let peerID = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    var myUsername: String = ""
    private var synthetizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    @State var neededPlayers: Int = 0 // numero di giocatori necessari
    @State var lastPlayer: Int = 1 // indice dell'ultimo giocatore che ha preso carte dal tavolo
    
    @Published var opponentName: String = "" // nome dell'avversario (browser)
    @Published var lobbyName: String = "" // nome della lobby
    @Published var startGame: Bool = false // true se la partita è iniziata
    @Published var peerDisconnected: Bool = false // true se un peer si è disconnesso
    @Published var connectedPeers: [MCPeerID] = [] // lista di peer connessi
    @Published var isHost: Bool = false // true se è l'advertiser
    @Published var isClient: Bool = false // true se è l'host
    @Published var blindMode: Bool { // vero se l'utente ha abilitato la blind mode
        didSet {
            UserDefaults.standard.set(blindMode, forKey: "blindMode")
        }
    }
    @Published var isRecording: Bool = false // true se l'utente sta registrando
    @Published var deck: [Card] = [] // mazzo di carte iniziale
    @Published var tableCards: [Card] = [] // carte presenti sul tavolo
    @Published var playerHand: [Card] = [] // carte nella mano del giocatore
    @Published var opponentHand: [Card] = [] // carte nella mano dell'avversario
    @Published var cardTakenByPlayer: [Card] = [] // mazzo di carte prese dal giocatore
    @Published var cardTakenByOpponent: [Card] = [] // mazzo di carte prese dall'avversario
    @Published var playerPoints: [Card] = [] // scope del giocatore
    @Published var opponentPoints: [Card] = [] // scope dell'avversario
    @Published var playerScore: Int = 0 // punteggio del giocatore
    @Published var opponentScore: Int = 0 // punteggio dell'avversario
    @Published var playerHasSettebello: Bool = false // true se il giocatore ha il 7 bello tra le carte prese
    @Published var opponentHasSettebello: Bool = false // true se l'avversario ha il 7 bello tra le carte prese
    @Published var playerHasPrimera: Bool = false
    @Published var opponentHasPrimera: Bool = false
    @Published var playerCoinsCount: Int = 0 // numero di carte oro prese dal giocatore
    @Published var opponentCoinsCount: Int = 0 // numero di carte oro prese dall'avversario
    @Published var currentPlayer: Int = 1 // indice del giocatore corrente (0 per l'advertiser e 1 per il browser)
    @Published var gameOver: Bool = false // true quando la partita finisce
    @Published var winner: String = "" // nome del giocatore che ha vinto

    override init() {
        self.blindMode = UserDefaults.standard.bool(forKey: "blindMode")
        super.init()
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        self.session.delegate = self
    }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                    self.sendUsername(username: self.myUsername)
                    self.sendLobbyName()
                }
            case .notConnected:
                self.peerDisconnected = true
                if let index = self.connectedPeers.firstIndex(of: peerID) {
                    self.connectedPeers.remove(at: index)
                }
                if self.connectedPeers.count < self.neededPlayers {
                    self.browser?.startBrowsingForPeers()
                    self.advertiser?.startAdvertisingPeer()
                    self.opponentName = ""
                    self.startHosting(lobbyName: self.lobbyName, numberOfPlayers: 1, username: self.myUsername)
                }
            default:
                break
            }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 5)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        guard let index = connectedPeers.firstIndex(of: peerID) else { return }
        DispatchQueue.main.async {
            self.connectedPeers.remove(at: index)
            self.peerDisconnected = true
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            if let receivedString = String(data: data, encoding: .utf8) {
                if receivedString == "START_GAME" {
                    self.startGame = true
                    self.gameOver = false
                } else if receivedString.starts(with: "Lobby:") {
                    self.lobbyName = String(receivedString.dropFirst(6))
                } else if receivedString.starts(with: "Deck:") {
                    let data = data.dropFirst(5)
                    self.deck = [Card].fromJSON(data)!
                } else if receivedString.starts(with: "PlayersHands:") {
                    self.handlePlayersHandsData(data.dropFirst(13))
                } else if receivedString.starts(with: "CardsTaken:") {
                    self.handleCardsTakenData(data.dropFirst(11))
                } else if receivedString.starts(with: "PlayersPoints:") {
                    self.handlePlayersPointsData(data.dropFirst(14))
                } else if receivedString.starts(with: "Primera:") {
                    self.handlePrimeraData(data.dropFirst(8))
                } else if receivedString.starts(with: "Settebello:") {
                    self.handleSettebelloData(data.dropFirst(11))
                } else if receivedString.starts(with: "PlayersCoins:") {
                    self.handlePlayersCoinsData(data.dropFirst(13))
                } else if receivedString.starts(with: "Table:") {
                    let data = data.dropFirst(6)
                    self.tableCards = [Card].fromJSON(data)!
                } else if receivedString.starts(with: "CurrentPlayer:") {
                    let data = data.dropFirst(14)
                    let dataString = String(data: data, encoding: .utf8)
                    self.currentPlayer = Int(dataString!)!
                } else if receivedString.starts(with: "GameOver:") {
                    self.gameOver = true
                    self.startGame = false
                } else if receivedString.starts(with: "PlayersScores:") {
                    self.handlePlayersScoresData(data.dropFirst(14))
                } else if receivedString.starts(with: "IsRecording:") {
                    self.handleIsRecordingData(data.dropFirst(12))
                } else {
                    self.opponentName = receivedString
                }
            }
        }
    }

    // Funzioni helper per la decodifica

    private func handlePlayersHandsData(_ jsonData: Data) {
        do {
            let hands = try JSONDecoder().decode(Hands.self, from: jsonData)
            self.playerHand = hands.playerHand
            self.opponentHand = hands.opponentHand
        } catch {
            print("Errore nella decodifica dei dati Hands: \(error.localizedDescription)")
        }
    }

    private func handleCardsTakenData(_ jsonData: Data) {
        do {
            let cardsTaken = try JSONDecoder().decode(CardsTaken.self, from: jsonData)
            self.cardTakenByPlayer = cardsTaken.playerCards
            self.cardTakenByOpponent = cardsTaken.opponentCards
        } catch {
            print("Errore nella decodifica dei dati CardsTaken: \(error.localizedDescription)")
        }
    }

    private func handlePlayersPointsData(_ jsonData: Data) {
        do {
            let points = try JSONDecoder().decode(Points.self, from: jsonData)
            self.playerPoints = points.playerPoints
            self.opponentPoints = points.opponentPoints
        } catch {
            print("Errore nella decodifica dei dati Points: \(error.localizedDescription)")
        }
    }

    private func handlePrimeraData(_ jsonData: Data) {
        do {
            let primera = try JSONDecoder().decode(Primera.self, from: jsonData)
            self.playerHasPrimera = primera.playerHasPrimera
            self.opponentHasPrimera = primera.opponentHasPrimera
        } catch {
            print("Errore nella decodifica dei dati Primera: \(error.localizedDescription)")
        }
    }

    private func handleSettebelloData(_ jsonData: Data) {
        do {
            let settebello = try JSONDecoder().decode(Settebello.self, from: jsonData)
            self.playerHasSettebello = settebello.playerHasSettebello
            self.opponentHasPrimera = settebello.opponentHasSettebello
        } catch {
            print("Errore nella decodifica dei dati Settebello: \(error.localizedDescription)")
        }
    }

    private func handlePlayersCoinsData(_ jsonData: Data) {
        do {
            let coins = try JSONDecoder().decode(Coins.self, from: jsonData)
            self.playerCoinsCount = coins.playerCoins
            self.opponentCoinsCount = coins.opponentCoins
        } catch {
            print("Errore nella decodifica dei dati Coins: \(error.localizedDescription)")
        }
    }

    private func handlePlayersScoresData(_ jsonData: Data) {
        do {
            let scores = try JSONDecoder().decode(Scores.self, from: jsonData)
            self.playerScore = scores.playerScore
            self.opponentScore = scores.opponentScore
            self.winner = scores.winner
        } catch {
            print("Errore nella decodifica dei dati Points: \(error.localizedDescription)")
        }
    }

    private func handleIsRecordingData(_ jsonData: Data) {
        do {
            _ = try JSONDecoder().decode(Bool.self, from: jsonData)
            self.isRecording = false
        } catch {
            print("Errore nella decodifica dei dati IsRecording: \(error.localizedDescription)")
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }

    func startHosting(lobbyName: String, numberOfPlayers: Int, username: String) { // eseguito dall'advertiser
        self.neededPlayers = numberOfPlayers
        self.lobbyName = lobbyName
        self.myUsername = username
        self.isHost = true // sono l'advertiser
        self.isClient = false // non sono il browser
        self.advertiser = MCNearbyServiceAdvertiser(peer: self.peerID, discoveryInfo: nil, serviceType: self.serviceType)
        self.advertiser?.delegate = self
        self.advertiser?.startAdvertisingPeer()
    }

    func joinSession() { // eseguito dal browser
        self.browser = MCNearbyServiceBrowser(peer: self.peerID, serviceType: self.serviceType)
        self.browser?.delegate = self
        self.isClient = true // sono il browser
        self.isHost = false // non sono l'advertiser
        self.browser?.startBrowsingForPeers()
    }

    func sendUsername(username: String) { // usato dal browser per inviare il suo username all'advertiser
        self.myUsername = username
        let data = "\(myUsername)".data(using: .utf8)
        do {
            try session.send(data!, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio username: \(error.localizedDescription)")
        }
    }

    func sendLobbyName() { // usato dall'advertiser per inviare il nome della lobby al browser
        let data = "Lobby:\(lobbyName)".data(using: .utf8)
        do {
            try session.send(data!, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio nome lobby: \(error.localizedDescription)")
        }
    }

    func sendStartGameSignal() { // segnala l'inizio della partita ai giocatori
        createDeck() // crea il mazzo iniziale
        placeTableCards() // posiziona le carte sul tavolo
        giveCardsToPlayers() // assegna le mani ai giocatori
        sendDeck() // aggiorna il mazzo iniziale
        sendCardsTaken() // invia i mazzi contenenti le carte prese
        sendPlayersPoints() // invia i mazzi contenenti le scope dei giocatori
        let startData = "START_GAME".data(using: .utf8)
        do {
            try session.send(startData!, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio segnale inizio partita: \(error.localizedDescription)")
        }
    }
    
    func sendCardsTaken() { // invia il mazzo delle carte prese all'avversario
        let cardsTaken = CardsTaken(playerCards: cardTakenByOpponent, opponentCards: cardTakenByPlayer)
        do {
            let data = try JSONEncoder().encode(cardsTaken)
            let prefixedData = "CardsTaken:".data(using: .utf8)! + data
            try session.send(prefixedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio carte prese dai giocatori: \(error.localizedDescription)")
        }
    }
        
    func sendPlayersPoints() { // invia il mazzo delle scope fatte all'avversario
        let points = Points(playerPoints: opponentPoints, opponentPoints: playerPoints)
        do {
            let data = try JSONEncoder().encode(points)
            let prefixedData = "PlayersPoints:".data(using: .utf8)! + data
            try session.send(prefixedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio scope dei giocatori: \(error.localizedDescription)")
        }
    }
    
    func sendPlayersCoins() {
        let coins = Coins(playerCoins: opponentCoinsCount, opponentCoins: playerCoinsCount)
        do {
            let data = try JSONEncoder().encode(coins)
            let prefixedData = "PlayersCoins:".data(using: .utf8)! + data
            try session.send(prefixedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio denari dei giocatori: \(error.localizedDescription)")
        }
    }
    
    func sendPrimera() {
        let primera = Primera(playerHasPrimera: self.opponentHasPrimera, opponentHasPrimera: self.playerHasPrimera)
        do {
            let data = try JSONEncoder().encode(primera)
            let prefixedData = "Primera:".data(using: .utf8)! + data
            try session.send(prefixedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio primera: \(error.localizedDescription)")
        }
    }
    
    func sendSettebello() {
        let settebello = Settebello(playerHasSettebello: self.opponentHasSettebello, opponentHasSettebello: self.playerHasSettebello)
        do {
            let data = try JSONEncoder().encode(settebello)
            let prefixedData = "Settebello:".data(using: .utf8)! + data
            try session.send(prefixedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio settebello: \(error.localizedDescription)")
        }
    }
        
    func createDeck() { // crea il deck e lo mescola
        let values: [String] = [ // possibili valori per le carte
            "asso", "due", "tre", "quattro", "cinque", //"sei", "sette", "otto", "nove", "dieci"
        ]
        let seeds: [String] = [ // possibili semi per le carte
            "denari", "coppe", //"spade", "bastoni"
        ]
        for seed in seeds { // inserisce ogni carta nel mazzo iniziale
            for value in values {
                let card = Card(value: value, seed: seed)
                deck.append(card)
            }
        }
        deck = deck.shuffled() // mescola il mazzo
    }
    
    func sendDeck() { // invia il deck al browser
        let deckData = deck.toJSON()
        let deckMessage = "Deck:".data(using: .utf8)! + deckData!
        do {
            try session.send(deckMessage, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio mazzo: \(error.localizedDescription)")
        }
    }

    func giveCardsToPlayers() { // assegna 3 carte ad ogni giocatore
        for _ in 0..<3 {
            if let playerCard = deck.first { // mano del giocatore
                self.playerHand.append(playerCard)
                self.deck.removeFirst()
            }
            if let opponentCard = deck.first { // mano dell'avversario
                self.opponentHand.append(opponentCard)
                self.deck.removeFirst()
            }
        }
        sendCardsToPlayers() // estrae le carte e le inserisce nelle mani dei giocatori
    }
    
    func sendCardsToPlayers() { // invia le carte delle mani dei giocatori
        let hand = Hands(playerHand: self.opponentHand, opponentHand: self.playerHand)
        do {
            let data = try JSONEncoder().encode(hand)
            let prefixedData = "PlayersHands:".data(using: .utf8)! + data
            try session.send(prefixedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio mani dei giocatori: \(error.localizedDescription)")
        }
    }
        
    func placeTableCards() { // estrae le carte del tavolo
        for _ in 0..<4 {
            if let card = deck.first {
                self.tableCards.append(card)
                self.deck.removeFirst()
            }
        }
        sendTableCards() // invia le carte del tavolo
    }
    
    func sendTableCards() { // invia le carte del tavolo al giocatore
        let tableCards = tableCards.toJSON()
        let message = "Table:".data(using: .utf8)! + tableCards!
        do {
            try session.send(message, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio tavolo: \(error.localizedDescription)")
        }
    }
    
    func sendTurnChange() {
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                self.currentPlayer = 1 - self.currentPlayer
                let turnData = "CurrentPlayer:\(self.currentPlayer)".data(using: .utf8)!
                do {
                    try self.session.send(turnData, toPeers: self.session.connectedPeers, with: .reliable)
                } catch {
                    print("Errore invio aggiornamento turno: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func sendEndGameSignal() { // notifica la fine della partita
        let endGame = "GameOver:\(gameOver)".data(using: .utf8)!
        do {
            try session.send(endGame, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore notifica fine partita: \(error.localizedDescription)")
        }
    }
    
    func sendPlayersScores() { // invia i punteggi finali all'avversario
        let scores = Scores(playerScore: opponentScore, opponentScore: playerScore, winner: self.winner)
        do {
            let data = try JSONEncoder().encode(scores)
            let prefixedData = "PlayersScores:".data(using: .utf8)! + data
            try session.send(prefixedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio punteggi dei giocatori: \(error.localizedDescription)")
        }
    }
    
    func sendRecordingStatus(_ Recording: Bool) {
        let recording = "IsRecording: \(Recording)".data(using: .utf8)!
        do{
            try session.send(recording, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore notifica recording: \(error.localizedDescription)")
        }
        
    }
            
    func playCard(card: Card) { // gestisce la mossa di un giocatore
        DispatchQueue.main.async { [self] in
            if let index = self.playerHand.firstIndex(of: card) { // rimuove la carta dalla mano del giocatore
                playerHand.remove(at: index)
            }
            
            var cardsToTake: [Card] = [] // carte prese dal giocatore con una mossa
            var shortestCombination: [Card]? = nil // combinazione di carte da prendere più breve
            if !tableCards.isEmpty { // controllo che il tavolo non sia vuoto
                for length in 1...tableCards.count { // cerco, se possibile, la combinazione di carte più breve che il giocatore può prendere
                    for combination in tableCards.combinations(length: length) {
                        let combinationValues = combination.map { card in
                            return numericValue(for: card.value) ?? 0
                        }
                        if combinationValues.reduce(0, +) == numericValue(for: card.value) ?? 0 {
                            if shortestCombination == nil || combination.count < shortestCombination!.count {
                                shortestCombination = combination
                            }
                        }
                    }
                }
            }
            
            if tableCards.isEmpty || shortestCombination == nil { // se il tavolo è vuoto o non c'è una combinazione valida
                tableCards.append(card) // aggiungi la carta giocata al tavolo
                sendTableCards() // notifica l'aggiornamento del tavolo
            } else if let validCombination = shortestCombination { // se ha trovato una combinazione
                cardsToTake = validCombination
                for cardToTake in cardsToTake {
                    if let index = tableCards.firstIndex(of: cardToTake) { // rimuove le carte dal tavolo
                        tableCards.remove(at: index)
                        sendTableCards()
                    }
                }
                if tableCards.isEmpty { // se il giocatore prende le ultime carte del tavolo ha fatto scopa
                    playerPoints.append(card)
                    if blindMode {
                        self.speakText("Hai fatto scopa")
                    }
                    sendPlayersPoints()
                }
            }
            
            if !cardsToTake.isEmpty { // aggiunge le carte prese al mazzo delle carte prese dal giocatore
                cardTakenByPlayer.append(contentsOf: cardsToTake)
                if cardsToTake.contains(Card(value: "sette", seed: "denari")) {
                    playerHasSettebello = true
                }
                sendCardsTaken() // notifica l'aggiornamento dei mazzi delle prese
            }
            sendCardsToPlayers() // invia le carte alle mani dei giocatori
            sendTurnChange() // aggiorna il turno
            
            if playerHand.isEmpty && opponentHand.isEmpty { // controlla se entrambi i giocatori hanno terminato le carte in mano
                if !deck.isEmpty { // se nel mazzo iniziale ci sono altre carte, i due giocatori pescano
                    giveCardsToPlayers() // invia le carte alle mani dei giocatori
                    sendDeck() // invia il mazzo iniziale aggiornato
                } else { // altrimenti si controllano i punteggi per decretare il vincitore
                    playerScore = 0 // azzera i punteggi del giocatore
                    opponentScore = 0 // azzera i punteggi dell'avversario
                    if !tableCards.isEmpty {
                        cardTakenByPlayer += tableCards // aggiunge tutte le carte del tavolo al mazzo delle sue carte prese
                        tableCards.removeAll() // rimuove tutte le carte dal tavolo in una volta sola
                    }
                    
                    // assegno un punto a chi ha preso più carte
                    if cardTakenByPlayer.count > cardTakenByOpponent.count {
                        playerScore += 1
                    } else if cardTakenByPlayer.count < cardTakenByOpponent.count {
                        opponentScore += 1
                    }
                    
                    // assegno un punto per ogni scopa fatta dai giocatori
                    playerScore += playerPoints.count
                    opponentScore += opponentPoints.count
                    
                    // assegno un punto a chi ha il 7 denari
                    if cardTakenByPlayer.contains(where: { $0.value == "sette" && $0.seed == "denari" }) || playerPoints.contains(where: { $0.value == "sette" && $0.seed == "denari" }) {
                        playerHasSettebello = true
                        playerScore += 1
                    } else {
                        opponentHasSettebello = true
                        opponentScore += 1
                    }
                    
                    // assegno un punto a chi ha più carte denari nel proprio mazzo
                    playerCoinsCount = cardTakenByPlayer.filter{$0.seed == "denari"}.count
                    opponentCoinsCount = 10 - playerCoinsCount
                    if playerCoinsCount > opponentCoinsCount {
                        playerScore += 1
                    } else if playerCoinsCount < opponentCoinsCount {
                        opponentScore += 1
                    }
                    
                    // assegno un punto a chi ha completato la "primera" (più sette)
                    let playerSevenCount = cardTakenByPlayer.filter { $0.value == "sette" }.count
                    let opponentSevenCount = 4 - playerSevenCount
                    if playerSevenCount > opponentSevenCount {
                        playerHasPrimera = true
                        playerScore += 1
                    } else if playerSevenCount < opponentSevenCount {
                        opponentHasPrimera = true
                        opponentScore += 1
                    }
                    
                    // decreto il vincitore
                    if playerScore > opponentScore {
                        winner = myUsername
                    } else if playerScore < opponentScore {
                        winner = opponentName
                    } else {
                        winner = "Pareggio"
                    }
                    self.gameOver = true // termina la partita
                    if blindMode {
                        self.speakText("Partita terminata")
                    }
                    sendSettebello()
                    sendPrimera()
                    sendPlayersScores() // invio i punteggi ai giocatori
                    sendEndGameSignal() // notifica la fine della partita
                }
            }
        }
    }
    
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "it-IT")
        utterance.pitchMultiplier = 1.0
        utterance.rate = 0.5
        synthetizer.speak(utterance)
    }

    func closeConnection() {
        self.connectedPeers.removeAll()
        self.advertiser?.stopAdvertisingPeer()
        self.browser?.stopBrowsingForPeers()
        self.session.disconnect()
        myUsername = ""
        opponentName = ""
        lobbyName = ""
        sendUsername(username: self.myUsername)
        sendLobbyName()
    }
    
    func reset() {
        DispatchQueue.main.async {
            self.peerDisconnected = false
            self.gameOver = false
            self.startGame = false
            self.playerHasSettebello = false
            self.opponentHasSettebello = false
            self.playerHasPrimera = false
            self.opponentHasPrimera = false
            self.deck = []
            self.opponentHand = []
            self.playerHand = []
            self.tableCards = []
            self.cardTakenByPlayer = []
            self.cardTakenByOpponent = []
            self.playerPoints = []
            self.opponentPoints = []
            self.playerScore = 0
            self.opponentScore = 0
            self.currentPlayer = 1
            self.lastPlayer = 1
        }
    }
}
