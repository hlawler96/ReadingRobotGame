import UIKit
import SpriteKit
import GameplayKit

class LevelViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    let levels = ["LevelOne", "LevelTwo"]
    
    
    @IBOutlet weak var LevelCollectionView: UICollectionView!
    
    @IBAction func unwindToLevelMenu(unwindSegue: UIStoryboardSegue)
    {
        
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
        
        let tow = segue.destination as! GameViewController
        tow.levelNumber = (sender as! UIButton).tag
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
        //must add condition for scoring and retrieving from database
        //ex. if % > 33 1 star
        // if % > 66 2 star
        // if % = 100 3 star
        cell.StarView.image = UIImage(named: "Star.png")
        cell.StarView1.image = UIImage(named: "Star.png")
        //cell.StarView2.image = UIImage(named: "Star.png")
        
        return cell
    }
    

    
    
}

