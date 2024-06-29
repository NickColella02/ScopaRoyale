import SwiftUI
import AVFoundation

struct SettingsView: View {
    @Binding var username: String
    @State private var newUsername: String = ""
    @State private var showEmptyUsernameAlert = false
    @Environment(\.presentationMode) var presentationMode
    @State private var isMuted = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome back \(username)")
                    .font(.title)
                    .padding()
                VStack {
                    Button(action: {
                        toggleMute()
                    }) {
                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .foregroundStyle(.black)
                            .font(.system(size: 40))
                    }
                }

                TextField("Enter new username", text: $newUsername)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .padding(.horizontal, 35)

                Button(action: {
                    if !newUsername.isEmpty {
                        // Salva il nuovo username in UserDefaults
                        UserDefaults.standard.set(newUsername, forKey: "username")
                        // Aggiorna la variabile username
                        username = newUsername
                        // Chiude il popup
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        showEmptyUsernameAlert = true
                    }
                }) {
                    Text("Done")
                        .font(.system(size: 20, design: .default))
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                }
                .frame(width: 330, height: 60)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 50))
                .padding(.horizontal, 35)
            }
        }
        .alert("Username required", isPresented: $showEmptyUsernameAlert) { // messaggio di errore se non si assegna un nome alla lobby
            VStack {
                Button("OK", role: .cancel) {
                    showEmptyUsernameAlert = false
                }
            }
        } message: {
            Text("You need to enter a username.")
        }
    }
    private func toggleMute() {
        isMuted.toggle()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            if isMuted {
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                try audioSession.setCategory(.playback, options: .mixWithOthers)
                try audioSession.overrideOutputAudioPort(.none)
            } else {
                try audioSession.setCategory(.playback, options: [])
                try audioSession.overrideOutputAudioPort(.speaker)
            }
        } catch {
            print("Failed to set audio session category: \(error.localizedDescription)")
        }
    }
}
