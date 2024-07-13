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
                    HStack {
                        showWinnerAvatar(username: peerManager.winner, avatarImage: peerManager.myAvatarImage)
                    }
                    .padding()
                    
                    HStack {
                        TotalPointsView(title: "I tuoi punti", score: peerManager.playerScore, isWinner: peerManager.playerScore > peerManager.opponentScore)
                        Spacer()
                        TotalPointsView(title: "I punti di \(peerManager.opponentName)", score: peerManager.opponentScore, isWinner: peerManager.opponentScore > peerManager.playerScore)
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
                            .background(Color .black)
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                            .padding(.horizontal, 25)
                    }
                    .frame(width: 330, height: 60)
                    .padding(.horizontal, 35)
                }
                .padding()
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
    
    var body: some View {
        VStack {
            ZStack {
                Image("winnerCrown")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 95, height: 95)
                    .clipShape(Circle())
                Image(avatarImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 63, height: 63)
                    .clipShape(Circle())
                    .padding(.top, 26)
            }
            
            Text(username)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.black)
        }
        .padding()
    }
}

struct ScoreGridView: View {
    let peerManager: MultiPeerManager
    
    var body: some View {
        Grid {
            GridRow {
                ScoreParameterCellView(title: "Scope", myScore: peerManager.playerPoints.count, opponentScore: peerManager.opponentPoints.count)
            }
            Divider()
            GridRow {
                ScoreParameterCellView(title: "Carte prese", myScore: peerManager.cardTakenByPlayer.count, opponentScore: peerManager.cardTakenByOpponent.count)
            }
            Divider()
            GridRow {
                ScoreParameterCellView(title: "Settebello", myScore: peerManager.playerHasSettebello ? 1 : 0, opponentScore: peerManager.opponentHasSettebello ? 1 : 0)
            }
            Divider()
            GridRow {
                ScoreParameterCellView(title: "Carte oro", myScore: peerManager.playerCoinsCount, opponentScore: peerManager.opponentCoinsCount)
            }
            Divider()
            GridRow {
                ScoreParameterCellView(title: "Primera", myScore: peerManager.playerHasPrimera ? 1 : 0, opponentScore: peerManager.opponentHasPrimera ? 1 : 0)
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
    let myScore: Int
    let opponentScore: Int
    
    var body: some View {
        HStack {
            VStack {
                Text("\(myScore)")
                    .font(.system(size: 20, design: .default))
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    //.padding()
                    //.background(myScore > opponentScore ? Color.green : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            Spacer()
            
            Text(title)
                .font(.subheadline) // Ridotto rispetto a .headline
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .frame(width: 120) // Regolato per adattarsi al testo più piccolo
            
            Spacer()
            
            VStack {
                Text("\(opponentScore)")
                    .font(.system(size: 20, design: .default))
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    //.padding() // Ridotto padding
                    //.background(opponentScore > myScore ? Color.green : Color.clear)
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
        VStack(spacing: 4) { // Aumentato spacing per migliorare leggibilità
            Text(title)
                .font(.title3) // Aumentato rispetto a .headline
                .fontWeight(.bold)
                .foregroundStyle(.black)
            Text("\(score)")
                .font(.title3) // Aumentato rispetto a .headline
                .fontWeight(.bold)
                .foregroundStyle(.black)
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
            .previewLayout(.sizeThatFits) // Regola il layout della preview
    }
}
