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
import SQLite3

let colors = ["Red","Grey","Blue","Yellow","Turquoise","Green"]

class AccountViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
  
    
    
    @IBOutlet weak var character: UIImageView!
    @IBOutlet weak var dropDown: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropDown.delegate = self
        dropDown.dataSource = self
        updateImage()
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colors.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return colors[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        userColor = colors[row]
        updateImage()
        if sqlite3_exec(db, "UPDATE CharacterData SET color = '" + userColor + "' WHERE user = 1", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error inserting into table: \(errmsg)")
        }
    }

    
    override var shouldAutorotate: Bool {
        return true;
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func updateImage(){
         character.image = UIImage(named: userColor + "_Idle_000")
    }






}
