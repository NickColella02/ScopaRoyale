import SwiftUI

struct JoinAGameView: View {
    let username: String
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
                Text("Lobby's name: \(peerManager.lobbyName)")
                    .font(.title)
                    .padding()
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
            .alert("No game selected", isPresented: $showAlert) {
                VStack {
                    Button("OK", role: .cancel) {
                        showAlert = false
                    }
                }
            }
        }
        .onAppear {
            peerManager.sendUsername(username: username)
            peerManager.joinSession()
        }
       
        .preferredColorScheme(.light) // Forza la light mode
    }
}
