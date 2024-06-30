import SwiftUI

struct JoinAGameView: View {
    let username: String
    @State private var showAlert = false // Stato per la visualizzazione dell'alert
    @EnvironmentObject private var peerManager: MultiPeerManager // Accesso al MultiPeerManager dall'ambiente
    @State private var navigateToGame = false
    
    var body: some View {
        VStack {
            if !peerManager.isConnected { // se l'utente deve ancora connettersi alla lobby
                Text("Searching a lobby...")
                    .font(.title)
                    .padding()
            }
            
            if peerManager.isConnected2 { // quando l'utente si connette alla lobby
                Text("Lobby's name: \(peerManager.lobbyName)") // nome della lobby trovata
                    .font(.title)
                    .padding()
                
                Text("Opponent: \(peerManager.opponentName)") // nome dell'avversario
                    .font(.title)
                    .padding()
            }
            
            Spacer()
            
            .navigationDestination(isPresented: $navigateToGame) { // navigazione alla modalità 1 vs 1
                OneVsOneGameView().environmentObject(peerManager)
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
