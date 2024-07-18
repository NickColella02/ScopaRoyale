import SwiftUI

struct ContentView: View {
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? "" // username del giocatore
    @State private var showJoinGame: Bool = false // true se l'utente sceglie di entrare in una lobby esistente
    @State private var showUsernameEntry: Bool = false
    @State private var createdLobby: Bool = false // true se l'utente ha creato una lobby
    @State private var lobbyName: String = "" // nome della lobby
    @State private var showLobbyForm: Bool = false // true se l'utente sceglie di creare una lobby e visualizza il corrispondente overlay
    @State private var showGameRules: Bool = false // true se l'utente ha aperto le regole del gioco
    @State private var showProfileView: Bool = false // true se l'utente ha aperto le impostazioni
    @EnvironmentObject private var peerManager: MultiPeerManager // riferimento al peer manager
    private var speechRecognizer: SpeechRecognizer { // dichiarazione dello speech recognizer
        SpeechRecognizer(peerManager: peerManager)
    }
    
    init() {
        if username.isEmpty {
            _showUsernameEntry = State(initialValue: true)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                if showUsernameEntry { // se l'utente non ha ancora inserito l'username
                    UsernameEntryView().environmentObject(peerManager).environmentObject(speechRecognizer) // mostra la relativa view
                } else { // altrimenti resta sulla ContentView
                    content
                }
                Spacer()
            }
            .navigationTitle("")
            .toolbar { // pulsante per le impostazioni
                if !showUsernameEntry {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            showProfileView = true
                        }) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 20, weight: .regular))
                                .padding(.horizontal, 12)
                                .foregroundStyle(.black)
                        }
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .usernameEntered)) { _ in
                self.username = UserDefaults.standard.string(forKey: "username") ?? ""
                self.showUsernameEntry = false
            }
        }
        .preferredColorScheme(.light) // forza la light mode
        .overlay(lobbyFormOverlay) // overlay per la creazione della lobby
        .overlay(gameRulesOverlay) // overlay per la visualizzazione delle regole
        .overlay(profileOverlay) // overlay per le impostazioni
        .onTapGesture { // chiude la tastiera quando si preme sullo schermo
            hideKeyboard()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        VStack {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 180)
                .padding(.bottom, 20)
                .navigationDestination(isPresented: $showJoinGame) { // va alla JoinAGameView se l'utente entra in una lobby esistente
                    JoinAGameView(username: username).environmentObject(peerManager).environmentObject(speechRecognizer)
                }
                .navigationDestination(isPresented: $createdLobby) { // va alla OneVsOneView se l'utente ha creato una lobby
                    OneVsOneView(lobbyName: self.lobbyName).environmentObject(peerManager).environmentObject(speechRecognizer)
                }
            CreateNewLobby(showLobbyForm: $showLobbyForm) // mostra l'overlay per l'inserimento del nome della lobby
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            JoinExistentLobby(showJoinGame: $showJoinGame)
            HowToPlay(showGameRules: $showGameRules)
        }
    }
    
    @ViewBuilder
    private var lobbyFormOverlay: some View {
        if showLobbyForm {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        showLobbyForm = false
                    }
                VStack {
                    Image("lobbyName")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                    TextField("Inserisci il nome della lobby", text: $lobbyName)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                        .padding(.horizontal, 25)
                    Button(action: { // bottone per confermare il nome della lobby e crearla
                        if !lobbyName.isEmpty {
                            createdLobby = true
                            showLobbyForm = false
                            peerManager.closeConnection() // chiude la connessione
                        }
                    }) {
                        Text("Crea lobby")
                            .font(.system(size: 20, design: .default))
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(lobbyName.isEmpty ? Color.gray : Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                            .padding(.horizontal, 25)
                    }
                    .disabled(lobbyName.isEmpty) // disabilita il tasto se l'utente non ha inserito un username
                }
                .frame(width: 370)
                .padding(.top, 20)
                .padding(.bottom, 20)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 20)
            }
        }
    }
    
    @ViewBuilder
    private var gameRulesOverlay: some View {
        if showGameRules {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        showGameRules = false
                    }
                VStack {
                    Image("rules")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                    ScrollView {
                        Text("""
                        Scopa è un tradizionale gioco di carte italiano:
                        **1. Obiettivo**: totalizzare più punti del tuo avversario.
                        **2. Svolgimento del gioco**: si gioca con un mazzo di carte napoletane da 40 carte. A ciascun giocatore vengono distribuite tre carte, e quattro carte vengono messe scoperte sul tavolo. Al tuo turno, devi lanciare una carta dalla tua mano. Se ci sono carte di ugual valore o carte la cui somma corrisponde al valore della carta lanciata, le prendi e le aggiungi al tuo mazzo delle prese. Se prendi le ultime carte presenti sul tavolo hai fatto scopa. Se non puoi prendere alcuna carta, la carta lanciata resta sul tavolo.
                        **3. Punteggio**:
                        - 1 punto per il maggior numero di carte prese.
                        - 1 punto per il maggior numero di carte di denari prese.
                        - 1 punto per il 7 di denari (settebello).
                        - 1 punto per il maggior numero di 7 (primera).
                        - 1 punto per ogni scopa fatta
                        **4. Vittoria**: il gioco continua fino a quando tutte le carte sono state giocate. Il giocatore con il maggior numero di punti alla fine vince.
                        """)
                        .font(.body)
                        .padding(.horizontal, 20)
                    }
                    Spacer()
                    Button(action: { // bottone per chiudere l'overlay delle regole
                        showGameRules = false
                    }) {
                        Text("Chiudi")
                            .font(.system(size: 20, design: .default))
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                            .padding(.horizontal, 25)
                            .padding(.top, 10)
                    }
                }
                .frame(width: 370)
                .padding(.top, 20)
                .padding(.bottom, 20)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 20)
            }
        }
    }

    @ViewBuilder
    private var profileOverlay: some View {
        if showProfileView {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea(.all)
                VStack {
                    ProfileView(username: $username, showProfileView: $showProfileView)
                }
                .frame(width: 370)
                .padding(.top, 20)
                .padding(.bottom, 20)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 20)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MultiPeerManager())
            .environmentObject(SpeechRecognizer(peerManager: MultiPeerManager()))
    }
}

extension Notification.Name {
    static let usernameEntered = Notification.Name("usernameEntered")
}

struct CreateNewLobby: View {
    @Binding var showLobbyForm: Bool
    
    var body: some View {
        Button(action: {
            showLobbyForm = true
        }) {
            HStack {
                Text("Crea una lobby")
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
    }
}

struct JoinExistentLobby: View {
    @Binding var showJoinGame: Bool
    
    var body: some View {
        Button(action: {
            showJoinGame = true
        }) {
            HStack {
                Text("Entra in una lobby")
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
    }
}

struct HowToPlay: View {
    @Binding var showGameRules: Bool
    
    var body: some View {
        Button(action: {
            showGameRules = true
        }) {
            HStack {
                Text("Come si gioca")
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
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
