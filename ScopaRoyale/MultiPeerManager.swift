import Foundation
import MultipeerConnectivity
import SwiftUI

class MultiPeerManager: NSObject, ObservableObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    private let serviceType = "ScopaRoyale"
    private let peerID = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private var neededPlayers: Int = 0
    private var myUsername: String = ""
    
    @Published var receivedData: Data?
    @Published var isConnected: Bool = false
    @Published var isConnected2: Bool = false
    @Published var opponentName: String = ""
    @Published var lobbyName: String = ""
    @Published var showAlert: Bool = false
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
                print("Peer (peerID) connesso")
                self.sendUsername(username: self.myUsername)
                self.sendLobbyName(lobbyName: self.lobbyName)
                if self.connectedPeers.count == self.neededPlayers {
                    self.isConnected = false
                    self.advertiser?.stopAdvertisingPeer()
                }
            case .notConnected:
                self.peerDisconnected = true
                if let index = self.connectedPeers.firstIndex(of: peerID) {
                    self.connectedPeers.remove(at: index)
                }
                if self.connectedPeers.count < self.neededPlayers {
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
                print("Dati ricevuti: \(receivedString)")
                if receivedString == "START_GAME" { // riceve l'informazione relativa all'inizio della partita
                    self.startGame = true
                    print("Inizio partita ricevuto")
                } else if receivedString.starts(with: "Lobby:") { // riceve il nome della lobby
                    self.lobbyName = String(receivedString.dropFirst(6))
                    self.isConnected2 = true
                    print("Nome lobby ricevuto: \(self.lobbyName)")
                } else if receivedString.starts(with: "Deck:") { // riceve il deck
                    let deckData = data.dropFirst(5)
                    self.deck = [Card].fromJSON(deckData)!
                    print("Deck ricevuto")
                } else if receivedString.starts(with: "OpponentHand:") { // riceve la mano
                    let handData = data.dropFirst(13)
                    self.opponentHand = [Card].fromJSON(handData)!
                    print("Mano avversario ricevuta: \(self.opponentHand)")
                } else if receivedString.starts(with: "PlayerHand:") { // riceve la mano dell'avversario
                    let playerData = data.dropFirst(11)
                    self.playerHand = [Card].fromJSON(playerData)!
                    print("Mano giocatore ricevuta: \(self.playerHand)")
                } else if receivedString.starts(with: "Table:") { // riceve le carte del tavolo
                    let tableData = data.dropFirst(6)
                    self.tableCards = [Card].fromJSON(tableData)!
                    print("Tavolo ricevuto: \(self.tableCards)")
                } else if receivedString.starts(with: "CurrentPlayer:") { // Gestisce l'aggiornamento del turno
                    let turnData = data.dropFirst(14)
                    let turnString = String(data: turnData, encoding: .utf8)
                    self.currentPlayer = Int(turnString!)!
                    print("Aggiornamento turno ricevuto: \(self.currentPlayer)")
                } else {
                    self.opponentName = receivedString
                    self.isConnected2 = true
                    print("Nome avversario ricevuto: \(self.opponentName)")
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
        self.isConnected = true
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
        guard let data = username.data(using: .utf8) else { return }
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio username: \(error.localizedDescription)")
        }
    }

    func sendLobbyName(lobbyName: String) { // usato dall'advertiser per inviare il nome della lobby al browser
        guard !lobbyName.isEmpty else { return }
        self.lobbyName = lobbyName
        guard let data = "Lobby:\(lobbyName)".data(using: .utf8) else { return }
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio nome lobby: \(error.localizedDescription)")
        }
    }

    func sendStartGameSignal() { // segnala l'inizio della partita ai giocatori
        guard let startData = "START_GAME".data(using: .utf8) else { return }
        do {
            try session.send(startData, toPeers: session.connectedPeers, with: .reliable)
            print("Inviato START_GAME")
            createDeck()
            giveCardsToOpponent()
            giveCardsToPlayer()
            placeTableCards()
        } catch {
            print("Errore invio segnale inizio partita: \(error.localizedDescription)")
        }
    }

    func createDeck() { // crea il deck e lo mescola
        let values: [String] = [
            "asso", "due", "tre", "quattro", "cinque", "sei", "sette", "otto", "nove", "dieci"
        ]
        let seeds: [String] = [
            "denari", "coppe", "bastoni", "spade"
        ]
        deck = []
        for seed in seeds {
            for value in values {
                let card = Card(value: value, seed: seed)
                deck.append(card)
            }
        }
        deck = deck.shuffled()
        sendDeck()
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
        sendCardsToOpponent()
    }
    
    func sendCardsToOpponent() { // invia le carte all'avversario
        let opponentHandData = opponentHand.toJSON()
        let message = "OpponentHand:".data(using: .utf8)! + opponentHandData!
        print("Invio dati mano avversario: \(String(data: opponentHandData!, encoding: .utf8)!)")
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
        sendCardsToPlayer()
    }
    
    func sendCardsToPlayer() { // invia le carte al giocatore
        let playerHandData = playerHand.toJSON()
        let message = "PlayerHand:".data(using: .utf8)! + playerHandData!
        print("Invio dati mano giocatore: \(String(data: playerHandData!, encoding: .utf8)!)")
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
                print("Carta estratta per il tavolo: \(card.value) di \(card.seed)")
            }
        }
        sendTableCards()
    }
    
    func sendTableCards() { // invia le carte del tavolo al giocatore
        let tableCards = tableCards.toJSON()
        let message = "Table:".data(using: .utf8)! + tableCards!
        print("Invio tavolo: \(String(data: tableCards!, encoding: .utf8)!)")
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
            print("Invio aggiornamento turno: \(String(data: turnData, encoding: .utf8)!)")
        } catch {
            print("Errore invio aggiornamento turno: \(error.localizedDescription)")
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
            cardTakenByPlayer.append(contentsOf: cardsToTake)
        } else {
            cardTakenByOpponent.append(contentsOf: cardsToTake)
        }

        sendTableCards() // aggiorna le carte del tavolo

        sendCardsToOpponent() // aggiorna le carte dell'avversario

        sendCardsToPlayer() // aggiorna le carte del giocatore

        currentPlayer = 1 - currentPlayer // passa il turno

        if playerHand.isEmpty && opponentHand.isEmpty { // controlla se entrambi i giocatori hanno terminato le carte in mano e pescano nuove carte
            giveCardsToPlayer()
            giveCardsToOpponent()
        }

        sendTurnChange() // aggiorna il turno
    }

    func reset() {
        DispatchQueue.main.async {
            self.isConnected = false
            self.isConnected2 = false
            self.opponentName = ""
            self.peerDisconnected = false
            self.deck = []
            self.opponentHand = []
            self.playerHand = []
            self.tableCards = []
            self.connectedPeers = []

            // Stop advertising and browsing
            self.advertiser?.stopAdvertisingPeer()
            self.browser?.stopBrowsingForPeers()

            // Disconnect the session
            self.session.disconnect()

            // Reinitialize the session
            self.session = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .none)
            self.session.delegate = self

            // Clear advertiser and browser
            self.advertiser = nil
            self.browser = nil

            // Clear the player points
            self.playerPoints = []
            self.opponentPoints = []

            // Reset scores and current player
            self.playerScore = 0
            self.opponentScore = 0
            self.currentPlayer = 1
        }
    }
}
