import Foundation

struct LobbyInfo: Codable, Equatable, Hashable {
    var lobbyName: String
    var currentPlayers: Int
    
    // Implementazione del metodo hash(into:) per Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(lobbyName)
    }
    
    // Implementazione del metodo == per Equatable
    static func == (lhs: LobbyInfo, rhs: LobbyInfo) -> Bool {
        return lhs.lobbyName == rhs.lobbyName && lhs.currentPlayers == rhs.currentPlayers
    }
}
