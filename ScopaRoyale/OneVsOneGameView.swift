import SwiftUI
import SpriteKit

struct OneVsOneGameView: View {
    var scene: SKScene {
        let scene = OneVsOneGameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFill
        return scene
    }
    
    @EnvironmentObject private var peerManager: MultiPeerManager // Accesso al MultiPeerManager dall'ambiente
    @Environment(\.presentationMode) var presentationMode
    @State private var backModality = false
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(true)
            
            VStack {
                if peerManager.isHost {
                    // Sezione per le carte dell'avversario, posizionate sopra il tavolo se sei l'host
                    VStack {                        
                        HStack {
                            ForEach(peerManager.opponentHand, id: \.self) { card in
                                Image("retro")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 90)
                                    .padding(4)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(radius: 5)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20) // Aggiunta di padding inferiore per distanziare le carte dal bordo inferiore
                    }
                }
                if peerManager.isClient {
                    VStack {
                        HStack {
                            ForEach(peerManager.playerHand, id: \.self) { card in
                                Image("retro")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 90)
                                    .padding(4)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(radius: 5)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20) // Aggiunta di padding inferiore per distanziare le carte dal bordo inferiore
                    }
                }
                
                Spacer()
                
                // Sezione per le carte del tavolo, posizionate al centro
                VStack {                    
                    HStack {
                        ForEach(peerManager.tableCards, id: \.self) { card in
                            Image(card.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 90)
                                .padding(4)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                
                Spacer()
                
                if peerManager.isHost {
                    // Sezione per le carte del giocatore (solo per il browser)
                    VStack {
                        HStack {
                            ForEach(peerManager.playerHand, id: \.self) { card in
                                Image(card.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 90)
                                    .padding(4)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(radius: 5)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20) // Aggiunta di padding inferiore per distanziare le carte dal bordo inferiore
                    }
                }
                if peerManager.isClient {
                    // Sezione per le carte dell'avversario (solo per il browser)
                    VStack {
                        HStack {
                            ForEach(peerManager.opponentHand, id: \.self) { card in
                                Image(card.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 90)
                                    .padding(4)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(radius: 5)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20) // Aggiunta di padding inferiore per distanziare le carte dal bordo inferiore
                    }
                }
            }
        }
        .navigationDestination(isPresented: $backModality) {
            SelectModeView(lobbyName: peerManager.lobbyName).environmentObject(peerManager)
        }
    }
}
