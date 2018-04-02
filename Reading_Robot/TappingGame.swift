//
//  TappingGame.swift
//  Reading_Robot
//
//  Created by Hayden Lawler on 3/26/18.
//  Copyright © 2018 Hayden Lawler. All rights reserved.
//

import SpriteKit
//playground level used for testing, currently not planning on using this for prod
class TappingGame: SKScene {
    
    let player = SKSpriteNode(imageNamed:"Blue_Idle_000")
    let bucket = SKSpriteNode(imageNamed: "bucket")
    let background = SKSpriteNode(imageNamed: "LevelBackground1")
    let upperBackground = SKSpriteNode(imageNamed: "LevelBackground1")
    let cropNode = SKCropNode()
    let mud = SKSpriteNode(imageNamed: "mud")
    var mudStartY : CGFloat!
    var numOfFrames : CGFloat!
    var midMudPos : CGFloat!
    
    var spillingMud = false
    var bucket_taps = 0
    
    override func didMove(to view: SKView) {
        backgroundMusicPlayer.stop()
        
        player.size.width = size.width / 5
        player.size.height = size.height / 3.2
        player.position = CGPoint(x: size.width/2, y: size.height * 0.28)
        player.zPosition = 1
        player.xScale = player.xScale * -1;
        addChild(player)
        
        bucket.size.width = size.width / 4
        bucket.size.height = size.height / 3.2
        bucket.position = CGPoint(x: size.width/2 , y: size.height * 0.7)
        bucket.zPosition = 2
        addChild(bucket)
        
        // add background to view
        background.size.width = size.width
        background.size.height = size.height
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = 0
        addChild(background)
        
        upperBackground.size.width = size.width
        background.size.height = size.height
        
        mud.size.width = player.size.width
        mud.size.height = frame.size.height*1.3
        mudStartY = bucket.position.y - bucket.size.height/2 + mud.size.height/2
        
        mud.position = CGPoint(x: bucket.position.x+15  , y: mudStartY)
        mud.zPosition = 3
        print(player.size.width * 1.3)
        let rect = CGRect(x: bucket.position.x - bucket.size.width/2, y: bucket.position.y - bucket.size.height/2.5 - frame.size.height, width: player.size.width*1.2, height: frame.size.height)
        let shapeNode = SKShapeNode(rect: rect)
        shapeNode.fillColor = UIColor.white
        cropNode.maskNode = shapeNode
        cropNode.addChild(mud)
        cropNode.zPosition = -1
        addChild(cropNode)
        
        numOfFrames = mud.size.height / 5
    }
    
    override func update(_ currentTime: TimeInterval){
        if(spillingMud){
            cropNode.zPosition = 3
            mud.position.y = mud.position.y - 15
            if (mudStartY - mud.position.y) / 5 < numOfFrames/2 + 1 && (mudStartY - mud.position.y) / 5 > numOfFrames/2 - 1 {
                midMudPos = mud.position.y
            }
            if mud.position.y < mudStartY - mud.size.height + 25 {
                mud.position.y = midMudPos
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            let touchedNodes = self.nodes(at: currentPoint)
            for node in touchedNodes {
                if node == bucket {
                    bucket_taps += 1
                    if bucket_taps > 3 {
                        spillingMud = true
                        bucket_taps = 100
                        bucket.zRotation = -(CGFloat((Double.pi / 4) / 25) * (CGFloat(bucket_taps)))
                        return
                        // spill the mud (TODO)
                    }
                    bucket.zRotation = -(CGFloat((Double.pi / 4) / 25) * (CGFloat(bucket_taps)))
                   
                }
            }
        }
    }

}
