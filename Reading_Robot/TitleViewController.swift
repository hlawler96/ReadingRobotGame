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
    
    var db: OpaquePointer?
    
    @IBAction func unwindToMainMenu(unwindSegue: UIStoryboardSegue){}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("test.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }

        dropDB(db: db, table: "UserData")
    
        // checking for UserData table, creating if not found
        if sqlite3_exec(db, "create table if not exists UserData (miniGame text , lvl int , stars int , wrongWords text , time CURRENT_TIMESTAMP)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
  
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
    
    
    func testNewDB(){
        var db2: OpaquePointer?
        print("testing db connection")
        let filePath = Bundle.main.path(forResource: "ReadingRobot", ofType: "db")
        if sqlite3_open(filePath, &db2) != SQLITE_OK {
            print("error opening database")
        }
        
        let queryString = "Select * from Words"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let phoneme = String(cString: sqlite3_column_text(stmt, 0))
            let word = String(cString: sqlite3_column_text(stmt, 1))
            print("Phoneme: \(phoneme) , Word: \(word) ")
        }
        
    }
    
}

