import SwiftUI

struct SelectModeView: View {
    @State private var navigateToOneVsOne = false
    @State private var navigateToTwoVsTwo = false
    @State private var numberOfPlayers: Int = 0
    let lobbyName: String
    
    var body: some View {
        VStack (spacing: 20) {
            Image("gameMode")
                .resizable()
                .scaledToFit()
                .frame(height: 40)

            .navigationDestination(isPresented: $navigateToOneVsOne) { // navigazione alla modalità 1 vs 1
                OneVsOneView(numberOfPlayer: numberOfPlayers, lobbyName: lobbyName)
            }
            
            .navigationDestination(isPresented: $navigateToTwoVsTwo) { // navigazione alla modalità 2 vs 2
                TwoVsTwoView(numberOfPlayer: numberOfPlayers, lobbyName: lobbyName)
            }
            
            VStack (spacing: 5) {
                Image("2users")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 55)
                
                Button(action: { // bottone per selezionare la modalità 1 vs 1
                    navigateToOneVsOne = true
                    numberOfPlayers = 1
                }) {
                    Text("1 vs 1")
                        .font(.system(size: 20, design: .default))
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.83, green: 0.69, blue: 0.22)) // Oro
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                        .padding(.horizontal, 35)
                }
                .padding()
                
                Text("Play with one person nearby in a one vs one mode.")
                    .font(.system(size: 14, design: .default))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 70)
                    .bold()
                    .padding()
            }
            
            VStack (spacing: 5) {
                Image("4users")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 70)
                
                Button(action: { // bottone per selezionare la modalità 2 vs 2
                    navigateToTwoVsTwo = true
                    numberOfPlayers = 3
                }) {
                    Text("2 vs 2")
                        .font(.system(size: 20, design: .default))
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.0, green: 0.5, blue: 0.0), Color(red: 0.2, green: 0.8, blue: 0.2)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                        .padding(.horizontal, 35)
                }
                .padding()
                
                Text("Play with multiple people nearby in a two vs two mode where all the players will play with ten cards, also known, as 'Scopone'.")
                    .font(.system(size: 14, design: .default))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 70)
                    .bold()
                    .padding()
            }
        }
        .preferredColorScheme(.light) // forza la light mode
        .navigationTitle("")
    }
}
