//
//  ContentView.swift
//  ScopaRoyale
//
//  Created by Nicolò Colella on 24/06/24.
//

import SwiftUI

struct ContentView: View {
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var showSelectMode = false
    @State private var showJoinGame = false
    @State private var showUsernameEntry = false
    @State private var showSettings = false

    init() {
        // Controlla se è presente uno username nell'app
        if username.isEmpty {
            _showUsernameEntry = State(initialValue: true)
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                if showUsernameEntry {
                    // Mostra la schermata di inserimento dello username se necessario
                    UsernameEntryView()
                } else {
                    // Logo dell'applicazione
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
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
                        showSelectMode = true
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
                        showJoinGame = true
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
                }
                Spacer()
            }
            .navigationBarHidden(false) // Mostra la barra di navigazione
            .navigationTitle("")
            .navigationBarItems(trailing: Button(action: {
                showSettings = true
            }) {
                Image(systemName: "ellipsis.circle")
                    .imageScale(.large)
                    .foregroundColor(.black)
            })
            .onReceive(NotificationCenter.default.publisher(for: .usernameEntered)) { _ in
                self.username = UserDefaults.standard.string(forKey: "username") ?? ""
                self.showUsernameEntry = false
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(username: $username)
            }
        }
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

extension Notification.Name {
    static let usernameEntered = Notification.Name("usernameEntered")
}
