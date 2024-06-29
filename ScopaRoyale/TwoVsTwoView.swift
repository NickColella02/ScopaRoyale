import SwiftUI

struct TwoVsTwoView: View {
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    let numberOfPlayer: Int
    @State private var showStartGameAlert: Bool = false
    @EnvironmentObject private var peerManager: MultiPeerManager // Accesso al MultiPeerManager dall'ambiente
    let lobbyName: String
    
    var body: some View {
        VStack {
            // Immagine rappresentativa della modalità di gioco (2 vs 2)
            Image("4users")
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
            
            // Visualizzazione dei team
            VStack(alignment: .leading, spacing: 20) {
                // Team 1
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("Team 1:")
                            .font(.title2)
                            .padding(.bottom, 5)
                        
                        // Nome utente del giocatore dell'host del Team 1
                        HStack(spacing: 10) {
                            Image("1user")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                            Text("\(username) (host)")
                                .font(.title3)
                        }
                        
                        // Altri giocatori del Team 1
                        Image("1user")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                    .padding(.leading, 20)
                }
                
                Spacer().frame(height: 10)
                
                // Team 2 (da implementare)
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("Team 2:")
                            .font(.title2)
                            .padding(.bottom, 5)
                        
                        // Qui andranno aggiunti i giocatori del Team 2 quando saranno disponibili
                        HStack(spacing: 10) {
                            Image("1user")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        
                        // Altri giocatori del Team 2 (da implementare)
                        Image("1user")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            // Bottone per avviare la partita
            Button(action: {
                if peerManager.connectedPeers.count != 4 { // se non ci sono abbastanza peer connessi
                    showStartGameAlert = true
                } else {
                    
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
        .preferredColorScheme(.light) // forza la light mode
        .onAppear() { // quando la pagina è caricata, avvia la connessione
            peerManager.startHosting(lobbyName: lobbyName, numberOfPlayers: numberOfPlayer, username: username)
        }
        .navigationTitle("")
        .alert("Unable to Start the Game", isPresented: $showStartGameAlert) { // messaggio di errore se si tenta di avviare una partita senza abbastanza giocatori
            VStack {
                Button("OK", role: .cancel) {
                    showStartGameAlert = false
                }
            }
        } message: {
            Text("You need 4 players to start a 2 vs 2 game.")
        }
    }
}
