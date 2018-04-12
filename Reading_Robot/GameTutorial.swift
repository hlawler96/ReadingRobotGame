
import SpriteKit

class GameTutorial: SKScene {
    let rope = SKSpriteNode(imageNamed: "rope")
    let background = SKSpriteNode(imageNamed: "LevelBackground1")
    var player = SKSpriteNode(imageNamed: "Blue_Attack_005")
    let player2 = SKSpriteNode(imageNamed: "Red_Attack_005")
    let bottom = SKSpriteNode(imageNamed: "rectangle-2")
    var popup: SKShapeNode!
    let arrow = SKSpriteNode(imageNamed: "arrow")
    let scoreboard = SKSpriteNode(imageNamed: "rectangle")
    let label = SKLabelNode(fontNamed: font)
    let popupText = SKLabelNode(fontNamed: font)
    var viewController : UIViewController!
    
    var cloudPeriod: Double!
    var count = 0
    var circles = [SKShapeNode]()

    var playerOneStartX: CGFloat!
    var playerTwoStartX: CGFloat!

    var gamePaused = true
    
    var cloudArray = [SKSpriteNode]()
    var wordsShownArray = [SKLabelNode] ()

    
    // function called at start of game
    override func didMove(to view: SKView) {
        
        pauseBackgroundMusic()
        
        
        // add background to view
        background.size.width = size.width
        background.size.height = size.height
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = 0
        addChild(background)
        
        playerOneStartX = size.width * 0.8
        playerTwoStartX = size.width * 0.2
        
        //add right player to the game
        player.size.width = size.width / 2.5
        player.size.height = size.height / 1.6
        player.position = CGPoint(x: playerOneStartX , y: size.height * 0.31)
        player.zPosition = 2
        addChild(player)
        
        //add left player to the game
        player2.size.width = size.width / 2.5
        player2.size.height = size.height / 1.6
        player2.position = CGPoint(x: playerTwoStartX , y: size.height * 0.31)
        player2.zPosition = 2
        player2.xScale = player.xScale * -1;
        addChild(player2)
        
        //add rope to the game
        rope.position = CGPoint(x: frame.size.width / 2, y: frame.size.height * 0.35  - player.size.height/4 )
        rope.size.width = size.width * 0.46
        rope.size.height = player.size.height / 10
        rope.zPosition = 1
        addChild(rope)
        
        //add bottom board to the game
        bottom.position = CGPoint(x: frame.size.width/2, y:frame.size.height*0.08)
        bottom.size.height = frame.size.height * 0.16
        bottom.size.width  = frame.size.width
        bottom.zPosition = 3
        addChild(bottom)
        
        //add label for the bottom board, initialize with the pattern and then changed to ready, set , tug of war through first 5 seconds
        label.text = "Your Pattern is: CK"
        label.position = CGPoint(x: frame.size.width/2, y: frame.size.height*0.04)
        label.fontSize = 100
        label.zPosition = 4
        label.fontColor = UIColor.white
        addChild(label)
        
        
        //add scoreboard at top of screen to the game
        scoreboard.position = CGPoint(x: frame.size.width/2, y: 15*frame.size.height/16)
        scoreboard.size.width = size.width / 2
        scoreboard.size.height = size.height / 8
        scoreboard.zPosition = 2
        addChild(scoreboard)
        
        let rect = CGRect(x: 0 , y: 0, width: size.width/2, height: size.height / 6)
        popup = SKShapeNode(rect: rect, cornerRadius: rect.size.width / 10)
        popup.position = CGPoint(x: size.width/4, y: size.height/2)
        popup.fillColor = UIColor.cyan
        popup.strokeColor = UIColor.black
        popup.zPosition = 5
        addChild(popup)
        
        popupText.position = CGPoint(x: size.width/2 , y: size.width/2 - rect.height/2)
        popupText.fontSize = 40
        popupText.preferredMaxLayoutWidth = rect.size.width
        popupText.zPosition = 6
        popupText.numberOfLines = 4
        popupText.horizontalAlignmentMode = .center
        popupText.verticalAlignmentMode = .center
        popupText.fontColor = UIColor.black
        
        arrow.zPosition = -1
        arrow.colorBlendFactor = 1.0
        arrow.color = UIColor.cyan
        addChild(arrow)
        
        popupText.text = "Tap to Start Tutorial"
        addChild(popupText)
        
        // Adds 3 clouds to the game. Cloud nodes are resized and have the text changed throughout the game but only 3 objects are ever created
        insertCloud(x: size.width * 0.2, y: size.height * 0.65, count: 1)
        insertCloud(x: size.width * 0.5, y: size.height * 0.65, count: 2)
        insertCloud(x: size.width * 0.8 , y: size.height * 0.65 ,count: 3)
        
        //set circle parameters for scoreboard to scale with numWords
        let buffer = scoreboard.size.width / 64
        let numCircles = CGFloat(7)
        let radius = (scoreboard.size.width - numCircles * buffer) / (numCircles * 2)
        let diameter = 2.0 * radius
        let startX = (scoreboard.position.x - scoreboard.size.width / 2 ) + 2.0 * radius + buffer
        
        // add properly scaled circles to the scoreboard
        for i in 0 ... 5 {
            let circle = SKShapeNode(circleOfRadius: radius)
            circle.position.x = startX + CGFloat(i) * (diameter + buffer)
            circle.position.y = scoreboard.position.y
            circle.zPosition = 3
            circle.name = "circle-\(i+1)"
            circles.append(circle)
            addChild(circle)
        }
        
        cloudPeriod = 3.0
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gamePaused {
            count += 1
            updatePopup(count: count)
        }
        return
    }
    
    
    
    func insertCloud(x: CGFloat, y: CGFloat, count: Int){
        // create spritenode and label node for cloud and words and store in an array so they can be referenced later on without name lookup
        let cloud = SKSpriteNode(imageNamed: "cloud-cartoon")
        cloud.position = CGPoint(x: x, y: y)
        //grow to size.width / 4
        if !stillMode {
            cloud.size.width = 0
            cloud.size.height = 0
        } else {
            cloud.size.width = size.width/4
            cloud.size.height = size.height/4
        }
        cloud.zPosition = 1
        addChild(cloud)
        cloud.name = "cloud-\(count)"
        cloudArray.append(cloud)
        
        let text = SKLabelNode(fontNamed: font!)
        text.text = ""
        text.fontSize = 50
        text.fontColor = SKColor.black
        text.position = CGPoint(x: x, y: y - frame.size.height/32 )
        text.zPosition = 2
        addChild(text)
        wordsShownArray.append(text)
    }
    
    
    
    func updatePopup(count: Int) {
        let pause = SKAction.customAction(withDuration: cloudPeriod/9.0) {
            node, elapsedTime in
            self.gamePaused = true
        }
        if count == 1 {
            let rect = CGRect(x: 0 , y: 0, width: size.width/4, height: size.width/4)
            popup.removeFromParent()
            popup = SKShapeNode(rect: rect, cornerRadius: rect.size.width / 6)
            popup.position = CGPoint(x: 5*size.width/8, y: size.height/4)
            popup.fillColor = UIColor.cyan
            popup.strokeColor = UIColor.black
            popup.zPosition = 5
            addChild(popup)
            
            popupText.text = "This is the pattern you are looking for!"
            popupText.position = CGPoint(x: popup.position.x + rect.width/2, y: popup.position.y + rect.height/2)
            popupText.fontSize = 32
            popupText.preferredMaxLayoutWidth = rect.size.width
            popupText.zPosition = 6
            popupText.numberOfLines = 4
            popupText.horizontalAlignmentMode = .center
            popupText.verticalAlignmentMode = .center
            popupText.fontColor = UIColor.black
            
            arrow.size.height = popup.position.y - (bottom.position.y + bottom.size.height/2)
            arrow.size.width = rect.size.width/2
            arrow.zRotation =  CGFloat(-1 *  Double.pi / 4 )
            arrow.position = CGPoint(x: popup.position.x + 3*rect.width/4, y: popup.position.y - arrow.size.height/2)
            arrow.zPosition = 4
            arrow.colorBlendFactor = 1.0
            arrow.color = UIColor.cyan
            
        }else if count == 2 {
            popupText.text = "Make sure you remember the pattern! It will dissappear when the game starts"
            
        }else if count == 3 {
            gamePaused = false
            cloudArray[0].run(SKAction.sequence([ SKAction.resize(toWidth: size.width/4, height: size.height/4, duration: cloudPeriod/3.0), pause]))
            wordsShownArray[0].text = "pick"
            
            let rect = CGRect(x: 0 , y: 0, width: size.width/4, height: size.width/5)
            popup.removeFromParent()
            popup = SKShapeNode(rect: rect, cornerRadius: rect.size.width / 8)
            popup.position = CGPoint(x: 3*size.width/8, y: size.height/2)
            popup.fillColor = UIColor.cyan
            popup.strokeColor = UIColor.black
            popup.zPosition = 5
            addChild(popup)
            
            popupText.text = "When a word with the pattern appears, tap it!"
            popupText.position = CGPoint(x: popup.position.x + rect.width/2, y: popup.position.y + rect.height/2)
            popupText.fontSize = 32
            popupText.preferredMaxLayoutWidth = rect.size.width
            popupText.zPosition = 6
            popupText.numberOfLines = 4
            popupText.horizontalAlignmentMode = .center
            popupText.verticalAlignmentMode = .center
            popupText.fontColor = UIColor.black
            
            arrow.size.height = rect.height / 3
            arrow.size.width = 2 * (popup.position.x - cloudArray[0].position.x) / 3
            arrow.zRotation =  CGFloat(Double.pi)
            arrow.position = CGPoint(x: popup.position.x - arrow.size.width/2, y: popup.position.y + rect.height/2)
            arrow.zPosition = 4
            arrow.colorBlendFactor = 1.0
            arrow.color = UIColor.cyan
            
        }else if count == 4 {
            gamePaused = false
            cloudArray[0].run(SKAction.sequence([SKAction.resize(toWidth: 0, height: 0, duration: cloudPeriod/3.0), pause]))
            wordsShownArray[0].text = ""
            
            popupText.text = "When you click a right answer you get a green circle up top!"
            
            let rect = CGRect(x: 0 , y: 0, width: size.width/4, height: size.width/5)
            arrow.zRotation = CGFloat(8 * Double.pi / 12)
            arrow.size.width = (scoreboard.position.y - scoreboard.size.height/2) - (popup.position.y + rect.size.height)
            arrow.size.height = rect.width / 3
            circles[0].fillColor = UIColor.green
            arrow.position = CGPoint(x: popup.position.x , y: popup.position.y + rect.height + arrow.size.height/2)
            
        }else if count == 5 {
            circles[0].fillColor = UIColor.clear
            cloudArray[0].size.width = size.width/4
            cloudArray[0].size.height = size.height/4
            gamePaused = false
            let wait = SKAction.wait(forDuration: cloudPeriod/3.0)
            let shrink = SKAction.resize(toWidth: 0, height: 0, duration: cloudPeriod/3.0)
            let recolor = SKAction.customAction(withDuration: 0) {
                node, elapsedTime in
                
                self.wordsShownArray[0].text = ""
                self.circles[0].fillColor = UIColor.red
                self.gamePaused = true
            }
            cloudArray[0].run(SKAction.sequence([wait, recolor, shrink]))
            wordsShownArray[0].text = "pick"
            popupText.text = "If you wait too long the word will dissapear and you get a red circle"
            let rect = CGRect(x: 0 , y: 0, width: size.width/4, height: size.width/5)
            arrow.size.height = rect.height / 3
            arrow.size.width = 2 * (popup.position.x - cloudArray[0].position.x) / 3
            arrow.zRotation =  CGFloat(Double.pi)
            arrow.position = CGPoint(x: popup.position.x - arrow.size.width/2, y: popup.position.y + rect.height/2)
            arrow.zPosition = 4
            arrow.colorBlendFactor = 1.0
            arrow.color = UIColor.cyan
            
            
        }else if count == 6 {
            circles[0].fillColor = UIColor.clear
            cloudArray[0].size.width = size.width/4
            cloudArray[0].size.height = size.height/4
            wordsShownArray[0].text = "trap"
            popupText.text = "If you tap a wrong word, you get a red X"
            let rect = CGRect(x: 0 , y: 0, width: size.width/4, height: size.width/5)
            arrow.size.height = rect.height / 3
            arrow.size.width = 2 * (popup.position.x - cloudArray[0].position.x) / 3
            arrow.zRotation =  CGFloat(Double.pi)
            arrow.position = CGPoint(x: popup.position.x - arrow.size.width/2, y: popup.position.y + rect.height/2)
            arrow.zPosition = 4
            arrow.colorBlendFactor = 1.0
            arrow.color = UIColor.cyan
            
            
        }else if count == 7 {
            cloudArray[0].run(SKAction.resize(toWidth: 0, height: 0 , duration: cloudPeriod/3))
            wordsShownArray[0].text = ""
            arrow.size.height = size.width/15
            arrow.size.width = (popup.position.x - cloudArray[0].position.x) / 2
            arrow.zRotation = CGFloat(7 * Double.pi / 12)
            arrow.position = CGPoint(x: popup.position.x - arrow.size.height/2 , y: popup.position.y + size.width/10 + arrow.size.height/2)
            let x = SKSpriteNode(imageNamed: "X")
            x.size.height = circles[0].frame.height
            x.size.width = circles[0].frame.width
            x.position = CGPoint(x: circles[0].position.x , y: circles[0].position.y - scoreboard.size.height)
            x.zPosition = 2
            addChild(x)
            
        }else if count == 8 {
            circles[0].fillColor = UIColor.green
            circles[1].fillColor = UIColor.green
            circles[2].fillColor = UIColor.red
            circles[3].fillColor = UIColor.green
            circles[4].fillColor = UIColor.green
            circles[5].fillColor = UIColor.green
            
            arrow.zPosition = -1
            
            popupText.text = "If you get enough green circles and only a few red X's you win!"
        }else if count == 9 {
            popupText.text = "Based on how well you do, you'll earn 1, 2, or 3 stars!"
        }else if count == 10 {
            popupText.text = "Lets give this a try, tap to go and choose your robot!"
        }else {
            viewController.performSegue(withIdentifier: "TUTORIAL_END", sender: viewController)
        }
        
    }
    
    
}



