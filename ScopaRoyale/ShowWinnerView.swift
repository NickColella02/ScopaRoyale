import Foundation
import SwiftUI

struct ShowWinnerView: View {
    @EnvironmentObject private var peerManager: MultiPeerManager // Accesso al MultiPeerManager dall'ambiente
    @State private var showHomeView: Bool = false
    @State private var animateWinner: Bool = false
    
    var body: some View {
        ZStack {
            // Background Image
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .blur(radius: 10) // aggiunge un effetto blur
            
            VStack {
                Text("Risultato della Partita")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                    .foregroundStyle(.white)
                
                Spacer()
                
                if peerManager.isHost {
                    HStack {
                        VStack {
                            Text("\(peerManager.myUsername)")
                                .font(.title2)
                                .foregroundStyle(.white)
                            Text("\(peerManager.playerScore)")
                                .font(.largeTitle)
                                .foregroundStyle(.yellow)
                                .bold()
                        }
                        .padding()
                        
                        VStack {
                            Text("\(peerManager.opponentName)")
                                .font(.title2)
                                .foregroundStyle(.white)
                            Text("\(peerManager.opponentScore)")
                                .font(.largeTitle)
                                .foregroundStyle(.yellow)
                                .bold()
                        }
                        .padding()
                    }
                    .background(Color.black.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                } else {
                    HStack {
                        VStack {
                            Text("\(peerManager.myUsername)")
                                .font(.title2)
                                .foregroundStyle(.white)
                            Text("\(peerManager.opponentScore)")
                                .font(.largeTitle)
                                .foregroundStyle(.yellow)
                                .bold()
                        }
                        .padding()
                        
                        VStack {
                            Text("\(peerManager.opponentName)")
                                .font(.title2)
                                .foregroundStyle(.white)
                            Text("\(peerManager.playerScore)")
                                .font(.largeTitle)
                                .foregroundStyle(.yellow)
                                .bold()
                        }
                        .padding()
                    }
                    .background(Color.black.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                
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
                ContentView().environmentObject(peerManager)
            }
        }
    }
}
