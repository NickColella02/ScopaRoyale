import SwiftUI

struct JoinAGameView: View {
    let username: String
    @State private var showAlert = false // Stato per la visualizzazione dell'alert
    @ObservedObject private var peerManager: MultiPeerManager = MultiPeerManager()

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
            
            // Bottone per unirsi alla partita
            Button(action: {
                if peerManager.isConnected2 {
                    // Navigazione alla partita da implementare
                    print("Joining lobby: \(peerManager.lobbyName) with username: \(username)")
                } else {
                    showAlert = true // Mostra l'alert se nessuna lobby è stata trovata
                }
            }) {
                Text("Join")
                    .font(.system(size: 20, design: .default))
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .padding(.horizontal, 35)
                    .padding(.bottom, 20)
            }
            .alert("No game found", isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    showAlert = false
                }
            }
        }
        .onAppear {
            peerManager.sendUsername(username: username)
            peerManager.joinSession()
        }
        .preferredColorScheme(.light) // Forza la light mode
    }
}
