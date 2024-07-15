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
    }
    
    @MainActor var transcript: String = ""
    @Published var text: String = ""
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
        "spade",
        "coppe"
    ]
    
    public let valori: [String] = [ // possibili parole attribuibili ai valori delle carte (compresi sinonimi)
        "asso",
        "due",
        "tre",
        "quattro",
        "cinque",
        "sei",
        "sette",
        "otto",
        "nove",
        "re"
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
    private var messageQueue: [String] = []
    private var isProcessingMessage: Bool = false
    
    /**
     Initializes a new speech recognizer. If this is the first time you've used the class, it
     requests access to the speech recognizer and the microphone.
     */
    init(peerManager: MultiPeerManager) {
        self.peerManager = peerManager
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: "it-IT")) ?? nil
        Task {
            do {
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                    throw RecognizerError.notAuthorizedToRecognize
                }
                guard await AVAudioApplication.shared.hasPermissionToRecord() else {
                    throw RecognizerError.notPermittedToRecord
                }
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
        do {
            let (audioEngine, request) = try Self.prepareEngine()
            self.audioEngine = audioEngine
            self.request = request
            // Passa una closure sincrona a recognitionTask
            self.task = recognizer?.recognitionTask(with: request, resultHandler: { [weak self] result, error in
                Task {
                    await self?.recognitionHandler(audioEngine: audioEngine, result: result, error: error)
                }
            })
        } catch {
            self.reset()
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
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.mixWithOthers, .allowBluetooth])
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
            await enqueueMessage(command)
        }
    }
    
    private func enqueueMessage(_ message: String) async {
        messageQueue.append(message)
        await processNextMessage()
    }
    
    private func processNextMessage() async {
        guard !isProcessingMessage, !messageQueue.isEmpty else {
            return
        }
        isProcessingMessage = true
        
        let message = messageQueue.removeFirst()
        await processCommand(transcription: message)
        
        isProcessingMessage = false
        if !messageQueue.isEmpty {
            await processNextMessage()
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
                if (peerManager.isHost && peerManager.currentPlayer == 0) || (peerManager.isClient && peerManager.currentPlayer == 1) {
                    if peerManager.playerHand.contains(Card(value: foundValue, seed: foundSeed)) { // se la carta è nella sua mano
                        peerManager.playCard(card: Card(value: foundValue, seed: foundSeed)) // la gioca
                    } else {
                        await stopTranscribing()
                        await speakText("La carta non è nella tua mano")
                        await startTranscribing()
                    }
                }
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
                    await stopTranscribing()
                    if foundObject == "tavolo" || foundObject == "banco" {
                        for card in peerManager.tableCards {
                            await speakText("\(card.value) di \(card.seed)")
                        }
                    } else if foundObject == "mie" || foundObject == "mano" {
                        for card in peerManager.playerHand {
                            await speakText("\(card.value) di \(card.seed)")
                        }
                    }
                    await startTranscribing()
                }
            }
        }
    }
    
    nonisolated private func transcribe(_ message: String) {
        Task { @MainActor in
            transcript = message
        }
    }
    
    @MainActor
    public func speakText(_ testo: String) {
        let utterance = AVSpeechUtterance(string: testo)
        utterance.voice = AVSpeechSynthesisVoice(language: "it-IT")
        utterance.pitchMultiplier = 1.0
        utterance.rate = 0.5
        do {
            // Configura l'AVAudioSession per la riproduzione audio
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Riproduci l'utterance tramite il synthesizer
            synthesizer.speak(utterance)
        } catch {
            print("Errore nella configurazione dell'AVAudioSession: \(error.localizedDescription)")
        }
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
