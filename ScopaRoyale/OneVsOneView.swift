

import SwiftUI

struct OneVsOneView: View {
    @EnvironmentObject private var peerManager: MultiPeerManager // Accesso al MultiPeerManager dall'ambiente
    private let numberOfPlayer: Int = 2 // numero di giocatori
    let lobbyName: String // nome della lobby
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? "" // username del giocatore
    @State private var navigateToGame = false
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    
    var body: some View {
        VStack(spacing: 30) {
            VStack {
                Text("Nome della lobby")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Text(lobbyName)
                    .font(.largeTitle)
                    .padding(.horizontal)
                    .padding(.top, 10)
            }
            
            Spacer()
            
            if peerManager.connectedPeers.isEmpty {
                VStack(spacing: 10) {
                    Text("In attesa di un avversario...")
                        .font(.headline)
                        .foregroundStyle(.gray)
                        .padding()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                .padding()
            }
            
            HStack {
                VStack {
                    // Immagine dell'avatar dell'utente
                    avatarImage(for: peerManager.myAvatarImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    
                    Text(username) // nome dell'avversario
                        .font(.title2)
                        .padding(.top, 10)
                }
                
                Text("VS")
                    .font(.title)
                    .padding(.horizontal, 20)
                
                if !peerManager.opponentName.isEmpty {
                    VStack {
                        // va aggiunto l'avatar dell'avversario
                        avatarImage(for: peerManager.opponentAvatarImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        
                        Text(peerManager.opponentName) // nome dell'avversario
                            .font(.title2)
                            .padding(.top, 10)
                    }
                }
            }
            .padding(.horizontal, 35)
                        
            Spacer()
            
            Button(action: { // bottone per avviare la partita
                if !peerManager.connectedPeers.isEmpty {
                    peerManager.sendStartGameSignal()
                    navigateToGame = true
                }
            }) {
                if peerManager.connectedPeers.isEmpty { // se non ci sono peer connessi
                    Text("Gioca")
                        .font(.system(size: 20, design: .default))
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                        .padding(.horizontal, 35)
                } else {
                    Text("Gioca")
                        .font(.system(size: 20, design: .default))
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                        .padding(.horizontal, 35)
                }
            }
            .padding(.bottom, 20)
        }
        .navigationDestination(isPresented: $navigateToGame) { // navigazione alla modalità 1 vs 1
            OneVsOneGameView().environmentObject(peerManager).environmentObject(speechRecognizer)
        }
        .onChange(of: peerManager.peerDisconnected) {
            if peerManager.peerDisconnected {
                peerManager.reset()
            }
        }
        .preferredColorScheme(.light) // forza la light mode
        .onAppear() { // quando la pagina è caricata, da avvio alla connessione
            peerManager.startHosting(lobbyName: self.lobbyName, numberOfPlayers: self.numberOfPlayer, username: username)
        }
        .navigationTitle("")
    }
    
    // Funzione per recuperare l'immagine dell'avatar dell'utente
    private func avatarImage(for avatarName: String?) -> Image {
        if let avatarName = avatarName {
            return Image(avatarName)
        } else {
            return Image(systemName: "person.circle")
        }
    }
}
