import SwiftUI

struct ContentView: View {
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var showJoinGame: Bool = false
    @State private var showUsernameEntry: Bool = false
    @State private var lobbyName: String = ""
    @State private var showLobbyForm: Bool = false
    @State private var showSelectMode: Bool = false
    @State private var showLobbyNameAlert: Bool  = false

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
                                        
                    .navigationDestination(isPresented: $showJoinGame) { // navigazione verso la pagina di accesso ad una lobby
                        JoinAGameView(username: username)
                    }
                    
                    .navigationDestination(isPresented: $showSelectMode) { // navigazione verso la pagina di selezione della modalità di partita
                        SelectModeView(lobbyName: lobbyName)
                    }
                    
                    Button(action: { // bottone per creare una lobby
                        showLobbyForm = true
                    }) {
                        Text("Create a new lobby")
                            .font(.system(size: 20, design: .default))
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.83, green: 0.69, blue: 0.22)) // Oro
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                            .padding(.horizontal, 35)
                            .padding(.top, 20)
                    }
                    
                    Button(action: { // bottone per unirsi ad una lobby esistente
                        showJoinGame = true
                    }) {
                        Text("Join a lobby")
                            .font(.system(size: 20, design: .default))
                            .foregroundStyle(.white)
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
            .overlay( // visualizzato quando si clicca su create a lobby
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
                                    Button(action: {
                                        showLobbyForm = false
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.gray)
                                            .font(.system(size: 24))
                                    }
                                    .padding(.top, 10)
                                    .padding(.trailing, 10)
                                }
                                TextField("Lobby Name", text: $lobbyName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal)
                                Button(action: {
                                    if !lobbyName.isEmpty { // se l'utente ha assegnato un nome alla lobby
                                        showSelectMode = true
                                        showLobbyForm = false
                                    } else { // se l'utente non ha assegnato un nome alla lobby
                                        showLobbyNameAlert = true
                                    }
                                }) {
                                    Text("Done")
                                        .font(.system(size: 20, design: .default))
                                        .foregroundStyle(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color(red: 0.83, green: 0.69, blue: 0.22))
                                        .clipShape(RoundedRectangle(cornerRadius: 50))
                                        .padding(.horizontal, 35)
                                        .padding(.top, 20)
                                }
                            }
                            .frame(width: 300, height: 400)
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
