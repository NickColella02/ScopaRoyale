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
    @Published var deck: [Card] = []
    @Published var tableCards: [Card] = []
    @Published var playerHand: [Card] = []
    @Published var opponentHand: [Card] = []
    @Published var isHost: Bool = false
    @Published var isClient: Bool = false

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
                print("Peer \(peerID) connesso")
                self.sendUsername(username: self.myUsername)
                self.sendLobbyName(lobbyName: self.lobbyName)
                if self.connectedPeers.count == self.neededPlayers {
                    self.isConnected = false
                    self.advertiser?.stopAdvertisingPeer()
                }
            case .notConnected:
                if let index = self.connectedPeers.firstIndex(of: peerID) {
                    self.connectedPeers.remove(at: index)
                }
                if self.connectedPeers.count < self.neededPlayers {
                    self.advertiser?.startAdvertisingPeer()
                    self.opponentName = ""
                    self.isConnected = false
                    self.startHosting(lobbyName: self.lobbyName, numberOfPlayers: 1, username: self.myUsername)
                    self.peerDisconnected = true
                } else {
                    self.peerDisconnected = true
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
                if receivedString == "START_GAME" {
                    self.startGame = true
                    print("Inizio partita ricevuto")
                } else if receivedString.starts(with: "Lobby:") {
                    self.lobbyName = String(receivedString.dropFirst(6))
                    self.isConnected2 = true
                    print("Nome lobby ricevuto: \(self.lobbyName)")
                } else if receivedString.starts(with: "Deck:") {
                    let deckData = data.dropFirst(5)
                    self.deck = [Card].fromJSON(deckData)!
                    print("Deck ricevuto")
                } else if receivedString.starts(with: "OpponentHand:") {
                    let handData = data.dropFirst(13)
                    self.opponentHand = [Card].fromJSON(handData)!
                    print("Mano avversario ricevuta: \(self.opponentHand)")
                } else if receivedString.starts(with: "PlayerHand:") {
                    let playerData = data.dropFirst(11)
                    self.playerHand = [Card].fromJSON(playerData)!
                    print("Mano giocatore ricevuta: \(self.playerHand)")
                } else if receivedString.starts(with: "Table:") {
                    let tableData = data.dropFirst(6)
                    self.tableCards = [Card].fromJSON(tableData)!
                    print("Tavolo ricevuto: \(self.tableCards)")
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

    func startHosting(lobbyName: String, numberOfPlayers: Int, username: String) {
        self.neededPlayers = numberOfPlayers
        self.isConnected = true
        self.lobbyName = lobbyName
        self.myUsername = username
        self.isHost = true
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func joinSession() {
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser?.delegate = self
        self.isClient = true
        self.isConnected2 = true
        browser?.startBrowsingForPeers()
    }

    func sendUsername(username: String) {
        self.myUsername = username
        guard let data = username.data(using: .utf8) else { return }
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio username: \(error.localizedDescription)")
        }
    }

    func sendLobbyName(lobbyName: String) {
        guard !lobbyName.isEmpty else { return }
        self.lobbyName = lobbyName
        guard let data = "Lobby:\(lobbyName)".data(using: .utf8) else { return }
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio nome lobby: \(error.localizedDescription)")
        }
    }

    func sendStartGameSignal() {
        guard let startData = "START_GAME".data(using: .utf8) else { return }
        do {
            try session.send(startData, toPeers: session.connectedPeers, with: .reliable)
            print("Inviato START_GAME")
            sendDeck()
            sendCardsToOpponent()
            sendCardsToPlayer()
            sendTableCarts()
        } catch {
            print("Errore invio segnale inizio partita: \(error.localizedDescription)")
        }
    }

    func createDeck() {
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
        print("Mazze creato e mescolato")
    }
    
    func sendDeck() {
        createDeck()
        let deckData = deck.toJSON()
        let deckMessage = "Deck:".data(using: .utf8)! + deckData!
        do {
            try session.send(deckMessage, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio mazzo: \(error.localizedDescription)")
        }
    }
    
    func giveCardsToOpponent() {
        for _ in 0..<3 {
            if let card = deck.first {
                self.opponentHand.append(card)
                self.deck.removeFirst()
            }
        }
    }
    
    func sendCardsToOpponent() {
        giveCardsToOpponent()
        let opponentHandData = opponentHand.toJSON()
        let message = "OpponentHand:".data(using: .utf8)! + opponentHandData!
        print("Invio dati mano avversario: \(String(data: opponentHandData!, encoding: .utf8)!)")
        do {
            try session.send(message, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio mano avversario: \(error.localizedDescription)")
        }
    }
    
    // Estrae le carte per il giocatore (advertiser)
    func giveCardsToPlayer() {
        for _ in 0..<3 {
            if let card = deck.first {
                self.playerHand.append(card)
                self.deck.removeFirst()
            }
        }
    }
    
    func sendCardsToPlayer() {
        giveCardsToPlayer()
        let playerHandData = playerHand.toJSON()
        let message = "PlayerHand:".data(using: .utf8)! + playerHandData!
        print("Invio dati mano giocatore: \(String(data: playerHandData!, encoding: .utf8)!)")
        do {
            try session.send(message, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio mano giocatore: \(error.localizedDescription)")
        }
    }
    
    // Posiziona le carte sul tavolo
    func placeTableCards() {
        for _ in 0..<4 {
            if let card = deck.first {
                self.tableCards.append(card)
                self.deck.removeFirst()
                print("Carta estratta per il tavolo: \(card.value) di \(card.seed)")
            }
        }
    }
    
    func sendTableCarts() {
        placeTableCards()
        let tableCards = tableCards.toJSON()
        let message = "Table:".data(using: .utf8)! + tableCards!
        print("Invio tavolo: \(String(data: tableCards!, encoding: .utf8)!)")
        do {
            try session.send(message, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio tavolo: \(error.localizedDescription)")
        }
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
            self.connectedPeers = []
        }
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        session.disconnect()
    }
}
