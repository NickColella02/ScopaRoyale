import SwiftUI

struct JoinAGameView: View {
    let username: String
    @EnvironmentObject private var peerManager: MultiPeerManager // Accesso al MultiPeerManager dall'ambiente
    @State private var navigateToGame = false
    @EnvironmentObject public var speechRecognized: SwiftUISpeech
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            if peerManager.connectedPeers.isEmpty { // se l'utente deve ancora connettersi alla lobby
                VStack(spacing: 10) {
                    Text("Searching a lobby...")
                        .font(.headline)
                        .foregroundStyle(.gray)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                .padding()
            } else { // quando l'utente si connette alla lobby
                VStack(spacing: 10) {
                    Text("Lobby's Name")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text(peerManager.lobbyName) // nome della lobby trovata
                        .font(.largeTitle)
                        .padding(.horizontal)
                    
                    HStack {
                        VStack {
                            Image("1user")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                            Text(username) // nome dell'utente
                                .font(.title2)
                                .padding(.top, 10)
                        }
                        
                        Text("VS")
                            .font(.title)
                            .padding(.horizontal, 20)
                        
                        VStack {
                            Image("1user")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                            Text(peerManager.opponentName) // nome dell'avversario
                                .font(.title2)
                                .padding(.top, 10)
                        }
                    }
                    
                    // Messaggio di attesa
                    Text("Waiting for the host to start the game...")
                        .font(.headline)
                        .foregroundStyle(.gray)
                        .padding(.top, 20)
                }
                .padding()
            }
            
            Spacer()
        }
        .navigationDestination(isPresented: $navigateToGame) { // navigazione alla modalità 1 vs 1
            OneVsOneGameView().environmentObject(peerManager).environmentObject(speechRecognized)
        }
        .onAppear {
            peerManager.sendUsername(username: username)
            peerManager.joinSession()
        }
        .onReceive(peerManager.$startGame) { startGame in
            if startGame {
                navigateToGame = true
            }
        }
        .preferredColorScheme(.light) // Forza la light mode
    }
}
