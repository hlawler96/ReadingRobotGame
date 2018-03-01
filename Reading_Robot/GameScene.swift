
import SpriteKit
import SQLite3

class GameScene: SKScene {
    
    // 1
    let rope = SKSpriteNode(imageNamed: "rope")
    let background = SKSpriteNode(imageNamed: "LevelBackground1")
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
    
    var correctWords = [String]()
    var Words = [String]()
    
    var correctCounter = 0
    var wordCounter = 0
    
    let timeOfGame = 30.0
    
    var cloudArray = [SKSpriteNode]()
    
    override func didMove(to view: SKView) {
        
        background.size.width = size.width
        background.size.height = size.height
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = 0
        addChild(background)
        
        player.size.width = size.width / 3.1
        player.size.height = size.height / 2
        player.position = CGPoint(x: size.width * 0.8 , y: size.height * 0.33)
        player.zPosition = 2
        addChild(player)
        
        
        player2.size.width = size.width / 3.1
        player2.size.height = size.height / 2
        player2.position = CGPoint(x: size.width * 0.2 , y: size.height * 0.33)
        player2.zPosition = 2
        player2.xScale = player2.xScale * -1
        addChild(player2)
        
        rope.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 4  - player.size.height/4 + size.height * 0.08)
        rope.size.width = size.width * 0.6
        rope.size.height = player.size.height / 3
        rope.zPosition = 1
        addChild(rope)
        
       
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("test.sqlite")
        // open database
        var db: OpaquePointer?
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        correctWords = getRandomCorrectWords(phoneme: "-ck", db: db)
        Words = getRandomWrongWords(phoneme: "not-ck", db: db)
        Words.append(contentsOf: correctWords)
        Words.shuffle()
        
        
        insertCloud(x: size.width * 0.2, y: size.height * 0.8)
        insertCloud(x: size.width * 0.5, y: size.height * 0.8)
        insertCloud(x: size.width * 0.8 , y: size.height * 0.8)
        
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
    
    
    func insertCloud(x: CGFloat, y: CGFloat){
        print("inserting cloud")
        let cloud = SKSpriteNode(imageNamed: "cloud-cartoon")
        cloud.position = CGPoint(x: x, y: y)
        cloud.size.width = size.width / 4
        cloud.size.height = size.height / 4
        cloud.zPosition = 1
        addChild(cloud)
        cloudArray.append(cloud)
        
        let text = SKLabelNode(fontNamed: "MarkerFelt-Thin")
        text.text = Words[wordCounter]
        text.fontSize = 32
        text.fontColor = SKColor.black
        text.position = CGPoint(x: x, y: y - cloud.size.height / 8)
        text.zPosition = 2
        addChild(text)
        
        wordCounter = wordCounter + 1
        
    }
    
    func getRandomCorrectWords(phoneme: String, db: OpaquePointer?) -> [String] {
        var wordArray = [String]()
        let queryString = "select word from Words where phoneme = '" + phoneme + "'"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return []
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let word = String(cString: sqlite3_column_text(stmt, 0))
            //adding values to list
            wordArray.append(word)
        }
        wordArray.shuffle();
        wordArray = Array(wordArray.prefix(7))
        return wordArray
    }
    
    func getRandomWrongWords(phoneme: String, db: OpaquePointer?) -> [String] {
        var wordArray = [String]()
        let queryString = "select word from Words where phoneme = '" + phoneme + "'"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return []
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let word = String(cString: sqlite3_column_text(stmt, 0))
            //adding values to list
            wordArray.append(word)
        }
        wordArray.shuffle();
        wordArray = Array(wordArray.prefix(14))
        return wordArray
    }
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}





