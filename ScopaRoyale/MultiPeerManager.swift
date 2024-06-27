import MultipeerConnectivity
import SwiftUI

class MultiPeerManager: NSObject, ObservableObject, MCSessionDelegate, MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    private let serviceType = "ScopaRoyale"
    private let peerID = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    @Published var receivedData: Data?
    @Published var isConnected: Bool = false
    @Published var opponentName: String = ""
    private var connectedPeers: [MCPeerID] = []
    private var neededPlayers: Int = 0
    private var myUsername: String = ""
    @Published var availableLobbies: [LobbyInfo] = [] // Elenco delle lobby disponibili

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.connectedPeers.append(peerID)
                print("Peer \(peerID) connesso")
                self.sendUsername(username: self.myUsername)
                if self.connectedPeers.count == self.neededPlayers {
                    print("Interruzione connessione")
                    self.isConnected = false
                    self.advertiser?.stopAdvertisingPeer()
                }
            case .notConnected:
                if let index = self.connectedPeers.firstIndex(of: peerID) {
                    self.connectedPeers.remove(at: index)
                }
                if self.connectedPeers.count < self.neededPlayers {
                    self.advertiser?.startAdvertisingPeer()
                    self.opponentName = "" // Rimuovi il nome dell'avversario
                    self.isConnected = false
                    self.startHosting(numberOfPlayers: self.neededPlayers) // Ricomincia la ricerca
                }
            default:
                break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let lobbyInfo = try JSONDecoder().decode(LobbyInfo.self, from: data)
            DispatchQueue.main.async {
                // Aggiungi l'informazione sulla lobby alla lista delle lobby disponibili
                if !self.availableLobbies.contains(lobbyInfo) {
                    self.availableLobbies.append(lobbyInfo)
                }
            }
        } catch {
            print("Errore decoding lobby info: \(error.localizedDescription)")
        }
    }
    
    func sendLobbyInfo(lobbyInfo: LobbyInfo) {
        do {
            let data = try JSONEncoder().encode(lobbyInfo)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio lobby info: \(error.localizedDescription)")
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}

    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }

    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 5)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}

    override init() {
        super.init()
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        self.session.delegate = self
    }

    func startHosting(numberOfPlayers: Int) {
        self.neededPlayers = numberOfPlayers
        self.isConnected = true
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
}
