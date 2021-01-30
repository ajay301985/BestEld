//
//  MenuViewController.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-30.
//

import UIKit

class MenuViewController: UIViewController {

  @IBOutlet weak var collectionView: UICollectionView!
  private var menuItems: [MenuItem] = []


  var didSelectMenuItem: ((_ selectedItem: MenuItem?, _ index:Int)->())!

  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

  func setup(menuItemArr: [MenuItem]) {
    menuItems = menuItemArr

    //collectionView.reloadData()
  }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

  @IBAction func hideButtonDidClicked(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
}

extension MenuViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    3
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    3
  }


  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuitemcellidentifier", for: indexPath) as? MenuCollectionCell else {
      return UICollectionViewCell()
    }
    let rowIndex = (indexPath.section * 3) + indexPath.row
    let menuItem = menuItems[rowIndex]

    let imageObj = UIImage(named: menuItem.imageName)
    cell.imageView.image = imageObj
    cell.title.text = menuItem.title
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    dismiss(animated: true, completion: {
      self.didSelectMenuItem(nil, indexPath.row)
    })
  }

  func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
    // 1
    switch kind {
      // 2
      case UICollectionView.elementKindSectionHeader:

        // 3
        guard
          let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "\(MenuItemHeaderView.self)",
            for: indexPath) as? MenuItemHeaderView
        else {
          fatalError("Invalid view type")
        }
        headerView.headerButton.isHidden = (indexPath.section != 0)
        return headerView
      default:
        // 4
        assert(false, "Invalid element type")
    }
  }
}


extension UICollectionView {
  func indexPathForSupplementaryElement(ofKind kind: String, at point: CGPoint) -> IndexPath? {
    let targetRect = CGRect(origin: point, size: CGSize(width: 0.1, height: 0.1))
    guard let attributes = collectionViewLayout.layoutAttributesForElements(in: targetRect) else { return nil }

    return attributes.filter { $0.representedElementCategory == .supplementaryView && $0.representedElementKind == kind }.first?.indexPath
  }
}


class MenuCollectionCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var title: UILabel!
}

class MenuItemHeaderView: UICollectionReusableView {
  @IBOutlet weak var headerButton: UIButton!
}
