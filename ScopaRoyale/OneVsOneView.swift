import SwiftUI

struct OneVsOneView: View {
    @ObservedObject private var peerManager: MultiPeerManager = MultiPeerManager() // riferimento al peer manager
    let numberOfPlayer: Int // numero di giocatori
    let lobbyName: String // nome della lobby
    @State private var showStartGameAlert: Bool = false // true se si tenta di avviare una partita senza sufficienti giocatori
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? "" // username del giocatore
    @State private var navigateToGame = false
    
    var body: some View {
        VStack {
            Image("2users")
                .resizable()
                .scaledToFit()
                .frame(height: 120)
            
            if peerManager.isConnected {
                ProgressView("Searching for opponents...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
            
            Text("Lobby's name: \(lobbyName)")
                .font(.title)
                .padding()
            
            HStack {
                if !peerManager.opponentName.isEmpty {
                    Text(peerManager.opponentName)
                        .font(.title2)
                        .padding(.top, 10)

                    Text("VS")
                        .font(.title2)
                        .padding(.top, 10)
        
                    Text(username)
                        .font(.title2)
                        .padding(.top, 10)
                }
            }
                        
            Button(action: { // bottone per avviare la partita
                if peerManager.connectedPeers.isEmpty { // se non ci sono peer connessi
                    showStartGameAlert = true
                } else {
                    peerManager.sendStartGameSignal()
                    navigateToGame = true;
                }
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
        .navigationDestination(isPresented: $navigateToGame) { // navigazione alla modalità 1 vs 1
            OneVsOneGameView()
        }
        .preferredColorScheme(.light) // forza la light mode
        .onAppear() { // quando la pagina è caricata, da avvio alla connessione
            peerManager.startHosting(lobbyName: lobbyName, numberOfPlayers: numberOfPlayer, username: username)
        }
        .navigationTitle("")
        .alert("Unable to Start the Game", isPresented: $showStartGameAlert) { // messaggio di errore se si tenta di avviare la partita senza avversario
            VStack {
                Button("OK", role: .cancel) {
                    showStartGameAlert = false
                }
            }
        } message: {
            Text("You need another player to start a 1 vs 1 game.")
        }
    }
}
