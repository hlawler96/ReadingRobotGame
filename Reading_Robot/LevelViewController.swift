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
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return levels.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelCell", for: indexPath) as! CollectionViewCell

        cell.LevelImage.image = UIImage(named: levels[indexPath.row])
        
        
        return cell
    }
    

    
    
}

