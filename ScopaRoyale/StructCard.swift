public let values: [String] = [ // possibili valori delle carte
    "asso", "due", "tre", "quattro", "cinque", "sei", "sette", "otto", "nove", "dieci"
]

public let seeds: [String] = [ // possibili semi delle carte
    "denari", "coppe", "bastoni", "spade"
]

struct Card: CustomStringConvertible, Equatable, Hashable { // definizione di una carta
    let value: String // valore
    let seed: String // seme
    var imageName: String { "\(value.lowercased())\(seed.lowercased())" }
    init(value: String, seed: String) {
        self.value = value
        self.seed = seed
    }
    var description: String {
        return "\(value) di \(seed)"
    }
}
