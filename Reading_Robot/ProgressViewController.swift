//
//  ProgressViewController.swift
//  Reading_Robot
//
//  Created by Programming on 4/2/18.
//  Copyright © 2018 Hayden Lawler. All rights reserved.
//

import UIKit
import Foundation

class ProgressViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let x = ["ck", "ing", "ch"]
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return x.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell1 = tableView.dequeueReusableCell(withIdentifier: "ProgressTableViewCell") as! UITableViewCell
        let cell1 = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ProgressTableViewCell")
        cell1.textLabel?.text = x[indexPath.row]
        //cell1.ProgressBar.progress = 0.5
        
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
