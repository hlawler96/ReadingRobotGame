//
//  TitleViewController.swift
//  Reading_Robot
//
//  Created by Programming on 2/22/18.
//  Copyright © 2018 Hayden Lawler. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import GameplayKit

class TitleViewController: UIViewController {
    
    
    @IBAction func unwindToMainMenu(unwindSegue: UIStoryboardSegue)
    {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
}
