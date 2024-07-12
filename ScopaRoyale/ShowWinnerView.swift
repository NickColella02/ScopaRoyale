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
                        VStack {
                            Text(peerManager.myUsername)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.black)
                            Image(peerManager.myAvatarImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack {
                            Text(peerManager.opponentName)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.black)
                            Image(peerManager.opponentAvatarImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    
                    VStack {
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
                        .padding(.horizontal)
                    }
                    
                    HStack {
                        TotalPointsView(title: "Punti totali", score: peerManager.playerScore, isWinner: peerManager.playerScore > peerManager.opponentScore)
                        
                        Spacer()
                        
                        TotalPointsView(title: "Punti totali", score: peerManager.opponentScore, isWinner: peerManager.opponentScore > peerManager.playerScore)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        if peerManager.isHost {
                            peerManager.sendEndGameSignal()
                            peerManager.closeConnection()
                        }
                        showHomeView = true
                    }) {
                        Text("Termina Partita")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 50))
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

struct ScoreParameterCellView: View {
    let title: String
    let myScore: Int
    let opponentScore: Int
    
    var body: some View {
        HStack {
            VStack {
                Text("\(myScore)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    .padding()
                    .background(myScore >= opponentScore ? Color.green : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            Spacer()
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .frame(width: 150)
            
            Spacer()
            
            VStack {
                Text("\(opponentScore)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    .padding()
                    .background(opponentScore > myScore ? Color.green : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.vertical, 8)
    }
}

struct TotalPointsView: View {
    let title: String
    let score: Int
    let isWinner: Bool
    
    var body: some View {
        VStack(spacing: -10) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .padding()
            Text("\(score)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .padding()
                .background(isWinner ? Color.green : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct ShowWinnerView_Previews: PreviewProvider {
    static var previews: some View {
        let peerManager = MultiPeerManager()
        let speechRecognizer = SpeechRecognizer(peerManager: MultiPeerManager())
        ShowWinnerView()
            .environmentObject(peerManager)
            .environmentObject(speechRecognizer)
    }
}
