import SwiftUI
import SpriteKit
import Combine

struct OneVsOneGameView: View {
    var scene: SKScene {
        let scene = OneVsOneGameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFill
        return scene
    }
    
    @EnvironmentObject private var peerManager: MultiPeerManager // Accesso al MultiPeerManager dall'ambiente
    @Environment(\.presentationMode) var presentationMode
    @State private var backModality = false
    @State private var playerHand: [Card] = [] // mano del giocatore (advertiser) inizialmente vuota
    @State private var tableCards: [Card] = [] // carte presenti sul tavolo
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(true)
            
            Color.clear // Placeholder for any additional views
            
            VStack {
                // Visualizzazione delle carte del giocatore (advertiser)
                HStack {
                    ForEach(playerHand, id: \.self) { card in
                        Image(card.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 90)
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Visualizzazione delle carte dell'avversario (browser)
                HStack {
                    ForEach(peerManager.opponentHand, id: \.self) { card in
                        Image(card.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 90)
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Visualizzazione delle carte sul tavolo
                HStack {
                    ForEach(tableCards, id: \.self) { card in
                        Image(card.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 90)
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationDestination(isPresented: $backModality) {
            SelectModeView(lobbyName: peerManager.lobbyName).environmentObject(peerManager)
        }
        .onAppear {
            peerManager.createDeck() // crea il mazzo iniziale e lo mescola
            giveCardsToPlayer() // estrae 3 carte e le da al giocatore (advertiser)
            peerManager.giveCardsToOpponent() // estrae 3 carte e le da all'avversario (browser)
            placeTableCards() // posiziona 4 carte al centro
        }
    }
    
    // Estrae le carte per il giocatore (advertiser)
    private func giveCardsToPlayer() {
        for _ in 0..<3 {
            if let card = peerManager.deck.first {
                playerHand.append(card)
                peerManager.deck.removeFirst()
                print("Carta estratta per il giocatore: \(card.value) di \(card.seed)")
            } else {
                print("Il mazzo è vuoto, non ci sono altre carte da estrarre per il giocatore.")
                break
            }
        }
    }
    
    // Posiziona le carte sul tavolo
    private func placeTableCards() {
        for _ in 0..<4 {
            if let card = peerManager.deck.first {
                tableCards.append(card)
                peerManager.deck.removeFirst()
                print("Carta estratta per il tavolo: \(card.value) di \(card.seed)")
            } else {
                print("Il mazzo è vuoto, non ci sono altre carte da posizionare sul tavolo.")
                break
            }
        }
    }
}

struct OneVsOneGameView_Previews: PreviewProvider {
    static var previews: some View {
        OneVsOneGameView()
    }
}
