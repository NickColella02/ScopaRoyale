import Speech
import SwiftUI
import AVFoundation

public class SwiftUISpeech: ObservableObject {
    @EnvironmentObject private var peerManager: MultiPeerManager
    
    public let verbi: [String] = [ // verbi da riconoscere per il comando vocale del voice over
        "Gioca",
        "Butta",
        "Lancia",
    ]
    
    public let verbiRipetizione: [String] = [
        "Ripeti",
        "Dimmi",
        "Dici"
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
    
    public let oggetti: [String] = [
        "tavolo",
        "banco",
        "mano",
        "mie"
    ]
    
    let separatori: [String] = [" ", "il", "lo", "la", "di", "l'", "le", "un", "le"] // parole da ignorare nel riconoscimento vocale
    
    var stringa = ""
    @Published var isRecording: Bool = false // vero se l'utente sta utilizzando il voice over
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "it-IT")) // riconoscitore di lingua italiana
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let authStat = SFSpeechRecognizer.authorizationStatus()
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    public var outputText: String = ""
    public var outputCart: String = ""
    let synthesizer = AVSpeechSynthesizer()
    
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
    
    func startRecording() {
        outputText = ""

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }

        do {
            try audioEngine.start()
        } catch {
            print("Errore durante l'avvio dell'AVAudioEngine: \(error.localizedDescription)")
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Impossibile creare un oggetto SFSpeechAudioBufferRecognitionRequest")
        }
        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                self.outputText = result.bestTranscription.formattedString
                self.recognizeCommand(command: self.outputText)
            }

            if let error = error {
                print("Errore durante il riconoscimento vocale: \(error.localizedDescription)")
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
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
        if  peerManager.playerHand.contains(cardValue) { // se la carta è nella mano del giocatore
            print("Hai giocato la carta \(Value) di \(Seed)")
            peerManager.playCard(card: cardValue)
        } else { // se la carta non è nella mano del giocatore
            outputCart = "Carta non in mano al giocatore o non valida"
        }
        //speakText(text: outputCart)
    }
    
    private func validateRepeatCommand(oggetto: String) {
        if oggetto == "tavolo" || oggetto == "banco" {
            outputCart = "Leggo il tavolo"
        } else {
            outputCart = "Leggo la mia mano"
        }
        //speakText(text: outputCart)
    }
    
    private func recognizeCommand(command: String) {
        for separatore in separatori {
            stringa = command.replacingOccurrences(of: separatore, with: "")
        }
        
        var isVerbFound: Bool = false // vero se la frase riconosciuta contiene uno dei verbi
        var isRepeatFound: Bool = false
        
        for verbo in verbi { // controlla che la frase riconosciuta contenga uno dei verbi
            if stringa.contains(verbo) {
                isVerbFound = true
                break
            }
        }
        
        for verbo in verbiRipetizione { // controlla che la frase riconosciuta contenga uno dei verbi
            if stringa.contains(verbo) {
                isRepeatFound = true
                break
            }
        }
        
        if isVerbFound {
            var isSeedFound: Bool = false // vero se la frase riconosciuta contiene uno dei semi
            var isValueFound: Bool = false // vero se la frase riconosciuta contiene uno dei valori
            var foundValue: String? // valore riconosciuto
            var foundSeed: String? // seme riconosciuto
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
        } else if isRepeatFound {
            var isObjectFound: Bool = false
            var foundObject: String? // seme riconosciuto
            for oggetto in oggetti { // controlla che la frase riconosciuta contenga uno dei semi
                if stringa.contains(oggetto) {
                    isObjectFound = true
                    foundObject = oggetto
                    break
                }
            }
            if isObjectFound {
                print(foundObject!)
                validateRepeatCommand(oggetto: foundObject!)
            }
        } else {
            print("frase non riconosciuta")
        }
    }
    
    private func speakText(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "it-IT")
        utterance.pitchMultiplier = 1.0
        utterance.rate = 0.5
        self.synthesizer.speak(utterance)
    }
}
