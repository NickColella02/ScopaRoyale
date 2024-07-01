import SwiftUI

struct UsernameEntryView: View {
    @State private var username: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showWelcome: Bool = true
    
    var body: some View {
        VStack {
            if showWelcome {
                WelcomeView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showWelcome = false
                    }
                }
            } else {
                UsernameFormView(username: $username, showAlert: $showAlert, alertMessage: $alertMessage)
                    .transition(.move(edge: .trailing)) // Aggiunto transition per far apparire la UsernameFormView dal lato destro
            }
        }
        .preferredColorScheme(.light) // Forza la light mode
    }
}

struct WelcomeView: View {
    let onContinue: () -> Void
    @State private var showTitle: Bool = false
    @State private var showDescription: Bool = false
    @State private var showContinueButton: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            if showTitle {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .transition(.scale)
                    .padding(.bottom, 20)
            }
            
            if showDescription {
                Text("Immerse yourself in thrilling rounds of Scopa with nearby players!")
                    .font(.system(size: 20, design: .default))
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
                    .padding(.horizontal, 35)
            }
            
            Spacer()
            
            if showContinueButton {
                Button(action: onContinue) {
                    HStack {
                        Text("Continue")
                            .font(.system(size: 20, design: .default))
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                        
                        /*Image(systemName: "arrow.right")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)*/
                    }
                    .frame(width: 330, height: 60)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .padding(.bottom, 50)
                    .transition(.opacity)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                showTitle = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showDescription = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showContinueButton = true
                }
            }
        }
    }
}

struct UsernameFormView: View {
    @Binding var username: String
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    
    var body: some View {
        VStack {
            Image("username")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40) // Aumentato per coerenza con AppLogo
            
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
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .padding(.horizontal, 25)
            }
            
            Text("You can change your username later in settings.")
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
    }
}

#Preview {
    UsernameEntryView()
}
