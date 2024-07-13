import SwiftUI

struct ShowWinnerView: View {
    @EnvironmentObject private var peerManager: MultiPeerManager
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    @State private var showHomeView: Bool = false
    
    var body: some View {
        if peerManager.gameOver {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                VStack {
                    Image("results")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                    HStack {
                        showWinnerAvatar(username: peerManager.myUsername, avatarImage: peerManager.myAvatarImage, isWinner: peerManager.winner == peerManager.myUsername)
                        
                        Spacer()
                        
                        showWinnerAvatar(username: peerManager.opponentName, avatarImage: peerManager.opponentAvatarImage, isWinner: peerManager.winner == peerManager.opponentName)
                    }
                    .padding()
                    
                    HStack {
                        TotalPointsView(title: "Punti totali", score: peerManager.playerScore, isWinner: peerManager.playerScore > peerManager.opponentScore)
                        Spacer()
                        TotalPointsView(title: "Punti totali", score: peerManager.opponentScore, isWinner: peerManager.opponentScore > peerManager.playerScore)
                    }
                    .padding(.horizontal)
                    
                    ScoreGridView(peerManager: peerManager)
                        .padding(.horizontal)
                    
                    Button(action: {
                        if peerManager.isHost {
                            peerManager.sendEndGameSignal()
                            peerManager.closeConnection()
                        }
                        showHomeView = true
                    }) {
                        Text("Termina Partita")
                            .font(.system(size: 20, design: .default))
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                            .padding(.horizontal, 25)
                    }
                    .padding(.horizontal, 35)
                }
                .onAppear {
                    if peerManager.blindMode {
                        DispatchQueue.main.async {
                            speechRecognizer.speakText("Il vincitore è \(peerManager.winner)")
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showHomeView) {
                ContentView().environmentObject(peerManager)
            }
        }
    }
}

struct showWinnerAvatar: View {
    let username: String
    let avatarImage: String
    let isWinner: Bool
    
    var body: some View {
        VStack {
            ZStack {
                if isWinner {
                    Image("winnerCrown")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                }
                Image(avatarImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 93, height: 93)
                    .clipShape(Circle())
                    .padding(.top, isWinner ? 39 : 0)
            }
            
            Text(username)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.black)
        }
    }
}

struct ScoreGridView: View {
    let peerManager: MultiPeerManager
    
    var body: some View {
        Grid {
            GridRow {
                ScoreParameterCellView(title: "Scope", myScore: "\(peerManager.playerPoints.count)", opponentScore: "\(peerManager.opponentPoints.count)")
            }
            Divider()
            GridRow {
                ScoreParameterCellView(title: "Carte prese", myScore: "\(peerManager.cardTakenByPlayer.count)", opponentScore: "\(peerManager.cardTakenByOpponent.count)")
            }
            Divider()
            GridRow {
                ScoreParameterCellView(title: "Settebello", myScore: peerManager.playerHasSettebello ? "Sì" : "No", opponentScore: peerManager.opponentHasSettebello ? "Sì" : "No")
            }
            Divider()
            GridRow {
                ScoreParameterCellView(title: "Carte oro", myScore: "\(peerManager.playerCoinsCount)", opponentScore: "\(peerManager.opponentCoinsCount)")
            }
            Divider()
            GridRow {
                ScoreParameterCellView(title: "Primera", myScore: peerManager.playerHasPrimera ? "Sì" : "No", opponentScore: peerManager.opponentHasPrimera ? "Sì" : "No")
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 15)
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
}

struct ScoreParameterCellView: View {
    let title: String
    let myScore: String
    let opponentScore: String
    
    var body: some View {
        HStack {
            VStack {
                Text(myScore)
                    .font(.system(size: 20, design: .default))
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    .padding(8)
                    .background((myScore > opponentScore || (myScore == "Sì" && opponentScore == "No")) ? Color.green.opacity(0.8) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            Spacer()
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .frame(width: 120)
            
            Spacer()
            
            VStack {
                Text(opponentScore)
                    .font(.system(size: 20, design: .default))
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    .padding(8)
                    .background((opponentScore > myScore || (opponentScore == "Sì" && myScore == "No")) ? Color.green.opacity(0.8) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

struct TotalPointsView: View {
    let title: String
    let score: Int
    let isWinner: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.black)
            Text("\(score)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .padding(8)
                .background(isWinner ? Color.green.opacity(0.8) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 15)
    }
}

struct ShowWinnerView_Previews: PreviewProvider {
    static var previews: some View {
        let peerManager = MultiPeerManager()
        let speechRecognizer = SpeechRecognizer(peerManager: MultiPeerManager())
        ShowWinnerView()
            .environmentObject(peerManager)
            .environmentObject(speechRecognizer)
            .previewLayout(.sizeThatFits)
    }
}
