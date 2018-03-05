
import SpriteKit
import SQLite3

//TODO:
// 1) Fix the scoreboard to center circles better and include the scores on the board itself - Hayden
// 2) Add labels to players and scores at the top - ??
// 3) Change the timing of clouds dissappearing/reappearing to go off of variable time instead of using mod - Hayden
// 4) Animate the tug of war during the game - ??
// 5) Add an end game animation based on the number of stars - ??
// 6) Have the phoneme spoken at the beginning of the mini game with possible time delay / "Start" popup message - ??
// 7) change the constructor to take in parameters to allow for multiple levels using the same GameScene object type - Hayden
// 8) Add an extra frame to the rope pulling animation to make animation cleaner - ??
// 9) Figure out way to center text on clouds with varying device screen size - Hayden
// 10) Read in words from project db file and not the db file stored on the local machine - Hayden

class GameScene: SKScene {
    
     var db: OpaquePointer?
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
    let scoreboard = SKSpriteNode(imageNamed: "rectangle")
    let homeScore = SKLabelNode()
    let awayScore = SKLabelNode()
    
    var homePoints = 0
    var awayPoints = 0
    
    
    var correctWords = [String]()
    var Words = [String]()
    var wrongAnswers = [String]()
    var circles = [SKShapeNode]()
    
    var wordCounter = 0
    var textCounter = 0
    var cloudCounter = 0
    var circleCounter = 0
    
    let numWords = 18
    let calendar = Calendar.current
    let date = Date()
    var startSecond = 0
    var startMinute = 0
    var startHour = 0
    var secondsSinceStart = 0
    
    var gameOver = false
    
    var cloudArray = [SKSpriteNode]()
    var wordsShownArray = [SKLabelNode] ()
    
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
        startHour = calendar.component(.hour, from: date)
        startSecond = calendar.component(.second, from: date)
        startMinute = calendar.component(.minute, from: date)
        
        scoreboard.position = CGPoint(x: frame.size.width/2, y: 15*frame.size.height/16)
        scoreboard.size.width = size.width / 2
        scoreboard.size.height = size.height / 8
        scoreboard.zPosition = 2
        addChild(scoreboard)
        
        homeScore.position = CGPoint(x: scoreboard.position.x - scoreboard.size.width/2 - frame.size.width / 16, y: 15*frame.size.height/16)
        homeScore.zPosition = 2
        homeScore.text = "0"
        homeScore.fontSize = 32
        homeScore.fontColor = UIColor.black
        addChild(homeScore)
        
        awayScore.position = CGPoint(x: scoreboard.position.x + scoreboard.size.width/2 + frame.size.width / 16, y: 15*frame.size.height/16)
        awayScore.zPosition = 2
        awayScore.text = "0"
        awayScore.fontSize = 32
        awayScore.fontColor = UIColor.black
        addChild(awayScore)
        
        
        let buffer = scoreboard.size.width / 64
        let radius = (scoreboard.size.width - 6*buffer) / 16
        
        for i in 1 ... 6 {
            
            let circle = SKShapeNode(circleOfRadius: radius)
            //MAKE THIS MATH MORE BETTER
            circle.position.x = (scoreboard.position.x - scoreboard.size.width / 2 ) + 1.8 * CGFloat(radius) + 2.0*buffer + CGFloat(2*(i-1)) * CGFloat(buffer + radius)
            circle.position.y = scoreboard.position.y
            circle.zPosition = 3
            circle.name = "circle-\(i)"
            circles.append(circle)
            addChild(circle)
        }
        
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("test.sqlite")
        // open database
       
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        correctWords = getRandomCorrectWords(phoneme: "-ck", db: db)
        Words = getRandomWrongWords(phoneme: "not-ck", db: db)
        Words.append(contentsOf: correctWords)
        Words.shuffle()
        
        insertCloud(x: size.width * 0.2, y: size.height * 0.7, count: 1)
        insertCloud(x: size.width * 0.5, y: size.height * 0.7, count: 2)
        insertCloud(x: size.width * 0.8 , y: size.height * 0.7 ,count: 3)

        
        
    }
    override func update(_ currentTime: TimeInterval){
       
        let seconds = getSecondsSinceStart()
        //only update words/ clouds until game is over
        if wordCounter < 18 {
            // only run once per second, not per frame
            if secondsSinceStart != seconds{
                homeScore.text = String(homePoints)
                awayScore.text = String(awayPoints)
                secondsSinceStart = seconds
                if secondsSinceStart <= 9 {
                    //grow cloud a second before the text appears
                    if secondsSinceStart % 3 == 2 {
                        cloudArray[cloudCounter].run( SKAction.resize(toWidth: size.width/4, height: size.height/4, duration: 0.8))
                    }else if secondsSinceStart % 3 == 0 {
                        wordsShownArray[cloudCounter].text = Words[wordCounter]
                        wordCounter = wordCounter + 1
                        cloudCounter = cloudCounter + 1
                        if cloudCounter == 3 {
                            cloudCounter = 0
                        }
                    }
                }else {
                    if secondsSinceStart % 3 == 1 {
                        if cloudArray[cloudCounter].size.width != 0 {
                            var word: String!
                            word = wordsShownArray[cloudCounter].text
                            if correctWords.contains(word){
                                circles[circleCounter].fillColor = UIColor.red
                                circleCounter = circleCounter + 1
                            }
                            wordsShownArray[cloudCounter].text = ""
                            cloudArray[cloudCounter].run(SKAction.resize(toWidth: 0, height: 0, duration: 0.8))
                        }
                    } else if secondsSinceStart % 3 == 2 {
                         cloudArray[cloudCounter].run(SKAction.resize(toWidth: size.width/4, height: size.height/4, duration: 0.8))
                        
                    } else if secondsSinceStart % 3 == 0 {
                        wordsShownArray[textCounter].text = Words[wordCounter]
                        wordCounter = wordCounter + 1
                        textCounter = textCounter + 1
                        if textCounter == 3 {
                            textCounter = 0
                        }
                        cloudCounter = cloudCounter + 1
                        if cloudCounter == 3 {
                            cloudCounter = 0
                        }
                        
                    }
                }
            }
        }else if getSecondsSinceStart() >= (Words.count+1) * 3{
            // end game
            // update db with data, asserting gameOver, printing most recent data
            if !gameOver {
                //add any remaining words in phoneme to wrongAnswers and color remaining circles in red
                for i in 0...2 {
                    let word = wordsShownArray[i].text!
                    if correctWords.contains(word){
                        circles[circleCounter].fillColor = UIColor.red
                        circleCounter = circleCounter + 1
                        wrongAnswers.append(word)
                    }
                }
                var stmt: OpaquePointer?
                let numStars = getStars()
                let wrong_words = wrongAnswers.joined(separator: ", ")
                let insert_query = "insert into LevelData VALUES('TOW' , 1 , \(numStars) , '\(wrong_words)', CURRENT_TIMESTAMP)"
                
                //preparing query
                if sqlite3_prepare(db, insert_query, -1, &stmt, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error preparing insert: \(errmsg)")
                }
                
                // executing insert
                if sqlite3_step(stmt) != SQLITE_DONE {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure inserting level data: \(errmsg)")
                }
    
                gameOver = true
                print(getLastPlayData()) // printing out the data from the last play, retrieving from db
                
            }
           // convert scores to stars, display an end-game screen or toast
            let stars = getStars()
            
            let popup = SKSpriteNode(imageNamed: "rounded-square")
            popup.position = CGPoint(x: 50, y: 50)
            popup.size.width = size.width/1.3
            popup.size.height = size.height/1.3
            popup.position = CGPoint(x: size.width/2, y: size.height/2)
            popup.zPosition = 4
            addChild(popup)
            
            let text = SKLabelNode(fontNamed: "MarkerFelt-Thin")
            text.text = "End-Game Message Placeholder, you got \(stars) stars!"
            text.fontSize = 32
            text.fontColor = SKColor.black
            text.position = CGPoint(x: 500, y: 350)
            text.zPosition = 5
            addChild(text)
            

        }
    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        
        //choose one of the touches to work with
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            let touchedNodes = self.nodes(at: currentPoint)
            for node in touchedNodes {
                // check and see if node touched was one of the clouds
                for i in 1...3 {
                    if node.name == "cloud-\(i)" {
                        let word =  wordsShownArray[i-1].text!
                        // if word is correct score the home 10 points
                        if correctWords.contains(word){
                            homePoints = homePoints + 10
                            circles[circleCounter].fillColor = UIColor.green
                            circleCounter = circleCounter + 1
                            
                        //if the word is incorrect give the oppenent 10 points and store the word missed
                        }else if !wrongAnswers.contains(word) {
                            awayPoints = awayPoints + 10
                            wrongAnswers.append(word)
                        }
                        wordsShownArray[i-1].text = ""
                        cloudArray[i-1].run( SKAction.resize(toWidth: 0, height: 0, duration: 0.8))
                        
                    }
                }
            }

        }
        return
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
    
    
    func insertCloud(x: CGFloat, y: CGFloat, count: Int){
        // create spritenode and label node for cloud and words and store in an array so they can be referenced later on without name lookup
        let cloud = SKSpriteNode(imageNamed: "cloud-cartoon")
        cloud.position = CGPoint(x: x, y: y)
        //grow to size.width / 4
        cloud.size.width = 0
        cloud.size.height = 0
        cloud.zPosition = 1
        addChild(cloud)
        cloud.name = "cloud-\(count)"
        cloudArray.append(cloud)
        
        let text = SKLabelNode(fontNamed: "MarkerFelt-Thin")
        text.text = ""
        text.fontSize = 32
        text.fontColor = SKColor.black
        text.position = CGPoint(x: x, y: y - frame.size.height/64 )
        text.zPosition = 2
        addChild(text)
        wordsShownArray.append(text)
        
        
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
        wordArray = Array(wordArray.prefix(numWords/3))
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
        wordArray = Array(wordArray.prefix(2*numWords/3))
        return wordArray
    }
    
    func getSecondsSinceStart() -> Int {
        let currentDate = Date()
        let currentSecond = calendar.component(.second, from: currentDate)
        let currentMinute = calendar.component(.minute, from: currentDate)
        let currentHour = calendar.component(.hour, from: currentDate)
        return (currentHour - startHour) * 3600 + (currentMinute - startMinute) * 60 + (currentSecond - startSecond)
    }
 
    func getStars() -> Int {
        // 0 stars = 50 away points or less than 40 home points
        // 1 star = 40 or 50 home points and no more than 40 away points
        // 2 stars = 60 home points and greater than 0 away points
        // 3 stars is perfect game (60 home points, 0 away points)
        
        if awayPoints < 50 && homePoints >= 40{
            if homePoints < 60{
                return 1
            }
            else if awayPoints > 0{
                return 2
            }
            else{
                return 3
            }
        }else{
            return 0
        }
    }
    
    func getLastPlayData() -> String {
        let queryString =  "select * from LevelData L where L.time in (select MAX(time) from LevelData)"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select : \(errmsg)")
            return " no record returned: error preparing query"
        }
        
        //traversing through all the records. should be just one, since I'm selecting only the most recent play
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let game = String(cString: sqlite3_column_text(stmt, 0))
            let lvl = String(sqlite3_column_int(stmt, 1))
            let star = String(sqlite3_column_int(stmt, 2))
            let wrongs = String(cString: sqlite3_column_text(stmt, 3))
            let time = String(cString: sqlite3_column_text(stmt, 4))
            return "\(game), \(lvl), \(star), [\(wrongs)], \(time)"
        }
        
        return "no record returned"
        
    }
    
}



//following two extensions allow to call .shuffle() on arrays to make life simpler when choosing words

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
