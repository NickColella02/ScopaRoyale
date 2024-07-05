import SwiftUI

@main
struct ScopaRoyaleApp: App {
    @StateObject private var peerManager = MultiPeerManager()
    @StateObject private var speechRecognized = SwiftUISpeech()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(peerManager).environmentObject(speechRecognized)
        }
    }
}
