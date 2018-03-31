
import SpriteKit
import SQLite3

//TODO:
// 2) Add labels to players and scores at the top - ??
// 4) Animate the tug of war during the game - ??
// 5) Add an end game animation based on the number of stars - ??
// 6) Have the pattern spoken at the beginning of the mini game with possible time delay / "Start" popup message - ??
// 8) Add an extra frame to the rope pulling animation to make animation cleaner - ??



class GameScene: SKScene {
    let rope = SKSpriteNode(imageNamed: "rope")
    let background = SKSpriteNode(imageNamed: "LevelBackground1")
    var player = SKSpriteNode(imageNamed: userColor + "_Attack_005")
    let player2 = SKSpriteNode(imageNamed: userColor + "_Attack_005")
    let bucket = SKSpriteNode(imageNamed: "bucket")
    let ok_button = SKSpriteNode(imageNamed: "rounded-square")
    let popup = SKSpriteNode(imageNamed: "rounded-square")
    let pull0 = SKTexture(imageNamed: userColor + "_Attack_007")
    let pull1 = SKTexture(imageNamed: userColor + "_Attack_006")
    let pull2 = SKTexture(imageNamed: userColor + "_Attack_005")
    var oppPull0 = SKTexture(imageNamed: userColor + "_Attack_007")
    var oppPull1 = SKTexture(imageNamed: userColor + "_Attack_006")
    var oppPull2 = SKTexture(imageNamed: userColor + "_Attack_005")
    let scoreboard = SKSpriteNode(imageNamed: "rectangle")
    var oppColor = "Blue"
    
    var timeToPull = true
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
    
    var playerOneStartX: CGFloat!
    var playerTwoStartX: CGFloat!
    
    var gameOver = false
    
    var cloudArray = [SKSpriteNode]()
    var wordsShownArray = [SKLabelNode] ()
    
    var pattern : String!
    var numWords : Int!
    var gameSpeed : String!
    
    var bucket_direction : Int!
    var bucket_taps = 0
    
    override func didMove(to view: SKView) {
        
        bucket_direction = 0
        bucket_taps = 0
        
        pauseBackgroundMusic()
        
        background.size.width = size.width
        background.size.height = size.height
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = 0
        addChild(background)
        
        getLevelData()
        
        oppPull0 = SKTexture(imageNamed: oppColor + "_Attack_007")
        oppPull1 = SKTexture(imageNamed: oppColor + "_Attack_006")
        oppPull2 = SKTexture(imageNamed: oppColor + "_Attack_005")
        
        playerOneStartX = size.width * 0.8
        player.size.width = size.width / 3.1
        player.size.height = size.height / 2
        player.position = CGPoint(x: playerOneStartX , y: size.height * 0.33)
        player.zPosition = 2
        addChild(player)
        
        playerTwoStartX = size.width * 0.2
        player2.size.width = size.width / 3.1
        player2.size.height = size.height / 2
        player2.position = CGPoint(x: playerTwoStartX , y: size.height * 0.33)
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
        if time < Double(Words.count+2) * cloudPeriod{
            let pulling = [pull2, pull1, pull0, pull1, pull2]
            let oppPulling = [oppPull2, oppPull1, oppPull0, oppPull1, oppPull2]
            let remainder = time.truncatingRemainder(dividingBy: 8.0)
            let action = SKAction.animate(with: pulling, timePerFrame: 0.15)
            let oppAction = SKAction.animate(with: oppPulling, timePerFrame: 0.15)
            if  remainder > 2.95 && remainder <  3.05  && timeToPull{
                player2.run(action, withKey: "pulling")
                timeToPull = false
            }else if remainder > 6.95 && remainder <  7.05 && !timeToPull {
                timeToPull = true
                player.run(oppAction, withKey: "pulling")
            }
            let sinApprox = CGFloat(sin(Double.pi * time / 4) + 0.33333*sin(3.0 * Double.pi * time / 4.0))
            let deltaX = (size.width * 0.1) * (2 / CGFloat.pi) * sinApprox
            player.position = CGPoint(x: playerOneStartX + deltaX, y: size.height*0.33)
            player2.position = CGPoint(x: playerTwoStartX + deltaX, y: size.height*0.33)
            rope.position = CGPoint(x: size.width/2 + deltaX, y: frame.size.height / 4  - player.size.height/4 + size.height * 0.08)
        }
        
        if wordCounter < Words.count {
            //Move Players back and forth
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
                //add any remaining words in pattern to wrongAnswers and color remaining circles in red
               
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
               
                //Move players to one side or the other
                let speed = size.width/15.0
                if numStars > 0 {
                    
                    let distance = abs(player2.position.x - size.width * 0.05)
                    player.run(SKAction.moveTo(x: size.width * 0.65, duration: Double(distance/speed)))
                    player2.run(SKAction.moveTo(x: size.width * 0.05, duration: Double(distance/speed)))
                    rope.run(SKAction.moveTo(x: size.width * 0.35, duration: Double(distance/speed)))
                    
                }else{
                    let distance = abs(player.position.x - size.width * 0.95)
                    player.run(SKAction.moveTo(x: size.width * 0.95, duration: Double(distance/speed)))
                    player2.run(SKAction.moveTo(x: size.width * 0.35, duration: Double(distance/speed)))
                    rope.run(SKAction.moveTo(x: size.width * 0.65, duration: Double(distance/speed)))
                }
                
                //executing the query to insert values
                
                if sqlite3_exec(db, insert_query, nil, nil, nil) != SQLITE_OK {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure inserting User Data: \(errmsg)")
                
                }
                gameOver = true
                
                
                
                // convert scores to stars, display an end-game screen or toast
                let stars = getStars()
                
                
                
                //endgame message, showing number of stars earned
                popup.position = CGPoint(x: 50, y: 50)
                popup.size.width = size.width/1.3
                popup.size.height = size.height/1.3
                popup.position = CGPoint(x: size.width/2, y: size.height/2)
                popup.zPosition = 4
                addChild(popup)
                
                let text = SKLabelNode(fontNamed: "MarkerFelt-Thin")
                
                if stars == 1 {
                    text.text = "You got 1 star!\nTap the bucket to soak your opponent in mud!"
                }
                else if stars > 0 {
                    text.text = "You got \(stars) stars!\nTap the bucket to soak your opponent in mud!"
                }
                else {
                    text.text = "You got 0 stars. Try again!"
                }
                
                text.fontSize = 32
                text.fontColor = SKColor.black
                text.position = CGPoint(x: 0, y: 0)
                text.zPosition = 5
                popup.addChild(text)
                
                
                //button to remove results prompt and clouds to make room for the bucket game
                ok_button.size.width = size.width/6.3
                ok_button.size.height = size.height/8.3
                ok_button.position = CGPoint(x: size.width/2, y: size.height/6)
                ok_button.zPosition = 6
                ok_button.color = SKColor.blue
                addChild(ok_button)
                let ok_text = SKLabelNode(fontNamed: "MarkerFelt-Thin")
                ok_text.text = "OK"
                ok_text.fontSize = 32
                ok_text.fontColor = SKColor.black
                ok_text.position = CGPoint(x: 0, y: 0)
                ok_text.zPosition = 7
                ok_button.addChild(ok_text)
                
                
                
                
                // positioning bucket based on result. loss = over user, win = over cpu
                var bucketPosX : CGFloat!
                
                if(stars == 0){
                    bucketPosX = size.width * 0.3
                    bucket_direction = 2 //bucket goes left, onto user's robot
                }
                else{
                    bucketPosX = size.width * 0.7
                    bucket_direction = 1 //bucket goes right, onto cpu's robot
                }
                bucket.size.width = size.width / 5
                bucket.size.height = size.height / 4
                bucket.position = CGPoint(x: bucketPosX , y: size.height * 0.6)
                bucket.zPosition = 2
                addChild(bucket)
                
                
            }
            else{
                //end-game mudbath game starts
                bucket.zPosition = 2
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
        else{
            if let touch = touches.first {
                let currentPoint = touch.location(in: self)
                let touchedNodes = self.nodes(at: currentPoint)
                for node in touchedNodes {
                    // check and see if node touched was ok_button
                    if node == ok_button{ // if it is, we clear the screen of end-game message and clouds
                        
                        popup.removeAllActions()
                        popup.removeAllChildren()
                        popup.removeFromParent()
                        
                        for i in 0...2{
                            cloudArray[i].removeAllActions()
                            cloudArray[i].removeAllChildren()
                            cloudArray[i].removeFromParent()
                        }
                        
                        for word in wordsShownArray {
                            word.removeAllActions()
                            word.removeFromParent()
                        }
                        
                        ok_button.removeAllActions()
                        ok_button.removeAllChildren()
                        ok_button.removeFromParent()
                    }
                    if node == bucket {
                        bucket_taps += 1
                        if bucket_taps > 75 {
                            return
                            // spill the mud (TODO)
                        }
                        
                        if bucket_direction == 1 { // rotating right, onto cpu
                            bucket.zRotation = -(CGFloat((Double.pi / 4) / 45) * (CGFloat(bucket_taps)))
                        }
                        else if bucket_direction == 2 { //rotating left, onto user
                            bucket.zRotation = (CGFloat((Double.pi / 4) / 45) * (CGFloat(bucket_taps)))
                        }
                    }
                }
            }
        }
        return
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
    
    func getRandomCorrectWords(pattern: String, db: OpaquePointer?) -> [String] {
        var wordArray = [String]()
        let queryString = "select word from Words where pattern = '" + pattern + "' and hasPattern = 1"
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
            wordArray.append(word)
        }
        wordArray.shuffle();
        wordArray = Array(wordArray.prefix(numWords))
        
        sqlite3_finalize(stmt)
        return wordArray
    }
    
    func getRandomWrongWords(pattern: String, db: OpaquePointer?) -> [String] {
        var wordArray = [String]()
        let queryString = "select word from Words where pattern = '" + pattern + "' and hasPattern = 0"
        
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
//            print(word)
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
            pattern = String(cString: sqlite3_column_text(stmt, 1))
            numWords = Int(sqlite3_column_int(stmt, 2))
            gameSpeed = String(cString: sqlite3_column_text(stmt, 3))
            oppColor = String(cString: sqlite3_column_text(stmt, 4))
//            print("Pattern: \(pattern) , Number of Words: \(numWords) , Game Speed: \(gameSpeed)")
        }
        var i = Int(arc4random_uniform(6))
        while(oppColor == userColor){
            oppColor = colors[i]
            i = Int(arc4random_uniform(6))
        }
        
        
        if(gameSpeed == "slow"){
            cloudPeriod = 3.0
        }else if(gameSpeed == "fast"){
            cloudPeriod = 2.0
        }else if(gameSpeed == "very_fast"){
            cloudPeriod = 1.5
        }else {
            cloudPeriod = 1.0
        }
        
        player = SKSpriteNode(imageNamed: oppColor + "_Attack_005")
        correctWords = getRandomCorrectWords(pattern: pattern, db: db2)
        Words = getRandomWrongWords(pattern: pattern, db: db2)
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
