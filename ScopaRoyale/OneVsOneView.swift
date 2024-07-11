import SwiftUI

struct OneVsOneView: View {
    @EnvironmentObject private var peerManager: MultiPeerManager // Accesso al MultiPeerManager dall'ambiente
    private let numberOfPlayer: Int = 2 // numero di giocatori
    let lobbyName: String // nome della lobby
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? "" // username del giocatore
    @State private var navigateToGame = false
    @State private var isAnimatingDots = false
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Nome della lobby: \(lobbyName)") // nome della lobby trovata
                .font(.headline)
                .padding(.bottom, 20)
            
            Spacer()
            
            HStack {
                VStack {
                    // Immagine dell'avatar dell'utente
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 96, height: 96) // Stesso diametro dell'immagine più padding
                        peerManager.avatarImage(for: peerManager.myAvatarImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                    }
                    
                    Text(username) // nome dell'utente
                        .font(.system(size: 20, design: .default))
                        .bold()
                }
                
                if !peerManager.opponentName.isEmpty {
                    Image("vs")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 90, height: 90)
                    
                    VStack {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 96, height: 96) // Stesso diametro dell'immagine più padding
                            peerManager.avatarImage(for: peerManager.opponentAvatarImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                        }
                        
                        Text(peerManager.opponentName) // nome dell'avversario
                            .font(.system(size: 20, design: .default))
                            .bold()
                    }
                }
            }
            
            Spacer()
            
            if peerManager.connectedPeers.isEmpty {
                VStack {
                    Text("In attesa di un avversario...")
                        .font(.headline)
                    
                    AnimatedDotsView(isAnimating: $isAnimatingDots)
                        .onAppear {
                            isAnimatingDots = true
                        }
                }
                .padding()
            }
            
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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("")
    }
}
