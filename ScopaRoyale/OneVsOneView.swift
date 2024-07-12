import SwiftUI

struct OneVsOneView: View {
    @EnvironmentObject private var peerManager: MultiPeerManager
    private let numberOfPlayer: Int = 2
    let lobbyName: String
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var navigateToGame = false
    @State private var isAnimatingDots = false
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Lobby: \(lobbyName)")
                .font(.title)
                .padding()
                .bold()
            
            Spacer()
            
            HStack(spacing: 10) {
                VStack(spacing: 10) {
                    Text(username)
                        .font(.title2)
                        .bold()
                    
                    peerManager.avatarImage(for: peerManager.myAvatarImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                }
                
                Image("vs")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 90, height: 90)
                
                if !peerManager.opponentName.isEmpty {
                    VStack(spacing: 10) {
                        Text(peerManager.opponentName)
                            .font(.title2)
                            .bold()
                        
                        peerManager.avatarImage(for: peerManager.opponentAvatarImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                    }
                }
                
                if peerManager.connectedPeers.isEmpty {
                    VStack {
                        Text("In attesa di un avversario...")
                            .font(.headline)
                        
                        AnimatedDotsView(isAnimating: $isAnimatingDots)
                            .onAppear {
                                isAnimatingDots = true
                            }
                    }
                    .padding()
                }
            }
            
            Spacer()
            
            Button(action: {
                if !peerManager.connectedPeers.isEmpty {
                    peerManager.sendStartGameSignal()
                    navigateToGame = true
                }
            }) {
                Text("Gioca")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(peerManager.connectedPeers.isEmpty ? Color.gray : Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .padding(.horizontal, 35)
            }
            .padding(.bottom, 20)
        }
        .navigationDestination(isPresented: $navigateToGame) {
            OneVsOneGameView().environmentObject(peerManager).environmentObject(speechRecognizer)
        }
        .onChange(of: peerManager.peerDisconnected) {
            if peerManager.peerDisconnected {
                peerManager.reset()
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            peerManager.startHosting(lobbyName: self.lobbyName, numberOfPlayers: self.numberOfPlayer, username: username)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("")
    }
}

struct OneVsOneView_Previews: PreviewProvider {
    static var previews: some View {
        let peerManager = MultiPeerManager()
        let speechRecognizer = SpeechRecognizer(peerManager: MultiPeerManager())
        OneVsOneView(lobbyName: "Sample Lobby")
            .environmentObject(peerManager)
            .environmentObject(speechRecognizer)
    }
}

