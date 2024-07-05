import SwiftUI
import SpriteKit

struct OneVsOneGameView: View {
    var scene: SKScene {
        let scene = OneVsOneGameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFill
        return scene
    }

    @EnvironmentObject private var peerManager: MultiPeerManager
    @Environment(\.presentationMode) var presentationMode
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var backModality = false
    @State private var showPeerDisconnectedAlert = false
    @State private var draggedCard: Card? = nil
    @State private var cardOffset: CGSize = .zero

    var body: some View {
        ZStack(alignment: .topLeading) { // Align contents to top left
            SpriteView(scene: scene)
                .edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(true)
            GeometryReader { geometry in
                ZStack {
                    // Top left (carti rimanenti)
                    ZStack {
                        if peerManager.deck.count > 0 {
                            Image("retro")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                                .shadow(radius: 2)
                                .zIndex(1)
                        }
                        Text("\(peerManager.deck.count)")
                            .font(.system(size: 12, design: .default))
                            .foregroundStyle(Color(red: 191 / 255, green: 191 / 255, blue: 191 / 255))
                            .padding(1)
                            .background(Color(red: 59 / 255, green: 125 / 255, blue: 35 / 255))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .offset(x: 0, y: -36)
                            .zIndex(2)
                        Image("grayRectangle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 90)
                            .zIndex(0)
                    }
                    .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.1)
                    
                    // Lato host
                    if peerManager.isHost {
                        // Low Left (carte player)
                        ZStack {
                            Image("grayRectangle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 90)
                                .zIndex(0)
                            Text("\(peerManager.playerPoints.count)")
                                .font(.system(size: 12, design: .default))
                                .foregroundStyle(Color(red: 191 / 255, green: 191 / 255, blue: 191 / 255))
                                .padding(1)
                                .background(Color(red: 59 / 255, green: 125 / 255, blue: 35 / 255))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .offset(x: 0, y: -36)
                                .zIndex(2)
                            HStack {
                                if peerManager.cardTakenByPlayer.count > 0 {
                                    Image("retro")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30)
                                        .padding(1)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                                        .shadow(radius: 2)
                                        .zIndex(1)
                                }
                                if peerManager.playerPoints.count > 0 {
                                    Image(peerManager.playerPoints.last!.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30)
                                        .padding(1)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                                        .shadow(radius: 2)
                                        .zIndex(1)
                                }
                            }
                        }
                        .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.9)
                        
                        // Top right (carte opponent)
                        ZStack {
                            Image("grayRectangle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 90)
                                .zIndex(0)
                            Text("\(peerManager.opponentPoints.count)")
                                .font(.system(size: 12, design: .default))
                                .foregroundStyle(Color(red: 191 / 255, green: 191 / 255, blue: 191 / 255))
                                .padding(1)
                                .background(Color(red: 59 / 255, green: 125 / 255, blue: 35 / 255))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .offset(x: 0, y: -36)
                                .zIndex(2)
                            HStack {
                                if peerManager.cardTakenByOpponent.count > 0 {
                                    Image("retro")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30)
                                        .padding(1)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                                        .shadow(radius: 2)
                                        .zIndex(1)
                                }
                                if peerManager.opponentPoints.count > 0 {
                                    Image(peerManager.opponentPoints.last!.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30)
                                        .padding(1)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                                        .shadow(radius: 2)
                                        .zIndex(1)
                                }
                            }
                        }
                        .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.1)
                        if peerManager.currentPlayer == 0 {
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color(red: 254 / 255, green: 189 / 255, blue: 2 / 255), lineWidth: 2)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .edgesIgnoringSafeArea(.all)
                        }
                    }

                    // Lato client
                    if peerManager.isClient {
                        // Low Left (carte player)
                        ZStack {
                            Image("grayRectangle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 90)
                                .zIndex(0)
                            Text("\(peerManager.playerPoints.count)")
                                .font(.system(size: 12, design: .default))
                                .foregroundStyle(Color(red: 191 / 255, green: 191 / 255, blue: 191 / 255))
                                .padding(1)
                                .background(Color(red: 59 / 255, green: 125 / 255, blue: 35 / 255))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .offset(x: 0, y: -36)
                                .zIndex(2)
                            HStack {
                                if peerManager.cardTakenByPlayer.count > 0 {
                                    Image("retro")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30)
                                        .padding(1)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                                        .shadow(radius: 2)
                                        .zIndex(1)
                                }
                                if peerManager.playerPoints.count > 0 {
                                    Image(peerManager.playerPoints.last!.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30)
                                        .padding(1)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                                        .shadow(radius: 2)
                                        .zIndex(1)
                                }
                            }
                        }
                        .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.1)
                        
                        // Top right (carte opponent)
                        ZStack {
                            Image("grayRectangle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 90)
                                .zIndex(0)
                            Text("\(peerManager.opponentPoints.count)")
                                .font(.system(size: 12, design: .default))
                                .foregroundStyle(Color(red: 191 / 255, green: 191 / 255, blue: 191 / 255))
                                .padding(1)
                                .background(Color(red: 59 / 255, green: 125 / 255, blue: 35 / 255))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .offset(x: 0, y: -36)
                                .zIndex(2)
                            HStack {
                                if peerManager.cardTakenByOpponent.count > 0 {
                                    Image("retro")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30)
                                        .padding(1)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                                        .shadow(radius: 2)
                                        .zIndex(1)
                                }
                                if peerManager.opponentPoints.count > 0 {
                                    Image(peerManager.opponentPoints.last!.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30)
                                        .padding(1)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                                        .shadow(radius: 2)
                                        .zIndex(1)
                                }
                            }
                        }
                        .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.9)
                        if peerManager.currentPlayer == 1 {
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color(red: 254 / 255, green: 189 / 255, blue: 2 / 255), lineWidth: 5)
                                .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                                .edgesIgnoringSafeArea(.all)
                        }
                    }
                    /*VStack {
                        Text("YOUR POINTS \(peerManager.playerPoints.count)")
                            .font(.system(size: 20, design: .default))
                            .foregroundStyle(Color(red: 191 / 255, green: 191 / 255, blue: 191 / 255))
                            .padding(.bottom, -5)
                        Image("line")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 220)
                        Text("OPPONENT'S POINTS \(peerManager.opponentPoints.count)")
                            .font(.system(size: 15, design: .default))
                            .foregroundStyle(Color(red: 191 / 255, green: 191 / 255, blue: 191 / 255))
                            .padding(.bottom, 10)
                    }
                    .position(x: geometry.size.width * 0.63, y: geometry.size.height * 0.905)*/
                }
            }

            VStack {
                if peerManager.isHost {
                    VStack {
                        Text(peerManager.opponentName)
                            .font(.system(size: 15, design: .default))
                            .foregroundStyle(.white)
                            .padding()
                            .frame(width: 90, height: 20)
                            .background(Color(red: 254 / 255, green: 189 / 255, blue: 2 / 255))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .shadow(radius: 5)
                            .zIndex(2)
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
                                        .shadow(radius: 2)
                                        .rotationEffect(peerManager.opponentHand.count >= 3 ? (index == 0 ? Angle(degrees: 10) : (index == 2 ? Angle(degrees: -10) : Angle(degrees: 0))) : (peerManager.opponentHand.count == 2 ? (index == 0 ? Angle(degrees: 5) : Angle(degrees: -5)) : Angle(degrees: 0)))
                                        .rotationEffect(.degrees(180))
                                        .zIndex(index == 1 ? 1 : 0)
                                        .offset(x: peerManager.opponentHand.count == 3 ? (index == 0 ? -20 : (index == 2 ? 20 : 0)) : (peerManager.opponentHand.count == 2 ? (index == 0 ? -10 : 10) : 0), y: peerManager.opponentHand.count < 3 ? 4 : (index == 1 ? 4 : 0))
                                }
                            }
                            .offset(y: -15)
                        }
                        .padding(.horizontal)
                    }
                }
                if peerManager.isClient {
                    VStack {
                        Text(peerManager.opponentName)
                            .font(.system(size: 15, design: .default))
                            .foregroundStyle(.white)
                            .padding()
                            .frame(width: 90, height: 20)
                            .background(Color(red: 254 / 255, green: 189 / 255, blue: 2 / 255))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .shadow(radius: 5)
                            .zIndex(2)
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
                                        .shadow(radius: 2)
                                        .rotationEffect(peerManager.playerHand.count >= 3 ? (index == 0 ? Angle(degrees: 10) : (index == 2 ? Angle(degrees: -10) : Angle(degrees: 0))) : (peerManager.playerHand.count == 2 ? (index == 0 ? Angle(degrees: 5) : Angle(degrees: -5)) : Angle(degrees: 0)))
                                        .rotationEffect(.degrees(180))
                                        .zIndex(index == 1 ? 1 : 0)
                                        .offset(x: peerManager.playerHand.count == 3 ? (index == 0 ? -20 : (index == 2 ? 20 : 0)) : (peerManager.playerHand.count == 2 ? (index == 0 ? -10 : 10) : 0), y: peerManager.playerHand.count < 3 ? 4 : (index == 1 ? 4 : 0))
                                }
                            }
                            .offset(y: -15)
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()

                // Sezione per le carte sul tavolo
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
                    // Sezione per le carte dell'host
                    VStack {
                        HStack(spacing: 4) {
                            ForEach(peerManager.playerHand.indices, id: \.self) { index in
                                let card = peerManager.playerHand[index] // Salva la carta in una costante

                                Image(card.imageName) // Utilizza direttamente la proprietà imageName della carta
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 75)
                                    .padding(2)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .shadow(radius: 3)
                                    .rotationEffect(peerManager.playerHand.count >= 3 ? (index == 0 ? Angle(degrees: -10) : (index == 2 ? Angle(degrees: 10) : Angle(degrees: 0))) : (peerManager.playerHand.count == 2 ? (index == 0 ? Angle(degrees: -5) : Angle(degrees: 5)) : Angle(degrees: 0)))
                                    .zIndex(index == 1 ? 1 : 0)
                                    .offset(x: peerManager.playerHand.count == 3 ? (index == 0 ? 20 : (index == 2 ? -20 : 0)) : (peerManager.playerHand.count == 2 ? (index == 0 ? 10 : -10) : 0), y: peerManager.playerHand.count < 3 ? -10 : (index == 1 ? -10 : 0))
                                    .offset(card == draggedCard ? cardOffset : .zero)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { gesture in
                                                draggedCard = card // Assegna direttamente la carta trascinata
                                                cardOffset = gesture.translation
                                            }
                                            .onEnded { gesture in
                                                if gesture.translation.height < 400 && peerManager.currentPlayer == 0 {
                                                    peerManager.playCard(card: card) // Gioca la carta intera
                                                }
                                                draggedCard = nil
                                                cardOffset = .zero
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
                    // Sezione per le carte del client
                    VStack {
                        HStack(spacing: 4) {
                            ForEach(peerManager.opponentHand.indices, id: \.self) { index in
                                let card = peerManager.opponentHand[index] // Salva la carta in una costante

                                Image(card.imageName) // Utilizza direttamente la proprietà imageName della carta
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 75)
                                    .padding(2)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .shadow(radius: 3)
                                    .rotationEffect(peerManager.opponentHand.count >= 3 ? (index == 0 ? Angle(degrees: -10) : (index == 2 ? Angle(degrees: 10) : Angle(degrees: 0))) : (peerManager.opponentHand.count == 2 ? (index == 0 ? Angle(degrees: -5) : Angle(degrees: 5)) : Angle(degrees: 0)))
                                    .zIndex(index == 1 ? 1 : 0)
                                    .offset(x: peerManager.opponentHand.count == 3 ? (index == 0 ? 20 : (index == 2 ? -20 : 0)) : (peerManager.opponentHand.count == 2 ? (index == 0 ? 10 : -10) : 0), y: peerManager.opponentHand.count < 3 ? -10 : (index == 1 ? -10 : 0))
                                    .offset(card == draggedCard ? cardOffset : .zero)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { gesture in
                                                draggedCard = card // Assegna direttamente la carta trascinata
                                                cardOffset = gesture.translation
                                            }
                                            .onEnded { gesture in
                                                if gesture.translation.height < 400 && peerManager.currentPlayer == 1 {
                                                    peerManager.playCard(card: card) // Gioca la carta intera
                                                }
                                                draggedCard = nil
                                                cardOffset = .zero
                                            }
                                    )
                                    .disabled(peerManager.currentPlayer != 1)
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
                peerManager.reset()
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
