import SwiftUI

struct SettingsView: View {
    @Binding var username: String
    @State private var newUsername: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome back \(username)")
                    .font(.title)
                    .padding()

                TextField("Enter new username", text: $newUsername)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .padding(.horizontal, 35)

                Button(action: {
                    if !newUsername.isEmpty {
                        // Salva il nuovo username in UserDefaults
                        UserDefaults.standard.set(newUsername, forKey: "username")
                        // Aggiorna la variabile username
                        username = newUsername
                        // Chiude il popup
                        presentationMode.wrappedValue.dismiss()
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
                }
            }
            .navigationTitle("Settings")
        }
    }
}
