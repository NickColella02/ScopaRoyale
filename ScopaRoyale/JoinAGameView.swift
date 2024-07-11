import SwiftUI

struct JoinAGameView: View {
    let username: String
    @EnvironmentObject private var peerManager: MultiPeerManager // Accesso al MultiPeerManager dall'ambiente
    @State private var navigateToGame = false
    @State private var rotationAngle: Double = 0
    @State private var isAnimatingDots = false
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            if peerManager.connectedPeers.isEmpty {
                VStack {
                    RotatingImageView(rotationAngle: $rotationAngle)
                        .frame(width: 120, height: 120)
                        .onAppear {
                            startRotating()
                        }
                    Text("Ricerca di una lobby")
                        .font(.headline)
                    
                    AnimatedDotsView(isAnimating: $isAnimatingDots)
                        .onAppear {
                            isAnimatingDots = true
                        }
                }
                .padding()
                .onAppear {
                    if peerManager.blindMode {
                        speechRecognizer.speakText("In cerca di una lobby")
                    }
                }
            } else {
                VStack {
                    Text("Lobby: \(peerManager.lobbyName)") // nome della lobby trovata
                        .font(.title)
                        .padding()
                        .bold()
                    
                    Spacer()
                    
                    HStack (spacing: 10) {
                        VStack (spacing: 10) {
                            Text(username) // nome dell'utente
                                .font(.system(size: 20, design: .default))
                                .bold()
                            peerManager.avatarImage(for: peerManager.myAvatarImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                        }
                        
                        Image("vs")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 90, height: 90)
                        
                        VStack (spacing: 10) {
                            Text(peerManager.opponentName) // nome dell'avversario
                                .font(.system(size: 20, design: .default))
                                .bold()
                            peerManager.avatarImage(for: peerManager.opponentAvatarImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        }
                    }

                    Spacer()
                    
                    // Messaggio di attesa con animazione dei puntini
                    Text("In attesa che l'host avvii la partita")
                        .font(.headline)
                        .padding(.top, 20)
                    
                    AnimatedDotsView(isAnimating: $isAnimatingDots)
                        .onAppear {
                            isAnimatingDots = true
                        }
                }
                .padding()
            }
        }
        .navigationDestination(isPresented: $navigateToGame) {
            OneVsOneGameView().environmentObject(peerManager).environmentObject(speechRecognizer)
        }
        .onAppear {
            peerManager.sendUsername(username: username)
            peerManager.sendOpponentAvatarImage(peerManager.myAvatarImage)
            peerManager.joinSession()
        }
        .navigationBarTitle("", displayMode: .inline)
        .onReceive(peerManager.$startGame) { startGame in
            if startGame {
                navigateToGame = true
            }
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


struct RotatingImageView: View {
    @Binding var rotationAngle: Double
    
    var body: some View {
        Image("charging")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .rotationEffect(.degrees(rotationAngle))
    }
}

struct AnimatedDotsView: View {
    @Binding var isAnimating: Bool
    @State private var scales: [CGFloat] = [0.5, 0.5, 0.5]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 10, height: 10)
                    .scaleEffect(scales[index])
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 0.6).repeatForever().delay(Double(index) * 0.2)) {
                            scales[index] = 1
                        }
                    }
            }
        }
    }
}

struct JoinAGameView_Previews: PreviewProvider {
    static var previews: some View {
        let peerManager = MultiPeerManager()
        let speechRecognizer = SpeechRecognizer(peerManager: MultiPeerManager())
        JoinAGameView(username: "Player123")
            .environmentObject(peerManager)
            .environmentObject(speechRecognizer)
    }
}
