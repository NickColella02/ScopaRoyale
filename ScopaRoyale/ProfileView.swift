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
            self._avatarImage = State(initialValue: Image(systemName: "person.circle"))
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                avatarImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: 1)
                            .scaleEffect(1.1)
                            .padding(3)
                    )
            }
            .padding(.bottom, 10)
            
            Text("Change avatar")
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .onTapGesture {
                    showPicker = true
                }
                .padding(.bottom, 50)
            
            VStack {
                Image(systemName: peerManager.blindMode ? "eye.slash.fill" : "eye.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(peerManager.blindMode ? .red : .green)
                    .padding(.bottom, 20)
                
                Button(action: {
                    toggleBlindMode()
                }) {
                    Text(peerManager.blindMode ? "Disable Blind Mode" : "Enable Blind Mode")
                        .font(.title3)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(peerManager.blindMode ? .systemRed : .systemGreen))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 20)
            }
            
            VStack {
                Image("username")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                
                TextField("Enter username", text: $localUsername)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .padding(.horizontal, 25)
                
                if localUsername.count > maxUsernameLength {
                    Text("Username must be \(maxUsernameLength) characters or less.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 25)
                }
                
                Button(action: {
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
                        .padding(.top, 20)
                }
                .disabled(localUsername.isEmpty || localUsername.count > maxUsernameLength)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationBarTitle("Your profile", displayMode: .inline)
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
    }
    
    private func toggleBlindMode() {
        peerManager.blindMode.toggle()
        let message = peerManager.blindMode ? "Blind mode enabled" : "Blind mode disabled"
        speakText(message)
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
            Text("Choose an avatar")
                .font(.title2)
                .padding()
            
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
