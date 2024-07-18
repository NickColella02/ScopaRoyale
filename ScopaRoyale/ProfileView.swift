import SwiftUI
import AVFoundation

struct ProfileView: View {
    @Binding var username: String // username inserito dall'utente
    @Binding var showProfileView: Bool
    @EnvironmentObject private var peerManager: MultiPeerManager // riferimento al peer manager
    @State private var avatarImage: Image // avatar dell'utente
    @State private var showPicker: Bool = false // true se l'utente clicca sull'avatar per cambiarlo
    @State private var selectedAvatar: String? = UserDefaults.standard.string(forKey: "selectedAvatar") // avatar selezionato dall'utente nel picker
    @State private var localUsername: String // username memorizzato dell'utente
    let synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer() // sintetizzatore vocale
    
    init(username: Binding<String>, showProfileView: Binding<Bool>) { // costruttore: prende username e avatar del giocatore dalla UserDefault
        self._username = username
        self._showProfileView = showProfileView
        self._localUsername = State(initialValue: username.wrappedValue)
        if let selectedAvatar = UserDefaults.standard.string(forKey: "selectedAvatar") {
            self._avatarImage = State(initialValue: Image(selectedAvatar))
        } else {
            self._avatarImage = State(initialValue: Image("defaultUser").resizable())
        }
    }
    
    var body: some View {
        VStack {
            Image("yourProfile")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
            avatarImage
                .resizable()
                .scaledToFit()
                .frame(width: 110, height: 110)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 3)
                        .scaleEffect(1.1)
                        .padding(3)
                )
                .onTapGesture {
                    showPicker = true
                }
                .padding(.bottom, 20)
            TextField("Inserisci il tuo username", text: $localUsername)
                .padding()
                .frame(maxWidth: 300)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .padding(.horizontal, 25)
            // Pulsante "Save"
            Button(action: {
                saveProfile()
            }) {
                Text("Save")
                    .font(.system(size: 18, design: .default))
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: 300)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .padding(.horizontal, 25)
                    .padding(.bottom, 25)
            }
            // Toggle per abilitare/disabilitare la blind mode
            HStack {
                Text("Blind Mode")
                    .font(.system(size: 20, design: .default))
                
                Toggle(isOn: $peerManager.blindMode, label: {
                    EmptyView()
                })
                .toggleStyle(SwitchToggleStyle())
                .onChange(of: peerManager.blindMode) {
                    toggleBlindMode()
                }
                .padding(.vertical, 10)
            }
            .padding(.horizontal, 55)

            Text("La Blind mode fornisce, ai giocatori non vedenti, un supporto vocale che esegue l'azione richiesta (si consigliano le cuffie).")
                    .font(.system(size: 14, design: .default))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 35)
                    .padding(.top, 10)
            }
        .navigationBarTitle("", displayMode: .inline)
        .sheet(isPresented: $showPicker) {
            AvatarPickerView(selectedAvatar: $selectedAvatar, avatarImage: $avatarImage) {
                if let selectedAvatar = selectedAvatar {
                    self.selectedAvatar = selectedAvatar
                    self.avatarImage = Image(selectedAvatar)
                }
                showPicker = false
            }
        }
        .onAppear {
            if let savedAvatar = UserDefaults.standard.string(forKey: "selectedAvatar") {
                avatarImage = Image(savedAvatar)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func saveProfile() {
        UserDefaults.standard.set(localUsername, forKey: "username")
        username = localUsername
        if let selectedAvatar = selectedAvatar {
            UserDefaults.standard.set(selectedAvatar, forKey: "selectedAvatar")
            peerManager.myAvatarImage = selectedAvatar
        }
        showProfileView = false // Chiude l'overlay
        NotificationCenter.default.post(name: .usernameEntered, object: nil) // Notifica il cambio di username
    }
    
    private func toggleBlindMode() {
        let message = peerManager.blindMode ? "Blind mode abilitata" : "Blind mode disabilitata"
        speakText(message)
    }
    
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "it-IT")
        utterance.pitchMultiplier = 1.0
        utterance.rate = 0.5
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Errore nella configurazione dell'AVAudioSession: \(error.localizedDescription)")
        }
        synthesizer.speak(utterance)
    }
}

struct AvatarPickerView: View {
    @Binding var selectedAvatar: String?
    @Binding var avatarImage: Image
    var onSelection: () -> Void
    
    let avatarOptions = ["assobastoni", "assocoppe", "assodenari", "assospade", "duebastoni", "duecoppe", "duedenari", "duespade", "trebastoni", "trecoppe", "tredenari", "trespade", "quattrobastoni", "quattrocoppe", "quattrodenari", "quattrospade", "cinquebastoni", "cinquecoppe", "cinquedenari", "cinquespade", "seibastoni", "seicoppe", "seidenari", "seispade", "settebastoni", "settecoppe", "settedenari", "settespade", "ottobastoni", "ottocoppe", "ottodenari", "ottospade", "novebastoni", "novecoppe", "novedenari", "novespade", "rebastoni", "recoppe", "redenari", "respade"]
    
    var body: some View {
        VStack {
            Image("chooseAnAvatar")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                    ForEach(avatarOptions, id: \.self) { avatar in
                        Button(action: {
                            selectedAvatar = avatar
                            avatarImage = Image(avatar)
                            onSelection()
                        }) {
                            Image(avatar)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        }
                        .padding(5)
                    }
                }
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(username: .constant("TestUser"), showProfileView: .constant(true))
            .environmentObject(MultiPeerManager())
    }
}
