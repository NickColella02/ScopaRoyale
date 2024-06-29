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
                .frame(height: 60)

            .navigationDestination(isPresented: $navigateToOneVsOne) { // navigazione alla modalità 1 vs 1
                OneVsOneView(numberOfPlayer: numberOfPlayers, lobbyName: lobbyName)
            }
            
            .navigationDestination(isPresented: $navigateToTwoVsTwo) { // navigazione alla modalità 2 vs 2
                TwoVsTwoView(numberOfPlayer: numberOfPlayers, lobbyName: lobbyName)
            }
            
            VStack () {
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
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.black)
                                        .clipShape(RoundedRectangle(cornerRadius: 50))
                                }
                                .frame(width: 330, height: 60)
                                .padding(.horizontal, 35)
                                .padding(.top, 20)
                
                Text("Play with one person nearby in a one vs one mode.")
                    .font(.system(size: 14, design: .default))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 35)
                    .padding(.top, 10)
            }
            .padding(.bottom, 20)
            
            VStack () {
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
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.black)
                                        .clipShape(RoundedRectangle(cornerRadius: 50))
                                }
                                .frame(width: 330, height: 60)
                                .padding(.horizontal, 35)
                
                Text("Play with multiple people nearby in a two vs two mode where all the players will play with ten cards, also known, as 'Scopone'.")
                    .font(.system(size: 14, design: .default))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 35)
                    .padding(.top, 10)
            }
            .padding(.top, 20)
        }
        .preferredColorScheme(.light) // forza la light mode
        .navigationTitle("")
    }
}
