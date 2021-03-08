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
  var currentStatus: DutyStatus = .DRIVING {
    didSet {
      dutyStatusTextField.text = currentStatus.title
    }
  }

  override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationController?.navigationBar.isHidden = true
        drivingStatusText.text = "Stationary"
        disableButton(for: currentStatus)
        currentStatus = .ONDUTY
        locationTextField.text = BldLocationManager.shared.locationText
        tempratureTextField.isEnabled = false
        tempratureTextField.setTitle("56 F", for: .normal)
        circularProgressBar.lineWidth = 20
        let imageObj = UIImage(named: "speedindicator")
        circularProgressBar.image = imageObj
        //circularProgressBar.backgroundColor = .yellow
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
      currentStatus = .DRIVING
      //enter driving into database
      guard let driverObj = currentDriver else {
        assertionFailure("Invalid driver object")
        return
      }
      let driverMetaData = DataHandeler.shared.dayMetaData(dayStart: BLDAppUtility.startOfTheDayTimeInterval(for: Date()), driverDL: driverObj.dlNumber ?? TEST_DRIVER_DL_NUMBER)
      guard let metaData = driverMetaData, (metaData.dayData?.count ?? 0 > 0) else {
        assertionFailure("something wrong with database")
        return
      }
      let startDate = Date()
      DataHandeler.shared.dutyStatusChanged(status: .DRIVING, description: "Driving", timeToStart: startDate)
    }
  }

  @IBAction func dutyButtonClicked(_ sender: Any) {
    var status: DutyStatus = .OFFDUTY
    let button = sender as! UIButton
    switch button.tag {
      case 0:
        status = .OFFDUTY
      case 1:
        status = .ONDUTY
      case 2:
        status = .SLEEPER
      case 3:
        status = .PERSONAL
      default:
        status = .YARD
    }
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

}
