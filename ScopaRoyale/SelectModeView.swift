import SwiftUI

struct SelectModeView: View {
    @State private var navigateToOneVsOne = false
    @State private var navigateToTwoVsTwo = false
    @State private var numberOfPlayers: Int = 0
    let lobbyName: String
    
    var body: some View {
        VStack {
            Image("gameMode")
                .resizable()
                .scaledToFit()
                .frame(height: 40)
                .padding(.bottom, 40)
                .padding(.top, 70)

            // NavigationLink per passare alla modalità OneVsOneView
            .navigationDestination(isPresented: $navigateToOneVsOne) {
                OneVsOneView(numberOfPlayer: numberOfPlayers, lobbyName: lobbyName)
            }
            
            // NavigationLink per passare alla modalità TwoVsTwoView
            .navigationDestination(isPresented: $navigateToTwoVsTwo) {
                TwoVsTwoView(numberOfPlayer: numberOfPlayers, lobbyName: lobbyName)
            }
            
            // Bottone per selezionare la modalità 1 vs 1
            Button(action: {
                navigateToOneVsOne = true
                numberOfPlayers = 1
            }) {
                VStack {
                    Image("2users")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 55)
                    
                    Text("1 vs 1")
                        .font(.system(size: 20, design: .default))
                        .foregroundStyle(.white)
                        .padding()
                        .frame(width: 250, height: 35)
                        .background(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                    
                    Text("Play with one person nearby in a one vs one mode.")
                        .font(.system(size: 14, design: .default))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)
                        .padding(.horizontal, 70)
                }
            }
            .padding(.bottom, 40)
            .padding(.top, 40)
            
            // Bottone per selezionare la modalità 2 vs 2
            Button(action: {
                navigateToTwoVsTwo = true
                numberOfPlayers = 3
            }) {
                VStack {
                    Image("4users")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 70)
                    
                    Text("2 vs 2")
                        .font(.system(size: 20, design: .default))
                        .foregroundStyle(.white)
                        .padding()
                        .frame(width: 250, height: 35)
                        .background(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                    
                    Text("Play with multiple people nearby in a two vs two mode where all the players will play with ten cards, also known, as 'Scopone'.")
                        .font(.system(size: 14, design: .default))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)
                        .padding(.horizontal, 70)
                }
            }
            .padding(.top, 40)
            Spacer()
        }
        .preferredColorScheme(.light) // Forza la light mode
    }
}
