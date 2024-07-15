import Foundation

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

// Funzione di utilità per convertire il valore stringa della carta in un valore numerico
func numericValue(for stringValue: String) -> Int? {
    switch stringValue {
    case "asso": return 1
    case "due": return 2
    case "tre": return 3
    case "quattro": return 4
    case "cinque": return 5
    case "sei": return 6
    case "sette": return 7
    case "otto": return 8
    case "nove": return 9
    case "re": return 10
    default: return nil
    }
}

// Estensione per gestire le combinazioni di un array di carte
extension Array where Element == Card {
    func combinations(length: Int) -> [[Card]] {
        guard length > 0 else { return [[]] }
        guard length <= count else { return [] }
        
        if length == 1 {
            return self.map { [$0] }
        } else {
            var combinations: [[Card]] = []
            
            for (index, element) in self.enumerated() {
                var reduced = self
                reduced.removeFirst(index + 1)
                let subCombinations = reduced.combinations(length: length - 1)
                for var subCombination in subCombinations {
                    subCombination.insert(element, at: 0)
                    combinations.append(subCombination)
                }
            }
            
            return combinations
        }
    }
}
