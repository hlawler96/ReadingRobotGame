//
//  AccountViewController.swift
//  Reading_Robot
//
//  Created by Programming on 2/27/18.
//  Copyright © 2018 Hayden Lawler. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit


class AccountViewController: UIViewController {

    //var pushFromLevel = false
    

    //@IBAction func LevelBackButton(_ sender: Any) {pushFromLevel = true}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    /*override func viewDidAppear(_ animated: Bool) {
        performSegue(withIdentifier: "UnwindToLevelMenu", sender: self)
        self.pushFromLevel = false
        
    }
    */
    
    override var shouldAutorotate: Bool {
        return true;
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
