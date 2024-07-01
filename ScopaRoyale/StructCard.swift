import Foundation

// Definizione del valore e dei semi delle carte
public let values: [String] = [
    "asso", "due", "tre", "quattro", "cinque", "sei", "sette", "otto", "nove", "dieci"
]

public let seeds: [String] = [
    "denari", "coppe", "bastoni", "spade"
]

// Definizione della struttura Card
struct Card: CustomStringConvertible, Equatable, Hashable, Codable {
    let value: String
    let seed: String
    var imageName: String { "\(value.lowercased())\(seed.lowercased())" }
    init(value: String, seed: String) {
        self.value = value
        self.seed = seed
    }
    var description: String {
        return "\(value) di \(seed)"
    }
}

// Estensione per la serializzazione e deserializzazione di un array di Card
extension Array where Element == Card {
    func toJSON() -> Data? {
        return try? JSONEncoder().encode(self)
    }

    static func fromJSON(_ data: Data) -> [Card]? {
        return try? JSONDecoder().decode([Card].self, from: data)
    }
}


extension Card {
    func toJSON() -> Data? {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(self)
            return jsonData
        } catch {
            print("Errore nella codifica della carta: \(error.localizedDescription)")
            return nil
        }
    }

    static func fromJSON(_ data: Data) -> [Card]? {
        let decoder = JSONDecoder()
        do {
            let cards = try decoder.decode([Card].self, from: data)
            return cards
        } catch {
            print("Errore nella decodifica della carta: \(error.localizedDescription)")
            return nil
        }
    }
}
