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
  @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var dateHeightConstraint: NSLayoutConstraint!

  @IBOutlet weak var offDutyButton: UIButton!
  @IBOutlet weak var onDutyButton: UIButton!
  @IBOutlet weak var sleeperButton: UIButton!
  
  var didChangedDutyStatus: ((_ status: DutyStatus, _ notes:String?, _ location:String?) -> ())!

  private var currentDutyStatus: DutyStatus = .OffDuty {
    didSet {
      updateButton(status: currentDutyStatus)
    }
  }
  override func viewDidLoad() {
        super.viewDidLoad()
        viewBottomConstraint.constant = 0
        dateHeightConstraint.constant = 0
        dateContainerView.isHidden = true
        // Do any additional setup after loading the view.

    NotificationCenter.default.addObserver(self, selector: #selector(DutyStatusViewController.keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(DutyStatusViewController.keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }

  var isEditiingEvent: Bool = false {
    didSet {
      if isEditiingEvent == true {
        dateHeightConstraint.constant = 0
      }
      dateContainerView.isHidden = isEditiingEvent
    }
  }

  private func updateButton(status: DutyStatus) {
    switch status {
      case .OnDuty:
        print("on duty")
      case .OffDuty:
        print("off duty")
      case .Sleeper:
        print("sleeper duty")
      case .Yard:
        print("yad duty")
      case .Personal:
        print("personal duty")
      case .Driving:
        print("driving duty")
    }
  }

  @IBAction func cancelButtonClicked(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func submitButtonClicked(_ sender: Any) {
    dismiss(animated: true, completion: {
      self.didChangedDutyStatus(self.currentDutyStatus, self.noteTextField.text, self.locationTextField.text)
    })
  }

  @IBAction func offDutyClicked(_ sender: Any) {
    currentDutyStatus = .OffDuty
    updateViewOnDutyStatusChanged(dStatus: .OffDuty)
  }

  @IBAction func onDutyClicked(_ sender: Any) {
    currentDutyStatus = .OnDuty
    updateViewOnDutyStatusChanged(dStatus: .OnDuty)
  }

  @IBAction func sleeperClicked(_ sender: Any) {
    currentDutyStatus = .Sleeper
    updateViewOnDutyStatusChanged(dStatus: .Sleeper)
  }

  @IBAction func yardPersonalClicked(_ sender: Any) {
    let button = sender as! UIButton
    if button.tag == 101 { //yard mode selected
      currentDutyStatus = .Yard
    }else if (button.tag == 102){ //enable personal mode
      currentDutyStatus = .Personal
    }
  }

  private func updateViewOnDutyStatusChanged(dStatus: DutyStatus) {
    switch dStatus {
      case .Sleeper:
        yardPersonalButton.isHidden = true
      case .OnDuty:
        yardPersonalButton.isHidden = false
        yardPersonalButton.setTitle("Enable Yard Mode", for: .normal)
        yardPersonalButton.setImage(UIImage(named: "yardmode"), for: .normal)
        yardPersonalButton.tag = 101
      case .OffDuty:
        yardPersonalButton.isHidden = false
        yardPersonalButton.tag = 102
        yardPersonalButton.setTitle("Enable Personal Mode", for: .normal)
      default:
        print("invalid")
    }
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

extension DutyStatusViewController {
  @objc func keyboardWillShowNotification(_ notification: Notification) {
    guard let userInfo = notification.userInfo else {
      return
    }
    viewBottomConstraint.constant = 284
  }

  @objc func keyboardWillHideNotification(_ notification: Notification) {
    guard let userInfo = notification.userInfo else {
      return
    }
    viewBottomConstraint.constant = 0
  }
}
