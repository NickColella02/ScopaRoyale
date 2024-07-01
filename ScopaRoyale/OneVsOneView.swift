import SwiftUI

struct OneVsOneView: View {
    @EnvironmentObject private var peerManager: MultiPeerManager // Accesso al MultiPeerManager dall'ambiente
    let numberOfPlayer: Int // numero di giocatori
    let lobbyName: String // nome della lobby
    @State private var showStartGameAlert: Bool = false // true se si tenta di avviare una partita senza sufficienti giocatori
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? "" // username del giocatore
    @State private var navigateToGame = false
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("Lobby's Name")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Text(lobbyName)
                    .font(.largeTitle)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            if peerManager.isConnected {
                VStack(spacing: 10) {
                    Text("Searching for an opponent...")
                        .font(.headline)
                        .foregroundStyle(.gray)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                .padding()
            }
            
            HStack {
                VStack {
                    Image("1user")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                    Text(username) // nome dell'avversario
                        .font(.title2)
                        .padding(.top, 10)
                }
                
                Text("VS")
                    .font(.title)
                    .padding(.horizontal, 20)
                
                if !peerManager.opponentName.isEmpty {
                    VStack {
                        Image("1user")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                        Text(peerManager.opponentName) // nome dell'utente
                            .font(.title2)
                            .padding(.top, 10)
                    }
                }
            }
            .padding(.horizontal, 35)
                        
            Spacer()
            
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
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .padding(.horizontal, 35)
            }
            .padding(.bottom, 20)
        }
        .navigationDestination(isPresented: $navigateToGame) { // navigazione alla modalità 1 vs 1
            OneVsOneGameView().environmentObject(peerManager)
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
