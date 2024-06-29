import SpriteKit
import SwiftUI

class OneVsOneGameScene: SKScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Add background image
        let background = SKSpriteNode(imageNamed: "table")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = self.size
        background.zPosition = -1 // Make sure the background is behind other nodes
        addChild(background)
    }
}
