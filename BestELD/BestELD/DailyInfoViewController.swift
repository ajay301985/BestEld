//
//  DailyInfoViewController.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-02-11.
//

import Foundation
import UIKit


enum TripStatus: String {
  case PRETRIP
  case POSTTRIP
}


class DailyInfoViewController: UIViewController {

  struct DailyLogInfo {
    var logTitle: String
    var logValue: String
    var isEditable: Bool = false
    var isViolation: Bool? = false
    var extraInfo: String?
    var hadExtraInfo: Bool
  }

  @IBOutlet weak var preTripButton: UIButton!
  @IBOutlet weak var postTripButton: UIButton!
  @IBOutlet weak var inspectionButton: UIButton!
  @IBOutlet weak var dailylogButton: UIButton!
  @IBOutlet weak var inspectionView: UIView!
  @IBOutlet weak var logInfoTableView: UITableView!
  @IBOutlet weak var notesTextField: UITextField!
  @IBOutlet weak var locationTextField: UITextField!

  var currentTripStatus: TripStatus = .PRETRIP

  var dailyLogDataArr: [DailyLogInfo] = []
  @IBAction func postTripButtonClicked(_ sender: Any) {
    preTripButton.isSelected = false
    postTripButton.isSelected = true
    currentTripStatus = .POSTTRIP
  }

  @IBAction func preTripButtonClicked(_ sender: Any) {
    preTripButton.isSelected = false
    postTripButton.isSelected = false
    currentTripStatus = .PRETRIP
  }

  @IBAction func confirmClicked(_ sender: Any) {
    if (inspectionView.isHidden == false) {
      let dayTripData = DataHandeler.shared.saveTripData(status: currentTripStatus , notes: notesTextField.text, location: "", inDayData: Date())
      dismiss(animated: true, completion: nil)
    }
  }

  @IBAction func cancelClicked(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func inspectionClicked(_ sender: Any) {
    inspectionView.isHidden = false
    locationTextField.isEnabled = false
    locationTextField.text = BldLocationManager.shared.locationText
  }

  @IBAction func dailylogClicked(_ sender: Any) {
    inspectionView.isHidden = true
  }

  override func viewDidLoad() {
    inspectionView.isHidden = true
    notesTextField.applyBottomBorder()
    locationTextField.applyBottomBorder()
    generateDataModels()
    inspectionButton.applyLeftBorder()
    logInfoTableView.reloadData()
    notesTextField.delegate = self
    locationTextField.delegate = self
  }


  private func generateDataModels() {
    guard let currentEldData = DataHandeler.shared.currentEldData else {
      assertionFailure("Invalid Eld Data")
      return
    }

    var dailyLogObj = DailyLogInfo(logTitle: "Vehicles", logValue: currentEldData.truckNumber ?? "", isEditable: false, isViolation: false, extraInfo: nil, hadExtraInfo: false)
    dailyLogDataArr.append(dailyLogObj)

    dailyLogObj = DailyLogInfo(logTitle: "Trailers", logValue: "Invalid trailer", isEditable: false, isViolation: false, extraInfo: nil, hadExtraInfo: false)
    dailyLogDataArr.append(dailyLogObj)

    dailyLogObj = DailyLogInfo(logTitle: "Distance", logValue: "123Miles", isEditable: false, isViolation: false, extraInfo: nil, hadExtraInfo: true)
    dailyLogDataArr.append(dailyLogObj)

    dailyLogObj = DailyLogInfo(logTitle: "Odometer", logValue: "San Jon 300 Km  ", isEditable: false, isViolation: false, extraInfo: "4 Readings", hadExtraInfo: false)
    dailyLogDataArr.append(dailyLogObj)

    dailyLogObj = DailyLogInfo(logTitle: "Shipping Nos", logValue: "xyz shipping", isEditable: true, isViolation: false, extraInfo: nil, hadExtraInfo: false)
    dailyLogDataArr.append(dailyLogObj)


    let driverFullName = (DataHandeler.shared.currentDriver.firstName ?? "" + (DataHandeler.shared.currentDriver.lastName ?? ""))

    dailyLogObj = DailyLogInfo(logTitle: "Drivers", logValue: driverFullName, isEditable: false, isViolation: false, extraInfo: nil, hadExtraInfo: false)
    dailyLogDataArr.append(dailyLogObj)

    dailyLogObj = DailyLogInfo(logTitle: "Co-Drivers", logValue: "xyz co-driver", isEditable: false, isViolation: false, extraInfo: nil, hadExtraInfo: false)
    dailyLogDataArr.append(dailyLogObj)

    dailyLogObj = DailyLogInfo(logTitle: "Carrier", logValue: currentEldData.carrierName ?? "", isEditable: false, isViolation: false, extraInfo: nil, hadExtraInfo: false)
    dailyLogDataArr.append(dailyLogObj)

    dailyLogObj = DailyLogInfo(logTitle: "Home Terminal", logValue: DataHandeler.shared.currentDriver.homeTerminal ?? "Invalid Home Terminal" , isEditable: false, isViolation: false, extraInfo: nil, hadExtraInfo: false)
    dailyLogDataArr.append(dailyLogObj)

    dailyLogObj = DailyLogInfo(logTitle: "Main office", logValue: DataHandeler.shared.currentDriver.mainOffice ?? "Invalid Main office address", isEditable: false, isViolation: false, extraInfo: nil, hadExtraInfo: false)
    dailyLogDataArr.append(dailyLogObj)
  }

}

extension DailyInfoViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    dailyLogDataArr.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let tableCell = tableView.dequeueReusableCell(withIdentifier: "DailyLogTableViewCell") as! DailyLogTableViewCell
    let currenLog = dailyLogDataArr[indexPath.row]
    tableCell.titleLabel.text = currenLog.logTitle
    tableCell.titleLabel.textColor = currenLog.isViolation ?? false ? UIColor.red : UIColor.black
    tableCell.infoLabel.text = currenLog.extraInfo
    tableCell.valueTextField.text = currenLog.logValue
    tableCell.valueTextField.delegate = self
    tableCell.valueTextField.isEnabled = currenLog.isEditable
    return tableCell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

  }

}

