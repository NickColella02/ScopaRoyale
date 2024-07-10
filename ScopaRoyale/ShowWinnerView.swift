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
            
            VStack(spacing: 20) {
                Text("Risultato della Partita")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.top, 50)
                
                VStack(spacing: 20) {
                    ScoreView(name: peerManager.myUsername,
                              score: peerManager.playerScore,
                              cardsTaken: peerManager.cardTakenByPlayer.count,
                              scopesMade: peerManager.playerPoints.count,
                              hasSettebello: peerManager.playerHasSettebello,
                              coinsCount: peerManager.playerCoinsCount,
                              hasPrimera: peerManager.playerHasPrimera)
                    
                    ScoreView(name: peerManager.opponentName,
                              score: peerManager.opponentScore,
                              cardsTaken: peerManager.cardTakenByOpponent.count,
                              scopesMade: peerManager.opponentPoints.count,
                              hasSettebello: peerManager.opponentHasSettebello,
                              coinsCount: peerManager.opponentCoinsCount,
                              hasPrimera: peerManager.opponentHasPrimera)
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                Text("Vincitore: \(peerManager.winner)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
                    .scaleEffect(animateWinner ? 1.2 : 1.0)
                    .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateWinner)
                    .onAppear {
                        animateWinner = true
                    }
                
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
                        .background(Color.red)
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

struct ScoreView: View {
    let name: String
    let score: Int
    let cardsTaken: Int
    let scopesMade: Int
    let hasSettebello: Bool
    let coinsCount: Int
    let hasPrimera: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            Text("Punteggio: \(score)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.yellow)
            
            Text("Carte prese: \(cardsTaken)")
                .font(.subheadline)
                .foregroundStyle(.white)
            
            Text("Scope fatte: \(scopesMade)")
                .font(.subheadline)
                .foregroundStyle(.white)
            
            if hasSettebello {
                Text("Settebello fatto")
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            
            Text("Carte oro: \(coinsCount)")
                .font(.subheadline)
                .foregroundStyle(.white)
            
            if hasPrimera {
                Text("Primera fatta")
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
