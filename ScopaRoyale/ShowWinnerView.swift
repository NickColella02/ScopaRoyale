import SwiftUI

struct ShowWinnerView: View {
    @EnvironmentObject private var peerManager: MultiPeerManager // riferimento al peer manager
    @EnvironmentObject var speechRecognizer: SpeechRecognizer // riferimento allo speech recognizer
    @State private var showHomeView: Bool = false // true se l'utente clicca su termina partita e torna alla ContentView
    
    var body: some View {
        if peerManager.gameOver { // se la partita è terminata
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                VStack {
                    Image("results")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                    HStack { // mostra username e avatar del vincitore o un'avatar di default per il pareggio
                        if peerManager.winner == peerManager.myUsername {
                            showWinnerAvatar(username: peerManager.myUsername, avatarImage: peerManager.myAvatarImage, isWinner: peerManager.winner == peerManager.myUsername)
                        } else if peerManager.winner == peerManager.opponentName {
                            showWinnerAvatar(username: peerManager.opponentName, avatarImage: peerManager.opponentAvatarImage, isWinner: peerManager.winner == peerManager.opponentName)
                        } else if peerManager.winner == "Pareggio" {
                            showDrawAvatar(playerImage: peerManager.myAvatarImage, opponentImage: peerManager.opponentAvatarImage)
                        }
                    }
                    HStack { // mostra i punti totali dei 2 giocatori
                        TotalPointsView(title: peerManager.myUsername, score: peerManager.playerScore, isWinner: peerManager.playerScore > peerManager.opponentScore)
                        Spacer()
                        TotalPointsView(title: peerManager.opponentName, score: peerManager.opponentScore, isWinner: peerManager.opponentScore > peerManager.playerScore)
                    }
                    .padding(.horizontal)
                    ScoreGridView(peerManager: peerManager)
                        .padding(.horizontal)
                    
                    Button(action: { // bottone per terminare la partita e tornare alla ContentView
                        if peerManager.isHost { // se il server clicca su termina partita
                            peerManager.sendEndGameSignal() // invia un segnale notificando al client la fine della partita
                            peerManager.closeConnection() // chiude la connessione
                        }
                        showHomeView = true // ritorna alla ContentView
                    }) {
                        Text("Termina Partita")
                            .font(.system(size: 20, design: .default))
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                            .padding(.horizontal, 25)
                    }
                }
                .onAppear { // al caricamento della pagina
                    if peerManager.blindMode { // se è abilitata la blind mode
                        speechRecognizer.speakText("Il vincitore è \(peerManager.winner)") // pronuncia il vincitore
                    }
                }
            }
            .fullScreenCover(isPresented: $showHomeView) { // naviga alla ContentView quando si clicca su termina partita
                ContentView().environmentObject(peerManager)
            }
        }
    }
}

struct showWinnerAvatar: View {
    let username: String // username del vincitore
    let avatarImage: String // avatar del vincitore
    let isWinner: Bool
    
    var body: some View {
        VStack {
            Text(username)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.black)
            ZStack {
                if isWinner {
                    Image("winnerCrown")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170, height: 170)
                    Image(avatarImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 87, height: 87)
                        .clipShape(Circle())
                }
            }
        }
    }
}

struct showDrawAvatar: View {
    let playerImage: String
    let opponentImage: String
    
    var body: some View {
        VStack {
            ZStack {
                Image(playerImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .offset(x: -32, y: -41)
                    .zIndex(1)
                Image("draw")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170, height: 170)
                    .zIndex(0)
                Image(opponentImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .offset(x: 33, y: -9)
                    .zIndex(1)
            }
        }
        Text("")
            .font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(.black)
    }
}

struct ScoreGridView: View { // visualizza la descrizione dei punti fatti dai giocatori
    let peerManager: MultiPeerManager // riferimento al peer manager
    
    var body: some View {
        Grid {
            ForEach([
                ("Scope", peerManager.playerPoints.count, peerManager.opponentPoints.count, false),
                ("Carte prese", peerManager.cardTakenByPlayer.count, peerManager.cardTakenByOpponent.count, false),
                ("Settebello", peerManager.playerHasSettebello ? 1 : 0, peerManager.opponentHasSettebello ? 1 : 0, true),
                ("Carte oro", peerManager.playerCoinsCount, peerManager.opponentCoinsCount, false),
                ("Primera", peerManager.playerHasPrimera ? 1 : 0, peerManager.opponentHasPrimera ? 1 : 0, true)
            ], id: \.0) { (title, myScore, opponentScore, isBoolean) in
                ScoreParameterCellView(title: title, myScore: myScore, opponentScore: opponentScore, isBoolean: isBoolean)
            }
        }
        .padding(.horizontal, 15)
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
}

struct ScoreParameterCellView: View {
    let title: String
    let myScore: Int
    let opponentScore: Int
    let isBoolean: Bool
    
    var body: some View {
        HStack {
            VStack {
                Text(isBoolean ? (myScore == 1 ? "Sì" : "No") : "\(myScore)")
                    .font(.system(size: 20, design: .default))
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    .padding(3)
                    .frame(width: 50)
                    .background(myScore > opponentScore ? Color(red: 254 / 255, green: 189 / 255, blue: 2 / 255).opacity(0.8) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            Spacer()
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .frame(width: 120)
            
            Spacer()
            
            VStack {
                Text(isBoolean ? (opponentScore == 1 ? "Sì" : "No") : "\(opponentScore)")
                    .font(.system(size: 20, design: .default))
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    .padding(3)
                    .frame(width: 50)
                    .background(opponentScore > myScore ? Color(red: 254 / 255, green: 189 / 255, blue: 2 / 255).opacity(0.8) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

struct TotalPointsView: View {
    let title: String
    let score: Int
    let isWinner: Bool
    
    var body: some View {
        VStack(spacing: 4) { // Aumentato spacing per migliorare leggibilità
            Text("\(title): \(score)")
                .font(.title3) // Aumentato rispetto a .headline
                .fontWeight(.bold)
                .foregroundStyle(.black)
        }
        .padding(.horizontal, 20)
    }
}

struct ShowWinnerView_Previews: PreviewProvider {
    static var previews: some View {
        let peerManager = MultiPeerManager()
        let speechRecognizer = SpeechRecognizer(peerManager: MultiPeerManager())
        ShowWinnerView()
            .environmentObject(peerManager)
            .environmentObject(speechRecognizer)
            .previewLayout(.sizeThatFits) // Regola il layout della preview
    }
}
