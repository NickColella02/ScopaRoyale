import SwiftUI

@main
struct ScopaRoyaleApp: App {
    @StateObject private var peerManager = MultiPeerManager()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(peerManager)
        }
    }
}
