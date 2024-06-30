import Foundation

struct GameMove: Codable {
    enum Action: Int, Codable {
        case start, end, move
    }
    let action: Action
    let playerName: String?
    let index: Int?
    
    func data() -> Data? {
        try? JSONEncoder().encode(self)
    }
}
