
import SpriteKit
import SQLite3

//TODO:
// 8) Add an extra frame to the rope pulling animation to make animation cleaner - ??
// stillMode errors



class GameScene: SKScene {
    let rope = SKSpriteNode(imageNamed: "rope")
    let background = SKSpriteNode(imageNamed: "LevelBackground1")
    var player = SKSpriteNode(imageNamed: userColor + "_Attack_005")
    let player2 = SKSpriteNode(imageNamed: userColor + "_Attack_005")
    let bottom = SKSpriteNode(imageNamed: "rectangle-2")
    let ok_button = SKSpriteNode(imageNamed: "rounded-square")
    let popup = SKSpriteNode(imageNamed: "rounded-square")
    let pull0 = SKTexture(imageNamed: userColor + "_Attack_007")
    let pull1 = SKTexture(imageNamed: userColor + "_Attack_006")
    let pull2 = SKTexture(imageNamed: userColor + "_Attack_005")
    var oppPull0 = SKTexture(imageNamed: userColor + "_Attack_007")
    var oppPull1 = SKTexture(imageNamed: userColor + "_Attack_006")
    var oppPull2 = SKTexture(imageNamed: userColor + "_Attack_005")
    let scoreboard = SKSpriteNode(imageNamed: "rectangle")
    let label = SKLabelNode(fontNamed: font)
    let popupText = SKLabelNode(fontNamed: "GillSans-UltraBold")
    var viewController : UIViewController!
    
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

    
    // function called at start of game
    override func didMove(to view: SKView) {
        
        
        pauseBackgroundMusic()
        
        // add background to view
        background.size.width = size.width
        background.size.height = size.height
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = 0
        addChild(background)
        
        // get level specific data and assign to instance fields (pattern, numWords, and speed)
        getLevelData()
        
        oppPull0 = SKTexture(imageNamed: oppColor + "_Attack_007")
        oppPull1 = SKTexture(imageNamed: oppColor + "_Attack_006")
        oppPull2 = SKTexture(imageNamed: oppColor + "_Attack_005")
        
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
        
        let playerNameLabel = SKLabelNode(fontNamed: font)
        playerNameLabel.text = names[colors.index(of: oppColor)!]
        playerNameLabel.position = CGPoint(x: player.size.width * 0.05, y: player.size.height * 0.3)
        playerNameLabel.zPosition = 1
        playerNameLabel.color = UIColor.cyan
        player.addChild(playerNameLabel)
        
        let labelBackground = SKSpriteNode(color: UIColor.cyan, size: playerNameLabel.frame.size)
        labelBackground.zPosition = -1
        labelBackground.position.y = labelBackground.size.height*0.3
        playerNameLabel.addChild(labelBackground)
        
        let player2NameLabel = SKLabelNode(fontNamed: font)
        player2NameLabel.text = playerName
        player2NameLabel.position = CGPoint(x: player2.size.width * -0.05, y: player.size.height * 0.3)
        player2NameLabel.zPosition = 1
        player2NameLabel.color = UIColor.cyan
        player2NameLabel.xScale = player2NameLabel.xScale * -1
        player2.addChild(player2NameLabel)
        
        let label2Background = SKSpriteNode(color: UIColor.cyan, size: player2NameLabel.frame.size)
        label2Background.zPosition = -1
        label2Background.position.y = label2Background.size.height*0.3
        player2NameLabel.addChild(label2Background)
        
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
//        label.text = "Your Pattern is: \(pattern!)"
        label.position = CGPoint(x: frame.size.width/2, y: frame.size.height*0.04)
        label.fontSize = 100
        label.zPosition = 4
        label.fontColor = UIColor.white
        addChild(label)
        
        //intialize time values, used for updating the game
        startHour = calendar.component(.hour, from: date)
        startSecond = calendar.component(.second, from: date)
        startMinute = calendar.component(.minute, from: date)
        startNS = calendar.component(.nanosecond, from: date)
        
        //add scoreboard at top of screen to the game
        scoreboard.position = CGPoint(x: frame.size.width/2, y: 15*frame.size.height/16)
        scoreboard.size.width = size.width / 2
        scoreboard.size.height = size.height / 8
        scoreboard.zPosition = 2
        addChild(scoreboard)
        
        // Adds 3 clouds to the game. Cloud nodes are resized and have the text changed throughout the game but only 3 objects are ever created
        insertCloud(x: size.width * 0.2, y: size.height * 0.65, count: 1)
        insertCloud(x: size.width * 0.5, y: size.height * 0.65, count: 2)
        insertCloud(x: size.width * 0.8 , y: size.height * 0.65 ,count: 3)
        
        //set circle parameters for scoreboard to scale with numWords
        let buffer = scoreboard.size.width / 64
        let numCircles = CGFloat(1+correctWords.count)
        let radius = (scoreboard.size.width - numCircles * buffer) / (numCircles * 2)
        let diameter = 2.0 * radius
        let startX = (scoreboard.position.x - scoreboard.size.width / 2 ) + 2.0 * radius + buffer
        
        // add properly scaled circles to the scoreboard
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
        //get time since the start of the game
        //t is used to determine the start of the game then time is used throughout the rest of the update code
        let t = getSecondsSinceStart()
        let time = t - 8
        let dTime = time - previousTime
        // beginning
        if t > 0.3  && t < 3{
            if popup.position.x == 0 {
                popup.position = CGPoint(x: size.width/2, y: size.height/2)
                popup.size.height = size.height / 3
                popup.zPosition = 6
                
                popupText.text = "\(playerName!) Vs. \(names[colors.index(of: oppColor)!])"
                popupText.fontSize = 64
                popup.size.width = popupText.frame.width * 1.1
                addChild(popup)
                popupText.position.y = popupText.frame.height * -0.25
                popupText.fontColor = UIColor.black
                popupText.zPosition = 1
                popup.addChild(popupText)
            }
            
        }else if t > 3 && t < 6 {
            popupText.text = "Your pattern is \(pattern!)!"
            popup.size.width = popupText.frame.width * 1.1
        }else if t > 6 && t < 7 {
            popupText.fontSize = 100
            popupText.text = "Ready!"
            popupText.fontColor = UIColor.red
            popup.size.width = popupText.frame.width * 1.1
        } else if t > 7 && t < 8 {
            popupText.text = "Set!"
            popupText.fontColor = UIColor.yellow
        } else if t > 8 {
            if t < 9 {
                popup.removeAllChildren()
                popup.removeFromParent()
                if patternStaysOn {
                    label.text = "Your pattern is \(pattern!)!"
                }else {
                    label.text = "Tug Of War!"
                }
            }
            // if the game is still going on then have the two robots pull the rope back and forth
            if time < Double(Words.count+2) * cloudPeriod && !stillMode{
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
                //  2 term fourier series used to create non basic back and forth motion, used to find the delta x value for the current frame
                let sinApprox = CGFloat(sin(Double.pi * time / 4) + 0.33333*sin(3.0 * Double.pi * time / 4.0))
                let deltaX = (size.width * 0.1) * (2 / CGFloat.pi) * sinApprox
                player.position = CGPoint(x: playerOneStartX + deltaX, y: size.height*0.31)
                player2.position = CGPoint(x: playerTwoStartX + deltaX, y: size.height*0.31)
                rope.position = CGPoint(x: size.width/2 + deltaX, y: frame.size.height * 0.35  - player.size.height/4)
           
            }
            // if there are still words to go, then modify the clouds/words every cloud Period (assigned based on speed instance variable
            if wordCounter < Words.count {
                if wordCounter < 3 {
                    if !phaseTwo && dTime >= 2*cloudPeriod/3 {
                        phaseTwo = true
                        if !stillMode{
                            cloudArray[cloudCounter].run( SKAction.resize(toWidth: size.width/4, height: size.height/4, duration: cloudPeriod/3.0))
                        }
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
                        // Phase one is to make cloud text empty and to make cloud shrink
                        phaseOne = true
                        if cloudArray[cloudCounter].size.width != 0 {
                            let word = wordsShownArray[cloudCounter].text!
                            if correctWords.contains(word){
                                circles[circleCounter].fillColor = UIColor.red
                                circleCounter = circleCounter + 1
                                wrongAnswers.append(word)
                            }
                            wordsShownArray[cloudCounter].text = ""
                            if !stillMode{
                                cloudArray[cloudCounter].run(SKAction.resize(toWidth: 0, height: 0, duration: cloudPeriod/3.0))
                            }
                        }
                    }else if !phaseTwo && dTime >= 2*cloudPeriod/3 {
                        //phase two is to make the cloud reappear
                        phaseTwo = true
                        if !stillMode{
                            cloudArray[cloudCounter].run(SKAction.resize(toWidth: size.width/4, height: size.height/4, duration: cloudPeriod / 3.0))
                        }
                        
                    }else if dTime >= cloudPeriod {
                        //phase 3 is to add the new word to the cloud the just reappeared
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
                    let percentage = CFloat((Words.count - wrongAnswers.count)) / CFloat(Words.count)

                    let insert_query = "insert into UserData VALUES('TOW' , \(levelNumber) ,'\(pattern!)' , \(numStars) , '\(wrong_words)', \(percentage), CURRENT_TIMESTAMP)"
                    
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
                popup.size.height = size.height/1.8
                popup.position = CGPoint(x: size.width/2, y: size.height/2)
                popup.zPosition = 4
                addChild(popup)
                
                let text1 = SKLabelNode(fontNamed: font!)
                let text2 = SKLabelNode(fontNamed: font!)
                
                if stars == 1 {
                    text1.text = "You got 1 star!"
                    text2.text = "Tap the bucket to soak your opponent in goo!"
                }
                else if stars > 0 {
                    text1.text = "You got \(stars) stars!"
                    text2.text = "Tap the bucket to soak your opponent in goo!"
                }
                else {
                    text1.text = "You got 0 stars. Try again!"
                    text2.text = ""
                }
                
                text1.fontSize = 32
                text1.fontColor = SKColor.black
                text1.position = CGPoint(x: 0, y: 0)
                text1.zPosition = 5
                popup.addChild(text1)
                text2.fontSize = 32
                text2.fontColor = SKColor.black
                text2.position = CGPoint(x: 0, y: -50)
                text2.zPosition = 5
                popup.addChild(text2)
                
                //button to remove results prompt and clouds to make room for the bucket game
                ok_button.size.width = size.width/6.3
                ok_button.size.height = size.height/8.3
                ok_button.position = CGPoint(x: size.width/2, y: size.height/4)
                ok_button.zPosition = 6
                ok_button.colorBlendFactor = 1.0
                ok_button.color = UIColor(red: 0, green: 0.6784, blue: 0.949, alpha: 1.0) /* #00adf2 */
                addChild(ok_button)
                //"OK" text on the button
                let ok_text = SKLabelNode(fontNamed: font!)
                ok_text.text = "OK"
                ok_text.fontSize = 32
                ok_text.fontColor = SKColor.black
                ok_text.position = CGPoint(x: 0, y: -15)
                ok_text.zPosition = 7
                ok_button.addChild(ok_text)
                    
                }
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
                            if !stillMode {
                                cloudArray[i-1].run( SKAction.resize(toWidth: 0, height: 0, duration: cloudPeriod/3.0))
                            }
                            
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
                        if getStars() > 0 {
                        viewController.performSegue(withIdentifier: "TAPPING_GAME", sender: viewController)
                        }else{
                        viewController.performSegue(withIdentifier: "UNWIND_TO_LEVEL_MENU", sender: viewController)
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
            let word = String(cString: sqlite3_column_text(stmt, 0)).lowercased()
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
            let word = String(cString: sqlite3_column_text(stmt, 0)).lowercased()
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
        
        if awayPoints < 50 && homePoints >= (numWords - 2) * 10{
            if homePoints < numWords*10{
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
        let i = Int(arc4random_uniform(6))
        while(oppColor == userColor){
            oppColor = colors[i]
        }
        
        if(gameSpeed == "slow"){
            cloudPeriod = 2.0
        }else if(gameSpeed == "fast"){
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
