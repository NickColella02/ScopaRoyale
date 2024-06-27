import SwiftUI

struct SettingsView: View {
    @Binding var username: String
    @State private var newUsername: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            VStack {
                Text("Change Username")
                    .font(.title)
                    .padding(.top, 20)

                TextField("Enter new username", text: $newUsername)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .padding(.horizontal, 35)
                    .padding(.top, 20)

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
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                        .padding(.horizontal, 35)
                        .padding(.top, 20)
                }
                Spacer()
            }
            .navigationTitle("Settings")
        }
    }
}
