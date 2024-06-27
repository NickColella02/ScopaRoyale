import SwiftUI

struct LobbyNameEntryView: View {
    @Binding var lobbyName: String
    @State private var showSelectMode: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Lobby Name")
                .font(.headline)
                .padding(.top, 20)
            
            TextField("Lobby's name", text: $lobbyName)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 35)
            
            Button(action: { // shows a button to confirm the insertion
                if !lobbyName.isEmpty {
                    showSelectMode = true
                }
            }) {
                Text("Submit")
                    .font(.system(size: 20, design: .default))
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.83, green: 0.69, blue: 0.22)) // Oro
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .padding(.horizontal, 35)
            }
            Spacer()
            // Navigazione verso la schermata di selezione della modalità di gioco
            .navigationDestination(isPresented: $showSelectMode) {
                SelectModeView(lobbyName: lobbyName)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 20)
    }
}
