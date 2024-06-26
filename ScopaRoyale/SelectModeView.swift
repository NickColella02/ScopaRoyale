//
//  SelectModeView.swift
//  ScopaRoyale
//
//  Created by Nicolò Colella on 24/06/24.
//

import SwiftUI

struct SelectModeView: View {
    let username: String
    @State private var navigateToOneVsOne = false
    @State private var navigateToTwoVsTwo = false
    
    var body: some View {
        VStack {
            Spacer()
            
            // Titolo della schermata
            Text("Select game mode")
                .font(.title)
                .padding()
            
            // NavigationLink per passare alla modalità OneVsOneView
            .navigationDestination(isPresented: $navigateToOneVsOne) {
                OneVsOneView(username: username)
            }
            
            // NavigationLink per passare alla modalità TwoVsTwoView
            .navigationDestination(isPresented: $navigateToTwoVsTwo) {
                TwoVsTwoView(username: username)
            }
            
            // Bottone per selezionare la modalità 1 vs 1
            Button(action: {
                navigateToOneVsOne = true
            }) {
                VStack {
                    Image("2users")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .padding(.bottom, 10)
                    
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
            
            // Bottone per selezionare la modalità 2 vs 2
            Button(action: {
                navigateToTwoVsTwo = true
            }) {
                VStack {
                    Image("4users")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .padding(.bottom, 10)
                    
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
        .preferredColorScheme(.light) // Forza la light mode
    }
}

struct SelectModeView_Previews: PreviewProvider {
    static var previews: some View {
        SelectModeView(username: "HostPlayer")
    }
}

#Preview {
    SelectModeView(username: "HostPlayer")
}
