//
//  UsernameEntryView.swift
//  ScopaRoyale
//
//  Created by Nicolò Colella on 26/06/24.
//

import SwiftUI

struct UsernameEntryView: View {
    @State private var username: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Enter your username")
                .font(.title)
                .padding(.bottom, 20)
            
            TextField("Username", text: $username)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(100)
                .padding(.horizontal, 35)
            
            Button(action: {
                if username.isEmpty {
                    alertMessage = "Please enter a username."
                    showAlert = true
                } else {
                    // Salva lo username in UserDefaults
                    UserDefaults.standard.set(username, forKey: "username")
                    // Procede alla schermata principale
                    NotificationCenter.default.post(name: .usernameEntered, object: nil)
                }
            }) {
                Text("Submit")
                    .font(.system(size: 20, design: .default))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(100)
                    .padding(.horizontal, 35)
                    .padding(.top, 20)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Username Required"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            
            Spacer()
        }
        .preferredColorScheme(.light) // Forza la light mode
    }
}

struct UsernameEntryView_Previews: PreviewProvider {
    static var previews: some View {
        UsernameEntryView()
    }
}
