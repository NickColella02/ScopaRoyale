import SwiftUI

struct ContentView: View {
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var showJoinGame: Bool = false
    @State private var showUsernameEntry: Bool = false
    @State private var lobbyName: String = ""
    @State private var showLobbyForm: Bool = false
    @State private var showSelectMode: Bool = false

    init() {
        // Controlla se è presente un username nell'app
        if username.isEmpty {
            _showUsernameEntry = State(initialValue: true)
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                if showUsernameEntry {
                    // Mostra la schermata di inserimento dello username se necessario
                    UsernameEntryView()
                } else {
                    // Logo dell'applicazione
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .padding(.bottom, 20)
                                        
                    // Navigazione verso la schermata di ricerca della partita
                    .navigationDestination(isPresented: $showJoinGame) {
                        JoinAGameView(username: username)
                    }
                    
                    .navigationDestination(isPresented: $showSelectMode) {
                        SelectModeView(lobbyName: lobbyName)
                    }
                    
                    // Bottone per avviare una nuova partita
                    Button(action: {
                        showLobbyForm = true
                    }) {
                        Text("Create a new lobby")
                            .font(.system(size: 20, design: .default))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.83, green: 0.69, blue: 0.22)) // Oro
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                            .padding(.horizontal, 35)
                            .padding(.top, 20)
                    }
                    
                    // Bottone per unirsi a una partita esistente
                    Button(action: {
                        showJoinGame = true
                    }) {
                        Text("Join a lobby")
                            .font(.system(size: 20, design: .default))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(red: 0.0, green: 0.5, blue: 0.0), Color(red: 0.2, green: 0.8, blue: 0.2)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                            .padding(.horizontal, 35)
                    }
                    .padding(.bottom, 20)
                }
                Spacer()
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView(username: $username)) {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.black)
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .usernameEntered)) { _ in
                self.username = UserDefaults.standard.string(forKey: "username") ?? ""
                self.showUsernameEntry = false
            }
            .overlay(
                Group {
                    if showLobbyForm {
                        ZStack {
                            Color.black.opacity(0.4)
                                .edgesIgnoringSafeArea(.all)
                            VStack(spacing: 20) {
                                HStack {
                                    Text("Enter Lobby Name")
                                        .font(.headline)
                                        .padding()
                                    Spacer()
                                    Button(action: {
                                        showLobbyForm = false
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 24))
                                    }
                                    .padding(.top, 10)
                                    .padding(.trailing, 10)
                                }
                                TextField("Lobby Name", text: $lobbyName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal)
                                Button(action: {
                                    if !lobbyName.isEmpty {
                                        showSelectMode = true
                                        showLobbyForm = false
                                    }
                                }) {
                                    Text("Done")
                                        .font(.system(size: 20, design: .default))
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .padding(.horizontal, 20)
                                }
                            }
                            .frame(width: 300, height: 200)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(radius: 20)
                        }
                    }
                }
            )
        }
        .preferredColorScheme(.light) // Forza la light mode
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}

extension Notification.Name {
    static let usernameEntered = Notification.Name("usernameEntered")
}
