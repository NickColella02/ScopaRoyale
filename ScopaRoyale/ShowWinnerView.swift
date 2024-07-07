import SwiftUI

struct ShowWinnerView: View {
    @EnvironmentObject private var peerManager: MultiPeerManager
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    @State private var showHomeView: Bool = false
    @State private var animateWinner: Bool = false
    
    var body: some View {
        ZStack {
            // Background Image
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .all)
                .blur(radius: 10)
            
            VStack {
                Text("Risultato della Partita")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                    .foregroundStyle(.white)
                
                Spacer()
                
                HStack {
                    VStack {
                        Text(peerManager.myUsername)
                            .font(.title2)
                            .foregroundStyle(.white)
                        
                        Text("\(peerManager.playerScore)")
                            .font(.largeTitle)
                            .foregroundStyle(.yellow)
                            .bold()
                        
                        Text("Carte prese: \(peerManager.cardTakenByPlayer.count)")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        
                        Text("Scope fatte: \(peerManager.playerPoints.count)")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        
                        if peerManager.playerHasSettebello {
                            Text("Settebello")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                        }
                        
                        Text("Carte oro: \(peerManager.playerCoins)")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                    
                    VStack {
                        Text(peerManager.opponentName)
                            .font(.title2)
                            .foregroundStyle(.white)
                        
                        Text("\(peerManager.opponentScore)")
                            .font(.largeTitle)
                            .foregroundStyle(.yellow)
                            .bold()
                        
                        Text("Carte prese: \(peerManager.cardTakenByOpponent.count)")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        
                        Text("Scope fatte: \(peerManager.opponentPoints.count)")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        
                        if peerManager.opponentHasSettebello {
                            Text("Settebello")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                        }
                        
                        Text("Carte oro: \(peerManager.opponentCoins)")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                }
                .background(Color.black.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                Spacer()
                
                Text("Vincitore: \(peerManager.winner)")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .foregroundStyle(.green)
                    .scaleEffect(animateWinner ? 1.2 : 1.0)
                    .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateWinner)
                    .onAppear {
                        animateWinner = true
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
                        .font(.system(size: 20))
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
            .fullScreenCover(isPresented: $showHomeView) {
                ContentView().environmentObject(peerManager).environmentObject(speechRecognizer)
            }
        }
    }
}
