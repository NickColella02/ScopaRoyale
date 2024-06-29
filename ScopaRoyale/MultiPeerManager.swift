import MultipeerConnectivity
import SwiftUI

class MultiPeerManager: NSObject, ObservableObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    private let serviceType = "ScopaRoyale"
    private let peerID = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    @Published var receivedData: Data?
    @Published var isConnected: Bool = false
    @Published var isConnected2: Bool = false
    @Published var opponentName: String = ""
    @Published var lobbyName: String = ""
    @Published var showAlert: Bool = false
    @Published var startGame: Bool = false
    @Published var peerDisconnected: Bool = false

    @Published var connectedPeers: [MCPeerID] = []
    private var neededPlayers: Int = 0
    private var myUsername: String = ""

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
                    } else if receivedString.starts(with: "Lobby:") {
                        self.lobbyName = String(receivedString.dropFirst(6))
                        self.isConnected2 = true
                    } else {
                        self.opponentName = receivedString
                        self.isConnected2 = true
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
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func joinSession() {
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser?.delegate = self
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
        guard let data = "START_GAME".data(using: .utf8) else { return }
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio segnale inizio partita: \(error.localizedDescription)")
        }
    }
    
    func reset() {
            self.isConnected = false
            self.isConnected2 = false
            self.opponentName = ""
            self.lobbyName = ""
            self.startGame = false
            self.peerDisconnected = true
        }
}
