import SwiftUI

struct JoinAGameView: View {
    let username: String
    @State private var showAlert = false // Stato per la visualizzazione dell'alert
    @ObservedObject private var peerManager: MultiPeerManager = MultiPeerManager()
    @State private var navigateToGame = false
    
    var body: some View {
        VStack {
            Spacer()
            
            // Titolo della schermata
            Text(peerManager.isConnected2 ? "Lobby Found!" : "Searching...")
                .font(.title)
                .padding()
            
            // Visualizza il nome della lobby trovata
            if peerManager.isConnected2 {
                Text("Lobby's name: \(peerManager.lobbyName)")
                    .font(.title)
                    .padding()
                
                Text("Opponent: \(peerManager.opponentName)")
                    .font(.title)
                    .padding()
            }
            
            Spacer()
                .navigationDestination(isPresented: $navigateToGame) { // navigazione alla modalità 1 vs 1
                    OneVsOneGameView()
                }
            
                .onAppear {
                    peerManager.sendUsername(username: username)
                    peerManager.joinSession()
                }
                .onReceive(peerManager.$startGame) { startGame in
                                if startGame {
                                    navigateToGame = true
                                }
                            }
                .preferredColorScheme(.light) // Forza la light mode
        }
    }
}
