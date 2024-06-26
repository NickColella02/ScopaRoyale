//
//  TwoVsTwoView.swift
//  ScopaRoyale
//
//  Created by Nicolò Colella on 26/06/24.
//

import SwiftUI

struct TwoVsTwoView: View {
    let username: String
    
    var body: some View {
        VStack {
            // Immagine rappresentativa della modalità di gioco (2 vs 2)
            Image("4users")
                .resizable()
                .scaledToFit()
                .frame(height: 120)
            
            // Titolo della schermata
            Text("Waiting for opponents...")
                .font(.title)
                .padding()
            
            // Visualizzazione dei team
            VStack(alignment: .leading, spacing: 20) {
                // Team 1
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("Team 1:")
                            .font(.title2)
                            .padding(.bottom, 5)
                        
                        // Nome utente del giocatore dell'host del Team 1
                        HStack(spacing: 10) {
                            Image("1user")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                            Text("\(username) (host)")
                                .font(.title3)
                        }
                        
                        // Altri giocatori del Team 1
                        Image("1user")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                    .padding(.leading, 20)
                }
                
                Spacer().frame(height: 10)
                
                // Team 2 (da implementare)
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("Team 2:")
                            .font(.title2)
                            .padding(.bottom, 5)
                        
                        // Qui andranno aggiunti i giocatori del Team 2 quando saranno disponibili
                        HStack(spacing: 10) {
                            Image("1user")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        
                        // Altri giocatori del Team 2 (da implementare)
                        Image("1user")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            // Bottone per avviare la partita
            Button(action: {
                // Messaggio di debug quando il bottone "Start" viene premuto
                print("Start button tapped in TwoVsTwoView")
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

struct TwoVsTwoView_Previews: PreviewProvider {
    static var previews: some View {
        TwoVsTwoView(username: "HostPlayer")
    }
}

#Preview {
    TwoVsTwoView(username: "HostPlayer")
}
