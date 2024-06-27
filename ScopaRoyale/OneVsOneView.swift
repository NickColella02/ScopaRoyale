import SwiftUI

struct OneVsOneView: View {
    @ObservedObject private var peerManager: MultiPeerManager = MultiPeerManager() // riferimento al peer manager
    let numberOfPlayer: Int
    let lobbyName: String
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    
    var body: some View {
        VStack {
            // Immagine rappresentativa della modalità di gioco (1 vs 1)
            Image("2users")
                .resizable()
                .scaledToFit()
                .frame(height: 120)
            
            Text("Lobby's name: \(lobbyName)")
                .font(.title)
                .padding()
            
            if peerManager.isConnected {
                ProgressView("Searching for opponents...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
            
            HStack {
                // Nome avversario a destra
                if !peerManager.opponentName.isEmpty {
                    Spacer()
                    Text(peerManager.opponentName)
                        .font(.title2)
                        .padding(.top, 10)
                        .padding(.trailing, 20)
                }
                
                // VS al centro
                Text("VS")
                    .font(.title2)
                    .padding(.top, 10)
                
                // Nome utente dell'host a sinistra
                Text(username)
                    .font(.title2)
                    .padding(.top, 10)
                    .padding(.leading, 20)
                
                Spacer()
            }
            
            Spacer()
            
            // Bottone per avviare la partita
            Button(action: {

            }) {
                Text("Start")
                    .font(.system(size: 20, design: .default))
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .padding(.horizontal, 35)
                    .padding(.bottom, 20)
            }
        }
        .preferredColorScheme(.light) // Forza la light mode
        .onAppear() {
            peerManager.startHosting(numberOfPlayers: numberOfPlayer)
        }
       
    }
}
