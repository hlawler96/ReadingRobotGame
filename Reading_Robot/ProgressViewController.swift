//
//  ProgressViewController.swift
//  Reading_Robot
//
//  Created by Programming on 4/2/18.
//  Copyright © 2018 Derek Creason. All rights reserved.
//

import SQLite3
import UIKit
import Foundation

class ProgressViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var x = 0
    var y = 0
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func clearData(_ sender: Any) {
        dropDatabases()
        loadUserColor()
        oppColor = "Blue"
        loadSettings()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let queryString = "SELECT COUNT(L.number) from LevelData L"
        var stmt:OpaquePointer?
        if sqlite3_prepare(db2, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        while(sqlite3_step(stmt) == SQLITE_ROW){
            x = Int(sqlite3_column_int(stmt, 0))
            break;
        }
        sqlite3_finalize(stmt)
        y = x
        return x
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "ProgressTableViewCell") as! ProgressTableViewCell
        //cell1.textLabel?.text = x[indexPath.row]
        //cell1.ProgressBar.progress = 0.5
        
        let queryString = "SELECT AVG(U.percent) from UserData U where U.lvl = \(indexPath.row) + 1"

        var stmt:OpaquePointer?
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        while(sqlite3_step(stmt) == SQLITE_ROW){
            cell1.ProgressLevel.text = String(indexPath.row + 1)
            cell1.PercentageLabel.text = String((sqlite3_column_double(stmt, 0) * 100).rounded()) + " %"
            break;
        }
        
        let queryString2 = "SELECT U.pattern from UserData U where U.lvl = \(indexPath.row) + 1"
        
        var stmt2:OpaquePointer?

        if sqlite3_prepare(db, queryString2, -1, &stmt2, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        while(sqlite3_step(stmt2) == SQLITE_ROW){
            cell1.PhonemeType.text = String(cString : sqlite3_column_text(stmt2, 0))
            break;
        }
         sqlite3_finalize(stmt)
         sqlite3_finalize(stmt2)
        //cell1.PhonemeType.text = "0"
        return cell1
        
    }
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        super.viewDidLoad()
    }
    
    override var shouldAutorotate: Bool {
        return true;
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    


    




}
