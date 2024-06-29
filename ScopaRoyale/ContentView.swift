import SwiftUI

struct ContentView: View {
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var showJoinGame: Bool = false
    @State private var showUsernameEntry: Bool = false
    @State private var lobbyName: String = ""
    @State private var showLobbyForm: Bool = false
    @State private var showSelectMode: Bool = false
    @State private var showLobbyNameAlert: Bool  = false
    @State private var showGameRules: Bool = false
    
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
                                .foregroundStyle(.white)
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
                                    .foregroundStyle(.white)
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
                        showGameRules = true
                    }) {
                        HStack {
                            Text("How to play")
                                .font(.system(size: 20, design: .default))
                                .foregroundStyle(.white)
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
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(.black)
                                .font(.system(size: 20))
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
                                    }else{
                                        showLobbyNameAlert = true
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
            .overlay( // Overlay for game rules
                Group {
                    if showGameRules {
                        ZStack {
                            Color.black.opacity(0.4)
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    showGameRules = false
                                }
                            VStack(spacing: 20) {
                                Text("Scopa Rules")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(.top, 20)
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Scopa is a traditional Italian card game. Here are the basic rules:")
                                            .font(.headline)
                                        Text("""
                                        1. **Objective**: The goal is to capture cards on the table by matching them with a card in your hand that has the same value or by adding up to 15.
                                        2. **Gameplay**:
                                           - The game is usually played with a 40-card Italian deck.
                                           - Each player is dealt three cards, and four cards are placed face-up on the table.
                                           - On your turn, you can capture cards from the table that add up to the value of one card in your hand.
                                           - If you cannot capture any cards, you must place one card from your hand on the table.
                                        3. **Scoring**:
                                           - Each captured card is worth 1 point.
                                           - Additional points can be earned for:
                                             - The most cards.
                                             - The most 'coins' (denari) cards.
                                             - The 7 of coins (Settebello).
                                             - The most 'prime' cards (7s, 6s, aces, etc.).
                                        4. **Winning**: The game continues until all cards are played. The player with the most points at the end wins.
                                        """)
                                        .font(.body)
                                    }
                                    .padding()
                                }
                                Button(action: {
                                    showGameRules = false
                                }) {
                                    Text("Close")
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
                            .frame(width: 370, height: 400)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
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
