//
//  AccountViewController.swift
//  Reading_Robot
//
//  Created by Programming on 2/27/18.
//  Copyright © 2018 Derek Creason. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import SQLite3

let colors = ["Blue","Grey","Red","Yellow","Turquoise","Green"]
let names = ["Scrappie", "Rusty", "Sparky", "Tinker", "Ratchet", "Jet"]
var playerName: String!

class AccountViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet weak var character: UIImageView!
    @IBOutlet weak var dropDown: UIPickerView!
    @IBOutlet weak var nameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropDown.delegate = self
        dropDown.dataSource = self
        updateImage()
        if playerName == "" || playerName == nil {
            nameField.text = names[colors.index(of: userColor)!]
        }else{
            nameField.text = playerName
        }
        
        
        
    }
    
    @IBAction func nameChanged(_ sender: UITextView) {
        if sender.text!.count > 10 {
            sender.text = String(sender.text!.prefix(10))
        }
        playerName = sender.text
        
        if sqlite3_exec(db, "UPDATE CharacterData SET name = '" + playerName + "' WHERE user = 1", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error inserting into table: \(errmsg)")
        }
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
        if playerName == "" || playerName == nil {
            nameField.text = names[colors.index(of: userColor)!]
        }
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
