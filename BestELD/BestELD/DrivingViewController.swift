//
//  DrivingViewController.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-22.
//

import UIKit

class DrivingViewController: UIViewController {

  @IBOutlet weak var drivingStatusText: UILabel!
  @IBOutlet weak var sliderValueText: UILabel!
  @IBOutlet weak var circularProgressBar: CircularProgressBar!
  @IBOutlet weak var dutyStatusTextField: UILabel!
  @IBOutlet weak var deviceTextField: UILabel!

  @IBOutlet weak var tempratureTextField: UIButton!
  @IBOutlet weak var locationTextField: UILabel!
  var currentDriver: Driver?
  var isEnterDrivingStatus = false
  var currentStatus: DutyStatus = .OnDuty {
    didSet {
      dutyStatusTextField.text = currentStatus.title
    }
  }
  override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationController?.navigationBar.isHidden = true
        drivingStatusText.text = "Stationary"
        disableButton(for: currentStatus)
        currentStatus = .OnDuty
        locationTextField.text = "SA, USA"
        tempratureTextField.isEnabled = false
        tempratureTextField.setTitle("56 F", for: .normal)
        circularProgressBar.lineWidth = 20
        navigationController?.setNavigationBarHidden(true, animated: false)

    }
    

  override func viewWillDisappear(_ animated: Bool) {
//    navigationController?.setNavigationBarHidden(true, animated: false)
  }

  @IBAction func scanEldDevices(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }

  @IBAction func dutyModeChanged(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let dutyStatusController =  storyboard.instantiateViewController(withIdentifier: "DutyStatusViewController") as! DutyStatusViewController
    dutyStatusController.didChangedDutyStatus = { status, notes, location in
      DataHandeler.shared.dutyStatusChanged(status: status,description: notes, timeToStart: Date())
      self.currentStatus = status
      self.navigationController?.popViewController(animated: true)
    }
    dutyStatusController.modalPresentationStyle = .overCurrentContext
    present(dutyStatusController, animated: true, completion: nil)
  }

  @IBAction func sliderValueChanged(_ sender: Any) {
    let slider = sender as! UISlider
    sliderValueText.text = String(slider.value)
    if slider.value > 5.0 {
      drivingStatusText.text = "On Track"
    }else {
      drivingStatusText.text = "Stationary"
    }

    if !isEnterDrivingStatus {
      isEnterDrivingStatus.toggle()
      currentStatus = .Driving
      //enter driving into database
      guard let driverObj = currentDriver else {
        assertionFailure("Invalid driver object")
        return
      }
      let driverMetaData = DataHandeler.shared.dayMetaData(dayStart: Date(), driverDL: driverObj.dlNumber ?? testDriverDLNumber)
      guard let metaData = driverMetaData, (metaData.dayData?.count ?? 0 > 0) else {
        assertionFailure("something wrong with database")
        return
      }
      let startDate = Date()
      let currentDayData = DataHandeler.shared.createDayData(start: startDate, end: Date(), status: .Driving, desciption: "Driving On Fly",for: driverObj)

    }
  }

  @IBAction func dutyButtonClicked(_ sender: Any) {
    var status: DutyStatus = .OffDuty
    let button = sender as! UIButton
    switch button.tag {
      case 0:
        status = .OffDuty
      case 1:
        status = .OnDuty
      case 2:
        status = .Sleeper
      case 3:
        status = .Personal
      default:
        status = .Yard
    }
    print("duty status")
    showAlertToUser(
      status: currentStatus,
      continueAction: (title: nil, handler: { description,date in
        DataHandeler.shared.dutyStatusChanged(status: status,description: description, timeToStart: date)
        self.currentStatus = status
        self.disableButton(for: status)
        self.navigationController?.popViewController(animated: true)
      }),
      cancelAction: (title: nil, handler: { description,date in
      }))
  }

  func disableButton(for status:DutyStatus) {
    return
  }

  @IBAction func dutyStatusButtonClicked(_ sender: Any) {
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
