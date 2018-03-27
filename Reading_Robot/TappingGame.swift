//
//  TappingGame.swift
//  Reading_Robot
//
//  Created by Hayden Lawler on 3/26/18.
//  Copyright © 2018 Hayden Lawler. All rights reserved.
//

import SpriteKit

class TappingGame: SKScene {
    
    let player = SKSpriteNode(imageNamed: "Blue_Attack_005")
    let player2 = SKSpriteNode(imageNamed: "Red_Attack_005")
    let rope = SKSpriteNode(imageNamed: "rope")
    let bottom = SKSpriteNode(imageNamed: "rectangle")
    
    let pull0 = SKTexture(imageNamed: "Blue_Attack_007")
    let pull1 = SKTexture(imageNamed: "Blue_Attack_006")
    let pull2 = SKTexture(imageNamed: "Blue_Attack_005")
    var oppPull0 = SKTexture(imageNamed: "Red_Attack_007")
    var oppPull1 = SKTexture(imageNamed: "Red_Attack_006")
    var oppPull2 = SKTexture(imageNamed: "Red_Attack_005")
    
    var startSecond, startMinute, startHour, startNS : Int!
    let calendar = Calendar.current
    let date = Date()
    var timeToPull = true
    var playerOneStartX, playerTwoStartX: CGFloat!
    
    
    
    override func didMove(to view: SKView) {
        backgroundMusicPlayer.stop()
        
        playerOneStartX = size.width * 0.2
        playerTwoStartX = size.width * 0.8
        
        player2.size.width = size.width / 2.5
        player2.size.height = size.height / 1.6
        player2.position = CGPoint(x: playerTwoStartX , y: size.height * 0.33)
        player2.zPosition = 2
        addChild(player2)
        
        player.size.width = size.width / 2.5
        player.size.height = size.height / 1.6
        player.position = CGPoint(x: playerOneStartX , y: size.height * 0.33)
        player.zPosition = 2
        player.xScale = player.xScale * -1;
        addChild(player)
        
        rope.position = CGPoint(x: frame.size.width / 2, y: frame.size.height * 0.35  - player.size.height/4 )
        rope.size.width = size.width * 0.46
        rope.size.height = player.size.height / 10
        rope.zPosition = 1
        addChild(rope)
        
        startHour = calendar.component(.hour, from: date)
        startSecond = calendar.component(.second, from: date)
        startMinute = calendar.component(.minute, from: date)
        startNS = calendar.component(.nanosecond, from: date)
        
        bottom.position = CGPoint(x: frame.size.width/2, y:frame.size.height*0.08)
        bottom.size.height = frame.size.height * 0.16
        bottom.size.width  = frame.size.width
        bottom.zPosition = 3
        bottom.yScale = bottom.yScale * -1
        addChild(bottom)
        
        let label = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        label.text = "Your Pattern is: CK"
        label.position = CGPoint(x: frame.size.width/2, y: frame.size.height*0.04)
        label.fontSize = 100
        label.zPosition = 4
        label.fontColor = UIColor.white
        addChild(label)
        

    }
    
    override func update(_ currentTime: TimeInterval) {
        let time = getSecondsSinceStart()
//        let pulling = [pull2, pull1, pull0, pull1, pull2]
//        let oppPulling = [oppPull2, oppPull1, oppPull0, oppPull1, oppPull2]
//        let remainder = time.truncatingRemainder(dividingBy: 8.0)
//        let action = SKAction.animate(with: pulling, timePerFrame: 0.15)
//        let oppAction = SKAction.animate(with: oppPulling, timePerFrame: 0.15)
//        if  remainder > 2.95 && remainder <  3.05  && timeToPull{
//            player.run(action, withKey: "pulling")
//            timeToPull = false
//        }else if remainder > 6.95 && remainder <  7.05 && !timeToPull {
//            timeToPull = true
//            player2.run(oppAction, withKey: "pulling")
//        }
        let sinApprox = CGFloat(sin(Double.pi * time / 4) + 0.33333*sin(3.0 * Double.pi * time / 4.0))
        let deltaX = (size.width * 0.1) * (2 / CGFloat.pi) * sinApprox
        player.position = CGPoint(x: playerOneStartX + deltaX, y: size.height*0.33)
        player2.position = CGPoint(x: playerTwoStartX + deltaX, y: size.height*0.33)
        rope.position = CGPoint(x: size.width/2 + deltaX, y: frame.size.height * 0.35 - player.size.height/4 )
    }
    
    func getSecondsSinceStart() -> Double {
        let currentDate = Date()
        let dSec = Double(calendar.component(.second, from: currentDate) -  startSecond)
        let dMinute = Double((calendar.component(.minute, from: currentDate) - startMinute) * 60)
        let dHour = Double((calendar.component(.hour, from: currentDate) - startHour) * 3600)
        let dNS = Double(calendar.component(.nanosecond, from: currentDate) - startNS) * 0.000000001
        return dSec + dMinute + dHour + dNS
    }
}
