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
                    VStack (spacing: 10) {
                        Text(peerManager.myUsername)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                            .padding()
                        Image(peerManager.myAvatarImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                            .padding()
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack (spacing: 10) {
                        Text(peerManager.opponentName)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                            .padding()
                        Image(peerManager.opponentAvatarImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                            .padding()
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                VStack(spacing: 10) {
                    ScoreParameterRowView(title: "Carte prese", myScore: peerManager.cardTakenByPlayer.count, opponentScore: peerManager.cardTakenByOpponent.count)
                    ScoreParameterRowView(title: "Scope", myScore: peerManager.playerPoints.count, opponentScore: peerManager.opponentPoints.count)
                    ScoreParameterRowView(title: "Settebello", myScore: peerManager.playerHasSettebello ? 1 : 0, opponentScore: peerManager.opponentHasSettebello ? 1 : 0)
                    ScoreParameterRowView(title: "Carte oro", myScore: peerManager.playerCoinsCount, opponentScore: peerManager.opponentCoinsCount)
                    ScoreParameterRowView(title: "Primera", myScore: peerManager.playerHasPrimera ? 1 : 0, opponentScore: peerManager.opponentHasPrimera ? 1 : 0)
                }
                
                Spacer()
                
                HStack {
                    VStack (spacing: -20) {
                        Text("Punti totali")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.black) // Colore diverso per vincitore/sconfitto
                            .padding()
                        Text("\(peerManager.playerScore)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(peerManager.playerScore > peerManager.opponentScore ? .green : .red)
                            .padding()
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack (spacing: -20) {
                        Text("Punti totali")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                            .padding()
                        Text("\(peerManager.opponentScore)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(peerManager.opponentScore > peerManager.playerScore ? .green : .red)
                            .padding()
                    }
                    .padding(.horizontal)
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
                        .foregroundStyle(.white)
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
                .foregroundStyle(.black)
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

struct ShowWinnerView_Previews: PreviewProvider {
    static var previews: some View {
        let peerManager = MultiPeerManager()
        let speechRecognizer = SpeechRecognizer(peerManager: MultiPeerManager())
        
        ShowWinnerView()
            .environmentObject(peerManager)
            .environmentObject(speechRecognizer)
    }
}
