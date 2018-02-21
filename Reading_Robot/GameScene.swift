
import SpriteKit

class GameScene: SKScene {
    
    // 1
    let player = SKSpriteNode(imageNamed: "Idle_000")
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
   
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        player.setScale(0.2)
        player.position = CGPoint(x: size.width * 0.9, y: size.height * 0.5)
        addChild(player)
    }
    
    override func  touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let robotVelocity = self.frame.size.width / 4.0
        
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
        
        
    }
    
    func walkingRobot(){
        let walking = [walk0, walk1, walk2, walk3, walk4, walk5, walk6, walk7, walk8, walk9]
        let walkAnimation = SKAction.animate(with: walking, timePerFrame: 0.07)
        player.run(SKAction.repeatForever(walkAnimation), withKey:"walkingRobot")
    }
    
    func idleRobot(){
        player.removeAction(forKey: "walkingRobot")
    }
    
}

