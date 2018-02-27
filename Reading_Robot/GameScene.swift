
import SpriteKit
import SQLite3

class GameScene: SKScene {
    
    // 1
    let rope = SKSpriteNode(imageNamed: "rope")
    let background = SKSpriteNode(imageNamed: "Classroom")
    let player = SKSpriteNode(imageNamed: "Attack_005")
    let player2 = SKSpriteNode(imageNamed: "Attack_005")
    let walk0 = SKTexture(imageNamed: "Walk_000")
    let walk1 = SKTexture(imageNamed: "Walk_001")
    let walk2 = SKTexture(imageNamed: "Walk_002")
    let walk3 = SKTexture(imageNamed: "Walk_003")
    let walk4 = SKTexture(imageNamed: "Walk_004")
    let walk5 = SKTexture(imageNamed: "Walk_005")
    let walk6 = SKTexture(imageNamed: "Walk_006")
    let walk7 = SKTexture(imageNamed: "Walk_007")
    let walk8 = SKTexture(imageNamed: "Walk_008")
    let walk9 = SKTexture(imageNamed: "Walk_009")
    
    let pull0 = SKTexture(imageNamed: "Attack_007")
    let pull1 = SKTexture(imageNamed: "Attack_006")
    let pull2 = SKTexture(imageNamed: "Attack_005")
    let pull3 = SKTexture(imageNamed: "Attack_006")
    let pull4 = SKTexture(imageNamed: "Attack_007")
    
    var cloudArray = [SKSpriteNode]()
    
    override func didMove(to view: SKView) {
        player.size.width = size.width / 3.1
        player.size.height = size.height / 2
        player.position = CGPoint(x: size.width * 0.8 , y: size.height * 0.25)
        player.zPosition = 2
        addChild(player)
        
        
        player2.size.width = size.width / 3.1
        player2.size.height = size.height / 2
        player2.position = CGPoint(x: size.width * 0.2 , y: size.height * 0.25)
        player2.zPosition = 2
        player2.xScale = player2.xScale * -1
        addChild(player2)
        
        rope.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 4  - player.size.height/4)
        rope.size.width = size.width * 0.6
        rope.size.height = player.size.height / 3
        rope.zPosition = 1
        addChild(rope)
        
        insertCloud(x: size.width * 0.2, y: size.height * 0.8)
        insertCloud(x: size.width * 0.5, y: size.height * 0.8)
        insertCloud(x: size.width * 0.8 , y: size.height * 0.8)
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("test.sqlite")
        // open database
        var db: OpaquePointer?
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        printDB(db: db)
    }
    
    override func  touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let robotVelocity = self.frame.size.width / 6.0
        
        //choose one of the touches to work with
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            var multiplierForDirection : CGFloat
            if (currentPoint.x <= player.position.x) {
                // walk left
                multiplierForDirection = 1.0
            } else {
                // walk right
                multiplierForDirection = -1.0
            }
            player.xScale = fabs(player.xScale) * multiplierForDirection
            let walkingTime = fabs(player.position.x - currentPoint.x)  / robotVelocity
            
            //check if robot is moving if so stop the old walking so we can start the new walking
            if(player.action(forKey: "movingRobot") == nil){
                player.removeAction(forKey: "movingRobot")
            }
            //check if robot is already walking or not, if not start
            if(player.action(forKey: "walkingRobot") == nil){
                walkingRobot()
            }
            
            let moveAction = SKAction.moveTo(x: currentPoint.x, duration: Double(walkingTime))
            let idleAction = SKAction.run{
                self.idleRobot()
            }
            let sequence = SKAction.sequence([moveAction, idleAction])
            player.run(sequence, withKey:"movingRobot")
            
            
        }else {
            return
        }
        
        // pulling motion on every click
        pullingRobot()
        
    }
    
    func walkingRobot(){
        let walking = [walk0, walk1, walk2, walk3, walk4, walk5, walk6, walk7, walk8, walk9]
        let walkAnimation = SKAction.animate(with: walking, timePerFrame: 0.1)
        player.run(SKAction.repeatForever(walkAnimation), withKey:"walkingRobot")
    }
    
    func idleRobot(){
        player.removeAction(forKey: "walkingRobot")
    }
    
    func pullingRobot(){
        let pulling = [pull0, pull1, pull2, pull3, pull4]
        let pullAnimation = SKAction.animate(with: pulling, timePerFrame: 0.15)
        player.run(pullAnimation)
    }
    
    func printDB(db: OpaquePointer?){
        var wordList = [Word]()
        
        let queryString = "select phoneme, word from Words"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let phoneme = String(cString: sqlite3_column_text(stmt, 0))
            let word = String(cString: sqlite3_column_text(stmt, 1))
            
            //adding values to list
            wordList.append(Word(phoneme: phoneme, word: word))
            print("Phoneme: " + phoneme + " , Word: " + word)
        }
    }
    
    func insertCloud(x: CGFloat, y: CGFloat){
        let cloud = SKSpriteNode(imageNamed: "cloud-cartoon")
        cloud.position = CGPoint(x: x, y: y)
        cloud.size.width = size.width / 4
        cloud.size.height = size.height / 4
        cloud.zPosition = 0
        addChild(cloud)
        cloudArray.append(cloud)
        
    }
}




