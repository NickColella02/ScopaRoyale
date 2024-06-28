import SwiftUI

struct JoinAGameView: View {
    let username: String // username dell'utente
    @ObservedObject private var peerManager: MultiPeerManager = MultiPeerManager() // riferimento al peer manager

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
        }
        .onAppear { // quando la pagina è caricata, cerca di connettersi alla lobby e invia il proprio username
            peerManager.sendUsername(username: username)
            peerManager.joinSession()
        }
        .preferredColorScheme(.light) // forza la light mode
        .navigationTitle("")
    }
}
