import SwiftUI
import AVFAudio

struct JoinAGameView: View {
    let username: String
    @EnvironmentObject private var peerManager: MultiPeerManager // riferimento al peer manager
    @State private var navigateToGame: Bool = false // true se la partita inizia
    @State private var rotationAngle: Double = 0
    @State private var isAnimatingDots: Bool = false // true se non è stato trovato ancora un avversario
    @EnvironmentObject var speechRecognizer: SpeechRecognizer // riferimento allo speech recognizer
    @Environment(\.presentationMode) var presentationMode // freccia per tornare alla ContentView
    private let synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer() // sintetizzatore vocale
    
    var body: some View {
        VStack {
            if peerManager.connectedPeers.isEmpty { // se non ha ancora trovato un avversario
                VStack {
                    RotatingImageView(rotationAngle: $rotationAngle) // mostra un'animazione di ricerca
                        .frame(width: 120, height: 120)
                        .onAppear {
                            startRotating()
                        }
                    Text("Ricerca di una lobby")
                        .font(.system(size: 20, design: .default))
                    AnimatedDotsView(isAnimating: $isAnimatingDots)
                        .onAppear {
                            isAnimatingDots = true
                        }
                }
                .padding()
                .onAppear { // al caricamento della pagina
                    if peerManager.blindMode { // se è abilitata la blind mode
                        speakText("In cerca di una lobby") // fa capire all'utente che sta cercando una lobby
                    }
                }
            } else { // se ha trovato l'avversario
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
                            peerManager.avatarImage(for: peerManager.myAvatarImage) // avatar dell'utente
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 3)
                                        .scaleEffect(1.1)
                                        .padding(3)
                                )
                        }
                        
                        Image("vs")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 90, height: 90)
                        
                        VStack (spacing: 10) {
                            Text(peerManager.opponentName) // nome dell'avversario
                                .font(.system(size: 20, design: .default))
                                .bold()
                            peerManager.avatarImage(for: peerManager.opponentAvatarImage) // avatar dell'avversario
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 3)
                                        .scaleEffect(1.1)
                                        .padding(3)
                                )
                        }
                    }

                    Spacer()
                    
                    // Messaggio di attesa con animazione dei puntini
                    Text("In attesa che l'host avvii la partita")
                        .font(.system(size: 20, design: .default))
                        .padding(.top, 20)
                    
                    AnimatedDotsView(isAnimating: $isAnimatingDots)
                        .onAppear {
                            isAnimatingDots = true
                        }
                }
                .padding()
            }
        }
        .navigationDestination(isPresented: $navigateToGame) { // porta alla OneVsOneGameView se la partita è iniziata
            OneVsOneGameView().environmentObject(peerManager).environmentObject(speechRecognizer)
        }
        .onAppear { // al caricamento della pagina, invia all'avversario il proprio username e il proprio avatar
            peerManager.sendUsername(username: username)
            peerManager.sendOpponentAvatarImage(peerManager.myAvatarImage)
            peerManager.joinSession() // cerca di connettersi ad una lobby
        }
        .navigationBarTitle("", displayMode: .inline)
        .onReceive(peerManager.$startGame) { startGame in
            if startGame {
                navigateToGame = true
            }
        }
        .toolbar { // freccia per tornare alla ContentView
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .navigationBarBackButtonHidden(true) // nasconde la freccia di default della NavigationStack
        .preferredColorScheme(.light) // forza la light mode
    }
    
    private func startRotating() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            withAnimation(Animation.linear(duration: 1)) {
                rotationAngle += 360
            }
        }
    }
    
    public func speakText(_ testo: String) {
        let utterance = AVSpeechUtterance(string: testo)
        utterance.voice = AVSpeechSynthesisVoice(language: "it-IT")
        utterance.pitchMultiplier = 1.0
        utterance.rate = 0.5        
        synthesizer.speak(utterance)
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
