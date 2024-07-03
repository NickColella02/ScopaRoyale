import Foundation
import MultipeerConnectivity
import SwiftUI

class MultiPeerManager: NSObject, ObservableObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    private let serviceType = "ScopaRoyale"
    private let peerID = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    var myUsername: String = ""
    
    @Published var isConnected: Bool = false
    @Published var isConnected2: Bool = false
    @Published var opponentName: String = ""
    @Published var lobbyName: String = ""
    @Published var startGame: Bool = false
    @Published var peerDisconnected: Bool = false
    @Published var connectedPeers: [MCPeerID] = []
    @Published var isHost: Bool = false
    @Published var isClient: Bool = false
    
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
                self.connectedPeers.append(peerID)
                self.isConnected = true
                self.sendUsername(username: self.myUsername)
                self.sendLobbyName()
                if self.connectedPeers.count == self.neededPlayers {
                    self.isConnected = false
                    self.browser?.stopBrowsingForPeers()
                    self.advertiser?.stopAdvertisingPeer()
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
                    self.isConnected = false
                    self.startHosting(lobbyName: self.lobbyName, numberOfPlayers: 1, username: self.myUsername)
                }
            default:
                break
            }
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
                    self.isConnected2 = true
                } else if receivedString.starts(with: "Deck:") { // riceve il deck
                    let data = data.dropFirst(5)
                    self.deck = [Card].fromJSON(data)!
                } else if receivedString.starts(with: "OpponentHand:") { // riceve la mano
                    let data = data.dropFirst(13)
                    self.opponentHand = [Card].fromJSON(data)!
                } else if receivedString.starts(with: "PlayerHand:") { // riceve la mano dell'avversario
                    let data = data.dropFirst(11)
                    self.playerHand = [Card].fromJSON(data)!
                } else if receivedString.starts(with: "PlayerCards:") { // riceve il mazzo di carte prese del giocatore
                    let data = data.dropFirst(12)
                    self.cardTakenByPlayer = [Card].fromJSON(data)!
                } else if receivedString.starts(with: "OpponentCards:") { // riceve il mazzo di carte prese del giocatore
                    let data = data.dropFirst(14)
                    self.cardTakenByOpponent = [Card].fromJSON(data)!
                } else if receivedString.starts(with: "PlayerPoints:") { // riceve il mazzo di carte prese del giocatore
                    let data = data.dropFirst(13)
                    self.playerPoints = [Card].fromJSON(data)!
                } else if receivedString.starts(with: "OpponentPoints:") { // riceve il mazzo di carte prese del giocatore
                    let data = data.dropFirst(15)
                    self.opponentPoints = [Card].fromJSON(data)!
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
                    self.isConnected2 = false
                } else if receivedString.starts(with: "PlayerScore:") { // Gestisce l'aggiornamento del turno
                    let data = data.dropFirst(12)
                    let dataString = String(data: data, encoding: .utf8)
                    self.playerScore = Int(dataString!)!
                } else if receivedString.starts(with: "OpponentScore:") { // Gestisce l'aggiornamento del turno
                    let data = data.dropFirst(14)
                    let dataString = String(data: data, encoding: .utf8)
                    self.opponentScore = Int(dataString!)!
                } else if receivedString.starts(with: "Winner:") { // Gestisce l'aggiornamento del turno
                    self.winner = String(receivedString.dropFirst(7))
                } else { // riceve l'username
                    self.opponentName = receivedString
                }
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}

    // MARK: - MCNearbyServiceAdvertiserDelegate

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }

    // MARK: - MCNearbyServiceBrowserDelegate

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 5)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}

    // MARK: - Custom Methods

    func startHosting(lobbyName: String, numberOfPlayers: Int, username: String) { // eseguito dall'advertiser
        self.neededPlayers = numberOfPlayers
        self.lobbyName = lobbyName
        self.myUsername = username
        self.isHost = true
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func joinSession() { // eseguito dal browser
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser?.delegate = self
        self.isClient = true
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
            createDeck() // crea il mazzo iniziale
            placeTableCards() // posiziona le carte sul tavolo
            giveCardsToPlayer() // assegna le carte al giocatore
            giveCardsToOpponent() // assegna le carte all'avversario
            sendDeck()
            sendPlayerPoints()
            sendOpponentPoints()
            sendCardTakenByPlayer()
            sendCardTakenByOpponent()
            sendPlayerScore()
            sendOpponentScore()
        } catch {
            print("Errore invio segnale inizio partita: \(error.localizedDescription)")
        }
    }
    
    func sendCardTakenByPlayer() {
        let cards = cardTakenByPlayer.toJSON()
        let message = "PlayerCards:".data(using: .utf8)! + cards!
        do {
            try session.send(message, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio carte prese dal giocatore: \(error.localizedDescription)")
        }
    }
    
    func sendCardTakenByOpponent() {
        let cards = cardTakenByOpponent.toJSON()
        let message = "OpponentCards:".data(using: .utf8)! + cards!
        do {
            try session.send(message, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio carte prese dall'avversario: \(error.localizedDescription)")
        }
    }
    
    func sendPlayerPoints() {
        let points = playerPoints.toJSON()
        let message = "PlayerPoints:".data(using: .utf8)! + points!
        do {
            try session.send(message, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio scope del giocatore: \(error.localizedDescription)")
        }
    }
    
    func sendOpponentPoints() {
        let points = opponentPoints.toJSON()
        let message = "OpponentPoints:".data(using: .utf8)! + points!
        do {
            try session.send(message, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio scope del'avversario: \(error.localizedDescription)")
        }
    }

    func createDeck() { // crea il deck e lo mescola
        let values: [String] = [
            "asso", "due", "tre", "quattro", "cinque", "sei", "sette", "otto", "nove", "dieci"
        ]
        let seeds: [String] = [
            "denari", "coppe", "spade", "bastoni"
        ]
        for seed in seeds {
            for value in values {
                let card = Card(value: value, seed: seed)
                deck.append(card)
            }
        }
        deck = deck.shuffled() // mescola il mazzo
        sendDeck() // lo invia al browser
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
    
    func giveCardsToOpponent() { // assegna le carte all'avversario
        for _ in 0..<3 {
            if let card = deck.first {
                self.opponentHand.append(card)
                self.deck.removeFirst()
            }
        }
        sendCardsToOpponent() // invia le carte all'avversario
    }
    
    func sendCardsToOpponent() { // invia le carte all'avversario
        let opponentHandData = opponentHand.toJSON()
        let message = "OpponentHand:".data(using: .utf8)! + opponentHandData!
        do {
            try session.send(message, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio mano avversario: \(error.localizedDescription)")
        }
    }
    
    func giveCardsToPlayer() { // assegna le carte al giocatore
        for _ in 0..<3 {
            if let card = deck.first {
                self.playerHand.append(card)
                self.deck.removeFirst()
            }
        }
        sendCardsToPlayer() // invia le carte al giocatore
    }
    
    func sendCardsToPlayer() { // invia le carte al giocatore
        let playerHandData = playerHand.toJSON()
        let message = "PlayerHand:".data(using: .utf8)! + playerHandData!
        do {
            try session.send(message, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio mano giocatore: \(error.localizedDescription)")
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
        let turnData = "CurrentPlayer:\(currentPlayer)".data(using: .utf8)!
        do {
            try session.send(turnData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio aggiornamento turno: \(error.localizedDescription)")
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
    
    func sendPlayerScore() { // invia il punteggio del giocatore
        let score = "PlayerScore:\(playerScore)".data(using: .utf8)!
        do {
            try session.send(score, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore punteggio giocatore: \(error.localizedDescription)")
        }
    }
    
    func sendOpponentScore() { // invia il punteggio dell'avversario
        let score = "OpponentScore:\(opponentScore)".data(using: .utf8)!
        do {
            try session.send(score, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore punteggio avversario: \(error.localizedDescription)")
        }
    }
    
    func sendWinner() { // invia il nome del vincitore
        let winner = "Winner:\(winner)".data(using: .utf8)!
        do {
            try session.send(winner, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio vincitore: \(error.localizedDescription)")
        }
    }
    
    func playCard(card: Card) { // gestisce la mossa di un giocatore
        if currentPlayer == 0 { // rimuove la carta dalla mano del giocatore
            if let index = playerHand.firstIndex(of: card) {
                playerHand.remove(at: index)
            }
        } else {
            if let index = opponentHand.firstIndex(of: card) {
                opponentHand.remove(at: index)
            }
        }

        var cardsToTake: [Card] = [] // carte prese dal giocatore con una mossa
        var shortestCombination: [Card]? = nil
        if !tableCards.isEmpty { // controllo che il tavolo non sia vuoto
            for length in 1...tableCards.count {
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

        if currentPlayer == 0 { // aggiunge le carte prese al mazzo delle carte prese dal giocatore
            if !cardTakenByPlayer.isEmpty {
                cardTakenByPlayer.append(contentsOf: cardsToTake)
                lastPlayer = 0
            }
        } else {
            if !cardTakenByOpponent.isEmpty {
                cardTakenByOpponent.append(contentsOf: cardsToTake)
                lastPlayer = 1
            }
        }

        sendTableCards() // aggiorna le carte del tavolo
        sendCardsToOpponent() // aggiorna le carte dell'avversario
        sendCardsToPlayer() // aggiorna le carte del giocatore
        currentPlayer = 1 - currentPlayer // passa il turno
        sendTurnChange() // aggiorna il turno

        if playerHand.isEmpty && opponentHand.isEmpty { // controlla se entrambi i giocatori hanno terminato le carte in mano
            if !deck.isEmpty { // se nel mazzo iniziale ci sono altre carte, i due giocatori pescano
                giveCardsToPlayer()
                giveCardsToOpponent()
                sendDeck()
            } else { // altrimenti si controllano i punteggi per decretare il vincitore
                if !tableCards.isEmpty { // se alla fine della partita ci sono carte sul tavolo, le prende l'ultimo ad aver fatto una presa
                    if lastPlayer == 0 {
                        for card in tableCards {
                            cardTakenByPlayer.append(card)
                            if let index = tableCards.firstIndex(of: card) { // rimuove le carte dal tavolo
                                tableCards.remove(at: index)
                            }
                        }
                    } else {
                        for card in tableCards {
                            cardTakenByOpponent.append(card)
                        }
                        if let index = tableCards.firstIndex(of: card) { // rimuove le carte dal tavolo
                            tableCards.remove(at: index)
                        }
                    }
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
                sendPlayerScore() // invia il punteggio del giocatore
                sendOpponentScore() // invia il punteggio dell'avversario
                sendWinner() // notifica il vincitore
                sendEndGameSignal() // notifica la fine della partita
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
        isConnected = false
        sendUsername(username: self.myUsername)
        sendLobbyName()
    }
    
    func reset() {
        DispatchQueue.main.async {
            self.peerDisconnected = false
            self.isHost = false
            self.isClient = false
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
            self.session = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .none)
            self.session.delegate = self
        }
        
    }
}
