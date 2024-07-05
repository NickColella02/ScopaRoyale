import SwiftUI

struct ProfileView: View {
    @Binding var username: String
    @Environment(\.presentationMode) var presentationMode
    
    // Aggiungi una variabile di stato per gestire l'avatar
    @State private var avatarImage: Image
    
    @State private var showPicker: Bool = false
    @State private var selectedAvatar: String? = UserDefaults.standard.string(forKey: "selectedAvatar") // Carica l'avatar salvato
    
    @State private var showAlert: Bool = false // Per mostrare l'alert se lo username è vuoto
    
    let maxUsernameLength = 14 // Limite massimo di caratteri per lo username
    
    @State private var localUsername: String // Variabile di stato locale per lo username
    
    init(username: Binding<String>) {
        self._username = username
        self._localUsername = State(initialValue: username.wrappedValue) // Inizializza localUsername con il valore corrente di username
        // Imposta l'avatar iniziale dal UserDefaults o usa un valore di default
        if let selectedAvatar = UserDefaults.standard.string(forKey: "selectedAvatar") {
            self._avatarImage = State(initialValue: Image(selectedAvatar))
        } else {
            self._avatarImage = State(initialValue: Image(systemName: "person.circle"))
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                // Visualizzazione dell'avatar
                avatarImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: 1)
                            .scaleEffect(1.1) // Aumenta leggermente la dimensione del cerchio
                            .padding(3)
                    )
            }
            .padding(.bottom, 10)
            
            // Aggiungi un testo per cambiare l'avatar
            Text("Change avatar")
                .font(.system(size: 16))
                .foregroundStyle(.blue)
                .onTapGesture {
                    showPicker = true
                }
                .padding(.bottom, 50)
            
            VStack() {
                // Campo per l'inserimento del nuovo username
                Image("username")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                
                TextField("Enter username", text: $localUsername) // Usa localUsername come binding
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .padding(.horizontal, 25)
                
                // Aggiunta del testo di avviso per il limite di caratteri
                if localUsername.count > maxUsernameLength {
                    Text("Username must be \(maxUsernameLength) characters or less.")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 25)
                }
                
                Button(action: {
                    if localUsername.isEmpty {
                        showAlert = true
                    } else {
                        username = localUsername // Aggiorna il binding con il nuovo username
                        UserDefaults.standard.set(localUsername, forKey: "username")
                        presentationMode.wrappedValue.dismiss() // Chiudi la vista
                    }
                }) {
                    Text("Done")
                        .font(.system(size: 20, design: .default))
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(localUsername.isEmpty || localUsername.count > maxUsernameLength ? Color.gray : Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                        .padding(.horizontal, 25)
                        .padding(.top, 20)
                }
                .disabled(localUsername.isEmpty || localUsername.count > maxUsernameLength) // Disabilita il pulsante se lo username è vuoto o troppo lungo
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationBarTitle("Your profile", displayMode: .inline)
        .sheet(isPresented: $showPicker) {
            // Visualizza il picker personalizzato per la selezione dell'avatar
            AvatarPickerView(selectedAvatar: $selectedAvatar, avatarImage: $avatarImage) {
                // Chiusura della sheet e salvataggio dell'avatar selezionato negli UserDefaults
                if let selectedAvatar = selectedAvatar {
                    UserDefaults.standard.set(selectedAvatar, forKey: "selectedAvatar")
                    self.selectedAvatar = selectedAvatar // Aggiorna lo stato di selectedAvatar
                }
                showPicker = false // Chiudi la sheet dopo aver selezionato un avatar
            }
        }
        .onAppear {
            // Assicurati che l'avatar venga caricato correttamente all'apertura della vista
            if let savedAvatar = UserDefaults.standard.string(forKey: "selectedAvatar") {
                avatarImage = Image(savedAvatar)
            }
        }
    }
}

struct AvatarPickerView: View {
    @Binding var selectedAvatar: String?
    @Binding var avatarImage: Image
    var onSelection: () -> Void
    
    let avatarOptions = ["assobastoni", "assocoppe", "assodenari", "assospade", "duebastoni", "duecoppe", "duedenari", "duespade", "trebastoni", "trecoppe", "tredenari", "trespade", "quattrobastoni", "quattrocoppe", "quattrodenari", "quattrospade", "cinquebastoni", "cinquecoppe", "cinquedenari", "cinquespade", "seibastoni", "seicoppe", "seidenari", "seispade", "settebastoni", "settecoppe", "settedenari", "settespade", "ottobastoni", "ottocoppe", "ottodenari", "ottospade", "novebastoni", "novecoppe", "novedenari", "novespade", "diecibastoni", "diecicoppe", "diecidenari", "diecispade"] // Lista degli avatar disponibili
    
    var body: some View {
        VStack {
            Text("Choose an avatar")
                .font(.title2)
                .padding()
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                    ForEach(avatarOptions, id: \.self) { avatar in
                        Button(action: {
                            selectedAvatar = avatar
                            avatarImage = Image(avatar)
                            onSelection() // Chiamata alla chiusura della sheet e salvataggio
                        }) {
                            Image(avatar)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        }
                        .padding(5)
                    }
                }
            }
            
            Spacer()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(username: .constant("TestUser"))
    }
}
