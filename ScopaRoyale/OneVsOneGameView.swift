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
    @State private var draggedCard: Card? = nil
    @State private var cardOffset: CGSize = .zero

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
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
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
                                    .offset(card == draggedCard ? cardOffset : .zero)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { gesture in
                                                draggedCard = card
                                                cardOffset = gesture.translation
                                            }
                                            .onEnded { gesture in
                                                if gesture.translation.height < -50 && peerManager.currentPlayer == 0 {
                                                    peerManager.playCard(card: card)
                                                }
                                                // Resettare le variabili di stato dopo il rilascio del dito
                                                draggedCard = nil
                                                cardOffset = .zero
                                            }
                                    )
                                    .disabled(peerManager.currentPlayer != 0)
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
                                    .offset(card == draggedCard ? cardOffset : .zero)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { gesture in
                                                draggedCard = card
                                                cardOffset = gesture.translation
                                            }
                                            .onEnded { gesture in
                                                if gesture.translation.height < -50 && peerManager.currentPlayer == 1 {
                                                    peerManager.playCard(card: card)
                                                }
                                                // Resettare le variabili di stato dopo il rilascio del dito
                                                draggedCard = nil
                                                cardOffset = .zero
                                            }
                                    )
                                    .disabled(peerManager.currentPlayer != 1)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20) // Aggiunta di padding inferiore per distanziare le carte dal bordo inferiore
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
