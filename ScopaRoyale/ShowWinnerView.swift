import Foundation
import SwiftUI

struct ShowWinnerView: View {
    @EnvironmentObject private var peerManager: MultiPeerManager // Accesso al MultiPeerManager dall'ambiente
    @State private var showHomeView: Bool = false
    var body: some View {
        ZStack {
            VStack {
                Text("Punteggio \(peerManager.myUsername): \(peerManager.playerScore)")
                    .font(.title)
                    .padding()
                
                Text("Punteggio \(peerManager.opponentName): \(peerManager.opponentScore)")
                    .font(.title)
                    .padding()
                
                Text("Vincitore: \(peerManager.winner)")
                    .font(.title)
                    .padding()
                
                Button(action: {
                    showHomeView = true
                }) {
                    Text("Termina Partita")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                }
                .frame(width: 330, height: 60)
                .padding(.horizontal, 35)
            }
            .fullScreenCover(isPresented: $showHomeView) {
                ContentView().environmentObject(peerManager)
            }
        }
    }
}
