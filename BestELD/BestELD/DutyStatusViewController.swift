//
//  DutyStatusViewController.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-30.
//

import UIKit

class DutyStatusViewController: UIViewController {

  @IBOutlet weak var noteTextField: UITextField!
  @IBOutlet weak var locationTextField: UITextField!
  @IBOutlet weak var startDateTextField: UITextField!
  @IBOutlet weak var endDateTextField: UITextField!
  @IBOutlet weak var dateContainerView: UIView!
  @IBOutlet weak var yardPersonalButton: UIButton!
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
  @IBAction func cancelButtonClicked(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func submitButtonClicked(_ sender: Any) {
  }
  @IBAction func offDutyClicked(_ sender: Any) {
  }
  @IBAction func onDutyClicked(_ sender: Any) {
  }
  @IBAction func sleeperClicked(_ sender: Any) {
  }
  @IBAction func yardPersonalClicked(_ sender: Any) {
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
