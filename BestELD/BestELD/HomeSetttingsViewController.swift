//
//  HomeSetttingsViewController.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-30.
//

import UIKit

class MenuViewController: UIViewController {

  @IBOutlet weak var collectionView: UICollectionView!
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

  
}

extension MenuViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    patientData.count
  }
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PatientVCCollectionCell.typeName, for: indexPath) as? PatientVCCollectionCell else {
      return UICollectionViewCell()
    }
    let patientInfo = patientData[indexPath.row]

    cell.titleLabel.text = patientInfo.title
    cell.desctiptionLabel.text = patientInfo.description

    return cell
  }

}


class MenuCollectionCell: UICollectionViewCell {


  @IBOutlet weak var imageView: UIImageView!
}
