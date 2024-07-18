import SwiftUI

struct UsernameEntryView: View {
    @State private var username: String = "" // username del giocatore
    @State private var showTitle: Bool = false
    @State private var showDescription: Bool = false
    @State private var showUsernameField: Bool = false // campo di testo per l'inserimento dell'username
    @EnvironmentObject private var speechRecognizer: SpeechRecognizer // riferimento allo speech recognizer
    @EnvironmentObject var peerManager: MultiPeerManager
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(height: showTitle ? 180 : 0)
                .opacity(showTitle ? 1 : 0)
                .padding(.bottom, 50)
            
            UsernameFormView(username: $username, showUsernameField: $showUsernameField)
                .environmentObject(peerManager)
            .opacity(showUsernameField ? 1 : 0)
            .padding(.bottom, showUsernameField ? 0 : -100)
            
            Spacer()
        }
        .onAppear {
            // Animazione del titolo
            withAnimation(.easeInOut(duration: 1.0)) {
                showTitle = true
            }
            
            // Animazione della descrizione dopo un ritardo
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    showDescription = true
                }
            }
            
            // Animazione del campo username dopo un ulteriore ritardo
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    showUsernameField = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { //
                speechRecognizer.speakText("Desideri abilitare la modalità per non vedenti?")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    speechRecognizer.startTranscribing()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        speechRecognizer.stopTranscribing()
                    }
                }
            }
        }
        .background(Color.white.ignoresSafeArea(.all))
        .preferredColorScheme(.light)
    }
}

struct UsernameFormView: View {
    @Binding var username: String
    @Binding var showUsernameField: Bool
    @EnvironmentObject private var peerManager: MultiPeerManager
        
    var body: some View {
        VStack {
            TextField("Inserisci il tuo username", text: $username)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .padding(.horizontal, 25)
                .opacity(username.isEmpty ? 0.5 : 1.0)
            Button(action: {
                UserDefaults.standard.set(username, forKey: "username")
                NotificationCenter.default.post(name: .usernameEntered, object: nil)
            }) {
                Text("Fine")
                    .font(.system(size: 20, design: .default))
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(username.isEmpty ? Color.gray : Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .padding(.horizontal, 25)
                    .opacity(username.isEmpty ? 0.5 : 1.0)
            }
            .disabled(username.isEmpty)
            .onChange(of: peerManager.blindMode) {
                if peerManager.blindMode {
                    UserDefaults.standard.set("BlindUser", forKey: "username")
                    NotificationCenter.default.post(name: .usernameEntered, object: nil)
                }
            }
            Text("Puoi modificare il tuo username nelle impostazioni del profilo")
                .font(.system(size: 14, design: .default))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 35)
                .padding(.top, 10)
                .opacity(showUsernameField ? 1 : 0)
        }
    }
}

struct UsernameEntryView_Previews: PreviewProvider {
    static var previews: some View {
        UsernameEntryView()
    }
}
