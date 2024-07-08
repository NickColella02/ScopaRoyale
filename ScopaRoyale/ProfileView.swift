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
    
    let maxUsernameLength = 14
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
            /*Image("yourProfile")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .padding(.top, 20)*/
            Spacer()
            
            ZStack {
                avatarImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color(red: 254 / 255, green: 189 / 255, blue: 2 / 255), lineWidth: 3)
                            .scaleEffect(1.1)
                            .padding(3)
                    )
                    .onTapGesture {
                        showPicker = true
                    }
            }
            .padding(.bottom, 10)
            
            VStack {
                Text("Welcome back, \(username)")
                    .font(.system(size: 20, design: .default))
                    .foregroundColor(.black)
                    .bold()
                    .padding(.bottom, 10)
                
                if localUsername.count > maxUsernameLength {
                    Text("Username must be \(maxUsernameLength) characters or less.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 25)
                }
                TextField("Enter username", text: $localUsername)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .padding(.horizontal, 25)
                
                /*Button(action: {
                    if localUsername.isEmpty {
                        showAlert = true
                    } else {
                        username = localUsername
                        UserDefaults.standard.set(localUsername, forKey: "username")
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Done")
                        .font(.system(size: 20, design: .default))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(localUsername.isEmpty || localUsername.count > maxUsernameLength ? Color.gray : Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                        .padding(.horizontal, 25)
                }
                .disabled(localUsername.isEmpty || localUsername.count > maxUsernameLength)*/
                
                Button(action: {
                    toggleBlindMode()
                }) {
                    Text(peerManager.blindMode ? "Disable Blind Mode" : "Enable Blind Mode")
                        .font(.system(size: 20, design: .default))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(!peerManager.blindMode ? .black : Color(red: 254 / 255, green: 189 / 255, blue: 2 / 255)))
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                        .padding(.horizontal, 25)
                }
            }
            .padding(.horizontal)
            Text("La Blind mode fornisce, ai giocatori non udenti, un ​​supporto vocale che esegue l'azione richiesta (si consigliano le cuffie).")
                .font(.system(size: 14, design: .default))
                .foregroundStyle(.gray)
                .padding(.horizontal, 45)
                .padding(.top, 10)
            
            Spacer()
        }
        .navigationBarTitle("", displayMode: .inline) // lasciare così
        .toolbar {
            Text("Fine")
                .bold()
                .foregroundColor(.blue)
                .onTapGesture {
                    if localUsername.isEmpty {
                        showAlert = true
                    } else {
                        username = localUsername
                        UserDefaults.standard.set(localUsername, forKey: "username")
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        }
        .sheet(isPresented: $showPicker) {
            AvatarPickerView(selectedAvatar: $selectedAvatar, avatarImage: $avatarImage) {
                if let selectedAvatar = selectedAvatar {
                    UserDefaults.standard.set(selectedAvatar, forKey: "selectedAvatar")
                    self.selectedAvatar = selectedAvatar
                }
                showPicker = false
            }
        }
        .onAppear {
            if let savedAvatar = UserDefaults.standard.string(forKey: "selectedAvatar") {
                avatarImage = Image(savedAvatar)
            }
        }
        /*.navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .bold()
                .foregroundColor(.black)
        })*/
    }
    
    private func toggleBlindMode() {
        peerManager.blindMode.toggle()
        let message = peerManager.blindMode ? "Blind mode enabled" : "Blind mode disabled"
        DispatchQueue.main.async {
            speakText(message)
        }
    }
    
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.pitchMultiplier = 1.0
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
}


struct AvatarPickerView: View {
    @Binding var selectedAvatar: String?
    @Binding var avatarImage: Image
    var onSelection: () -> Void
    
    let avatarOptions = ["assobastoni", "assocoppe", "assodenari", "assospade", "duebastoni", "duecoppe", "duedenari", "duespade", "trebastoni", "trecoppe", "tredenari", "trespade", "quattrobastoni", "quattrocoppe", "quattrodenari", "quattrospade", "cinquebastoni", "cinquecoppe", "cinquedenari", "cinquespade", "seibastoni", "seicoppe", "seidenari", "seispade", "settebastoni", "settecoppe", "settedenari", "settespade", "ottobastoni", "ottocoppe", "ottodenari", "ottospade", "novebastoni", "novecoppe", "novedenari", "novespade", "diecibastoni", "diecicoppe", "diecidenari", "diecispade"]
    
    var body: some View {
        VStack {
            Image("chooseAnAvatar")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .padding(.top, 20)
            
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
            
            Spacer()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(username: .constant("TestUser"))
            .environmentObject(MultiPeerManager())
    }
}
