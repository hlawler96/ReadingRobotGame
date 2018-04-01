import UIKit
import SpriteKit
import GameplayKit
import SQLite3

class LevelViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var numLevels: Int!
    final var CHARACTER_CUSTOM_TAG = 1000
    
    @IBOutlet weak var charButton: UIButton!
    @IBOutlet weak var LevelCollectionView: UICollectionView!
    
    @IBAction func unwindToLevelMenu(unwindSegue: UIStoryboardSegue)
    {
        
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
        // uses tag of button to perform proper segue
        if sender.tag == numLevels + 1 {
             performSegue(withIdentifier: "TAPPING_SEGUE", sender: sender)
        }else if sender.tag == CHARACTER_CUSTOM_TAG {
            performSegue(withIdentifier: "CHARACTER_CUSTOM_SEGUE", sender: sender)
        }else{
            performSegue(withIdentifier: "TOW_SEGUE", sender: sender)
        }
        
    }
    // on load sets the proper robot in top right and makes sure the music is still playing,
    // also fixes the level cells if user just finished a level and now has more stars
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        charButton.setImage(UIImage(named: userColor + "_Idle_000"), for: .normal)
        self.LevelCollectionView.reloadData()
        if !backgroundMusicPlayer.isPlaying {
            playBackgroundMusic(filename: "music")
        }
    }
    
    //sets correct robot picture in top right corner and sets self as datasource/delegate for the level cells
    override func viewDidLoad() {
        super.viewDidLoad()
        charButton.setImage(UIImage(named: userColor + "_Idle_000"), for: .normal)
        LevelCollectionView.delegate = self
        LevelCollectionView.dataSource = self
       
    }
    override var shouldAutorotate: Bool {
        return true;
    }
    
    // if going to tug of war game it sets the corresponding class variable to the level number that was clicked
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "TOW_SEGUE"){
            let tow = segue.destination as! GameViewController
            tow.levelNumber = (sender as! UIButton).tag
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        //sets the number of cells to the number of levels in the database + 1 for a playground level
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
        return numLevels + 1
    }
    

    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        //for each cell gives the corresponding level number, the highest number of stars earned on that level and sets the right tag which is used for segues
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelCell", for: indexPath) as! CollectionViewCell
        cell.LevelButton.tag = indexPath.item + 1
        
        if (indexPath.item) == (numLevels!){
            cell.LevelLabel.text = "test"
            cell.LevelLabel.backgroundColor = UIColor.yellow
        }else{
        cell.LevelLabel.text = String(indexPath.item + 1)
        cell.LevelLabel.backgroundColor = UIColor.cyan
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
        }
        return cell
    }
    

    
    
}

