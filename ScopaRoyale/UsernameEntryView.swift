import SwiftUI

struct UsernameEntryView: View {
    @State private var username: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        VStack {            
            Image("username")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .padding(.bottom, 10)
            
            TextField("Enter username", text: $username)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .padding(.horizontal, 25)
            
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
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .padding(.horizontal, 25)
            }
            Text("You can change your username whenever you want in settings.")
                .font(.system(size: 14, design: .default))
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 35)
                .padding(.top, 10)
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
