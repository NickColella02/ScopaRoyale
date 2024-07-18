import SwiftUI
import AVFAudio
import MultipeerConnectivity

struct Hands: Codable { // struttura dati contenente le mani dei giocatori
    let playerHand: [Card] // mano del giocatore
    let opponentHand: [Card] // mano dell'avversario
}

struct CardsTaken: Codable { // struttura dati contenente i mazzi di carte presi dai giocatori
    let playerCards: [Card] // mazzo di carte prese dal giocatore
    let opponentCards: [Card] // mazzo di carte prese dall'avversario
}

struct Points: Codable { // struttura dati contenente i mazzi di scope fatte dai giocatori
    let playerPoints: [Card] // scope fatte dal giocatore
    let opponentPoints: [Card] // scope fatte dell'avversario
}

struct Coins: Codable { // struttura dati contenente il numero di carte oro prese dai giocatori
    let playerCoins: Int // carte oro del giocatore
    let opponentCoins: Int // carte oro dell'avversario
}

struct Scores: Codable { // struttura dati contenente i punteggi dei giocatori
    let playerScore: Int // punteggio del giocatore
    let opponentScore: Int // punteggio dell'avversario
    let winner: String // vincitore della partita
}

struct Primera: Codable { // struttura dati per indicare quale giocatore ha fatto la primera (più sette)
    let playerHasPrimera: Bool // true se il giocatore ha la primera
    let opponentHasPrimera: Bool // true se l'avversario ha la primera
}

struct Settebello: Codable { // struttura dati per indicare quale giocatore ha preso il settebello (sette denari)
    let playerHasSettebello: Bool // true se il giocatore ha il settebello
    let opponentHasSettebello: Bool // true se l'avversario ha il settebello
}

struct ScopaAnimation: Codable { // struttura dati per indicare chi ha fatto scopa e visualizzare l'animazione
    let showScopaAnimation: Bool // il giocatore ha fatto scopa
    let showOpponentScopaAnimation: Bool // l'avversario ha fatto scopa
}

struct SettebelloAnimation: Codable { // struttura dati per indicare chi ha preso il settebello e visualizzare l'animazione
    let showSettebelloAnimation: Bool // il giocatore ha preso il settebello
    let showOpponentSettebelloAnimation: Bool // l'avversario ha preso il settebello
}

class MultiPeerManager: NSObject, ObservableObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    private let serviceType = "ScopaRoyale"
    private let peerID = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private let synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    var myUsername: String = ""
    var neededPlayers: Int = 0 // numero di giocatori necessari
    var lastPlayer: Int = 1 // indice dell'ultimo giocatore che ha preso carte dal tavolo
    var isHost: Bool = false // true se è l'advertiser
    var isClient: Bool = false // true se è l'host
    var playerCoinsCount: Int = 0 // numero di carte oro prese dal giocatore
    var opponentCoinsCount: Int = 0 // numero di carte oro prese dall'avversario
    var playerHasSettebello: Bool = false // true se il giocatore ha il settebello tra le carte prese
    var opponentHasSettebello: Bool = false // true se l'avversario ha il settebello tra le carte prese
    var playerHasPrimera: Bool = false // true se il giocatore ha fatto la primera
    var opponentHasPrimera: Bool = false // true se l'avversario ha fatto la primera
    var playerScore: Int = 0 // punteggio del giocatore
    var opponentScore: Int = 0 // punteggio dell'avversario
    var winner: String = "" // nome del giocatore che ha vinto
    
    @Published var blindMode: Bool { // vero se l'utente ha abilitato la blind mode
        didSet {
            UserDefaults.standard.set(blindMode, forKey: "blindMode")
        }
    }
    @Published var opponentName: String = "" // nome dell'avversario (browser)
    @Published var lobbyName: String = "" // nome della lobby
    @Published var startGame: Bool = false // true se la partita è iniziata
    @Published var peerDisconnected: Bool = false // true se un peer si è disconnesso
    @Published var connectedPeers: [MCPeerID] = [] // lista di peer connessi
    @Published var deck: [Card] = [] // mazzo di carte iniziale
    @Published var tableCards: [Card] = [] // carte presenti sul tavolo
    @Published var playerHand: [Card] = [] // carte nella mano del giocatore
    @Published var opponentHand: [Card] = [] // carte nella mano dell'avversario
    @Published var cardTakenByPlayer: [Card] = [] // mazzo di carte prese dal giocatore
    @Published var cardTakenByOpponent: [Card] = [] // mazzo di carte prese dall'avversario
    @Published var playerPoints: [Card] = [] // scope del giocatore
    @Published var opponentPoints: [Card] = [] // scope dell'avversario
    @Published var currentPlayer: Int = 1 // indice del giocatore corrente (0 per l'advertiser e 1 per il browser)
    @Published var gameOver: Bool = false // true quando la partita finisce
    @Published var myAvatarImage: String = (UserDefaults.standard.string(forKey: "selectedAvatar")) ?? "defaultUser" // nome dell avatar che ha scelto l'utente
    @Published var opponentAvatarImage: String = ""//nome dell avatar che ha scelto l opponent
    @Published var showScopaAnimation: Bool = false // true se il giocatore ha fatto scopa e va mostrata l'animazione
    @Published var showOpponentScopaAnimation: Bool = false // true se l'avversario ha fatto scopa e va mostrata l'animazione
    @Published var showSettebelloAnimation: Bool = false // true se il giocatore ha preso il settebello e va mostrata l'animazione
    @Published var showOpponentSettebelloAnimation: Bool = false // true se l'avversario ha preso il settebello e va mostrata l'animazione
    @Published var showGameOverAnimation: Bool = false // true se la partita è terminata
    
    override init() {
        self.blindMode = UserDefaults.standard.bool(forKey: "blindMode")
        super.init()
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        self.session.delegate = self
    }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                    self.peerDisconnected = false
                    self.sendUsername(username: self.myUsername)
                    self.sendLobbyName()
                    self.sendOpponentAvatarImage(self.myAvatarImage)
                }
            case .notConnected:
                self.peerDisconnected = true
                if let index = self.connectedPeers.firstIndex(of: peerID) {
                    self.connectedPeers.remove(at: index)
                }
                self.opponentName = ""
            default:
                break
            }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 5)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        guard let index = connectedPeers.firstIndex(of: peerID) else { return }
        DispatchQueue.main.async {
            self.connectedPeers.remove(at: index)
            self.peerDisconnected = true
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            if let receivedString = String(data: data, encoding: .utf8) {
                if receivedString == "START_GAME" { // riceve il segnale di inizio partita
                    self.startGame = true // segnala l'inizio della partita
                    self.gameOver = false // mette a false per non mostrare la pagina dei punteggi
                    self.showGameOverAnimation = false // pulisce l'animazione di fine partita
                    if self.blindMode {
                        DispatchQueue.global(qos: .userInitiated).async {
                            self.speakText("È il tuo turno")
                        }
                    }
                } else if receivedString.starts(with: "Lobby:") { // riceve il nome della lobby
                    self.lobbyName = String(receivedString.dropFirst(6))
                } else if receivedString.starts(with: "Deck:") { // riceve il mazzo di carte iniziali
                    let data = data.dropFirst(5)
                    self.deck = [Card].fromJSON(data)!
                } else if receivedString.starts(with: "PlayersHands:") { // riceve le mani dei giocatori
                    self.handlePlayersHandsData(data.dropFirst(13))
                } else if receivedString.starts(with: "CardsTaken:") { // riceve i mazzi di carte prese dai giocatori
                    self.handleCardsTakenData(data.dropFirst(11))
                } else if receivedString.starts(with: "PlayersPoints:") { // riceve le scope fatte dai giocatori
                    self.handlePlayersPointsData(data.dropFirst(14))
                } else if receivedString.starts(with: "ScopaAnimation:") { // riceve la notifica che l'avversario ha fatto scopa
                    self.handleScopaMessage(data.dropFirst(15))
                } else if receivedString.starts(with: "Settebello:") { // riceve la notifica che l'avversario ha preso il settebello
                    self.handleSettebelloData(data.dropFirst(11))
                } else if receivedString.starts(with: "SettebelloAnimation:") {
                    self.handleSettebelloMessage(data.dropFirst(20))
                } else if receivedString.starts(with: "Primera:") { // riceve chi ha fatto la primera
                    self.handlePrimeraData(data.dropFirst(8))
                } else if receivedString.starts(with: "PlayersCoins:") { // riceve le carte oro prese dai giocatori
                    self.handlePlayersCoinsData(data.dropFirst(13))
                } else if receivedString.starts(with: "Table:") { // riceve le carte del tavolo
                    let data = data.dropFirst(6)
                    self.tableCards = [Card].fromJSON(data)!
                } else if receivedString.starts(with: "CurrentPlayer:") { // riceve la notifica del cambio turno
                    let data = data.dropFirst(14)
                    let dataString = String(data: data, encoding: .utf8)
                    self.currentPlayer = Int(dataString!)!
                } else if receivedString.starts(with: "GameOver:") { // riceve il segnale di fine partita
                    self.gameOver = true
                    self.startGame = false
                } else if receivedString.starts(with: "GameOverAnimation:") {
                    self.showGameOverAnimation = true
                } else if receivedString.starts(with: "PlayersScores:") { // riceve i punteggi dei giocatori
                    self.handlePlayersScoresData(data.dropFirst(14))
                } else if receivedString.starts(with: "IsAvatar:") { // riceve gli avatar dei giocatori
                    if String(receivedString.dropFirst(9)) != "" {
                        self.opponentAvatarImage = String(receivedString.dropFirst(9))
                    }
                } else { // riceve l'username dell'avversario
                    self.opponentName = receivedString
                }
            }
        }
    }

    // Funzioni helper per la decodifica

    private func handlePlayersHandsData(_ jsonData: Data) {
        do {
            let hands = try JSONDecoder().decode(Hands.self, from: jsonData)
            self.playerHand = hands.playerHand
            self.opponentHand = hands.opponentHand
        } catch {
            print("Errore nella decodifica dei dati Hands: \(error.localizedDescription)")
        }
    }

    private func handleCardsTakenData(_ jsonData: Data) {
        do {
            let cardsTaken = try JSONDecoder().decode(CardsTaken.self, from: jsonData)
            self.cardTakenByPlayer = cardsTaken.playerCards
            self.cardTakenByOpponent = cardsTaken.opponentCards
        } catch {
            print("Errore nella decodifica dei dati CardsTaken: \(error.localizedDescription)")
        }
    }

    private func handlePlayersPointsData(_ jsonData: Data) {
        do {
            let points = try JSONDecoder().decode(Points.self, from: jsonData)
            self.playerPoints = points.playerPoints
            self.opponentPoints = points.opponentPoints
        } catch {
            print("Errore nella decodifica dei dati Points: \(error.localizedDescription)")
        }
    }

    private func handlePrimeraData(_ jsonData: Data) {
        do {
            let primera = try JSONDecoder().decode(Primera.self, from: jsonData)
            self.playerHasPrimera = primera.playerHasPrimera
            self.opponentHasPrimera = primera.opponentHasPrimera
        } catch {
            print("Errore nella decodifica dei dati Primera: \(error.localizedDescription)")
        }
    }

    private func handleScopaMessage(_ jsonData: Data) {
        do {
            let data = try JSONDecoder().decode(ScopaAnimation.self, from: jsonData)
            self.showScopaAnimation = data.showScopaAnimation
            self.showOpponentScopaAnimation = data.showOpponentScopaAnimation
            if self.showOpponentScopaAnimation && self.blindMode {
                DispatchQueue.global(qos: .userInitiated).async {
                    self.speakText("L'avversario ha fatto scopa")
                }
            }
        } catch {
            print("Errore nella decodifica dei dati scopa animation: \(error.localizedDescription)")
        }
    }
    
    private func handleSettebelloMessage(_ jsonData: Data) {
        do {
            let data = try JSONDecoder().decode(SettebelloAnimation.self, from: jsonData)
            self.showSettebelloAnimation = data.showSettebelloAnimation
            self.showOpponentSettebelloAnimation = data.showOpponentSettebelloAnimation
            if self.showOpponentSettebelloAnimation && self.blindMode {
                DispatchQueue.global(qos: .userInitiated).async {
                    self.speakText("L'avversario ha preso il settebello")
                }
            }
        } catch {
            print("Errore nella decodifica dei dati settebello animation: \(error.localizedDescription)")
        }
    }
    
    private func handleSettebelloData(_ jsonData: Data) {
        do {
            let settebello = try JSONDecoder().decode(Settebello.self, from: jsonData)
            self.playerHasSettebello = settebello.playerHasSettebello
            self.opponentHasSettebello = settebello.opponentHasSettebello
        } catch {
            print("Errore nella decodifica dei dati Settebello: \(error.localizedDescription)")
        }
    }

    private func handlePlayersCoinsData(_ jsonData: Data) {
        do {
            let coins = try JSONDecoder().decode(Coins.self, from: jsonData)
            self.playerCoinsCount = coins.playerCoins
            self.opponentCoinsCount = coins.opponentCoins
        } catch {
            print("Errore nella decodifica dei dati Coins: \(error.localizedDescription)")
        }
    }

    private func handlePlayersScoresData(_ jsonData: Data) {
        do {
            let scores = try JSONDecoder().decode(Scores.self, from: jsonData)
            self.playerScore = scores.playerScore
            self.opponentScore = scores.opponentScore
            self.winner = scores.winner
        } catch {
            print("Errore nella decodifica dei dati Points: \(error.localizedDescription)")
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }

    func startHosting(lobbyName: String, numberOfPlayers: Int, username: String) { // eseguito dall'advertiser
        self.neededPlayers = numberOfPlayers
        self.lobbyName = lobbyName
        self.myUsername = username
        self.isHost = true // sono l'advertiser
        self.isClient = false // non sono il browser
        self.advertiser = MCNearbyServiceAdvertiser(peer: self.peerID, discoveryInfo: nil, serviceType: self.serviceType)
        self.advertiser?.delegate = self
        self.advertiser?.startAdvertisingPeer()
    }

    func joinSession() { // eseguito dal browser
        self.browser = MCNearbyServiceBrowser(peer: self.peerID, serviceType: self.serviceType)
        self.browser?.delegate = self
        self.isClient = true // sono il browser
        self.isHost = false // non sono l'advertiser
        self.browser?.startBrowsingForPeers()
    }

    func sendUsername(username: String) { // usato dal browser per inviare il suo username all'advertiser
        self.myUsername = username
        let data = "\(myUsername)".data(using: .utf8)
        do {
            try session.send(data!, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio username: \(error.localizedDescription)")
        }
    }

    func sendLobbyName() { // usato dall'advertiser per inviare il nome della lobby al browser
        let data = "Lobby:\(lobbyName)".data(using: .utf8)
        do {
            try session.send(data!, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio nome lobby: \(error.localizedDescription)")
        }
    }

    func sendStartGameSignal() { // segnala l'inizio della partita ai giocatori
        self.gameOver = false
        self.startGame = true
        self.playerHasSettebello = false
        self.opponentHasSettebello = false
        self.playerHasPrimera = false
        self.opponentHasPrimera = false
        self.showGameOverAnimation = false
        self.deck = []
        self.opponentHand = []
        self.playerHand = []
        self.tableCards = []
        self.currentPlayer = 1
        self.lastPlayer = 1
        createDeck() // crea il mazzo iniziale
        placeTableCards() // posiziona le carte sul tavolo
        giveCardsToPlayers() // assegna le mani ai giocatori
        sendDeck() // aggiorna il mazzo iniziale
        let startData = "START_GAME".data(using: .utf8)
        do {
            try session.send(startData!, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio segnale inizio partita: \(error.localizedDescription)")
        }
        self.cardTakenByPlayer = []
        self.cardTakenByOpponent = []
        self.playerPoints = []
        self.opponentPoints = []
        sendCardsTaken() // invia i mazzi contenenti le carte prese
        sendPlayersPoints() // invia i mazzi contenenti le scope dei giocatori
    }
    
    func sendCardsTaken() { // invia il mazzo delle carte prese all'avversario
        let cardsTaken = CardsTaken(playerCards: cardTakenByOpponent, opponentCards: cardTakenByPlayer)
        do {
            let data = try JSONEncoder().encode(cardsTaken)
            let prefixedData = "CardsTaken:".data(using: .utf8)! + data
            try session.send(prefixedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio carte prese dai giocatori: \(error.localizedDescription)")
        }
    }
        
    func sendPlayersPoints() { // invia il mazzo delle scope fatte all'avversario
        let points = Points(playerPoints: opponentPoints, opponentPoints: playerPoints)
        do {
            let data = try JSONEncoder().encode(points)
            let prefixedData = "PlayersPoints:".data(using: .utf8)! + data
            try session.send(prefixedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio scope dei giocatori: \(error.localizedDescription)")
        }
    }
    
    func sendPlayersCoins() {
        let coins = Coins(playerCoins: opponentCoinsCount, opponentCoins: playerCoinsCount)
        do {
            let data = try JSONEncoder().encode(coins)
            let prefixedData = "PlayersCoins:".data(using: .utf8)! + data
            try session.send(prefixedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio denari dei giocatori: \(error.localizedDescription)")
        }
    }
    
    func sendPrimera() {
        let primera = Primera(playerHasPrimera: self.opponentHasPrimera, opponentHasPrimera: self.playerHasPrimera)
        do {
            let data = try JSONEncoder().encode(primera)
            let prefixedData = "Primera:".data(using: .utf8)! + data
            try session.send(prefixedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio primera: \(error.localizedDescription)")
        }
    }
    
    func sendScopaAnimation() {
        let message = ScopaAnimation(showScopaAnimation: self.showOpponentScopaAnimation, showOpponentScopaAnimation: self.showScopaAnimation)
        do {
            let data = try JSONEncoder().encode(message)
            let prefixedData = "ScopaAnimation:".data(using: .utf8)! + data
            try session.send(prefixedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio showScopaAnimation: \(error.localizedDescription)")
        }
    }
    
    func sendSettebelloAnimation() {
        let message = SettebelloAnimation(showSettebelloAnimation: self.showOpponentSettebelloAnimation, showOpponentSettebelloAnimation: self.showSettebelloAnimation)
        do {
            let data = try JSONEncoder().encode(message)
            let prefixedData = "SettebelloAnimation:".data(using: .utf8)! + data
            try session.send(prefixedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio showScopaAnimation: \(error.localizedDescription)")
        }
    }
    
    func sendSettebello() {
        let settebello = Settebello(playerHasSettebello: self.opponentHasSettebello, opponentHasSettebello: self.playerHasSettebello)
        do {
            let data = try JSONEncoder().encode(settebello)
            let prefixedData = "Settebello:".data(using: .utf8)! + data
            try session.send(prefixedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio settebello: \(error.localizedDescription)")
        }
    }
        
    func createDeck() { // crea il deck e lo mescola
        let values: [String] = [ // possibili valori per le carte
            "asso", "due", "tre", "quattro", "cinque", "sei", "sette", "otto", "nove", "re"
        ]
        let seeds: [String] = [ // possibili semi per le carte
            "denari", "coppe", "spade", "bastoni"
        ]
        for seed in seeds { // inserisce ogni carta nel mazzo iniziale
            for value in values {
                let card = Card(value: value, seed: seed)
                deck.append(card)
            }
        }
        deck = deck.shuffled() // mescola il mazzo
    }
    
    func sendDeck() { // invia il deck al browser
        let deckData = deck.toJSON()
        let deckMessage = "Deck:".data(using: .utf8)! + deckData!
        do {
            try session.send(deckMessage, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio mazzo: \(error.localizedDescription)")
        }
    }

    func giveCardsToPlayers() { // assegna 3 carte ad ogni giocatore
        for _ in 0..<3 {
            if let playerCard = deck.first { // mano del giocatore
                self.playerHand.append(playerCard)
                self.deck.removeFirst()
            }
            if let opponentCard = deck.first { // mano dell'avversario
                self.opponentHand.append(opponentCard)
                self.deck.removeFirst()
            }
        }
        sendCardsToPlayers() // estrae le carte e le inserisce nelle mani dei giocatori
    }
    
     func avatarImage(for avatarName: String?) -> Image { // usata per visualizzare l'avatar dell'utente o uno di default se non è stato scelto
        if let avatarName = avatarName {
            return Image(avatarName)
        } else {
            return Image(systemName: "person.circle")
        }
    }
    
    func sendCardsToPlayers() { // invia le carte delle mani dei giocatori
        let hand = Hands(playerHand: self.opponentHand, opponentHand: self.playerHand)
        do {
            let data = try JSONEncoder().encode(hand)
            let prefixedData = "PlayersHands:".data(using: .utf8)! + data
            try session.send(prefixedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio mani dei giocatori: \(error.localizedDescription)")
        }
    }
        
    func placeTableCards() { // estrae le carte del tavolo
        for _ in 0..<4 {
            if let card = deck.first {
                self.tableCards.append(card)
                self.deck.removeFirst()
            }
        }
        sendTableCards() // invia le carte del tavolo
    }
    
    func sendTableCards() { // invia le carte del tavolo al giocatore
        let tableCards = tableCards.toJSON()
        let message = "Table:".data(using: .utf8)! + tableCards!
        do {
            try session.send(message, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio tavolo: \(error.localizedDescription)")
        }
    }
    
    func sendTurnChange() { // notifica il cambio del turno
        self.currentPlayer = 1 - self.currentPlayer
        let turnData = "CurrentPlayer:\(self.currentPlayer)".data(using: .utf8)!
        do {
            try self.session.send(turnData, toPeers: self.session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio aggiornamento turno: \(error.localizedDescription)")
        }
    }
    
    func sendGameOverMessage() {
        let message = "GameOverAnimation:".data(using: .utf8)
        do {
            try session.send(message!, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore notifica animazione fine partita: \(error.localizedDescription)")
        }
    }
    
    func sendEndGameSignal() { // notifica la fine della partita
        let endGame = "GameOver:\(gameOver)".data(using: .utf8)!
        do {
            try session.send(endGame, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore notifica fine partita: \(error.localizedDescription)")
        }
    }
    
    func sendPlayersScores() { // invia i punteggi finali all'avversario
        let scores = Scores(playerScore: opponentScore, opponentScore: playerScore, winner: self.winner)
        do {
            let data = try JSONEncoder().encode(scores)
            let prefixedData = "PlayersScores:".data(using: .utf8)! + data
            try session.send(prefixedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore invio punteggi dei giocatori: \(error.localizedDescription)")
        }
    }
        
     func sendOpponentAvatarImage(_ Image: String) { // invia l'avatar dell'avversario
        let avatar = "IsAvatar:\(Image)".data(using: .utf8)!
        do {
            try session.send(avatar, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Errore notifica avatar: \(error.localizedDescription)")
        }
    }

    func playCard(card: Card) { // gestisce la mossa di un giocatore
        DispatchQueue.main.async { [self] in
            var cardsToTake: [Card] = [] // carte prese dal giocatore con una mossa
            if let index = self.playerHand.firstIndex(of: card) { // rimuove la carta dalla mano del giocatore
                playerHand.remove(at: index)
            }
            var shortestCombination: [Card]? = nil // combinazione di carte da prendere più breve
            if !tableCards.isEmpty { // controllo che il tavolo non sia vuoto
                for length in 1...tableCards.count { // cerco, se possibile, la combinazione di carte più breve che il giocatore può prendere
                    for combination in tableCards.combinations(length: length) {
                        let combinationValues = combination.map { card in
                            return numericValue(for: card.value) ?? 0
                        }
                        if combinationValues.reduce(0, +) == numericValue(for: card.value) ?? 0 {
                            if shortestCombination == nil || combination.count < shortestCombination!.count {
                                shortestCombination = combination
                            }
                        }
                    }
                }
            }
            
            if tableCards.isEmpty || shortestCombination == nil { // se il tavolo è vuoto o non c'è una combinazione valida
                tableCards.append(card) // aggiungi la carta giocata al tavolo
                if blindMode {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.speakText("Hai giocato la carta \(card.value) di \(card.seed)")
                    }
                }
            } else if let validCombination = shortestCombination { // se ha trovato una combinazione di carte da prendere
                lastPlayer = currentPlayer // aggiorno l'ultimo giocatore che ha effettuato una presa
                cardsToTake = validCombination // salvo la combinazione
                for cardToTake in cardsToTake {
                    if let index = tableCards.firstIndex(of: cardToTake) { // rimuove le carte prese dal tavolo
                        tableCards.remove(at: index)
                    }
                    if blindMode {
                        DispatchQueue.global(qos: .userInitiated).async {
                            self.speakText("Hai preso la carta \(cardToTake.value) di \(cardToTake.seed)")
                        }
                    }
                }
                if tableCards.isEmpty { // se il giocatore prende le ultime carte del tavolo ha fatto scopa
                    playerPoints.append(card)
                    if blindMode {
                        DispatchQueue.global(qos: .userInitiated).async {
                            self.speakText("Hai fatto scopa")
                        }
                    } else {
                        self.showScopaAnimation = true
                        sendScopaAnimation()
                    }
                    sendPlayersPoints()
                }
            }
            sendTableCards() // notifico l'aggiornamento del tavolo
            if !cardsToTake.isEmpty {
                cardsToTake.append(card)
                cardTakenByPlayer.append(contentsOf: cardsToTake)
                if cardsToTake.contains(Card(value: "sette", seed: "denari")) {
                    if blindMode {
                        DispatchQueue.global(qos: .userInitiated).async {
                            self.speakText("Hai preso il settebello")
                        }
                    } else {
                        self.showSettebelloAnimation = true
                        sendSettebelloAnimation()
                    }
                }
                sendCardsTaken() // notifica l'aggiornamento dei mazzi delle prese
            }
            sendCardsToPlayers() // invia le carte alle mani dei giocatori
            sendTurnChange() // aggiorna il turno
            
            if playerHand.isEmpty && opponentHand.isEmpty { // controlla se entrambi i giocatori hanno terminato le carte in mano
                if !deck.isEmpty { // se ci sono altre carte
                    giveCardsToPlayers() // invia le carte alle mani dei giocatori
                    sendDeck() // invia il mazzo iniziale aggiornato
                } else { // altrimenti si controllano i punteggi per decretare il vincitore
                    playerScore = 0 // azzera i punteggi del giocatore
                    opponentScore = 0 // azzera i punteggi dell'avversario
                    if !tableCards.isEmpty { // aggiunge tutte le carte del tavolo al mazzo delle carte prese del giocatore che ha fatto l'ultima presa
                        if lastPlayer == 0 {
                            cardTakenByPlayer += tableCards
                        } else {
                            cardTakenByOpponent += tableCards
                        }
                        tableCards.removeAll() // rimuove tutte le carte dal tavolo in una volta sola
                        sendTableCards() // notifico il liberamento del tavolo
                    }
                    
                    // assegno un punto a chi ha preso più carte
                    if cardTakenByPlayer.count > cardTakenByOpponent.count {
                        playerScore += 1
                    } else if cardTakenByPlayer.count < cardTakenByOpponent.count {
                        opponentScore += 1
                    }
                    
                    // assegno un punto per ogni scopa fatta dai giocatori
                    playerScore += playerPoints.count
                    opponentScore += opponentPoints.count
                    
                    // assegno un punto a chi ha il 7 denari
                    if cardTakenByPlayer.contains(Card(value: "sette", seed: "denari")) || playerPoints.contains(Card(value: "sette", seed: "denari")) {
                        playerHasSettebello = true
                        playerScore += 1
                    } else {
                        opponentHasSettebello = true
                        opponentScore += 1
                    }
                    
                    // assegno un punto a chi ha più carte denari nel proprio mazzo
                    playerCoinsCount = cardTakenByPlayer.filter{$0.seed == "denari"}.count
                    opponentCoinsCount = 10 - playerCoinsCount
                    if playerCoinsCount > opponentCoinsCount {
                        playerScore += 1
                    } else if playerCoinsCount < opponentCoinsCount {
                        opponentScore += 1
                    }
                    
                    // assegno un punto a chi ha completato la "primera" (più sette)
                    let playerSevenCount = cardTakenByPlayer.filter { $0.value == "sette" }.count
                    let opponentSevenCount = 4 - playerSevenCount
                    if playerSevenCount > opponentSevenCount {
                        playerHasPrimera = true
                        playerScore += 1
                    } else if playerSevenCount < opponentSevenCount {
                        opponentHasPrimera = true
                        opponentScore += 1
                    }
                    
                    // decreto il vincitore
                    if playerScore > opponentScore {
                        winner = myUsername
                    } else if playerScore < opponentScore {
                        winner = opponentName
                    } else {
                        winner = "Pareggio"
                    }
                    sendSettebello() // invia chi ha preso il settebello
                    sendPrimera() // invia chi ha fatto la primera
                    sendPlayersScores() // invio i punteggi ai giocatori
                    sendPlayersCoins() // invia le carte oro prese dai giocatori
                    sendCardsTaken() // invia le carte prese dai giocatori
                    if blindMode {
                        DispatchQueue.global(qos: .userInitiated).async {
                            self.speakText("Partita terminata")
                        }
                    } else {
                        self.showGameOverAnimation = true // termina la partita
                    }
                    sendGameOverMessage() // notifica la fine della partita
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.gameOver = true // termina la partita
                        self.showGameOverAnimation = false
                        self.sendEndGameSignal() // notifica la fine della partita
                    }
                }
            }
        }
    }
    
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "it-IT")
        utterance.pitchMultiplier = 1.0
        utterance.rate = 0.5
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .mixWithOthers, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Errore nella configurazione dell'AVAudioSession: \(error.localizedDescription)")
        }
        synthesizer.speak(utterance)
    }
    
    func closeConnection() {
        self.connectedPeers.removeAll()
        self.advertiser?.stopAdvertisingPeer()
        self.browser?.stopBrowsingForPeers()
        self.session.disconnect()
        reset()
    }
    
    func reset() {
        self.lobbyName = ""
        sendLobbyName()
        sendUsername(username: "")
        sendOpponentAvatarImage("")
        self.opponentName = ""
        self.opponentAvatarImage = ""
        self.peerDisconnected = false
        self.playerHasSettebello = false
        self.opponentHasSettebello = false
        self.playerHasPrimera = false
        self.opponentHasPrimera = false
        self.showGameOverAnimation = false
        self.deck = []
        self.opponentHand = []
        self.playerHand = []
        self.tableCards = []
        self.cardTakenByPlayer = []
        self.cardTakenByOpponent = []
        self.playerPoints = []
        self.opponentPoints = []
        self.playerScore = 0
        self.opponentScore = 0
        self.currentPlayer = 1
        self.lastPlayer = 1
    }
}
