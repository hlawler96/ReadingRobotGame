
import SpriteKit
import SQLite3

//TODO:
// 2) Add labels to players and scores at the top - ??
// 4) Animate the tug of war during the game - ??
// 5) Add an end game animation based on the number of stars - ??
// 6) Have the phoneme spoken at the beginning of the mini game with possible time delay / "Start" popup message - ??
// 8) Add an extra frame to the rope pulling animation to make animation cleaner - ??
// 10) Read in words from project db file and not the db file stored on the local machine - Hayden



class GameScene: SKScene {
    
    var db: OpaquePointer?
    var db2: OpaquePointer?
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
    
    var levelNumber = 0
    var homePoints = 0
    var awayPoints = 0
    
    var cloudPeriod: Double!
    var previousTime = 0.0
    var phaseOne = false
    var phaseTwo = false
    
    var correctWords = [String]()
    var Words = [String]()
    var wrongAnswers = [String]()
    var circles = [SKShapeNode]()
    
    var wordCounter = 0
    var textCounter = 0
    var cloudCounter = 0
    var circleCounter = 0
    var xCounter = CGFloat(0)
    
    let calendar = Calendar.current
    let date = Date()
    var startSecond = 0
    var startMinute = 0
    var startHour = 0
    var startNS = 0
    var secondsSinceStart = 0
    
    var gameOver = false
    
    var cloudArray = [SKSpriteNode]()
    var wordsShownArray = [SKLabelNode] ()
    
    var phoneme = ""
    var numWords = 0
    var gameSpeed = "slow"
    
    override func didMove(to view: SKView) {
        
        pauseBackgroundMusic()
        
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
        startNS = calendar.component(.nanosecond, from: date)
        
        scoreboard.position = CGPoint(x: frame.size.width/2, y: 15*frame.size.height/16)
        scoreboard.size.width = size.width / 2
        scoreboard.size.height = size.height / 8
        scoreboard.zPosition = 2
        addChild(scoreboard)
        
        //open database on ios machine
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("test.sqlite")
       
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        //open project database
        let filePath = Bundle.main.path(forResource: "ReadingRobot", ofType: "db")
        if sqlite3_open(filePath, &db2) != SQLITE_OK {
            print("error opening database")
        }
        
        getLevelData()
        
        insertCloud(x: size.width * 0.2, y: size.height * 0.65, count: 1)
        insertCloud(x: size.width * 0.5, y: size.height * 0.65, count: 2)
        insertCloud(x: size.width * 0.8 , y: size.height * 0.65 ,count: 3)
        
        let buffer = scoreboard.size.width / 64
        let numCircles = CGFloat(1+correctWords.count)
        let radius = (scoreboard.size.width - numCircles * buffer) / (numCircles * 2)
        let diameter = 2.0 * radius
        let startX = (scoreboard.position.x - scoreboard.size.width / 2 ) + 2.0 * radius + buffer
        
        for i in 0 ... correctWords.count - 1 {
            
            let circle = SKShapeNode(circleOfRadius: radius)
            circle.position.x = startX + CGFloat(i) * (diameter + buffer)
            circle.position.y = scoreboard.position.y
            circle.zPosition = 3
            circle.name = "circle-\(i+1)"
            circles.append(circle)
            addChild(circle)
        }

    }
    override func update(_ currentTime: TimeInterval){
        let time = getSecondsSinceStart()
        let dTime = time - previousTime
        //only update words/ clouds until game is over
        if wordCounter < Words.count {
            if wordCounter < 3 {
                if !phaseTwo && dTime >= 2*cloudPeriod/3 {
                    phaseTwo = true
                    cloudArray[cloudCounter].run( SKAction.resize(toWidth: size.width/4, height: size.height/4, duration: cloudPeriod/3.0))
                }else if dTime >= cloudPeriod {
                    previousTime = time
                    phaseTwo = false
                    wordsShownArray[cloudCounter].text = Words[wordCounter]
                    wordCounter = wordCounter + 1
                    cloudCounter = cloudCounter + 1
                    if cloudCounter == 3 {
                        cloudCounter = 0
                    }
                }
            } else {
                if !phaseOne && dTime >= cloudPeriod/3 {
                    phaseOne = true
                    if cloudArray[cloudCounter].size.width != 0 {
                        let word = wordsShownArray[cloudCounter].text!
                        if correctWords.contains(word){
                            circles[circleCounter].fillColor = UIColor.red
                            circleCounter = circleCounter + 1
                            wrongAnswers.append(word)
                        }
                        wordsShownArray[cloudCounter].text = ""
                        cloudArray[cloudCounter].run(SKAction.resize(toWidth: 0, height: 0, duration: cloudPeriod/3.0))
                    }
                }else if !phaseTwo && dTime >= 2*cloudPeriod/3 {
                    phaseTwo = true
                     cloudArray[cloudCounter].run(SKAction.resize(toWidth: size.width/4, height: size.height/4, duration: cloudPeriod / 3.0))
                    
                }else if dTime >= cloudPeriod {
                    previousTime = time
                    phaseOne = false
                    phaseTwo = false
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
        }else if time >= Double(Words.count+2) * cloudPeriod{
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
                let numStars = getStars()
                let wrong_words = wrongAnswers.joined(separator: ", ")
                let insert_query = "insert into UserData VALUES('TOW' , \(levelNumber) , \(numStars) , '\(wrong_words)', CURRENT_TIMESTAMP)"
                
                //executing the query to insert values
                
                if sqlite3_exec(db, insert_query, nil, nil, nil) != SQLITE_OK {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure inserting User Data: \(errmsg)")
                
                }
                gameOver = true
                
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
    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //choose one of the touches to work with
        if !gameOver{
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
                            }else if !wrongAnswers.contains(word) && word != "" {
                                let x = SKSpriteNode(imageNamed: "X")
                                x.size.height = circles[0].frame.height
                                x.size.width = circles[0].frame.width
                                let cloudDX = CGFloat(xCounter*(circles[1].position.x - circles[0].position.x))
                                x.position = CGPoint(x: circles[0].position.x + cloudDX, y: circles[0].position.y - scoreboard.size.height)
                                x.zPosition = 2
                                addChild(x)
                                xCounter = xCounter + 1
                                awayPoints = awayPoints + 10
                                wrongAnswers.append(word)
                            }
                            wordsShownArray[i-1].text = ""
                            cloudArray[i-1].run( SKAction.resize(toWidth: 0, height: 0, duration: cloudPeriod/3.0))
                            
                        }
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
            print("error preparing select: \(errmsg)")
            return []
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let word = String(cString: sqlite3_column_text(stmt, 0))
            //adding values to list
            wordArray.append(word)
        }
        wordArray.shuffle();
        wordArray = Array(wordArray.prefix(numWords))
        
        sqlite3_finalize(stmt)
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
        wordArray = Array(wordArray.prefix(numWords + numWords % 3))
        sqlite3_finalize(stmt)
        return wordArray
    }
    
    func getSecondsSinceStart() -> Double {
        let currentDate = Date()
        let dSec = Double(calendar.component(.second, from: currentDate) -  startSecond)
        let dMinute = Double((calendar.component(.minute, from: currentDate) - startMinute) * 60)
        let dHour = Double((calendar.component(.hour, from: currentDate) - startHour) * 3600)
        let dNS = Double(calendar.component(.nanosecond, from: currentDate) - startNS) * 0.000000001
        return dSec + dMinute + dHour + dNS
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
    
//    func getLastPlayData() -> String {
//        let queryString =  "select * from UserData L where L.time in (select MAX(time) from UserData)"
//
//        //statement pointer
//        var stmt:OpaquePointer?
//
//        //preparing the query
//        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
//            let errmsg = String(cString: sqlite3_errmsg(db)!)
//            print("error preparing select : \(errmsg)")
//            return " no record returned: error preparing query"
//        }
//
//        //traversing through all the records. should be just one, since I'm selecting only the most recent play
//        while(sqlite3_step(stmt) == SQLITE_ROW){
//            let game = String(cString: sqlite3_column_text(stmt, 0))
//            let lvl = String(sqlite3_column_int(stmt, 1))
//            let star = String(sqlite3_column_int(stmt, 2))
//            let wrongs = String(cString: sqlite3_column_text(stmt, 3))
//            let time = String(cString: sqlite3_column_text(stmt, 4))
//            return "\(game), \(lvl), \(star), [\(wrongs)], \(time)"
//        }
//        return "no record returned"
//    }
    
    func getLevelData() {
        let levelQuery = "SELECT * FROM LevelData L WHERE L.number=\(levelNumber)"
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db2, levelQuery, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            phoneme = String(cString: sqlite3_column_text(stmt, 1))
            numWords = Int(sqlite3_column_int(stmt, 2))
            gameSpeed = String(cString: sqlite3_column_text(stmt, 3))
        }
        
        if(gameSpeed == "slow"){
            cloudPeriod = 3.0
        }else if(gameSpeed == "fast"){
            cloudPeriod = 2.0
        }else {
            cloudPeriod = 1.5
        }
        
        correctWords = getRandomCorrectWords(phoneme: phoneme, db: db2)
        Words = getRandomWrongWords(phoneme: "not\(phoneme)", db: db2)
        Words.append(contentsOf: correctWords)
        Words.shuffle()
        sqlite3_finalize(stmt)
        
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
