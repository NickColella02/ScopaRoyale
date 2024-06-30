public let values: [String] = [ // possibili valori delle carte
    "asso", "due", "tre", "quattro", "cinque", "sei", "sette", "otto", "nove", "dieci"
]

public let seeds: [String] = [ // possibili semi delle carte
    "denari", "coppe", "bastoni", "spade"
]

struct Card: CustomStringConvertible, Equatable, Hashable { // definizione di una carta
    let value: String // valore
    let seed: String // seme
    var imageName: String { "\(value.lowercased())\(seed.lowercased())" } // immagine della carta
    init(value: String, seed: String) { // costruttore
        self.value = value
        self.seed = seed
    }
    var description: String { // restituisce la carta sottoforma di stringa
        return "\(value) di \(seed)"
    }
}
