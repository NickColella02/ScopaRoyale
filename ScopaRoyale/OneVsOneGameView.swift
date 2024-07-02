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
    @State private var showPeerDisconnectedAlert = false // Variabile di stato per l'alert

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(true)
            
            VStack {
                if peerManager.isHost {
                    // Sezione per le carte dell'avversario, posizionate sopra il tavolo se sei l'host
                    VStack {
                        HStack(spacing: 4) {
                            ZStack {
                                ForEach(0..<peerManager.opponentHand.count, id: \.self) { index in
                                    Image("retro")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30)
                                        .padding(2)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                                        .shadow(radius: 3)
                                        .rotationEffect(index == 0 ? Angle(degrees: 10) : (index == 2 ? Angle(degrees: -10) : Angle(degrees: 0)))
                                        .rotationEffect(.degrees(180))
                                        .zIndex(index == 1 ? 1 : 0)
                                        .offset(x: index == 0 ? -20 : (index == 2 ? 20 : 0))
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                }
                if peerManager.isClient {
                    VStack {
                        HStack(spacing: 4) {
                            ZStack {
                                ForEach(0..<peerManager.playerHand.count, id: \.self) { index in
                                    Image("retro")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30)
                                        .padding(2)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                                        .shadow(radius: 3)
                                        .rotationEffect(index == 0 ? Angle(degrees: 20) : (index == 2 ? Angle(degrees: -20) : Angle(degrees: 0)))
                                        .rotationEffect(.degrees(180))
                                        .zIndex(index == 1 ? 1 : 0)
                                        .offset(x: index == 0 ? -24 : (index == 2 ? 24 : 0))
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10) // Reduced bottom padding
                    }
                }
                
                Spacer()
                
                // Sezione per le carte del tavolo, posizionate al centro
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 4), spacing: 20) {
                    ForEach(peerManager.tableCards, id: \.self) { card in
                        Image(card.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60)
                            .padding(1)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .shadow(radius: 3)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 5)
                
                Spacer()
                
                if peerManager.isHost {
                    // Sezione per le carte del giocatore (solo per l'host)
                    VStack {
                        HStack(spacing: 4) {
                            ForEach(peerManager.playerHand, id: \.self) { card in
                                Image(card.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 75)
                                    .padding(2)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .shadow(radius: 3)
                                    .gesture(
                                        DragGesture()
                                            .onEnded { gesture in
                                                if gesture.translation.height < -50 && peerManager.currentPlayer == 0 {
                                                    peerManager.playCard(card: card)
                                                }
                                            }
                                    )
                                    .disabled(peerManager.currentPlayer != 0)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 150)
                    }
                }
                if peerManager.isClient {
                    // Sezione per le carte dell'avversario (solo per il client)
                    VStack {
                        HStack(spacing: 20) {
                            ZStack {
                                ForEach(0..<peerManager.opponentHand.count, id: \.self) { index in
                                    Image(peerManager.opponentHand[index].imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 75)
                                        .padding(2)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                        .shadow(radius: 3)
                                        .gesture(
                                            DragGesture()
                                                .onEnded { gesture in
                                                    if gesture.translation.height < -50 && peerManager.currentPlayer == 1 {
                                                        peerManager.playCard(card: peerManager.opponentHand[index])
                                                    }
                                                }
                                        )
                                        .disabled(peerManager.currentPlayer != 1)
                                        .rotationEffect(index == 0 ? Angle(degrees: -10) : (index == 2 ? Angle(degrees: 10) : Angle(degrees: 0)))
                                        .zIndex(index == 1 ? 1 : 0)
                                        .offset(x: index == 0 ? -60 : (index == 2 ? 60 : 0))
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 150)
                    }
                }

            }
        }
        .alert(isPresented: $showPeerDisconnectedAlert) {
            Alert(title: Text("Disconnessione"), message: Text("Il giocatore ha abbandonato la partita."), dismissButton: .default(Text("OK")) {
                peerManager.reset() // chiude la connessione alla lobby quando uno dei due giocatori si disconnette
                backModality = true
            })
        }
        .fullScreenCover(isPresented: $backModality) {
            ContentView().environmentObject(peerManager)
        }
        .fullScreenCover(isPresented: $peerManager.gameOver) {
            ShowWinnerView().environmentObject(peerManager)
        }
        .onChange(of: peerManager.peerDisconnected) { oldValue, newValue in
            if newValue {
                showPeerDisconnectedAlert = true
            }
        }
    }
    private func chunkedArray<T>(array: [T], chunkSize: Int) -> [[T]] {
        return stride(from: 0, to: array.count, by: chunkSize).map {
            Array(array[$0 ..< Swift.min($0 + chunkSize, array.count)])
        }
    }
}
