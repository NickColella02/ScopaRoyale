import Foundation
import AVFoundation
import Speech
import SwiftUI

actor SpeechRecognizer: ObservableObject {
    enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable
        
        var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }
    
    @MainActor var transcript: String = ""
    public let verbi: [String] = [ // verbi da riconoscere per il comando vocale del voice over
        "gioca",
        "butta",
        "lancia",
    ]
    
    public let verbiRipetizione: [String] = [
        "ripeti",
        "dimmi",
        "dici"
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
        "fante",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "10"
    ]
    
    public let oggetti: [String] = [
        "tavolo",
        "banco",
        "mano",
        "mie"
    ]
    
    let separatori: [String] = [" ", "il", "lo", "la", "di", "l'", "le", "un", "le"] // parole da ignorare nel riconoscimento vocale
    
    private let peerManager: MultiPeerManager
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?
    private let synthesizer = AVSpeechSynthesizer()
    
    /**
     Initializes a new speech recognizer. If this is the first time you've used the class, it
     requests access to the speech recognizer and the microphone.
     */
    init(peerManager: MultiPeerManager) {
        self.peerManager = peerManager
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: "it-IT"))
        guard recognizer != nil else {
            transcribe(RecognizerError.nilRecognizer)
            return
        }
        
        Task {
            do {
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                    throw RecognizerError.notAuthorizedToRecognize
                }
                guard await AVAudioApplication.shared.hasPermissionToRecord() else {
                    throw RecognizerError.notPermittedToRecord
                }
            } catch {
                transcribe(error)
            }
        }
    }

    
    @MainActor func startTranscribing() {
        Task {
            await transcribe()
        }
    }
    
    @MainActor func resetTranscript() {
        Task {
            await reset()
        }
    }
    
    @MainActor func stopTranscribing() {
        Task {
            await reset()
        }
    }
    
    /**
     Begin transcribing audio.
     
     Creates a `SFSpeechRecognitionTask` that transcribes speech to text until you call `stopTranscribing()`.
     The resulting transcription is continuously written to the published `transcript` property.
     */
    private func transcribe() async {
        guard let recognizer, recognizer.isAvailable else {
            self.transcribe(RecognizerError.recognizerIsUnavailable)
            return
        }
        
        do {
            let (audioEngine, request) = try Self.prepareEngine()
            self.audioEngine = audioEngine
            self.request = request
            // Passa una closure sincrona a recognitionTask
            self.task = recognizer.recognitionTask(with: request, resultHandler: { [weak self] result, error in
                Task {
                    await self?.recognitionHandler(audioEngine: audioEngine, result: result, error: error)
                }
            })
        } catch {
            self.reset()
            self.transcribe(error)
        }
    }

    
    /// Reset the speech recognizer.
    private func reset() {
        task?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
    }
    
    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, request)
    }
    
    private func recognitionHandler(audioEngine: AVAudioEngine, result: SFSpeechRecognitionResult?, error: Error?) async {
    
        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil
        
        if receivedFinalResult || receivedError {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        if let result {
            let command: String = result.bestTranscription.formattedString
            transcribe(result.bestTranscription.formattedString)
            await processCommand(transcription: command)
        }
    }
    
    private func processCommand(transcription: String) async {
        var command = transcription.lowercased() // porto tutto a minuscolo
        for separatore in separatori { // rimuovo i separatori
            command = command.replacingOccurrences(of: separatore, with: "")
        }
        var foundVerb: String = "" // verbo trovato
        for verbo in verbi { // controllo se è riconosciuto un verbo di azione
            if command.contains(verbo) {
                foundVerb = verbo
                break
            }
        }
        if !foundVerb.isEmpty { // se è riconosciuto un verbo di azione
            print("Verbo riconosciuto: \(foundVerb)")
            var foundValue: String = "" // valore trovato
            var foundSeed: String = "" // seme trovato
            for valore in valori { // controllo se è riconosciuto un valore
                if command.contains(valore) {
                    foundValue = valore
                    break
                }
            }
            for seme in semi { // controllo se è riconosciuto un seme
                if command.contains(seme) {
                    foundSeed = seme
                    break
                }
            }
            if !foundValue.isEmpty && !foundSeed.isEmpty { // se sono riconosciuti un valore e un seme
                print("Valore riconosciuto: \(foundValue)")
                print("Seme riconosciuto: \(foundSeed)")
                if peerManager.playerHand.contains(Card(value: foundValue, seed: foundSeed)) { // se la carta è nella sua mano
                    await speakText("Gioco la carta \(foundValue) di \(foundSeed)")
                    peerManager.playCard(card: Card(value: foundValue, seed: foundSeed)) // la gioca
                } else {
                    await speakText("La carta non è nella tua mano")
                }
                DispatchQueue.main.async {
                    self.peerManager.isRecording = false // fermo la registrazione
                }
            } else {
                print("Valore o seme non riconosciuto")
            }
        } else {
            for verbo in verbiRipetizione { // controllo se è riconosciuto un verbo di ripetizione
                if command.contains(verbo) {
                    foundVerb = verbo
                    break
                }
            }
            if !foundVerb.isEmpty {
                var foundObject: String = ""
                for oggetto in oggetti {
                    if command.contains(oggetto) {
                        foundObject = oggetto
                        break
                    }
                }
                if !foundObject.isEmpty {
                    print("Oggetto riconosciuto: \(foundObject)")
                    if foundObject == "tavolo" || foundObject == "banco" {
                        for card in peerManager.tableCards {
                            await speakText("\(card.value) di \(card.seed)")
                        }
                        DispatchQueue.main.async {
                            self.peerManager.isRecording = false
                        }
                    } else if foundObject == "mie" || foundObject == "mano" {
                        for card in peerManager.playerHand {
                            await speakText("\(card.value) di \(card.seed)")
                        }
                        DispatchQueue.main.async {
                            self.peerManager.isRecording = false
                        }
                    }
                }
            }
        }
    }
    
    
    nonisolated private func transcribe(_ message: String) {
        Task { @MainActor in
            transcript = message
        }
    }
    nonisolated private func transcribe(_ error: Error) {
        var errorMessage = ""
        if let error = error as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage += error.localizedDescription
        }
        Task { @MainActor [errorMessage] in
            transcript = "<< \(errorMessage) >>"
        }
    }
    
    @MainActor
    public func speakText(_ testo: String) {
        let utterance = AVSpeechUtterance(string: testo)
        utterance.voice = AVSpeechSynthesisVoice(language: "it-IT")
        utterance.pitchMultiplier = 1.0
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
}


extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}


extension AVAudioApplication {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}
