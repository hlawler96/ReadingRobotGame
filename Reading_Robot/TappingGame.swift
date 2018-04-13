//
//  TappingGame.swift
//  Reading_Robot
//
//  Created by Hayden Lawler on 3/26/18.
//  Copyright © 2018 Hayden Lawler. All rights reserved.
//
import SQLite3
import SpriteKit
// Tapping game where the user knocks over a bucket of mud onto the opponent robots
//parameters to change here are the bucketScaling and playerScaling floats (bucketScaling used for bucket and for pulling against bucket taps
class TappingGame: SKScene {
    
    let player = SKSpriteNode(imageNamed:oppColor + "_Idle_000")
    let bucket = SKSpriteNode(imageNamed: "bucket")
    let background = SKSpriteNode(imageNamed: "LevelBackground1")
    let ok_button = SKSpriteNode(imageNamed: "rounded-square")
    let next_button = SKSpriteNode(imageNamed: "rounded-square")
    let rectangle = SKSpriteNode(imageNamed: "rectangle")
    let rectLabel = SKLabelNode(fontNamed: font)
    var viewController : UIViewController!
    var levelFrom : Int!
    
    let cropNode = SKCropNode()
    var mud : SKSpriteNode!
    var mud2 : SKSpriteNode!
    var mudStartY : CGFloat!
    var resetCount = 0
    
    var spillingMud = false
    var bucketFalling = false
    var gameOver = false
    var bucket_taps = 0.0
    var bucketScaling = CGFloat(1.0)
    var playerScaling = CGFloat(1.0)
    var mudType = "mud"
    
    override func didMove(to view: SKView) {
        // pause background at start if its already playing
        pauseBackgroundMusic()
        mud = SKSpriteNode(imageNamed: mudType)
        mud2 = SKSpriteNode(imageNamed: mudType)
        
        //add opposing player to the scene, size should be determined by difficulty of the level
        player.size.width = size.width / 5 * playerScaling
        player.size.height = size.height / 3.2 * playerScaling
        player.position = CGPoint(x: size.width/2, y: size.height * 0.1 + player.size.height/2.2)
        player.zPosition = 1
        addChild(player)
        
        // add bucket to the scene and place it directly over the player
        bucket.size.width = size.width / 4 * bucketScaling
        bucket.size.height = size.height / 3.2 * bucketScaling
        bucket.position = CGPoint(x: size.width/2 - player.size.width*0.05 , y: size.height * 0.65)
        bucket.zPosition = 2
        addChild(bucket)
        
        // add background to view
        background.size.width = size.width
        background.size.height = size.height
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = 0
        addChild(background)
        
        //keep track of mud start Y for replacing mud once it has fallen too far
        mudStartY = bucket.position.y - bucket.size.height/2 + mud.size.height/2
        
        // add first mud to the scene, hidden until spillingMud = true
        mud.size.width = bucket.size.width * 0.8
        mud.size.height = frame.size.height * 1.3
        mud.position = CGPoint(x: bucket.position.x+15  , y: mudStartY)
        mud.zPosition = 3
        
        // second mud node used so that you can have one node visible on the scene and the other node can be moved to create a continuous stream
        mud2.size = mud.size
        mud2.position = CGPoint(x: bucket.position.x+15  , y: mudStartY + mud2.size.height - 20)
        mud2.zPosition = 3
        
        //Crop Node used so that the mud is only visible below the bucket, creates the concept of pouring out of the bucket
        let rect = CGRect(x: bucket.position.x - bucket.size.width/2, y: bucket.position.y - bucket.size.height/2.5 - frame.size.height, width: bucket.size.width, height: frame.size.height)
        let shapeNode = SKShapeNode(rect: rect)
        shapeNode.fillColor = UIColor.white
        cropNode.maskNode = shapeNode
        cropNode.addChild(mud)
        cropNode.addChild(mud2)
        cropNode.zPosition = -1
        addChild(cropNode)
        
        // same scorboard image used at top to display text
        rectangle.position = CGPoint(x: frame.size.width/2, y: 15*frame.size.height/16)
        rectangle.size.width = size.width / 2
        rectangle.size.height = size.height / 8
        rectangle.zPosition = 2
        addChild(rectangle)
        
        // Simple label on rectangle to give instructions for the tapping game
        rectLabel.position = CGPoint(x: frame.size.width/2, y: 59*frame.size.height/64)
        rectLabel.fontSize = 48
        rectLabel.zPosition = 3
        rectLabel.text = "Tap the Bucket!"
        addChild(rectLabel)
        
    }
    
    override func update(_ currentTime: TimeInterval){
        // spillingMud set to true once the bucket is all the way upside down
        if spillingMud {
            //put the Crop Node in front so the mud is visible
            cropNode.zPosition = 3
            //Move mud south
            mud.position.y = mud.position.y - 8
            mud2.position.y = mud2.position.y - 8
            
            //only drop mud until the mud has fallen completely 5 times, this number could be changed based on difficulty
            if resetCount < 3 {
                if mud.position.y + mud.size.height/2 < 0 {
                    mud.position.y = mud2.position.y + mud.size.height - 10
                    resetCount += 1
                }else if mud2.position.y  + mud2.size.height/2 < 0 {
                    mud2.position.y = mud.position.y + mud.size.height - 10
                    resetCount += 1
                }
            }else {
                //If the mud is done falling and both are off the screen get rid of the mud nodes and the cropNode
                if mud.position.y + mud.size.height/2 < 0 && mud2.position.y  + mud2.size.height/2 < 0 {
                    cropNode.removeAllChildren()
                    cropNode.removeFromParent()
                    addPopup()
                }
            }
        }else if bucketFalling && bucket_taps < 100{
            //Once the user clicks 75 times the bucket falls the rest of the way
            bucket_taps += 1
            if bucket_taps > 100 {
                //round the number once it hits 100
                bucket_taps = 100
            }
            bucket.zRotation = -(CGFloat((Double.pi / 4) / 25) * (CGFloat(bucket_taps)))
        }else if bucket_taps == 100 && !gameOver{
            //once the taps are at 100 start spilling the mud
            spillingMud = true
        }else if !bucketFalling && bucket_taps > 0.1 {
            //this is the pull back against the users taps, this number should be changed based on the difficulty of the level
            bucket_taps = bucket_taps - Double(0.4 * bucketScaling)
             bucket.zRotation = -(CGFloat((Double.pi / 4) / 25) * (CGFloat(bucket_taps)))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            let touchedNodes = self.nodes(at: currentPoint)
            for node in touchedNodes {
                if node == bucket && !bucketFalling{
                    // if the user touches the bucket then increment the bucket taps the number of times the user tapped
                    bucket_taps = bucket_taps +  Double(2 * touches.count)
                    if bucket_taps >= 75 {
                        //once the user has tapped 75 times then start the bucket tipping over the rest of the way
                        bucketFalling = true
                    }
                    bucket.zRotation = -(CGFloat(Double.pi / 100.0) * (CGFloat(bucket_taps)))
                   
                }else if node == ok_button {
                    viewController.performSegue(withIdentifier: "UNWIND_TO_LEVEL_MENU", sender: viewController)
                }else if node == next_button {
                    viewController.performSegue(withIdentifier: "UNWIND_TO_GAME", sender: viewController)
                }
                
            }
        }
    }
    
    func addPopup() {
        //endgame message, showing number of stars earned
        let popup = SKSpriteNode(imageNamed: "rounded-square")
        popup.size.width = size.width/1.3
        popup.size.height = size.height/1.3
        popup.position = CGPoint(x: size.width/2, y: size.height/2)
        popup.zPosition = 4
        addChild(popup)
        
        let text1 = SKLabelNode(fontNamed: font!)
        text1.text = "Great reading out there!"
        text1.fontSize = 32
        text1.fontColor = SKColor.black
        text1.position = CGPoint(x: 0, y: -1 *  popup.size.height / 4)
        text1.zPosition = 5
        popup.addChild(text1)
        
        let user = SKSpriteNode(imageNamed: userColor + "_Idle_000")
        user.size.width = size.width / 2.5
        user.size.height = size.height / 1.6
        user.position = CGPoint(x: size.width/2, y: size.height * 0.6)
        user.zPosition = 7
        addChild(user)
        
        //check and see if there is another level left to paly
        var numLevels = 0
        let queryString = "SELECT COUNT(L.number) from LevelData L"
        var stmt:OpaquePointer?
        if sqlite3_prepare(db2, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        while(sqlite3_step(stmt) == SQLITE_ROW){
            numLevels = Int(sqlite3_column_int(stmt, 0))
            break;
        }
        sqlite3_finalize(stmt)
        
        if levelFrom + 1 <= numLevels {
            //button to remove results prompt and clouds to make room for the bucket game
            
            ok_button.size.width = size.width/5
            ok_button.size.height = size.height/8.3
            ok_button.position = CGPoint(x: size.width/2 - popup.size.width / 4, y: size.height/6 + 30)
            ok_button.zPosition = 6
            ok_button.colorBlendFactor = 1.0
            ok_button.color = UIColor(red: 0, green: 0.6784, blue: 0.949, alpha: 1.0) /* #00adf2 */
            addChild(ok_button)
            
            //"OK" text on the button
            let ok_text = SKLabelNode(fontNamed: font!)
            ok_text.text = "Home"
            ok_text.fontSize = 32
            ok_text.fontColor = SKColor.black
            ok_text.position = CGPoint(x: 0, y: -15)
            ok_text.zPosition = 7
            ok_button.addChild(ok_text)
            
            next_button.size.width = size.width/5
            next_button.size.height = size.height/8.3
            next_button.position = CGPoint(x: size.width/2 + popup.size.width / 4, y: size.height/6 + 30)
            next_button.zPosition = 6
            next_button.colorBlendFactor = 1.0
            next_button.color = UIColor(red: 0, green: 0.6784, blue: 0.949, alpha: 1.0) /* #00adf2 */
            addChild(next_button)
            
            //"OK" text on the button
            let next_text = SKLabelNode(fontNamed: font!)
            next_text.text = "Next Level"
            next_text.fontSize = 32
            next_text.fontColor = SKColor.black
            next_text.position = CGPoint(x: 0, y: -15)
            next_text.zPosition = 7
            next_button.addChild(next_text)
            
        }else {
            //button to remove results prompt and clouds to make room for the bucket game
            
            ok_button.size.width = size.width/5
            ok_button.size.height = size.height/8.3
            ok_button.position = CGPoint(x: size.width/2 , y: size.height/6 + 30)
            ok_button.zPosition = 6
            ok_button.colorBlendFactor = 1.0
            ok_button.color = UIColor(red: 0, green: 0.6784, blue: 0.949, alpha: 1.0) /* #00adf2 */
            addChild(ok_button)
            //"OK" text on the button
            let ok_text = SKLabelNode(fontNamed: font!)
            ok_text.text = "Home"
            ok_text.fontSize = 32
            ok_text.fontColor = SKColor.black
            ok_text.position = CGPoint(x: 0, y: -15)
            ok_text.zPosition = 7
            ok_button.addChild(ok_text)
            
            
        }
        
        spillingMud = false
        gameOver = true
        
    }

}
