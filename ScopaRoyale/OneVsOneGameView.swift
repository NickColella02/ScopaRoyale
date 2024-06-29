import SwiftUI
import SpriteKit
import Combine

struct OneVsOneGameView: View {
    var scene: SKScene {
        let scene = OneVsOneGameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFill
        return scene
    }
    
    @ObservedObject private var peerManager: MultiPeerManager = MultiPeerManager()
    @Environment(\.presentationMode) var presentationMode
    @State private var backModality = false
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(true)
            
            Color.clear // Placeholder for any additional views
        }
        .onReceive(peerManager.$peerDisconnected) { disconnected in
            if disconnected {
                print(disconnected)
                self.presentationMode.wrappedValue.dismiss()
                backModality = true
            }
        }
        .navigationDestination(isPresented: $backModality) {
            SelectModeView(lobbyName: peerManager.lobbyName)
        }
        .onAppear {
            peerManager.$peerDisconnected
                .receive(on: RunLoop.main)
                .sink { disconnected in
                    if disconnected {
                        print("Peer disconnected: \(disconnected)")
                        self.presentationMode.wrappedValue.dismiss()
                        backModality = true
                    }
                }
                .store(in: &cancellables)
        }
    }
}

struct OneVsOneGameView_Previews: PreviewProvider {
    static var previews: some View {
        OneVsOneGameView()
    }
}

#Preview {
    OneVsOneGameView()
}
