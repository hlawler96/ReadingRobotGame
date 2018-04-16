//
//  TutorialViewController.swift
//  Reading_Robot
//
//  Created by Hayden Lawler on 4/12/18.
//  Copyright © 2018 Hayden Lawler. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class TutorialViewController: UIViewController {

    var scene: GameTutorial!
    var skView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scene = GameTutorial(size: view.bounds.size)
        scene.viewController = self
        skView = view as! SKView
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


}
