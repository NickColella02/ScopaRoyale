import SwiftUI

struct UsernameEntryView: View {
    @State private var username: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showTitle: Bool = false
    @State private var showDescription: Bool = false
    @State private var showUsernameField: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(height: showTitle ? 180 : 0)
                .opacity(showTitle ? 1 : 0)
                .padding(.bottom, showTitle ? 20 : 0)
            
            Text("Immerse yourself in thrilling rounds of Scopa with nearby players!")
                .font(.system(size: 20, design: .default))
                .multilineTextAlignment(.center)
                .opacity(showDescription ? 1 : 0)
                .padding(.horizontal, 35)
            
            Spacer()
            
            UsernameFormView(username: $username, showAlert: $showAlert, alertMessage: $alertMessage, showUsernameField: $showUsernameField) {
                UserDefaults.standard.set(username, forKey: "username")
                NotificationCenter.default.post(name: .usernameEntered, object: nil)
            }
            .opacity(showUsernameField ? 1 : 0)
            .padding(.bottom, showUsernameField ? 0 : -100)
            
            Spacer()
        }
        .onAppear {
            // Animazione del titolo
            withAnimation(.easeInOut(duration: 1.0)) {
                showTitle = true
            }
            
            // Animazione della descrizione dopo un ritardo
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    showDescription = true
                }
            }
            
            // Animazione del campo username dopo un ulteriore ritardo
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    showUsernameField = true
                }
            }
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .preferredColorScheme(.light)
    }
}

struct UsernameFormView: View {
    @Binding var username: String
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    @Binding var showUsernameField: Bool
    let onContinue: () -> Void
    
    let maxUsernameLength = 14
    
    var body: some View {
        VStack {
            Image("username")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
            
            TextField("Enter username", text: $username)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .padding(.horizontal, 25)
                .opacity(username.isEmpty || username.count > maxUsernameLength ? 0.5 : 1.0)
            
            if username.count > maxUsernameLength {
                Text("Username must be \(maxUsernameLength) characters or less.")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 25)
                    .transition(.opacity)
            }
            
            Button(action: {
                if username.isEmpty {
                    showAlert = true
                } else {
                    onContinue()
                }
            }) {
                Text("Done")
                    .font(.system(size: 20, design: .default))
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(username.isEmpty || username.count > maxUsernameLength ? Color.gray : Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .padding(.horizontal, 25)
                    .opacity(username.isEmpty || username.count > maxUsernameLength ? 0.5 : 1.0)
            }
            .disabled(username.isEmpty || username.count > maxUsernameLength)
            
            Text("You can change your username later in settings.")
                .font(.system(size: 14, design: .default))
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 35)
                .padding(.top, 10)
                .opacity(showUsernameField ? 1 : 0)
        }
    }
}

struct UsernameEntryView_Previews: PreviewProvider {
    static var previews: some View {
        UsernameEntryView()
    }
}
