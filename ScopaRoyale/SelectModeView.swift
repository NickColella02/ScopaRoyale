//
//  SelectModeView.swift
//  ScopaRoyale
//
//  Created on 24/06/24.
//

import SwiftUI

struct SelectModeView: View {
    let username: String
    
    var body: some View {
        VStack {
            Spacer()
            Text("Select game mode")
                .font(.largeTitle)
                .padding()
            
            Button(action: {
                // Qui andrà aggiunta la logica per la modalità 1 vs 1
                print("Selected 1 vs 1")
            }) {
                VStack {
                    Image("2users")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                    
                    Text("1 vs 1")
                        .font(.system(size: 20, design: .default))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(100)
                        .padding(.horizontal, 35)
                    
                    Text("Play with one person nearby in a one-on-one mode.")
                        .font(.system(size: 14, design: .default))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)
                }
            }
            
            Button(action: {
                // Qui andrà aggiunta la logica per la modalità 2 vs 2
                print("Selected 2 vs 2")
            }) {
                VStack {
                    Image("4users")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                    
                    Text("2 vs 2")
                        .font(.system(size: 20, design: .default))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(100)
                        .padding(.horizontal, 35)
                    
                    Text("Play with multiple people nearby in a two-on-two mode, also known as 'Scopone'.")
                        .font(.system(size: 14, design: .default))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)
                }
            }
            
            Spacer()
        }
    }
}

struct SelectModeView_Previews: PreviewProvider {
    static var previews: some View {
        SelectModeView(username: "Player1")
    }
}

#Preview {
    SelectModeView(username: "Player 1")
}
