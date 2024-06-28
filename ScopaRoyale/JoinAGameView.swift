import SwiftUI

struct JoinAGameView: View {
    let username: String
    @ObservedObject private var peerManager: MultiPeerManager = MultiPeerManager()

    var body: some View {
        VStack {
            Spacer()
            
            // Titolo della schermata
            if peerManager.lobbyName.isEmpty {
                Text("Searching for a lobby...")
                    .font(.title)
                    .padding()
            } else {
                Text("Lobby found!")
                    .font(.title)
                    .padding()
                Text("Lobby's name: \(peerManager.lobbyName)")
                    .font(.headline)
                    .padding()
                Text("Opponent: \(peerManager.opponentName)")
                    .font(.subheadline)
                    .padding()
            }
            
            Spacer()
            
            // Bottone per unirsi a una partita trovata
            Button(action: {
                if !peerManager.lobbyName.isEmpty {
                    // Messaggio di debug
                    print("Joining match: \(peerManager.lobbyName) with username: \(username)")
                    // Navigazione alla partita da implementare
                } else {
                    peerManager.showAlert = true // Mostra l'alert se nessuna lobby è stata trovata
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
            .alert("No lobby found", isPresented: $peerManager.showAlert) {
                Button("OK", role: .cancel) {
                    peerManager.showAlert = false
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
