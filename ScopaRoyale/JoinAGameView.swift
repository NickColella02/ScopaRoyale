import SwiftUI

struct JoinAGameView: View {
    let username: String
    @EnvironmentObject private var peerManager: MultiPeerManager // Accesso al MultiPeerManager dall'ambiente
    @State private var navigateToGame = false
    @State private var rotationAngle: Double = 0
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    
    var body: some View {
        VStack {
            Spacer()
            if peerManager.connectedPeers.isEmpty {
                VStack {
                    RotatingImageView(rotationAngle: $rotationAngle)
                        .frame(width: 120, height: 120)
                        .onAppear {
                            startRotating()
                        }
                    Image("searchingALobby")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                }
                .padding()
            } else {
                VStack {
                    Text("Nome della lobby")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text(peerManager.lobbyName) // nome della lobby trovata
                        .font(.largeTitle)
                        .padding(.horizontal)
                    
                    HStack {
                        VStack {
                            // Immagine dell'avatar dell'utente
                            avatarImage(for: peerManager.myAvatarImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                            
                            Text(username) // nome dell'utente
                                .font(.title2)
                                .padding(.top, 10)
                        }
                        
                        Text("VS")
                            .font(.title)
                            .padding(.horizontal, 20)
                        
                        VStack {
                            
                            // Immagine dell'avatar dell'avversario
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
                    
                    // Messaggio di attesa
                    Text("In attesa che l'host avvii la partita...")
                        .font(.headline)
                        .foregroundStyle(.gray) // Cambiato da .foregroundStyle a .foregroundStyle
                        .padding(.top, 20)
                }
                .padding()
            }
            Spacer()
        }
        .navigationDestination(isPresented: $navigateToGame) {
            OneVsOneGameView().environmentObject(peerManager).environmentObject(speechRecognizer)
        }
        .onAppear {
            peerManager.sendUsername(username: username)
            peerManager.sendOpponentAvatarImage(peerManager.myAvatarImage!)
            peerManager.joinSession()
        }
        .navigationBarTitle("", displayMode: .inline)
        .onReceive(peerManager.$startGame) { startGame in
            if startGame {
                navigateToGame = true
            }
        }
        .preferredColorScheme(.light)
    }
    
    private func startRotating() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            withAnimation(Animation.linear(duration: 1)) {
                rotationAngle += 360
            }
        }
    }
}

// Funzione per recuperare l'immagine dell'avatar dell'utente
private func avatarImage(for avatarName: String?) -> Image {
    if let avatarName = avatarName {
        return Image(avatarName)
    } else {
        return Image(systemName: "person.circle")
    }
}

struct RotatingImageView: View {
    @Binding var rotationAngle: Double
    
    var body: some View {
        Image("charging")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .rotationEffect(.degrees(rotationAngle))
    }
}
