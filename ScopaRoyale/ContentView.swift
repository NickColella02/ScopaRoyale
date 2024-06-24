//
//  ContentView.swift
//  ScopaRoyale
//
//  Created on 24/06/24.
//

import SwiftUI

struct ContentView: View {
    @State private var username: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSelectMode = false

    var body: some View {
        NavigationView {
            VStack {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .padding(.bottom, 20)
                
                Text("Username")
                    .font(.system(size: 20, design: .default))
                    .padding(.top, 20)
                
                TextField("Enter your username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(100)
                    .padding(.horizontal, 35)
                    .padding(.bottom, 20)
                
                NavigationLink(destination: SelectModeView(username: username), isActive: $showSelectMode) {
                    EmptyView()
                }
                
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
                
                Button(action: {
                    if username.isEmpty {
                        alertMessage = "Please enter your username to join a game."
                        showAlert = true
                    } else {
                        // Azione per unirsi a un gioco esistente
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
