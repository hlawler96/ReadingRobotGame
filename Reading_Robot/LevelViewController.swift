import UIKit
import SpriteKit
import GameplayKit
import SQLite3

class LevelViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var numLevels: Int!
    
    
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
        
        let queryString = "SELECT COUNT(L.number) from LevelData L"
        var stmt:OpaquePointer?
        if sqlite3_prepare(db2, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        while(sqlite3_step(stmt) == SQLITE_ROW){
            numLevels = Int(sqlite3_column_int(stmt, 0))
            break;
        }
        sqlite3_finalize(stmt)
        return numLevels
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelCell", for: indexPath) as! CollectionViewCell
        cell.LevelButton.tag = indexPath.row + 1
        cell.LevelLabel.text = String(indexPath.row + 1)
        
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
        return cell
    }
    

    
    
}

