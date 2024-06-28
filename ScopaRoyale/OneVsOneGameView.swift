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

    var body: some View {
        SpriteView(scene: scene)
            .edgesIgnoringSafeArea(.all) // Serve a far sì che la scena occupi tutto lo schermo
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
