import SwiftUI
import SpriteKit

struct OneVsOneGameView: View {
    var scene: SKScene {
        guard let scene = SKScene(fileNamed: "OneVsOneGameScene") else {
            fatalError("Scene not found")
        }
        scene.scaleMode = .aspectFill
        return scene
    }
    
    @ObservedObject private var peerManager: MultiPeerManager = MultiPeerManager()
    @Environment(\.presentationMode) var presentationMode
    @State private var backModality = false

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(true)
            
            Color.clear // Placeholder for any additional views
        }
        .onChange(of: peerManager.peerDisconnected) { disconnected in
            if disconnected {
                print(disconnected)
                self.presentationMode.wrappedValue.dismiss()
                backModality = true
            }
        }
        .navigationDestination(isPresented: $backModality) {
            SelectModeView(lobbyName: peerManager.lobbyName)
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
