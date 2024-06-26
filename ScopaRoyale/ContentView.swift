//
//  ContentView.swift
//  ScopaRoyale
//
//  Created by Nicolò Colella on 24/06/24.
//

import SwiftUI

struct ContentView: View {
    @State private var username: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Stati per la navigazione verso le altre schermate
    @State private var showSelectMode = false
    @State private var showJoinGame = false

    var body: some View {
        NavigationStack {
            VStack {
                // Logo dell'applicazione
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .padding(.bottom, 20)
                
                // Titolo e campo di inserimento per l'username
                Text("USERNAME")
                    .font(.system(size: 20, design: .default))
                    .padding(.top, 20)
                TextField("Enter your username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(100)
                    .padding(.horizontal, 35)
                    .padding(.bottom, 20)
                
                // Navigazione verso la schermata di selezione della modalità di gioco
                .navigationDestination(isPresented: $showSelectMode) {
                    SelectModeView(username: username)
                }
                
                // Navigazione verso la schermata di ricerca della partita
                .navigationDestination(isPresented: $showJoinGame) {
                    JoinAGameView(username: username)
                }
                
                // Bottone per avviare una nuova partita
                Button(action: {
                    if username.isEmpty {
                        alertMessage = "Please enter your username to start a new game."
                        showAlert = true
                    } else {
                        showSelectMode = true
                    }
                }) {
                    Text("Start new game")
                        .font(.system(size: 20, design: .default))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(100)
                        .padding(.horizontal, 35)
                        .padding(.top, 20)
                }
                
                // Bottone per unirsi a una partita esistente
                Button(action: {
                    if username.isEmpty {
                        alertMessage = "Please enter your username to join a game."
                        showAlert = true
                    } else {
                        showJoinGame = true
                    }
                }) {
                    Text("Join a game")
                        .font(.system(size: 20, design: .default))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(100)
                        .padding(.horizontal, 35)
                }
                .padding(.bottom, 20)
                
                Spacer()
            }
            .padding(.top, 100)
            .padding(.bottom, 100)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Username Required"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationBarHidden(true) // Nasconde la barra di navigazione
        }
        .accentColor(.black)
        .preferredColorScheme(.light) // Forza la light mode
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}
