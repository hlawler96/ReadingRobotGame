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
       dropDB(db: db)
        
        if sqlite3_exec(db, "create table if not exists Words (phoneme text , word text)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        loadWords(db: db)
//        printDB(db: db)
    
        // checking for LevelData table, creating if not found
        if sqlite3_exec(db, "create table if not exists LevelData (miniGame text , lvl int , stars int , wrongWords text , time CURRENT_TIMESTAMP)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")

        
        
        
    }

        
        
        
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
    
    func dropDB(db: OpaquePointer?){
        //creating a statement
        var stmt: OpaquePointer?
        
        //the insert query
        let queryString = "Drop table Words"
        
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
        
        //displaying a success message
        print("Words dropped")
    }
    
    func printDB(db: OpaquePointer?){
        var wordList = [Word]()
        
        let queryString = "select phoneme, word from Words"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let phoneme = String(cString: sqlite3_column_text(stmt, 0))
            let word = String(cString: sqlite3_column_text(stmt, 1))
            
            //adding values to list
            wordList.append(Word(phoneme: phoneme, word: word))
            print("Phoneme: " + phoneme + " , Word: " + word)
        }
    }
    
    func insertWord(phoneme: String, word: String, db: OpaquePointer?){
        //the insert query
        let queryString = "INSERT INTO Words VALUES ('" + phoneme + "','" + word + "');"
//        print(queryString)
        
        //executing the query to insert values
        if sqlite3_exec(db, queryString, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting Words: \(errmsg)")
            return
        }
        
        //displaying a success message
//        print("Words inserted into successfully")
    }
    
    func loadWords(db: OpaquePointer?){
        for correctWord in correctWordsArray {
            insertWord(phoneme: "-ck", word: correctWord, db: db)
        }
        for wrongWord in wrongWordsArray {
            insertWord(phoneme: "not-ck", word: wrongWord, db: db)
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
