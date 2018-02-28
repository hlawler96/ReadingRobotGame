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
        return false;
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return levels.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelCell", for: indexPath) as! CollectionViewCell

        cell.LevelImage.image = UIImage(named: levels[indexPath.row])
        
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

