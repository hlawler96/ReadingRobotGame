//
//  TappingGame.swift
//  Reading_Robot
//
//  Created by Hayden Lawler on 3/26/18.
//  Copyright © 2018 Hayden Lawler. All rights reserved.
//

import SpriteKit

class TappingGame: SKScene {
    
    let player = SKSpriteNode(imageNamed: userColor + "_Attack_005")
    
    
    override func didMove(to view: SKView) {
        player.size.width = size.width / 3.1
        player.size.height = size.height / 2
        player.position = CGPoint(x: size.width * 0.5 , y: size.height * 0.5)
        player.zPosition = 2
        addChild(player)
        

    }
}
