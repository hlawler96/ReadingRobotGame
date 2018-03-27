//
//  TappingGame.swift
//  Reading_Robot
//
//  Created by Hayden Lawler on 3/26/18.
//  Copyright © 2018 Hayden Lawler. All rights reserved.
//

import SpriteKit

class TappingGame: SKScene {
    
    let player = SKSpriteNode(imageNamed: "Attack_005")
    let pull0 = SKTexture(imageNamed: "Attack_007")
    let pull1 = SKTexture(imageNamed: "Attack_006")
    let pull2 = SKTexture(imageNamed: "Attack_005")
    
    
    override func didMove(to view: SKView) {
        player.size.width = size.width / 3.1
        player.size.height = size.height / 2
        player.position = CGPoint(x: size.width * 0.5 , y: size.height * 0.5)
        player.zPosition = 2
        addChild(player)
        
        let pulling = [pull2, pull1, pull0, pull1, pull2]
        player.run(SKAction.animate(with: pulling, timePerFrame: 0.5))
    }
}
