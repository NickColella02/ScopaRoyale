import SwiftUI
import AVFoundation
import MediaPlayer

struct SettingsView: View {
    @Binding var username: String
    @State private var newUsername: String = ""
    @State private var showEmptyUsernameAlert = false
    @State private var showChangeUsernameForm = false
    @Environment(\.presentationMode) var presentationMode
    @State private var volumeLevel: Float = AVAudioSession.sharedInstance().outputVolume * 100

    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    showChangeUsernameForm = true
                }) {
                    HStack {
                        Text("Change username")
                            .font(.system(size: 20, design: .default))
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                        Image(systemName: "pencil")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 330, height: 60)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .padding(.horizontal, 35)
                    .padding(.top, 20)
                }

                VStack {
                    HStack {
                        Image(systemName: volumeLevel > 0 ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .foregroundStyle(.black)
                            .font(.system(size: 40))
                        Slider(value: $volumeLevel, in: 0...100, step: 1, onEditingChanged: { _ in
                            setVolume(level: volumeLevel)
                        })
                        .padding(.horizontal, 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(size: 24, weight: .bold))
                }
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
        .overlay(
            Group {
                if showChangeUsernameForm {
                    ZStack {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                showChangeUsernameForm = false
                            }
                        VStack {
                            HStack {
                                Image("username")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .padding(.bottom, 10)
                            }
                            TextField("Enter new username", text: $newUsername)
                                .onAppear {
                                    self.newUsername = self.username
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 100))
                                .padding(.horizontal, 25)
                            Button(action: {
                                if !newUsername.isEmpty {
                                    // Salva il nuovo username in UserDefaults
                                    UserDefaults.standard.set(newUsername, forKey: "username")
                                    // Aggiorna la variabile username
                                    username = newUsername
                                    // Chiude il popup
                                    showChangeUsernameForm = false
                                } else {
                                    showEmptyUsernameAlert = true
                                }
                            }) {
                                Text("Done")
                                    .font(.system(size: 20, design: .default))
                                    .foregroundStyle(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(.black)
                                    .clipShape(RoundedRectangle(cornerRadius: 50))
                                    .padding(.horizontal, 25)
                            }
                        }
                        .frame(width: 370, height: 250)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 20)
                    }
                }
            }
        )
    }

    private func setVolume(level: Float) {
        let volume = level / 100
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            let volumeView = MPVolumeView(frame: .zero)
            if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
                slider.value = volume
            }
        } catch {
            print("Failed to set volume: \(error.localizedDescription)")
        }
    }
}
