//
//  StartNewGameView.swift
//  ScopaRoyale
//
//  Created by Nicolò Colella on 24/06/24.
//

import SwiftUI

struct OneVsOneView: View {
    let username: String
    
    var body: some View {
        VStack {
            // Immagine rappresentativa della modalità di gioco (1 vs 1)
            Image("2users")
                .resizable()
                .scaledToFit()
                .frame(height: 120)
            
            // Titolo della schermata
            Text("Waiting for an opponent...")
                .font(.title)
                .padding()
            
            // Nome utente del giocatore
            Text(username)
                .font(.title2)
                .padding(.top, 10)
            
            Spacer()
            
            // Bottone per avviare la partita
            Button(action: {
                // Messaggio di debug quando il bottone "Start" viene premuto
                print("Start button tapped in OneVsOneView")
            }) {
                Text("Start")
                    .font(.system(size: 20, design: .default))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(100)
                    .padding(.horizontal, 35)
                    .padding(.bottom, 20)
            }
        }
        .preferredColorScheme(.light) // Forza la light mode
    }
}

struct OneVsOneView_Previews: PreviewProvider {
    static var previews: some View {
        OneVsOneView(username: "HostPlayer")
    }
}

#Preview {
    OneVsOneView(username: "HostPlayer")
}
