import PlaygroundSupport
import UIKit
class TableViewCollection:UIViewController,UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = UICollectionViewCell()
        return cell;
    }

    override func viewDidLoad() {
        let collection = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 200))
        collection.delegate = self
        collection.dataSource = self
        view.addSubview(collection)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2;
    }
    
//      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//          
//      }
}


PlaygroundPage.current.liveView = TableViewCollection().view
