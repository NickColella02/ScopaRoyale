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
                VStack(alignment: .leading) {
                    Text("Games found:")
                        .font(.title2)
                        .padding(.bottom, 5)
                    
                    // Ciclo attraverso le partite trovate
                    ForEach(peerManager.availableLobbies, id: \.self) { lobbyInfo in
                        Button(action: {
                            // Azioni quando viene selezionata una lobby
                        }) {
                            Text("\(lobbyInfo.lobbyName) (\(lobbyInfo.currentPlayers) players)")
                                .font(.title3)
                                .padding()
                                .background(Color.gray.opacity(0.5))
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
