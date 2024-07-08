import SwiftUI

struct ContentView: View {
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var showJoinGame: Bool = false
    @State private var showUsernameEntry: Bool = false
    @State private var createLobby: Bool = false
    @State private var lobbyName: String = ""
    @State private var showLobbyForm: Bool = false
    @State private var showGameRules: Bool = false
    @State private var showSettings: Bool = false
    @State private var newUsername: String = ""
    @State private var showEmptyUsernameAlert = false
    @State private var showChangeUsernameForm = false
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var peerManager: MultiPeerManager
    private var speechRecognizer: SpeechRecognizer {
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
                if showUsernameEntry {
                    UsernameEntryView()
                } else {
                    content
                }
                Spacer()
            }
            .navigationTitle("")
            .toolbar {
                if !showUsernameEntry {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: ProfileView(username: $username).environmentObject(peerManager)) {
                            Image(systemName: "person.crop.circle")
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
        .preferredColorScheme(.light)
        .overlay(lobbyFormOverlay)
        .overlay(gameRulesOverlay)
    }
    
    @ViewBuilder
    private var content: some View {
        VStack {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 180)
                .padding(.bottom, 20)
                .navigationDestination(isPresented: $showJoinGame) {
                    JoinAGameView(username: username).environmentObject(peerManager).environmentObject(speechRecognizer)
                }
                .navigationDestination(isPresented: $createLobby) {
                    OneVsOneView(lobbyName: self.lobbyName).environmentObject(peerManager).environmentObject(speechRecognizer)
                }
            
            CreateNewLobby(showLobbyForm: $showLobbyForm)
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
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showLobbyForm = false
                    }
                VStack {
                    HStack {
                        Image("lobbyName")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .padding(.top, 20)
                    }
                    TextField("Inserisci il nome della lobby", text: $lobbyName)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                        .padding(.horizontal, 25)
                    Button(action: {
                        if !lobbyName.isEmpty {
                            createLobby = true
                            showLobbyForm = false
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
                            .padding(.bottom, 20)
                    }
                    .disabled(lobbyName.isEmpty)
                }
                .frame(width: 370, height: 215)
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
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showGameRules = false
                    }
                VStack {
                    Image("rules")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .padding(.top, 20)
                    Text("""
                        Scopa è un tradizionale gioco di carte italiano:
                        **1. Obiettivo**: l'obiettivo è catturare le carte sul tavolo abbinandole con una carta nella tua mano che ha lo stesso valore o sommando fino a 15.
                        **2. Svolgimento del gioco**: il gioco si gioca solitamente con un mazzo di carte italiane da 40 carte. A ciascun giocatore vengono distribuite tre carte, e quattro carte vengono messe scoperte sul tavolo. Al tuo turno, puoi catturare le carte dal tavolo che sommano al valore di una carta nella tua mano. Se non puoi catturare alcuna carta, devi mettere una carta dalla tua mano sul tavolo.
                        **3. Punteggio**: ogni carta catturata vale 1 punto, punti aggiuntivi possono essere guadagnati per:
                        - Il maggior numero di carte.
                        - Il maggior numero di carte di 'denari'.
                        - Il 7 di denari (Settebello).
                        - Il maggior numero di carte 'prime' (7, 6, assi, ecc.).
                        **4. Vittoria**: il gioco continua fino a quando tutte le carte sono state giocate. Il giocatore con il maggior numero di punti alla fine vince.
                        """)
                        .font(.body)
                        .padding(.horizontal, 20)
                    Button(action: {
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
                    }
                    .frame(width: 330, height: 60)
                    .padding(.bottom, 20)
                }
                .frame(width: 370, height: 700)
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
