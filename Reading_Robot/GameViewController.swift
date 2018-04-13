//
//  GameViewController.swift
//  Reading_Robot
//
//  Created by Hayden Lawler on 2/17/18.
//  Copyright © 2018 Hayden Lawler. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    var levelNumber: Int!
    var scene: GameScene!
    var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scene = GameScene(size: view.bounds.size)
        scene.viewController = self
        scene.levelNumber = levelNumber
        skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    override var shouldAutorotate: Bool {
        return true;
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        var bucketScale = CGFloat(1.4)
        var playerScale = CGFloat(0.7)
        var mudType = "mud"
        if scene.cloudPeriod == 3.0 {
            bucketScale = 0.8
            playerScale =  1.0
        }else if scene.cloudPeriod == 2.0 {
            bucketScale = 1.0
            playerScale = 0.9
            mudType = "lava"
        }else if scene.cloudPeriod == 1.5{
            bucketScale = 1.2
            playerScale = 0.8
            mudType = "slime"
        }
        
       if segue.identifier == "TAPPING_GAME" {
            let tap = segue.destination as! TappingGameViewController
            tap.playerScale = playerScale
            tap.bucketScale = bucketScale
            tap.mudType = mudType
            tap.level = levelNumber
        }
    }
    
    @IBAction func unwindToGame(segue:UIStoryboardSegue) {
//        print("Coming back from tapping game")
        scene = GameScene(size: view.bounds.size)
        scene.viewController = self
        scene.levelNumber = levelNumber
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        
    }
}
