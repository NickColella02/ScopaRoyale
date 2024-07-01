
import Foundation
import MultipeerConnectivity
import SwiftUI

class Manager: NSObject, ObservableObject {
    private let serviceType = "ScopaRoyale"
    private var peerID = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession!
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser
    
    @Published var avaiblePeers: [MCPeerID] = []
    @Published var receivedInvite: Bool = false
    @Published var receivedInviteFrom: MCPeerID?
    @Published var invitationHandle: ((Bool, MCSession?) -> Void)?
    @Published var paired: Bool = false
    
    @State var showGameView: Bool = false
    
    var isAdvertiserReady: Bool = false {
        didSet {
            if isAdvertiserReady {
                startAdvertising()
            } else {
                stopAdvertising()
            }
        }
    }
    
    var isBrowsingReady: Bool = false {
        didSet {
            if isBrowsingReady {
                startBrowsing()
            } else {
                stopBrowsing()
            }
        }
    }
    
    override init() {
        peerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerID)
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        super.init()
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
    }
    
    deinit {
        stopBrowsing()
        stopAdvertising()
    }
    
    func startAdvertising() {
        advertiser.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        advertiser.stopAdvertisingPeer()
    }
    
    func startBrowsing() {
        browser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        browser.stopBrowsingForPeers()
    }
    
    func sendMove(gameMove: GameMove) {
        if !session.connectedPeers.isEmpty {
            do {
                if let data = gameMove.data() {
                    try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                }
            } catch {
                print("Errore invio mossa")
            }
        }
    }
}

extension Manager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?){
        DispatchQueue.main.async {
            if !self.avaiblePeers.contains(peerID) {
                self.avaiblePeers.append(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        guard let index = avaiblePeers.firstIndex(of: peerID) else { return }
        DispatchQueue.main.async {
            self.avaiblePeers.remove(at: index)
        }
    }
    
}

extension Manager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            self.receivedInvite = true
            self.receivedInviteFrom = peerID
            self.invitationHandle = invitationHandler
        }
    }
}

extension Manager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            DispatchQueue.main.async {
                self.paired = false
                self.isAdvertiserReady = true
            }
        case .connected:
            DispatchQueue.main.async {
                self.paired = true
                self.isAdvertiserReady = false
            }
        default:
            DispatchQueue.main.async {
                self.paired = false
                self.isAdvertiserReady = true
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let gameMove = try? JSONDecoder().decode(GameMove.self, from: data) {
            DispatchQueue.main.async {
                switch gameMove.action {
                case .start:
                    self.showGameView = true
                case .end:
                    self.session.disconnect()
                    self.isAdvertiserReady = true
                case .move:
                    print("mossa")
                }
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
        
    }
}
