import SwiftUI

struct OneVsOneView: View {
    let username: String
    @ObservedObject private var peerManager: MultiPeerManager = MultiPeerManager() // riferimento al peer manager
    let numberOfPlayer: Int
    
    var body: some View {
        VStack {
            // Immagine rappresentativa della modalità di gioco (1 vs 1)
            Image("2users")
                .resizable()
                .scaledToFit()
                .frame(height: 120)
            
            if peerManager.isConnected {
                ProgressView("Searching for opponents...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
            
            if !peerManager.opponentName.isEmpty {
                Text("Nome avversario: \(peerManager.opponentName)")
                    .font(.title2)
                    .padding(.top, 10)
            }
    
            // Nome utente del giocatore
            Text(username)
                .font(.title2)
                .padding(.top, 10)
            
            Spacer()
            
            // Bottone per avviare la partita
            Button(action: {
                // Messaggio di debug quando il bottone "Start" viene premuto
                print("Start button tapped in OneVsOneView")
            }) {
                Text("Start")
                    .font(.system(size: 20, design: .default))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(100)
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

struct OneVsOneView_Previews: PreviewProvider {
    static var previews: some View {
        OneVsOneView(username: "HostPlayer", numberOfPlayer: 1)
    }
}

#Preview {
    OneVsOneView(username: "HostPlayer", numberOfPlayer: 1)
}
