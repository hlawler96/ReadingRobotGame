//
//  TappingGameViewController.swift
//  Reading_Robot
//
//  Created by Derek Creason on 3/26/18.
//  Copyright © 2018 Derek Creason. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class TappingGameViewController: UIViewController {
    var playerScale, bucketScale : CGFloat!
    var level : Int!
    var scene : TappingGame!

    override func viewDidLoad() {
        super.viewDidLoad()
        scene = TappingGame(size: view.bounds.size)
        scene.playerScaling = playerScale
        scene.bucketScaling = bucketScale
        scene.viewController = self
        scene.levelFrom = level
        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
    
    override var shouldAutorotate: Bool {
        return true;
    }
    @IBAction func SkipClicked(_ sender: UIButton) {
        scene.skipClicked = true
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
    
    // if going to tug of war game it sets the corresponding class variable to the level number that was clicked
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "UNWIND_TO_GAME"){
            let tow = segue.destination as! GameViewController
            tow.levelNumber = level + 1
        }
    }

}
