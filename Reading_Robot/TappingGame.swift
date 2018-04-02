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
    let rectangle = SKSpriteNode(imageNamed: "rectangle")
    let rectLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
    
    let cropNode = SKCropNode()
    let mud = SKSpriteNode(imageNamed: "mud")
    let mud2 = SKSpriteNode(imageNamed: "mud")
    var mudStartY : CGFloat!
    var resetCount = 0
    
    var spillingMud = false
    var bucketFalling = false
    var bucket_taps = 0.0
    
    override func didMove(to view: SKView) {
        backgroundMusicPlayer.stop()
        
        player.size.width = size.width / 5
        player.size.height = size.height / 3.2
        player.position = CGPoint(x: size.width/2, y: size.height * 0.26)
        player.zPosition = 1
        player.xScale = player.xScale * -1;
        addChild(player)
        
        bucket.size.width = size.width / 4
        bucket.size.height = size.height / 3.2
        bucket.position = CGPoint(x: size.width/2 - player.size.width*0.05 , y: size.height * 0.65)
        bucket.zPosition = 2
        addChild(bucket)
        
        // add background to view
        background.size.width = size.width
        background.size.height = size.height
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = 0
        addChild(background)
        
        mudStartY = bucket.position.y - bucket.size.height/2 + mud.size.height/2
        
        mud.size.width = player.size.width
        mud.size.height = frame.size.height*1.3
        mud.position = CGPoint(x: bucket.position.x+15  , y: mudStartY)
        mud.zPosition = 3
        
        mud2.size.width = player.size.width
        mud2.size.height = frame.size.height*1.3
        mud2.position = CGPoint(x: bucket.position.x+15  , y: mudStartY + mud2.size.height - 20)
        mud2.zPosition = 3
        
        let rect = CGRect(x: bucket.position.x - bucket.size.width/2, y: bucket.position.y - bucket.size.height/2.5 - frame.size.height, width: player.size.width*1.2, height: frame.size.height)
        let shapeNode = SKShapeNode(rect: rect)
        shapeNode.fillColor = UIColor.white
        cropNode.maskNode = shapeNode
        cropNode.addChild(mud)
        cropNode.addChild(mud2)
        cropNode.zPosition = -1
        addChild(cropNode)
        
        rectangle.position = CGPoint(x: frame.size.width/2, y: 15*frame.size.height/16)
        rectangle.size.width = size.width / 2
        rectangle.size.height = size.height / 8
        rectangle.zPosition = 2
        addChild(rectangle)
        
        rectLabel.position = CGPoint(x: frame.size.width/2, y: 59*frame.size.height/64)
        rectLabel.fontSize = 48
        rectLabel.zPosition = 3
        rectLabel.text = "Tap the Bucket!"
        addChild(rectLabel)
        
    }
    
    override func update(_ currentTime: TimeInterval){
        if spillingMud {
            cropNode.zPosition = 3
            mud.position.y = mud.position.y - 8
            mud2.position.y = mud2.position.y - 8
            if resetCount < 5 {
                if mud.position.y + mud.size.height/2 < 0 {
                    mud.position.y = mud2.position.y + mud.size.height - 10
                    resetCount += 1
                }else if mud2.position.y  + mud2.size.height/2 < 0 {
                    mud2.position.y = mud.position.y + mud.size.height - 10
                    resetCount += 1
                }
            }else {
                if mud.position.y + mud.size.height/2 < 0 && mud2.position.y  + mud2.size.height/2 < 0 {
                    cropNode.removeAllChildren()
                    cropNode.removeFromParent()
                }
            }
        }else if bucketFalling && bucket_taps < 100{
            bucket_taps += 1
            if bucket_taps > 100 {
                bucket_taps = 100
            }
            bucket.zRotation = -(CGFloat((Double.pi / 4) / 25) * (CGFloat(bucket_taps)))
        }else if bucket_taps == 100 {
            spillingMud = true
        }else if !bucketFalling && bucket_taps > 0.1 {
            bucket_taps = bucket_taps - 0.1
             bucket.zRotation = -(CGFloat((Double.pi / 4) / 25) * (CGFloat(bucket_taps)))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            let touchedNodes = self.nodes(at: currentPoint)
            for node in touchedNodes {
                if node == bucket && !bucketFalling{
                    bucket_taps = bucket_taps +  Double(2 * touches.count)
                    if bucket_taps >= 75 {
                        bucketFalling = true
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
