//
//  LogBookViewController.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-19.
//

import UIKit


enum DutyStatus: Int16 {
  case OnDuty
  case OffDuty
  case Sleeper
  case Yard
  case Driving
  case Personal

  var dutyIndex: Int16 {
    switch self {
      case .OnDuty:
        return 0
      case .OffDuty:
        return 1
      case .Sleeper:
        return 2
      case .Yard:
        return 3
      case .Driving:
        return 4
      default:
        return 5
    }
  }

/*  init(index: Int) {
    switch index {
      case 0: self = .OnDuty
      case 1: self = .OffDuty
      case 2: self = .Sleeper
      case 3: self = .Yard

      default:
        assertionFailure("Index out of bounds for UISegmentControl")
        self = .Personal
    }
  } */
}

class LogBookViewController: UIViewController {

  @IBOutlet weak var dutyStatusStackView: UIStackView!
  @IBOutlet weak var dutyStatusButton: UIButton!
  private var viewModel: LogBookViewModel!  //TODO: fix it
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentDriver = viewModel.driverName
        let currentDriver1 = viewModel.currentDay
        print("driver name is = \(currentDriver) and driving on \(currentDriver1)")

        dutyStatusStackView.isHidden = true
        performLoggedIn()
        // Do any additional setup after loading the view.
    }


  func performLoggedIn() {
    if (viewModel.shouldSetDefaultOffDuty) {
      self.viewModel?.dutyStatusChanged(status: .OffDuty)
    }
  }

  func setViewModel(dataViewModel: LogBookViewModel) {
    viewModel = dataViewModel
  }

  @IBAction func dutyButtonClicked(_ sender: Any) {
    var currentStatus: DutyStatus = .OffDuty
    let button = sender as! UIButton
    switch button.tag {
      case 0:
        print("off duty")
        dutyStatusButton.setTitle("Off Duty", for: .normal)
        currentStatus = .OffDuty
      case 1:
        print("on duty")
        dutyStatusButton.setTitle("On Duty", for: .normal)
        currentStatus = .OnDuty
      case 2:
        print("sleeper duty")
        dutyStatusButton.setTitle("Sleeper", for: .normal)
        currentStatus = .Sleeper
      case 3:
        print("personal duty")
        dutyStatusButton.setTitle("Personal", for: .normal)
        currentStatus = .Personal
      default:
        print("duty status yard")
        dutyStatusButton.setTitle("Yard", for: .normal)
        currentStatus = .Yard
    }
    print("duty status")
    dutyStatusStackView.isHidden.toggle()
    showAlertToUser(status: currentStatus)
  }

  @IBAction func dutyStatusButtonClicked(_ sender: Any) {
    dutyStatusStackView.isHidden.toggle()
  }
  /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

  func showAlertToUser(status: DutyStatus) {

    let textField = UITextField(frame: CGRect(x: 10, y: 65, width: 260, height: 30))
    textField.backgroundColor = .yellow

    let myDatePicker: UIDatePicker = UIDatePicker()
    // setting properties of the datePicker
    myDatePicker.timeZone = NSTimeZone.local
    myDatePicker.frame = CGRect(x: 50, y: 100, width: 270, height: 200)
    myDatePicker.minimumDate = Date()
    myDatePicker.datePickerMode = .time

    let alertController = UIAlertController(title: "Select Date \n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertController.Style.alert)
    alertController.view.addSubview(textField)
    alertController.view.addSubview(myDatePicker)
    let somethingAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {_ in
      let description = textField.text
      let datePickerValue = myDatePicker.date
      self.viewModel?.dutyStatusChanged(status: status,description: description, timeToStart: datePickerValue)
    })
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
    alertController.addAction(somethingAction)
    alertController.addAction(cancelAction)
    self.present(alertController, animated: true, completion:{
    })
  }


}
