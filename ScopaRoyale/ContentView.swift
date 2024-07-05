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
    @EnvironmentObject private var speechRecognized: SwiftUISpeech
    
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
                        NavigationLink(destination: ProfileView(username: $username).environmentObject(peerManager).environmentObject(speechRecognized)) {
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
                    JoinAGameView(username: username).environmentObject(peerManager).environmentObject(speechRecognized)
                }
                .navigationDestination(isPresented: $createLobby) {
                    OneVsOneView(lobbyName: self.lobbyName).environmentObject(peerManager).environmentObject(speechRecognized)
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
                    TextField("Enter lobby name", text: $lobbyName)
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
                        Text("Create lobby")
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
                        Scopa is a traditional Italian card game:
                        **1. Goal**: the goal is to capture cards on the table by matching them with a card in your hand that has the same value or by adding up to 15.
                        **2. Gameplay**: the game is usually played with a 40-card Italian deck. Each player is dealt three cards, and four cards are placed face-up on the table. On your turn, you can capture cards from the table that add up to the value of one card in your hand. If you cannot capture any cards, you must place one card from your hand on the table.
                        **3. Scoring**: each captured card is worth 1 point, additional points can be earned for:
                        - The most cards.
                        - The most 'coins' (denari) cards.
                        - The 7 of coins (Settebello).
                        - The most 'prime' cards (7s, 6s, aces, etc.).
                        **4. Winning**: The game continues until all cards are played. The player with the most points at the end wins.
                        """)
                        .font(.body)
                        .padding(.horizontal, 20)
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
            .environmentObject(SwiftUISpeech())
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
    }
}

struct JoinExistentLobby: View {
    @Binding var showJoinGame: Bool
    
    var body: some View {
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
    }
}

struct HowToPlay: View {
    @Binding var showGameRules: Bool
    
    var body: some View {
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
}
