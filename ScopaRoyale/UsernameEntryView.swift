//
//  UsernameEntryView.swift
//  ScopaRoyale
//
//  
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
                .clipShape(RoundedRectangle(cornerRadius: 100))
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
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .padding(.horizontal, 35)
                    .padding(.top, 20)
            }
            .alert("Username required", isPresented: $showAlert) {
                VStack {
                    Button("OK", role: .cancel) {
                        showAlert = false
                    }
                }
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
