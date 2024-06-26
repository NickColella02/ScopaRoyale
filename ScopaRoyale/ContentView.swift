import SwiftUI

struct ContentView: View {
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var showSelectMode: Bool = false
    @State private var showJoinGame: Bool = false
    @State private var showUsernameEntry: Bool = false
    @State private var showSettings: Bool = false
    @State private var lobbyName: String = ""
    @State private var showLobbyName: Bool = false

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
                    
                    // Navigazione verso la schermata di selezione della modalità di gioco
                    .navigationDestination(isPresented: $showSelectMode) {
                        SelectModeView(username: username, lobbyName: lobbyName)
                    }
                    
                    // Navigazione verso la schermata di ricerca della partita
                    .navigationDestination(isPresented: $showJoinGame) {
                        JoinAGameView(username: username)
                    }
                    
                    // Bottone per avviare una nuova partita
                    Button(action: {
                        showLobbyName = true
                    }) {
                        Text("Create a new lobby")
                            .font(.system(size: 20, design: .default))
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 100))
                            .padding(.horizontal, 35)
                            .padding(.top, 20)
                    }
                    .sheet(isPresented: $showLobbyName) {
                        VStack {
                            TextField("Lobby's name", text: $lobbyName)
                                .padding() // contact's name's input
                            Button(action: { // shows a button to confirm the insertion
                                if !lobbyName.isEmpty {
                                    showLobbyName = false
                                    showSelectMode = true
                                }
                            }) {
                                Text("Submit")
                                    .padding()
                                    .foregroundStyle(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                            }
                        }
                    }
                    
                    // Bottone per unirsi a una partita esistente
                    Button(action: {
                        showJoinGame = true
                    }) {
                        Text("Join a lobby")
                            .font(.system(size: 20, design: .default))
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 100))
                            .padding(.horizontal, 35)
                    }
                    .padding(.bottom, 20)
                }
                Spacer()
            }
            .navigationBarHidden(false) // Mostra la barra di navigazione
            .navigationTitle("")
            .navigationBarItems(trailing: Button(action: {
                showSettings = true
            }) {
                Image(systemName: "ellipsis.circle")
                    .imageScale(.large)
                    .foregroundStyle(.black)
            })
            .onReceive(NotificationCenter.default.publisher(for: .usernameEntered)) { _ in
                self.username = UserDefaults.standard.string(forKey: "username") ?? ""
                self.showUsernameEntry = false
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(username: $username)
            }
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
