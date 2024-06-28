import SwiftUI

struct UsernameEntryView: View {
    @State private var username: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        VStack {            
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
                    showAlert = true
                } else {
                    UserDefaults.standard.set(username, forKey: "username")
                    NotificationCenter.default.post(name: .usernameEntered, object: nil)
                }
            }) {
                Text("Done")
                    .font(.system(size: 20, design: .default))
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.83, green: 0.69, blue: 0.22))
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .padding(.horizontal, 35)
                    .padding(.top, 20)
            }
            .alert("Username required", isPresented: $showAlert) {
                VStack {
                    Button("OK", role: .cancel) {
                        showAlert = false
                    }
                }
            } message: {
                Text("You need to enter a username.")
            }
        }
        .preferredColorScheme(.light) // Forza la light mode
    }
}

struct UsernameEntryView_Previews: PreviewProvider {
    static var previews: some View {
        UsernameEntryView()
    }
}
