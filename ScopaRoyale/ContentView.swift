import SwiftUI

struct ContentView: View {
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var showJoinGame: Bool = false
    @State private var showUsernameEntry: Bool = false
    @State private var lobbyName: String = ""
    @State private var showLobbyForm: Bool = false
    @State private var showSelectMode: Bool = false
    @State private var showLobbyNameAlert: Bool  = false
    
    @ObservedObject private var peerManager: MultiPeerManager = MultiPeerManager() // Osserviamo il MultiPeerManager per rilevare i cambiamenti

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
                if showUsernameEntry { // mostra la schermata di inserimento dell'username se non ancora inserito
                    UsernameEntryView()
                } else {
                    Image("AppLogo") // logo dell'app
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .padding(.bottom, 20)
                                        
                        .navigationDestination(isPresented: $showJoinGame) {
                                            JoinAGameView(username: username)
                                                .onDisappear {
                                                    peerManager.reset() // Chiamiamo il reset del MultiPeerManager quando si torna qui da JoinAGameView
                                                }
                                        }
                    
                    .navigationDestination(isPresented: $showSelectMode) { // navigazione verso la pagina di selezione della modalità di partita
                        SelectModeView(lobbyName: lobbyName)
                    }
                    
                    Button(action: {
                        showLobbyForm = true
                    }) {
                        HStack {
                            Text("Create a new lobby")
                                .font(.system(size: 20, design: .default))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            Image("createANewLobby")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 60)
                                .padding(.horizontal)
                        }
                        .frame(width: 330, height: 60)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                        .padding(.horizontal, 35)
                        .padding(.top, 20)
                    }
                    
                    Button(action: {
                        showJoinGame = true
                        }) {
                            HStack {
                                Text("Join existent lobby")
                                    .font(.system(size: 20, design: .default))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                Image("joinAGame")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .padding(.horizontal)
                            }
                            .frame(width: 330, height: 60)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                        }
                    Button(action: {
                        //showJoinGame = true
                    }) {
                        HStack {
                            Text("How to play")
                                .font(.system(size: 20, design: .default))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            Image("howToPlay")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .padding(.horizontal)
                        }
                        .frame(width: 330, height: 60)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                    }
                .padding(.bottom, 70)
                }
                Spacer()
            }
            .navigationTitle("")
            .toolbar {
                if !showUsernameEntry {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: SettingsView(username: $username)) {
                            Image(systemName: "gear.circle")
                                .foregroundStyle(.gray)
                                .font(.system(size: 25))
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .usernameEntered)) { _ in
                self.username = UserDefaults.standard.string(forKey: "username") ?? ""
                self.showUsernameEntry = false
            }
            .overlay( // visualizzato quando si clicca su create a lobby
                Group {
                    if showLobbyForm {
                        ZStack {
                            Color.black.opacity(0.4)
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    showLobbyForm = false
                                }
                            VStack() {
                                HStack {
                                    Image("lobbyName")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                        .padding(.bottom, 10)
                                    /*Spacer()
                                    Button(action: {
                                        showLobbyForm = false
                                    }) {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 20))
                                            .padding(.horizontal, 35)
                                    }*/
                                }
                                TextField("Enter lobby name", text: $lobbyName)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 100))
                                    .padding(.horizontal, 25)
                                Button(action: {
                                    if !lobbyName.isEmpty {
                                        showSelectMode = true
                                        showLobbyForm = false
                                    }
                                }) {
                                    Text("Create lobby")
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
        .preferredColorScheme(.light) // forza la light mode
        .alert("Lobby's name required", isPresented: $showLobbyNameAlert) { // messaggio di errore se non si assegna un nome alla lobby
            VStack {
                Button("OK", role: .cancel) {
                    showLobbyNameAlert = false
                }
            }
        } message: {
            Text("You need to assign a name to the lobby.")
        }
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
