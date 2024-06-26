import SwiftUI

struct JoinAGameView: View {
    let username: String
    @State private var matches: [String] = [] // Array provvisorio per mantenere i nomi delle partite trovate
    @State private var selectedMatch: String? = nil // Match selezionato
    @State private var showAlert = false // Stato per la visualizzazione dell'alert
    @ObservedObject private var peerManager: MultiPeerManager = MultiPeerManager()

    var body: some View {
        VStack {
            Spacer()
            
            // Titolo della schermata
            Text("Searching...")
                .font(.title)
                .padding()
            
            // Elenco delle partite trovate
            HStack {
                VStack(alignment: .leading) {
                    Text("Games found:")
                        .font(.title2)
                        .padding(.bottom, 5)
                    
                    // Ciclo attraverso le partite trovate
                    ForEach(matches, id: \.self) { match in
                        Button(action: {
                            selectedMatch = match
                        }) {
                            Text(match)
                                .font(.title3)
                                .padding()
                                .background(selectedMatch == match ? .gray.opacity(0.5) : .clear)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding(.leading, 20)
                
                Spacer()
            }
            
            Spacer()
            
            // Bottone per unirsi a una partita selezionata
            Button(action: {
                if let selectedMatch = selectedMatch {
                    //Messaggio di debug
                    print("Joining match: \(selectedMatch) with username: \(username)")
                    // Navigazione alla partita da implementare
                } else {
                    showAlert = true // Mostra l'alert se nessun match è stato selezionato
                }
            }) {
                Text("Join")
                    .font(.system(size: 20, design: .default))
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .padding(.horizontal, 35)
                    .padding(.bottom, 20)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("No game selected"),
                    message: Text("Please select a game before joining."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            peerManager.sendUsername(username: username)
            peerManager.joinSession()
        }
       
        .preferredColorScheme(.light) // Forza la light mode
    }
}

struct JoinAGameView_Previews: PreviewProvider {
    static var previews: some View {
        JoinAGameView(username: "Player1")
    }
}

#Preview {
    JoinAGameView(username: "Player1")
}
