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
import SQLite3
import AVKit

var db, db2: OpaquePointer?
var backgroundMusicPlayer: AVAudioPlayer!
var userColor, oppColor, font: String!
var stillMode : Bool!
var music = 1

class TitleViewController: UIViewController {
    
    @IBAction func unwindToMainMenu(unwindSegue: UIStoryboardSegue){}
    
    
    @IBAction func SettingsClicked(_ sender: Any) {
        performSegue(withIdentifier: "SETTINGS_SEGUE", sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // open db variables for project and local databases
        openLocalDB()
        openProjectDB()
        
//        dropDB(db: db, table: "UserData")
        
        // checking for UserData table, creating if not found
        if sqlite3_exec(db, "create table if not exists UserData (miniGame text , lvl int , stars int , wrongWords text , percent real, time CURRENT_TIMESTAMP)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        if sqlite3_exec(db, "create table if not exists SettingsData (musicVol real, fxVol real, font text, stillMode int)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        if sqlite3_exec(db, "create table if not exists CharacterData (user int, color text, accessory text)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        playBackgroundMusic(filename: "music")
        loadUserColor()
        loadSettings()
        oppColor = "Blue"

    }


    override var shouldAutorotate: Bool {
        return true
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
    
    func dropDB(db: OpaquePointer?, table: String){
        //creating a statement
        var stmt: OpaquePointer?
        
        //the insert query
        let queryString = "Drop table \(table)"
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing drop: \(errmsg)")
            return
        }
        
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure dropping Words: \(errmsg)")
            return
        }
        sqlite3_finalize(stmt)
        return
    }
    
    
    func openProjectDB(){
        let filePath = Bundle.main.path(forResource: "ReadingRobot", ofType: "db")
        if sqlite3_open(filePath, &db2) != SQLITE_OK {
            print("error opening database")
        }
    }
    
    func openLocalDB(){
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("reading_robot.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
    }
    func loadUserColor(){
        let queryString = "select color from CharacterData WHERE user = 1"
        var stmt:OpaquePointer?
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        if(sqlite3_step(stmt) != SQLITE_ROW){
            if sqlite3_exec(db, "Insert into CharacterData(user,color,accessory) SELECT 1, 'Blue', 'none' WHERE NOT EXISTS (SELECT * FROM CharacterData)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error inserting into table: \(errmsg)")
            }
            userColor = "Blue"
            
        }else{
            userColor = String(cString: sqlite3_column_text(stmt, 0))
        }
        sqlite3_finalize(stmt)
    }
    
    func loadSettings(){
        let queryString = "select * from SettingsData"
        var stmt:OpaquePointer?
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        if(sqlite3_step(stmt) != SQLITE_ROW){
            if sqlite3_exec(db, "Insert into SettingsData VALUES(1.0, 1.0, 'ChalkboardSE-Bold', 0 ) ", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error inserting into table: \(errmsg)")
            }
            font = "ChalkboardSE-Bold"
            
        }else{
            backgroundMusicPlayer.volume = Float(sqlite3_column_double(stmt, 0))
            // fxVolume.volume = Float(sqlite3_column_double(stmt,1))
            font = String(cString: sqlite3_column_text(stmt, 2))
            let still = Int(sqlite3_column_int(stmt, 3))
            if still == 0 {
                stillMode = false
            }else {
                stillMode = true
            }
            
        }
        sqlite3_finalize(stmt)
    }
    
}

func playBackgroundMusic(filename: String) {
    
    //The location of the file and its type
    let filepath = Bundle.main.path(forResource: filename, ofType: "mp3")
    
    //Returns an error if it can't find the file name
    if (filepath == nil) {
        print("Could not find the file \(filename)")
    }
    
    let url = URL(fileURLWithPath: filepath!)
    
    //Assigns the actual music to the music player
    do{
    backgroundMusicPlayer =  try AVAudioPlayer(contentsOf: url)
    }catch{
        print("Could not create audio player")
    }
    
    //A negative means it loops forever
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.volume = 0.7
    backgroundMusicPlayer.prepareToPlay()
    backgroundMusicPlayer.play()
}

func pauseBackgroundMusic(){
    backgroundMusicPlayer.pause()
    music = 0
}
func resumeBackgroundMusic(){
    backgroundMusicPlayer.play()
    music = 1
}


