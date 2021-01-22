//
//  UserPreferencesViewController.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-16.
//

import UIKit
import L10n_swift

class UserPreferencesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
  @IBAction func changeLanguage(_ sender: Any) {
    L10n.shared.language = "hi"
  }

  @IBAction func changeLanguageToPunjabi(_ sender: Any) {
    L10n.shared.language = "pa"
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
