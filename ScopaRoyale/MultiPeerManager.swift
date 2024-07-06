import Foundation
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

struct Scores: Codable { // struttura dati contenente i punteggi dei giocatori
    let playerScore: Int // punteggio del giocatore
    let opponentScore: Int // punteggio dell'avversario
    let winner: String // vincitore della partita
}

class MultiPeerManager: NSObject, ObservableObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    private let serviceType = "ScopaRoyale"
    private let peerID = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    var myUsername: String = ""
    
    @Published var opponentName: String = "" // nome dell'avversario (browser)
    @Published var lobbyName: String = "" // nome della lobby
    @Published var startGame: Bool = false // true se la partita è iniziata
    @Published var peerDisconnected: Bool = false // true se un peer si è disconnesso
    @Published var connectedPeers: [MCPeerID] = [] // lista di peer connessi
    @Published var isHost: Bool = false // true se è l'advertiser
    @Published var isClient: Bool = false // true se è l'host
    @Published var blindMode: Bool = false
    @Published var isHostRecording: Bool = false
    @Published var isClientRecording: Bool = false
    
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
    @Published var currentPlayer: Int = 1 // indice del giocatore corrente (0 per l'advertiser e 1 per il browser)
    @State var neededPlayers: Int = 0 // numero di giocatori necessari
    @State var lastPlayer: Int = 1 // indice dell'ultimo giocatore che ha preso carte dal tavolo
    @Published var gameOver: Bool = false // true quando la partita finisce
    @Published var winner: String = "" // nome del giocatore che ha vinto

    override init() {
        super.init()
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        self.session.delegate = self
    }

    // MARK: - MCSessionDelegate

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                    self.sendUsername(username: self.myUsername)
                    self.sendLobbyName()
                    if self.connectedPeers.count == self.neededPlayers {
                        self.browser?.stopBrowsingForPeers()
                        self.advertiser?.stopAdvertisingPeer()
                    }
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
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 5)
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
                if receivedString == "START_GAME" { // riceve l'informazione relativa all'inizio della partita
                    self.startGame = true
                    self.gameOver = false
                } else if receivedString.starts(with: "Lobby:") { // riceve il nome della lobby
                    self.lobbyName = String(receivedString.dropFirst(6))
                } else if receivedString.starts(with: "Deck:") { // riceve il deck
                    let data = data.dropFirst(5)
                    self.deck = [Card].fromJSON(data)!
                } else if receivedString.starts(with: "PlayersHands:") { // riceve le mani dei giocatori
                    let jsonData = data.dropFirst(13)
                    do {
                        let hands = try JSONDecoder().decode(Hands.self, from: jsonData)
                        self.playerHand = hands.playerHand
                        self.opponentHand = hands.opponentHand
                    } catch {
                        print("Errore nella decodifica dei dati Hands: \(error.localizedDescription)")
                    }
                } else if receivedString.starts(with: "CardsTaken:") { // riceve i mazzi di carte prese dai giocatori
                    let jsonData = data.dropFirst(11)
                    do {
                        let cardsTaken = try JSONDecoder().decode(CardsTaken.self, from: jsonData)
                        self.cardTakenByPlayer = cardsTaken.playerCards
                        self.cardTakenByOpponent = cardsTaken.opponentCards
                    } catch {
                        print("Errore nella decodifica dei dati CardsTaken: \(error.localizedDescription)")
                    }
                } else if receivedString.starts(with: "PlayersPoints:") { // riceve i mazzi di scope dei giocatori
                    let jsonData = data.dropFirst(14)
                    do {
                        let points = try JSONDecoder().decode(Points.self, from: jsonData)
                        self.playerPoints = points.playerPoints
                        self.opponentPoints = points.opponentPoints
                    } catch {
                        print("Errore nella decodifica dei dati Points: \(error.localizedDescription)")
                    }
                } else if receivedString.starts(with: "Table:") { // riceve le carte del tavolo
                    let data = data.dropFirst(6)
                    self.tableCards = [Card].fromJSON(data)!
                } else if receivedString.starts(with: "CurrentPlayer:") { // Gestisce l'aggiornamento del turno
                    let data = data.dropFirst(14)
                    let dataString = String(data: data, encoding: .utf8)
                    self.currentPlayer = Int(dataString!)!
                } else if receivedString.starts(with: "GameOver:") { // Gestisce la ricezione del segnale di fine partita
                    self.gameOver = true
                    self.startGame = false
                } else if receivedString.starts(with: "PlayersScores:") { // riceve i punteggi dei giocatori e il vincitore
                    let jsonData = data.dropFirst(14)
                    do {
                        let scores = try JSONDecoder().decode(Scores.self, from: jsonData)
                        self.playerScore = scores.playerScore
                        self.opponentScore = scores.opponentScore
                        self.winner = scores.winner
                    } catch {
                        print("Errore nella decodifica dei dati Points: \(error.localizedDescription)")
                    }
                } else { // riceve l'username
                    self.opponentName = receivedString
                }
            }
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
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func joinSession() { // eseguito dal browser
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser?.delegate = self
        self.isClient = true // sono il browser
        self.isHost = false // non sono l'advertiser
        browser?.startBrowsingForPeers()
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
        let startData = "START_GAME".data(using: .utf8)
        do {
            try session.send(startData!, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio segnale inizio partita: \(error.localizedDescription)")
        }
        createDeck() // crea il mazzo iniziale
        placeTableCards() // posiziona le carte sul tavolo
        giveCardsToPlayers() // assegna le mani ai giocatori
        sendDeck() // aggiorna il mazzo iniziale
        sendPlayersPoints() // invia i mazzi contenenti le scope dei giocatori
        //sendCardsTaken() // invia i mazzi contenenti le carte prese dai giocatori
    }
    
    func sendCardsTaken() { // invia il mazzo delle carte prese all'avversario
        let cardsTaken = CardsTaken(playerCards: cardTakenByPlayer, opponentCards: cardTakenByOpponent)
        do {
            let data = try JSONEncoder().encode(cardsTaken)
            let prefixedData = "CardsTaken:".data(using: .utf8)! + data
            try session.send(prefixedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio carte prese dai giocatori: \(error.localizedDescription)")
        }
    }
        
    func sendPlayersPoints() { // invia il mazzo delle scope fatte all'avversario
        let points = Points(playerPoints: self.playerPoints, opponentPoints: self.opponentPoints)
        do {
            let data = try JSONEncoder().encode(points)
            let prefixedData = "PlayersPoints:".data(using: .utf8)! + data
            try session.send(prefixedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio scope dei giocatori: \(error.localizedDescription)")
        }
    }
    
    func createDeck() { // crea il deck e lo mescola
        let values: [String] = [ // possibili valori per le carte
            "asso", "due", "tre", "quattro", "cinque", "sei", "sette", "otto", "nove", "dieci"
        ]
        let seeds: [String] = [ // possibili semi per le carte
            "denari", "coppe", "spade", "bastoni"
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
        for _ in 0..<3 { // mano del giocatore
            if let card = deck.first {
                self.playerHand.append(card)
                self.deck.removeFirst()
            }
        }
        
        for _ in 0..<3 { // mano dell'avversario
            if let card = deck.first {
                self.opponentHand.append(card)
                self.deck.removeFirst()
            }
        }
        sendCardsToPlayers() // estrae le carte e le inserisce nelle mani dei giocatori
    }
    
    func sendCardsToPlayers() { // invia le carte delle mani dei giocatori
        let hand = Hands(playerHand: self.playerHand, opponentHand: self.opponentHand)
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
    
    func sendTurnChange() { // invia e notifica il cambio del turno
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                self.currentPlayer = 1 - self.currentPlayer // passa il turno

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
        DispatchQueue.main.async { [self] in
            let scores = Scores(playerScore: self.playerScore, opponentScore: self.opponentScore, winner: self.winner)
            do {
                let data = try JSONEncoder().encode(scores)
                let prefixedData = "PlayersScores:".data(using: .utf8)! + data
                try session.send(prefixedData, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                print("Errore invio punteggi dei giocatori: \(error.localizedDescription)")
            }
        }
    }
            
    func playCard(card: Card) { // gestisce la mossa di un giocatore
        DispatchQueue.main.async{ [self] in
            if currentPlayer == 0 {
                if let index = self.playerHand.firstIndex(of: card) { // rimuove la carta dalla mano del giocatore
                    playerHand.remove(at: index)
                }
            } else {
                if let index = self.opponentHand.firstIndex(of: card) { // rimuove la carta dalla mano dell'avversario
                    opponentHand.remove(at: index)
                }
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
            } else if let validCombination = shortestCombination { // se ha trovato una combinazione
                cardsToTake = validCombination
                for cardToTake in cardsToTake {
                    if let index = tableCards.firstIndex(of: cardToTake) { // rimuove le carte dal tavolo
                        tableCards.remove(at: index)
                    }
                }
                if tableCards.isEmpty { // se il giocatore prende le ultime carte del tavolo ha fatto scopa
                    if currentPlayer == 0 {
                        playerPoints.append(card)
                    } else {
                        opponentPoints.append(card)
                    }
                }
            }
            
            if !cardsToTake.isEmpty { // aggiunge le carte prese al mazzo delle carte prese dal giocatore
                if currentPlayer == 0 {
                    cardTakenByPlayer.append(contentsOf: cardsToTake)
                    
                } else {
                    cardTakenByOpponent.append(contentsOf: cardsToTake)
                    //opponentPoints.append(contentsOf: cardsToTake)
                }
                sendCardsTaken() // notifica l'aggiornamento dei mazzi delle prese
                sendPlayersPoints()
            }
            
            sendTableCards() // aggiorna le carte del tavolo
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
                        if lastPlayer == 0 { // se l'ultimo giocatore ad aver preso carte è l'advertiser
                            cardTakenByPlayer += tableCards // aggiunge tutte le carte del tavolo al mazzo delle sue carte prese
                        } else { // altrimenti le aggiunge al mazzo di carte prese dal browser
                            cardTakenByOpponent += tableCards
                        }
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
                        playerScore += 1
                    } else {
                        opponentScore += 1
                    }
                    
                    // assegno un punto a chi ha più carte denari nel proprio mazzo
                    let playerDenariCount = cardTakenByPlayer.filter{$0.seed == "denari"}.count
                    let opponentDenariCount = cardTakenByOpponent.filter{$0.seed == "denari"}.count
                    if playerDenariCount > opponentDenariCount {
                        playerScore += 1
                    } else if playerDenariCount < opponentDenariCount {
                        opponentScore += 1
                    }
                    
                    // assegno un punto a chi ha completato la "primera" (più sette)
                    let playerSevenCount = cardTakenByPlayer.filter { $0.value == "sette" }.count
                    let opponentSevenCount = cardTakenByOpponent.filter { $0.value == "sette" }.count
                    if playerSevenCount > opponentSevenCount {
                        playerScore += 1
                    } else if playerSevenCount < opponentSevenCount {
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
                    
                    DispatchQueue.main.async {
                        self.gameOver = true // termina la partita
                    }
                    sendPlayersScores() // invio i punteggi ai giocatori
                    sendEndGameSignal() // notifica la fine della partita
                }
            }
        }
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
