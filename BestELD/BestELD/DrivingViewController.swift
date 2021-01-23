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
  @IBOutlet weak var dutyStatusStackView: UIStackView!
  @IBOutlet weak var dutyStatusButton: UIButton!

  var currentDriver: Driver?
  var isEnterDrivingStatus = false
  var currentStatus: DutyStatus = .OnDuty {
    didSet {
      dutyStatusButton.setTitle(currentStatus.title, for: .normal)
    }
  }
  override func viewDidLoad() {
        super.viewDidLoad()
        drivingStatusText.text = "Stationary"
        dutyStatusStackView.isHidden = true
        disableButton(for: currentStatus)
        currentStatus = .OnDuty
        navigationController?.setNavigationBarHidden(true, animated: false)

    }
    

  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.setNavigationBarHidden(false, animated: false)
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
      let driverMetaData = DataHandeler.shared.dayMetaData(dayStart: Date(), driverDL: driverObj.dlNumber ?? "xyz12345")
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
    dutyStatusStackView.isHidden.toggle()

    showAlertToUser(
      status: currentStatus,
      continueAction: (title: nil, handler: { description,date in
        DataHandeler.shared.dutyStatusChanged(status: status,description: description, timeToStart: date)
        self.currentStatus = status
        self.disableButton(for: status)
        self.dutyStatusStackView.isHidden.toggle()
        self.navigationController?.popViewController(animated: true)
      }),
      cancelAction: (title: nil, handler: { description,date in
      }))
  }

  func disableButton(for status:DutyStatus) {
    let index = status.dutyIndex
    let array = dutyStatusStackView.subviews
    for currentView in array {
      if (currentView.isKind(of: UIButton.self)) {
        let button = currentView as! UIButton
        if (button.tag == index)
        {
          button.isEnabled = false
        }else {
          button.isEnabled = true
        }
      }
    }
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

}
