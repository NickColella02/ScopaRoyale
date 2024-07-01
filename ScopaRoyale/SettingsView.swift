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
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        NavigationStack {
            VStack {
                
                Spacer()
                
                Button(action: {
                    showChangeUsernameForm = true
                }) {
                    HStack {
                        Text("Welcome back \(username)")
                            .font(.system(size: 30, design: .default))
                            .foregroundStyle(.black)
                        Image(systemName: "pencil")
                            .font(.system(size: 30))
                            .foregroundStyle(.black)
                    }
                    .padding(.horizontal, 35)
                    .padding(.top, 20)
                }

                VStack {
                    HStack {
                        Image(systemName: volumeLevel > 0 ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .foregroundStyle(.white)
                            .font(.system(size: 25))
                            .padding(.horizontal, 20)
                        Slider(value: $volumeLevel, in: 0...100, step: 1, onEditingChanged: { _ in
                            setVolume(level: volumeLevel)
                        })
                        .padding(.horizontal, 20)
                    }
                    .frame(width: 330, height: 60)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .padding(.horizontal, 35)
                }
                
                Spacer()
            }
        }
        .alert("Username required", isPresented: $showEmptyUsernameAlert) {
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
                                    .padding(.top, 20)
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
                                    UserDefaults.standard.set(newUsername, forKey: "username")
                                    username = newUsername
                                    UserDefaults.standard.set(newUsername, forKey: "username")
                                    username = newUsername
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
                            .padding(.bottom, 20)
                        }
                        .frame(width: 370)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 20)
                    }
                }
            }
        )
        .onAppear {
            playBackgroundMusic()
        }
    }

    private func setVolume(level: Float) {
        let volume = level / 100
        audioPlayer?.volume = volume
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

    private func playBackgroundMusic() {
        if let path = Bundle.main.path(forResource: "sound", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1 // loop indefinitely
                audioPlayer?.play()
                setVolume(level: volumeLevel) // set the initial volume
            } catch {
                print("Error loading background music: \(error.localizedDescription)")
            }
        }
    }
}
