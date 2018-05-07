//
//  TappingGame.swift
//  Reading_Robot
//
//  Created by Derek Creason on 3/26/18.
//  Copyright © 2018 Derek Creason. All rights reserved.
//
import SQLite3
import SpriteKit
import AVKit
// Tapping game where the user knocks over a bucket of mud onto the opponent robots
//parameters to change here are the bucketScaling and playerScaling floats (bucketScaling used for bucket and for pulling against bucket taps
class TappingGame: SKScene {
    
    let player = SKSpriteNode(imageNamed:oppColor + "_Idle_000")
    let bucket = SKSpriteNode(imageNamed: "bucket")
    let ok_button = SKSpriteNode(imageNamed: "rounded-square")
    let next_button = SKSpriteNode(imageNamed: "rounded-square")
    let rectangle = SKSpriteNode(imageNamed: "rectangle")
    let rectLabel = SKLabelNode(fontNamed: font)
    var viewController : UIViewController!
    var levelFrom : Int!
    
    let cropNode = SKCropNode()
    var mud : SKSpriteNode!
    var mudStartY : CGFloat!
    
    var skipClicked = false
    var spillingMud = false
    var bucketFalling = false
    var gameOver = false
    var bucket_taps = 0.0
    var bucketScaling = CGFloat(1.0)
    var playerScaling = CGFloat(1.0)
    var mudType : String!
    var playerInMud : SKTexture!
    
    override func didMove(to view: SKView) {
        // pause background at start if its already playing
        pauseBackgroundMusic()
        loadTapping()
        
        let background = getBackground(i: levelFrom-1)
        let i = Int(arc4random_uniform(3)) + 1
        if i == 1 {
            mudType = "mud"
            playerInMud = SKTexture(imageNamed: "blue_mud")
        }else if i == 2 {
            mudType = "lava"
            playerInMud = SKTexture(imageNamed: "red mud")
        }else {
            mudType = "slime"
            playerInMud = SKTexture(imageNamed: "green mud")
        }
        
        mud = SKSpriteNode(imageNamed: mudType)
        
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
        
        
        //Crop Node used so that the mud is only visible below the bucket, creates the concept of pouring out of the bucket
        let rect = CGRect(x: bucket.position.x - bucket.size.width/2, y: bucket.position.y - bucket.size.height/2.5 - frame.size.height, width: bucket.size.width, height: frame.size.height)
        let shapeNode = SKShapeNode(rect: rect)
        shapeNode.fillColor = UIColor.white
        cropNode.maskNode = shapeNode
        cropNode.addChild(mud)
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
        if skipClicked && bucket.zRotation < CGFloat.pi{
            bucket.zRotation = CGFloat.pi
            cropNode.removeAllChildren()
            cropNode.removeFromParent()
            player.texture = playerInMud
            bucketFalling = true
            bucket_taps = 100
            gameOver = true
            addPopup()
        }else if spillingMud{
            //put the Crop Node in front so the mud is visible
            cropNode.zPosition = 3
            //Move mud south
            mud.position.y = mud.position.y - 8
            
            if mud.position.y < mudStartY - mud.size.height/2 {
                player.texture = playerInMud
            }
                //If the mud is done falling and both are off the screen get rid of the mud nodes and the cropNode
                if mud.position.y + mud.size.height/2 < 0 {
                    cropNode.removeAllChildren()
                    cropNode.removeFromParent()
                    addPopup()
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
            playSplatEffect()
        }else if !bucketFalling && bucket_taps > 0.1 {
            //this is the pull back against the users taps, this number should be changed based on the difficulty of the level
            bucket_taps = bucket_taps - Double(0.08 * bucketScaling)
             bucket.zRotation = -(CGFloat((Double.pi / 4) / 25) * (CGFloat(bucket_taps)))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            let touchedNodes = self.nodes(at: currentPoint)
            for node in touchedNodes {
                if !bucketFalling{
                    // if the user touches the bucket then increment the bucket taps the number of times the user tapped
                    bucket_taps = bucket_taps +  Double(touches.count)
                    fxPlayer.play()
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
        fxPlayer.pause()
        playTromboneEffect()
        let popup = SKSpriteNode(imageNamed: "rounded-square")
        popup.size.width = size.width/1.5
        popup.size.height = size.height/4
        popup.position = CGPoint(x: size.width/2, y: size.height/2)
        popup.zPosition = 4
        addChild(popup)
        
        let text1 = SKLabelNode(fontNamed: font!)
        text1.text = "Great reading out there \(playerName!)!"
        text1.fontSize = 32
        text1.fontColor = SKColor.black
        text1.position = CGPoint(x: 0, y: popup.size.height / 6)
        text1.zPosition = 5
        popup.addChild(text1)
        
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
            
            ok_button.size.width = popup.size.width / 3
            ok_button.size.height = popup.size.height / 3
            ok_button.position = CGPoint(x: -1 *  popup.size.width / 4, y: -1 * popup.size.height / 4)
            ok_button.zPosition = 6
            ok_button.colorBlendFactor = 1.0
            ok_button.color = UIColor(red: 0, green: 0.6784, blue: 0.949, alpha: 1.0) /* #00adf2 */
            popup.addChild(ok_button)
            
            //"OK" text on the button
            let ok_text = SKLabelNode(fontNamed: font!)
            ok_text.text = "Home"
            ok_text.fontSize = 32
            ok_text.fontColor = SKColor.black
            ok_text.position = CGPoint(x: 0, y: -15)
            ok_text.zPosition = 7
            ok_button.addChild(ok_text)
            
            next_button.size.width = popup.size.width / 3
            next_button.size.height = popup.size.height / 3
            next_button.position = CGPoint(x: popup.size.width/4, y: -1 * popup.size.height / 4)
            next_button.zPosition = 6
            next_button.colorBlendFactor = 1.0
            next_button.color = UIColor(red: 0, green: 0.6784, blue: 0.949, alpha: 1.0) /* #00adf2 */
            popup.addChild(next_button)
            
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
            
            ok_button.size.width = popup.size.width / 3
            ok_button.size.height = popup.size.height / 3
            ok_button.position = CGPoint(x: 0 , y: -1 * popup.size.height / 4)
            ok_button.zPosition = 6
            ok_button.colorBlendFactor = 1.0
            ok_button.color = UIColor(red: 0, green: 0.6784, blue: 0.949, alpha: 1.0) /* #00adf2 */
            popup.addChild(ok_button)
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
    
    func playSplatEffect() {
        
        //The location of the file and its type
        let filepath = Bundle.main.path(forResource: "splat", ofType: "mp3")
        
        //Returns an error if it can't find the file name
        if (filepath == nil) {
            print("Could not find the file splat.mp3")
        }
        
        let url = URL(fileURLWithPath: filepath!)
        //Assigns the actual music to the music player
        do{
            fxPlayer =  try AVAudioPlayer(contentsOf: url)
        }catch{
            print("Could not create audio player")
        }
        
        fxPlayer.volume = 0.7
        fxPlayer.prepareToPlay()
        fxPlayer.play()
    }
    
    func playTromboneEffect() {
        
        //The location of the file and its type
        let filepath = Bundle.main.path(forResource: "trombone", ofType: "mp3")
        
        //Returns an error if it can't find the file name
        if (filepath == nil) {
            print("Could not find the file splat.mp3")
        }
        
        let url = URL(fileURLWithPath: filepath!)
        //Assigns the actual music to the music player
        do{
            fxPlayer =  try AVAudioPlayer(contentsOf: url)
        }catch{
            print("Could not create audio player")
        }
        
        fxPlayer.volume = 0.7
        fxPlayer.prepareToPlay()
        fxPlayer.play()
    }
    
    func loadTapping() {
        //The location of the file and its type
        let filepath = Bundle.main.path(forResource: "tap", ofType: "mp3")
        
        //Returns an error if it can't find the file name
        if (filepath == nil) {
            print("Could not find the file tap.mp3")
        }
        
        let url = URL(fileURLWithPath: filepath!)
        //Assigns the actual music to the music player
        do{
            fxPlayer =  try AVAudioPlayer(contentsOf: url)
        }catch{
            print("Could not create audio player")
        }
        

        fxPlayer.volume = 0.7
        fxPlayer.prepareToPlay()
    }
    

}
