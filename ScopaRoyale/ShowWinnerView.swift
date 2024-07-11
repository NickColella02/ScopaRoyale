import SwiftUI

struct ShowWinnerView: View {
    @EnvironmentObject private var peerManager: MultiPeerManager
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    @State private var showHomeView: Bool = false
    @State private var animateWinner: Bool = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Text(peerManager.myUsername)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    Spacer()
                    Text(peerManager.opponentName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                Spacer()
                
                VStack(spacing: 10) {
                    ScoreParameterRowView(title: "Carte prese", myScore: peerManager.cardTakenByPlayer.count, opponentScore: peerManager.cardTakenByOpponent.count)
                    ScoreParameterRowView(title: "Scope", myScore: peerManager.playerPoints.count, opponentScore: peerManager.opponentPoints.count)
                    ScoreParameterRowView(title: "Settebello", myScore: peerManager.playerHasSettebello ? 1 : 0, opponentScore: peerManager.opponentHasSettebello ? 1 : 0)
                    ScoreParameterRowView(title: "Carte oro", myScore: peerManager.playerCoinsCount, opponentScore: peerManager.opponentCoinsCount)
                    ScoreParameterRowView(title: "Primera", myScore: peerManager.playerHasPrimera ? 1 : 0, opponentScore: peerManager.opponentHasPrimera ? 1 : 0)
                }
                
                Spacer()
                
                VStack {
                    if peerManager.winner == "Pareggio" {
                        Text("Pareggio")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    } else {
                        Text("Il vincitore è...")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Text("\(peerManager.winner)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .scaleEffect(animateWinner ? 1.2 : 1.0)
                            .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateWinner)
                            .onAppear {
                                animateWinner = true
                            }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    if peerManager.isHost {
                        peerManager.sendEndGameSignal()
                        peerManager.closeConnection()
                    }
                    showHomeView = true
                }) {
                    Text("Termina Partita")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                }
                .frame(width: 330, height: 60)
                .padding(.horizontal, 35)
                
                Spacer()
            }
            .padding()
            .onAppear() {
                if peerManager.blindMode {
                    speechRecognizer.speakText("Il vincitore è \(peerManager.winner)")
                }
            }
        }
        .fullScreenCover(isPresented: $showHomeView) {
            ContentView().environmentObject(peerManager)
        }
    }
}

struct ScoreParameterRowView: View {
    let title: String
    let myScore: Int
    let opponentScore: Int
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack {
                Circle()
                    .fill(myScore == opponentScore ? Color.yellow : (myScore > opponentScore ? Color.green : Color.red))
                    .frame(width: 20, height: 20)
            }
            
            Spacer()
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .frame(width: 150)
            
            Spacer()
            
            VStack {
                Circle()
                    .fill(opponentScore == myScore ? Color.yellow : (opponentScore > myScore ? Color.green : Color.red))
                    .frame(width: 20, height: 20)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
