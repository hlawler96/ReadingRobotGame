import UIKit
import SpriteKit
import GameplayKit
import SQLite3

class LevelViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    let levels = ["LevelOne", "LevelTwo"]
    
    
    @IBOutlet weak var LevelCollectionView: UICollectionView!
    
    @IBAction func unwindToLevelMenu(unwindSegue: UIStoryboardSegue)
    {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.LevelCollectionView.reloadData()
        if !backgroundMusicPlayer.isPlaying {
            playBackgroundMusic(filename: "music")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    LevelCollectionView.delegate = self
    LevelCollectionView.dataSource = self
        
        
    }
    override var shouldAutorotate: Bool {
        return true;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "Game_Segue"){
            let tow = segue.destination as! GameViewController
            tow.levelNumber = (sender as! UIButton).tag
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return levels.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelCell", for: indexPath) as! CollectionViewCell
        
        cell.LevelImage.image = UIImage(named: levels[indexPath.row])
        cell.LevelButton.tag = indexPath.row + 1
        
        var db: OpaquePointer?
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("test.sqlite")
        // open database
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        let queryString = "SELECT max(U.stars) from UserData U where U.lvl = \(cell.LevelButton.tag)"
        
        var stmt:OpaquePointer?
        var numStars = 0
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        //traversing through all the records, should only be one
        while(sqlite3_step(stmt) == SQLITE_ROW){
            numStars = Int(sqlite3_column_int(stmt, 0))
            break;
        }
        
        switch numStars {
        case 1:
           cell.StarView.image = UIImage(named: "Star.png")
        case 2:
             cell.StarView.image = UIImage(named: "Star.png")
             cell.StarView1.image = UIImage(named: "Star.png")
        case 3:
             cell.StarView.image = UIImage(named: "Star.png")
             cell.StarView1.image = UIImage(named: "Star.png")
             cell.StarView2.image = UIImage(named: "Star.png")
        default:
            numStars = 0
        }
        sqlite3_finalize(stmt)
        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        
        return cell
    }
    

    
    
}

