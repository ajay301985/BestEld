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

  private var currentDutyStatus: DutyStatus = .OFFDUTY {
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
      case .ONDUTY:
        print("on duty")
      case .OFFDUTY:
        print("off duty")
      case .SLEEPER:
        print("sleeper duty")
      case .YARD:
        print("yad duty")
      case .PERSONAL:
        print("personal duty")
      case .DRIVING:
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
    currentDutyStatus = .OFFDUTY
    updateViewOnDutyStatusChanged(dStatus: .OFFDUTY)
  }

  @IBAction func onDutyClicked(_ sender: Any) {
    currentDutyStatus = .ONDUTY
    updateViewOnDutyStatusChanged(dStatus: .ONDUTY)
  }

  @IBAction func sleeperClicked(_ sender: Any) {
    currentDutyStatus = .SLEEPER
    updateViewOnDutyStatusChanged(dStatus: .SLEEPER)
  }

  @IBAction func yardPersonalClicked(_ sender: Any) {
    let button = sender as! UIButton
    if button.tag == 101 { //yard mode selected
      currentDutyStatus = .YARD
    }else if (button.tag == 102){ //enable personal mode
      currentDutyStatus = .PERSONAL
    }
  }

  private func updateViewOnDutyStatusChanged(dStatus: DutyStatus) {
    switch dStatus {
      case .SLEEPER:
        yardPersonalButton.isHidden = true
      case .ONDUTY:
        yardPersonalButton.isHidden = false
        yardPersonalButton.setTitle("Enable Yard Mode", for: .normal)
        yardPersonalButton.setImage(UIImage(named: "yardmode"), for: .normal)
        yardPersonalButton.tag = 101
      case .OFFDUTY:
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
