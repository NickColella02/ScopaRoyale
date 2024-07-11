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
    @State private var moveLeft = false
    @State private var moveOpponentLeft = false
    @EnvironmentObject var speechRecognizer: SpeechRecognizer

    var body: some View {
        ZStack {
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
                        Text("Mazzo: \(peerManager.deck.count)")
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
                    
                    // Low Left (carte player)
                    ZStack {
                        Image("grayRectangle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 90)
                            .zIndex(0)
                        Text("Carte: \(peerManager.cardTakenByPlayer.count)")
                            .font(.system(size: 12, design: .default))
                            .foregroundStyle(Color(red: 191 / 255, green: 191 / 255, blue: 191 / 255))
                            .padding(1)
                            .background(Color(red: 59 / 255, green: 125 / 255, blue: 35 / 255))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .offset(x: 0, y: -36)
                            .zIndex(2)
                        Text("Scope: \(peerManager.playerPoints.count)")
                            .font(.system(size: 12, design: .default))
                            .foregroundStyle(Color(red: 191 / 255, green: 191 / 255, blue: 191 / 255))
                            .padding(1)
                            .background(Color(red: 59 / 255, green: 125 / 255, blue: 35 / 255))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .offset(x: 0, y: 36)
                            .zIndex(2)
                        HStack {
                            VStack {
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
                            }
                            .offset(x: moveLeft ? 0 : 0)
                            .animation(.easeInOut, value: moveLeft)
                            .animation(.easeInOut, value: peerManager.cardTakenByPlayer.count)
                            
                            VStack {
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
                            .animation(.easeInOut, value: peerManager.playerPoints.count)
                        }
                    }
                    .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.9)
                    .onReceive(peerManager.$playerPoints) { playerPoints in
                        let newCount = playerPoints.count
                        if newCount > 0 {
                            moveLeft = true
                        }
                    }
                    
                    // Top right (carte opponent)
                    ZStack {
                        Image("grayRectangle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 90)
                            .zIndex(0)
                        Text("Carte: \(peerManager.cardTakenByOpponent.count)")
                            .font(.system(size: 12, design: .default))
                            .foregroundStyle(Color(red: 191 / 255, green: 191 / 255, blue: 191 / 255))
                            .padding(1)
                            .background(Color(red: 59 / 255, green: 125 / 255, blue: 35 / 255))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .offset(x: 0, y: -36)
                            .zIndex(2)
                        Text("Scope: \(peerManager.opponentPoints.count)")
                            .font(.system(size: 12, design: .default))
                            .foregroundStyle(Color(red: 191 / 255, green: 191 / 255, blue: 191 / 255))
                            .padding(1)
                            .background(Color(red: 59 / 255, green: 125 / 255, blue: 35 / 255))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .offset(x: 0, y: 36)
                            .zIndex(2)
                        HStack {
                            VStack {
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
                            }
                            .offset(x: moveOpponentLeft ? 0 : 0)
                            .animation(.easeInOut, value: moveOpponentLeft)
                            .animation(.easeInOut, value: peerManager.cardTakenByPlayer.count)
                            
                            VStack {
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
                            .animation(.easeInOut, value: peerManager.opponentPoints.count)
                        }
                    }
                    .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.1)
                    .onReceive(peerManager.$opponentPoints) { opponentPoints in
                        let newCount = opponentPoints.count
                        if newCount > 0 {
                            moveOpponentLeft = true
                        }
                    }

                    VStack {
                        if (peerManager.isHost && peerManager.currentPlayer == 0) || (peerManager.isClient && peerManager.currentPlayer == 1) {
                            VStack {
                                Image("isYourTurn")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 220)
                            }
                            .animation(.easeInOut, value: peerManager.currentPlayer)
                        }
                    }
                    .position(x: geometry.size.width * 0.63, y: geometry.size.height * 0.9)
                }
            }


            VStack {
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
                                    .zIndex(1)
                                    .offset(x: peerManager.opponentHand.count == 3 ? (index == 0 ? -20 : (index == 2 ? 20 : 0)) : (peerManager.opponentHand.count == 2 ? (index == 0 ? -10 : 10) : 0), y: peerManager.opponentHand.count < 3 ? 4 : (index == 1 ? 4 : 0))
                            }
                        }
                        .offset(y: -15)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()

                // Sezione per le carte sul tavolo
                var bottomPaddingTable: CGFloat {
                    return draggedCard != nil ? -5 : 5
                }
                
                var bottomPaddingHand: CGFloat {
                    return draggedCard != nil ? 143 : 150
                }

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
                .padding(.bottom, bottomPaddingTable) // Usa la proprietà bottomPadding per il padding inferiore

                Spacer()
                
                VStack {
                    HStack(spacing: 4) {
                        ForEach(peerManager.playerHand.indices, id: \.self) { index in
                            let card = peerManager.playerHand[index] // Salva la carta in una costante
                            
                            // Calcolo degli zIndex in base alla selezione
                            var zIndex: Double {
                                if draggedCard == card {
                                    return 1 // Carta selezionata in primo piano
                                } else if index == 0 && draggedCard == peerManager.playerHand[0] {
                                    return 0.5 // Carta sinistra selezionata, in secondo piano
                                } else if index == 1 && draggedCard == peerManager.playerHand[0] {
                                    return 0.25 // Carta centrale se selezionata, in terzo piano
                                } else {
                                    return 0 // Altrimenti, carta normale
                                }
                            }

                            Image(card.imageName) // Utilizza direttamente la proprietà imageName della carta
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: draggedCard == card ? 85 : 75) // Ingrandisce leggermente la carta selezionata
                                .padding(2)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .shadow(radius: 3)
                                .rotationEffect(peerManager.playerHand.count >= 3 ? (index == 0 ? Angle(degrees: -10) : (index == 2 ? Angle(degrees: 10) : Angle(degrees: 0))) : (peerManager.playerHand.count == 2 ? (index == 0 ? Angle(degrees: -5) : Angle(degrees: 5)) : Angle(degrees: 0)))
                                .zIndex(zIndex)
                                .offset(x: peerManager.playerHand.count == 3 ? (index == 0 ? 20 : (index == 2 ? -20 : 0)) : (peerManager.playerHand.count == 2 ? (index == 0 ? 10 : -10) : 0), y: peerManager.playerHand.count < 3 ? -10 : (index == 1 ? -10 : 0))
                                .offset(draggedCard == card ? cardOffset : .zero)
                                .gesture(
                                    TapGesture()
                                        .onEnded {
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                draggedCard = card // Seleziona la carta
                                            }
                                        }
                                )
                                .gesture(
                                    DragGesture(minimumDistance: 20, coordinateSpace: .local)
                                        .onChanged { gesture in
                                            if draggedCard == card && gesture.translation.height < 0 {
                                                cardOffset = gesture.translation
                                            }
                                        }
                                        .onEnded { gesture in
                                            if draggedCard == card && gesture.translation.height < -50 {
                                                if peerManager.currentPlayer == 0 && peerManager.isHost || peerManager.currentPlayer == 1 && peerManager.isClient {
                                                    peerManager.playCard(card: card) // Gioca la carta
                                                }
                                            }
                                            draggedCard = nil
                                            cardOffset = .zero
                                        }
                                )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, bottomPaddingHand)
                }
            }
            if peerManager.blindMode {
                if peerManager.isHost && peerManager.currentPlayer == 0 || peerManager.isClient && peerManager.currentPlayer == 1 {
                    RecordingButton(isRecording: peerManager.isRecording) {
                        if peerManager.isRecording {
                            peerManager.isRecording = false
                            peerManager.sendRecordingStatus(false)
                            speechRecognizer.stopTranscribing()
                        } else {
                            peerManager.isRecording = true
                            peerManager.sendRecordingStatus(true)
                            speechRecognizer.startTranscribing()
                        }
                    }
                }
            }
        }
        .onChange(of: peerManager.currentPlayer) {
            if peerManager.blindMode && !peerManager.gameOver {
                if (peerManager.isHost && peerManager.currentPlayer == 0) {
                    DispatchQueue.main.async {
                        speechRecognizer.speakText("È il tuo turno")
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
            ContentView().environmentObject(peerManager).environmentObject(speechRecognizer)
        }
        .fullScreenCover(isPresented: $peerManager.gameOver) {
            ShowWinnerView().environmentObject(peerManager).environmentObject(speechRecognizer)
        }
        .onChange(of: peerManager.peerDisconnected) {
            if peerManager.peerDisconnected {
                DispatchQueue.main.async {
                    showPeerDisconnectedAlert = true
                }
            }
        }
    }

    private func RecordingButton(isRecording: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(isRecording ? "Interrompi registrazione" : "Avvia registrazione")
                .font(.system(size: 30, weight: .regular))
                .bold()
                .padding()
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black).opacity(0.8)
    }
    
    private func chunkedArray<T>(array: [T], chunkSize: Int) -> [[T]] {
        return stride(from: 0, to: array.count, by: chunkSize).map {
            Array(array[$0 ..< Swift.min($0 + chunkSize, array.count)])
        }
    }
}
