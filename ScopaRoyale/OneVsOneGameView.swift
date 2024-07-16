import SwiftUI
import SpriteKit

struct OneVsOneGameView: View {
    var scene: SKScene {
        let scene = OneVsOneGameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFill
        return scene
    }
    @EnvironmentObject private var peerManager: MultiPeerManager
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var backModality: Bool = false
    @State private var isRecording: Bool = false
    @State private var showPeerDisconnectedAlert: Bool = false
    @State private var draggedCard: Card? = nil
    @State private var cardOffset: CGSize = .zero
    @State private var moveLeft: Bool = false
    @State private var moveOpponentLeft: Bool = false
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
                // Sezione per il nome dell'avversario e le carte dell'avversario
                VStack {
                    // Nome dell'avversario
                    Text(peerManager.opponentName)
                        .font(.system(size: 15, design: .default))
                        .foregroundStyle(.white)
                        .padding()
                        .frame(width: 90, height: 20)
                        .background(Color(red: 254 / 255, green: 189 / 255, blue: 2 / 255))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .shadow(radius: 5)
                        .zIndex(2)
                    
                    // Carte dell'avversario
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
                
                if peerManager.showScopaAnimation || peerManager.showOpponentScopaAnimation {
                    Text("Scopa!")
                        .font(.system(size: 40, weight: .bold, design: .default))
                        .foregroundStyle(peerManager.showScopaAnimation ? Color.yellow : Color.red)
                        .padding()
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.7))
                                .shadow(color: .gray, radius: 10, x: 5, y: 5)
                        )
                        .scaleEffect(peerManager.showScopaAnimation ? 1.2 : 1.0)
                        .transition(.scale)
                        .animation(.easeInOut(duration: 0.3), value: peerManager.showScopaAnimation || peerManager.showOpponentScopaAnimation)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    peerManager.showScopaAnimation = false
                                    peerManager.showOpponentScopaAnimation = false
                                }
                            }
                        }
                }
                
                if peerManager.showSettebelloAnimation || peerManager.showOpponentSettebelloAnimation {
                    Text("Settebello!")
                        .font(.system(size: 40, weight: .bold, design: .default))
                        .foregroundStyle(peerManager.showSettebelloAnimation ? Color.yellow : Color.red)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .clipShape(Capsule())
                        .transition(.asymmetric(insertion: .scale, removal: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    peerManager.showSettebelloAnimation = false
                                    peerManager.showOpponentSettebelloAnimation = false
                                }
                            }
                        }
                }
                
                if peerManager.showGameOverAnimation {
                    VStack {
                        Spacer()
                        Text("Partita terminata!")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding()
                            .background(Color.black.opacity(0.4))
                            .clipShape(Capsule())
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Spacer()
                    }
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
                            .transition(.scale(scale: 0.5, anchor: .center)) // Scala la transizione per l'apparizione
                        /*.onDisappear {
                         if peerManager.isHost {                 // host
                         if peerManager.currentPlayer == 0 { // host
                         withAnimation(.easeInOut(duration: 0.3)) {
                         }
                         } else if peerManager.currentPlayer == 1 { // client
                         withAnimation(.easeInOut(duration: 0.3)) {
                         }
                         }
                         } else if peerManager.isClient {        // client
                         if peerManager.currentPlayer == 0 { // host
                         withAnimation(.easeInOut(duration: 0.3)) {
                         }
                         } else if peerManager.currentPlayer == 1 { // client
                         withAnimation(.easeInOut(duration: 0.3)) {
                         }
                         }
                         }
                         }*/
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: peerManager.tableCards)
                .padding(.horizontal, 40)
                .padding(.bottom, bottomPaddingTable)
                
                
                Spacer()
                
                VStack {
                    HStack(spacing: 4) {
                        ForEach(peerManager.playerHand.indices, id: \.self) { index in
                            let card = peerManager.playerHand[index]
                            
                            // Calcolo degli zIndex in base alla selezione
                            var zIndex: Double {
                                if draggedCard == card {
                                    return 1 // Carta selezionata in primo piano
                                } else if index == 0 && draggedCard == peerManager.playerHand[0] {
                                    return 0.5 // Carta sinistra selezionata, in secondo piano
                                } else if index == 1 && draggedCard == peerManager.playerHand[0] {
                                    return 0.25 // Carta centrale se selezionata, in terzo piano
                                } else {
                                    return 0 // Carta normale
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
                                .gesture(
                                    DragGesture(minimumDistance: 0, coordinateSpace: .global) // Utilizza il coordinateSpace globale per un movimento fluido
                                        .onChanged { gesture in
                                            if draggedCard == nil {
                                                draggedCard = card
                                            }
                                            cardOffset = gesture.translation
                                        }
                                        .onEnded { gesture in
                                            if gesture.translation.height < -50 {
                                                // Solo se il gesto è verso l'alto e abbastanza lungo
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    cardOffset = CGSize(width: 0, height: -200) // Sposta la carta verso l'alto fuori dallo schermo
                                                }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    if peerManager.currentPlayer == 0 && peerManager.isHost || peerManager.currentPlayer == 1 && peerManager.isClient {
                                                        peerManager.playCard(card: card) // Gioca la carta
                                                    }
                                                    // Resetta stato dopo l'animazione
                                                    draggedCard = nil
                                                    cardOffset = .zero
                                                }
                                            } else {
                                                // Se il gesto non è valido, annulla l'animazione e resetta la posizione
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    cardOffset = .zero
                                                }
                                                draggedCard = nil
                                            }
                                        }
                                )
                                .disabled((peerManager.currentPlayer == 1 && peerManager.isHost) || (peerManager.currentPlayer == 0 && peerManager.isClient))
                                .offset(draggedCard == card ? cardOffset : .zero)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, bottomPaddingHand) // Padding inferiore per le carte nella mano
                }
            }
            
            if peerManager.blindMode && !peerManager.gameOver {
                if peerManager.isHost && peerManager.currentPlayer == 0 || peerManager.isClient && peerManager.currentPlayer == 1 {
                    Button(action: {
                        if !isRecording {
                            speechRecognizer.speakText("Registrazione attiva")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isRecording = true
                                speechRecognizer.startTranscribing()
                            }
                        }
                    }) {
                        Text("")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .padding()
                }
            }
        }
        .onChange(of: peerManager.currentPlayer) {
            if peerManager.blindMode && !peerManager.gameOver {
                if peerManager.isHost && peerManager.currentPlayer == 0 {
                    speechRecognizer.speakText("È il tuo turno")
                    speechRecognizer.stopTranscribing()
                    isRecording = false
                }
            }
        }
        .alert(isPresented: Binding(
            get: {
                return showPeerDisconnectedAlert && !peerManager.gameOver && !peerManager.blindMode
            },
            set: { _ in }
        )) {
            Alert(
                title: Text("Disconnessione"),
                message: Text("Il giocatore ha abbandonato la partita."),
                dismissButton: .default(Text("OK")) {
                    peerManager.reset()
                    backModality = true
                }
            )
        }
        .fullScreenCover(isPresented: $backModality) {
            ContentView().environmentObject(peerManager).environmentObject(speechRecognizer)
        }
        .onChange(of: peerManager.peerDisconnected) {
            if peerManager.peerDisconnected {
                speechRecognizer.stopTranscribing()
                if peerManager.blindMode {
                    speechRecognizer.speakText("Utente disconnesso")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        backModality = true
                    }
                } else {
                    showPeerDisconnectedAlert = true
                }
            }
        }
        .overlay(winnerOverlay)
    }
    
    @ViewBuilder
    private var winnerOverlay: some View {
        if peerManager.gameOver {
            ZStack {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    ShowWinnerView()
                }
                .frame(width: 370, height: 560)
                .padding(.top, 20)
                .padding(.bottom, 20)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 20)
            }
        }
    }
    
    private func chunkedArray<T>(array: [T], chunkSize: Int) -> [[T]] {
        return stride(from: 0, to: array.count, by: chunkSize).map {
            Array(array[$0 ..< Swift.min($0 + chunkSize, array.count)])
        }
    }
}
