import SwiftUI
import AVFoundation

struct ProfileView: View {
    @Binding var username: String
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var peerManager: MultiPeerManager
    
    @State private var avatarImage: Image
    @State private var showPicker: Bool = false
    @State private var selectedAvatar: String? = UserDefaults.standard.string(forKey: "selectedAvatar")
    @State private var showAlert: Bool = false
    @State private var localUsername: String
    
    let synthesizer = AVSpeechSynthesizer()
    
    init(username: Binding<String>) {
        self._username = username
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
            
            TextField("Inserisci il nickname", text: $localUsername)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .padding(.horizontal, 25)
            
            Button(action: {
                toggleBlindMode()
            }) {
                Text(peerManager.blindMode ? "Blind mode abilitata" : "Blind mode disabilitata")
                    .font(.system(size: 20, design: .default))
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(peerManager.blindMode ? Color.green : Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .padding(.horizontal, 25)
            }
            
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
                    UserDefaults.standard.set(selectedAvatar, forKey: "selectedAvatar")
                    self.selectedAvatar = selectedAvatar
                    peerManager.myAvatarImage = selectedAvatar
                }
                showPicker = false
            }
        }
        .onAppear {
            if let savedAvatar = UserDefaults.standard.string(forKey: "selectedAvatar") {
                avatarImage = Image(savedAvatar)
            }
        }
        .onDisappear {
            UserDefaults.standard.set(localUsername, forKey: "username")
            username = localUsername
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func toggleBlindMode() {
        peerManager.blindMode.toggle()
        let message = peerManager.blindMode ? "Blind mode abilitata" : "Blind mode disabilitata"
        speakText(message)
    }
    
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "it-IT")
        utterance.pitchMultiplier = 1.0
        utterance.rate = 0.5
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
        ProfileView(username: .constant("TestUser"))
            .environmentObject(MultiPeerManager())
    }
}
