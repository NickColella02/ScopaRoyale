import Speech
import SwiftUI
import Foundation

public class SwiftUISpeech: ObservableObject{
    @EnvironmentObject private var peerManager: MultiPeerManager
    public let verbi: [String] = [ // verbi da riconoscere per il comando vocale del voice over
        "Gioca",
        "Butta",
        "Lancia"
    ]
    
    public let semi: [String] = [ // possibili parole attribuibili ai semi delle carte (compresi sinonimi)
        "bastoni",
        "denari",
        "denaro",
        "spade",
        "spada",
        "coppe",
        "coppa",
        "oro"
    ]
    
    public let valori: [String] = [ // possibili parole attribuibili ai valori delle carte (compresi sinonimi)
        "uno",
        "asso",
        "due",
        "tre",
        "quattro",
        "cinque",
        "sei",
        "sette",
        "otto",
        "lotto",
        "nove",
        "dieci",
        "re",
        "cavallo",
        "fante"
    ]
    
    let separatori: [String] = [" ", "il", "lo","la", "di", "l'", "le", "un"] // parole da ignorare nel riconoscimento vocale
    
    var stringa = ""
    @Published var isRecording: Bool = false // vero se l'utente sta utilizzando il voice over
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "it-IT")) // riconoscitore di lingua italiana
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let authStat = SFSpeechRecognizer.authorizationStatus()
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    public var outputText: String = ""
    public var outputCart: String = ""
    
    init() {
        // Requests auth from User
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    break
                case .denied:
                    break
                case .restricted:
                    break
                case .notDetermined:
                    break
                @unknown default:
                    break
                }
            }
        }
        
        recognitionTask?.cancel()
        self.recognitionTask = nil
    }
    
    
    func startRecording() { // starts the recording sequence
        
        outputText = ""
        
        // Configure the audio session for the app
        let audioSession = AVAudioSession.sharedInstance()
        let inputNode = audioEngine.inputNode
        
        // try catch to start audio session
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("ERROR: - Audio Session Failed!")
        }
        
        // Configure the microphone input and request auth
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("ERROR: - Audio Engine failed to start")
        }
        
        // Create and configure the speech recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        // Create a recognition task for the speech recognition session
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                // Update the text view with the results
                self.outputText = result.bestTranscription.formattedString
                self.recognizeCommand(command: self.outputText)
                //self.processCommand(command: self.outputText)
            }
            
            if error != nil {
                // Stop recognizing speech if there is a problem
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
    }
    
    func stopRecording() { // end recording
        audioEngine.stop()
        recognitionRequest?.endAudio()
        self.audioEngine.inputNode.removeTap(onBus: 0)
        self.recognitionTask?.cancel()
        self.recognitionTask = nil
    }
    
    func getSpeechStatus() -> String { // gets the status of authorization
        switch authStat {
        case .authorized:
            return "Authorized"
        case .notDetermined:
            return "Not yet Determined"
        case .denied:
            return "Denied - Close the App"
        case .restricted:
            return "Restricted - Close the App"
        @unknown default:
            return "ERROR: No Status Defined"
        }
    }
    
    private func validateCommand(Value: String, Seed: String) { // controlla che la carta da giocare sia effettivamente presente nella mano del giocatore
        let cardValue = Card(value: Value, seed: Seed)
        if peerManager.playerHand.contains(cardValue) { // se la carta è nella mano del giocatore
            print("Hai giocato la carta \(Value) di \(Seed)")
            peerManager.playCard(card: cardValue)
        } else { // se la carta non è nella mano del giocatore
            print("Carta non trovata o non valida")
            
        }
    }

    private func recognizeCommand(command: String) {
        for separatore in separatori {
                stringa = command.replacingOccurrences(of: separatore, with: "")
            }
        
        var isVerbFound: Bool = false // vero se la frase riconosciuta contiene uno dei verbi
        var isSeedFound: Bool = false // vero se la frase riconosciuta contiene uno dei semi
        var isValueFound: Bool = false // vero se la frase riconosciuta contiene uno dei valori
        var foundValue: String? // valore riconosciuto
        var foundSeed: String? // seme riconosciuto

        for verbo in verbi { // controlla che la frase riconosciuta contenga uno dei verbi
            if stringa.contains(verbo) {
                isVerbFound = true
                break
            }
        }
        
        for seme in semi { // controlla che la frase riconosciuta contenga uno dei semi
            if stringa.contains(seme) {
                isSeedFound = true
                foundSeed = seme
                break
            }
        }
        
        for valore in valori { // controlla che la frase riconosciuta contenga uno dei valori
            if stringa.contains(valore) {
                isValueFound = true
                foundValue = valore
                break
            }
        }
        
        if !isVerbFound { // gestisce il caso in cui non è riconosciuto il verbo
            print("Verbo non riconosciuto")
        }
        if !isSeedFound { // gestisce il caso in cui non è riconosciuto il seme
            print("Seme non riconosciuto")
        }
        if !isValueFound { // gestisce il caso in cui non è riconosciuto il valore
            print("Valore non riconosciuto")
        }
        if isVerbFound && isSeedFound && isValueFound { // se nella frase riconosciuta c'è un verbo, un seme e un valore
            print(foundSeed!)
            print(foundValue!)
            validateCommand(Value: foundValue!, Seed: foundSeed!) // controlla che la carta da giocare appartenga alla mano del giocatore
        }
    }
}
