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

class TitleViewController: UIViewController {
    let correctWordsArray =  ["Sick","Sock","Lock","Luck","Click","Clock","Frock","Smack","Tuck","Tack","Tock","Dock","Duck","Mack","Nick","Truck","Sack","Stack","Rack","Hack","Shack","Thick","Pack","Pick","Rick","Crack","Chuck","Wick","Shuck","Shock","Lack","Struck","Chick","Slick","Slack"]
    
    let wrongWordsArray = ["Hill","Still","Must","Pass","Sin","Pig","Wig","Thin","Make","Wag","Pox","Box","Fox","Zen","Cake","Frog","Step","Slip","Prom","Chin","Chill","Shell","Ship","Fish","Rush","Wish","Shin","Take","Rope","Tap","Clam","Sing","Wing","Chop","Thing",]
    
    @IBAction func unwindToMainMenu(unwindSegue: UIStoryboardSegue){}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("test.sqlite")
        // open database
        var db: OpaquePointer?
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        dropDB(db: db, table: "Words")
        dropDB(db: db, table: "LevelData")
        dropDB(db: db, table: "UserData")
        
        if sqlite3_exec(db, "create table if not exists Words (phoneme text , word text)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        loadWords(db: db)
    
        // checking for UserData table, creating if not found
        if sqlite3_exec(db, "create table if not exists UserData (miniGame text , lvl int , stars int , wrongWords text , time CURRENT_TIMESTAMP)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        //checking for LevelData table, creating if not found
        if sqlite3_exec(db, "create table if not exists LevelData (number int, phoneme text, numWords int, speed text)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        loadLevels(db: db)
        
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
    }
    
    func insertWord(phoneme: String, word: String, db: OpaquePointer?){
        //the insert query
        let queryString = "INSERT INTO Words VALUES ('" + phoneme + "','" + word + "');"
        
        //executing the query to insert values
        if sqlite3_exec(db, queryString, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting Words: \(errmsg)")
            return
        }
    }
    
    func loadWords(db: OpaquePointer?){
        for correctWord in correctWordsArray {
            insertWord(phoneme: "-ck", word: correctWord, db: db)
        }
        for wrongWord in wrongWordsArray {
            insertWord(phoneme: "not-ck", word: wrongWord, db: db)
        }
    }
    
    func loadLevels(db: OpaquePointer?){
        
        var queryString = "INSERT INTO LevelData VALUES (1,'-ck',6,'slow');"
        
        //executing the query to insert values
        if sqlite3_exec(db, queryString, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting LevelData: \(errmsg)")
            return
        }
        
        queryString = "INSERT INTO LevelData VALUES (2,'-ck',7,'fast');"
        
        //executing the query to insert values
        if sqlite3_exec(db, queryString, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting LevelData: \(errmsg)")
            return
        }
    }
    
    
    
}

class Word {
    var phoneme: String
    var word: String
    
    init(phoneme: String, word: String){
        self.phoneme = phoneme
        self.word = word
    }
}
