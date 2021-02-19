//
//  DailyInfoViewController.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-02-11.
//

import Foundation
import UIKit

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

  var dailyLogDataArr: [DailyLogInfo] = []
  @IBOutlet weak var postTripButtonClicked: UIButton!
  @IBAction func preTripButtonClicked(_ sender: Any) {
  }
  @IBAction func confirmClicked(_ sender: Any) {
  }

  @IBAction func cancelClicked(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func inspectionClicked(_ sender: Any) {
    inspectionView.isHidden = false
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
    var dailyLogObj = DailyLogInfo(logTitle: "Vehicles", logValue: "BT001", isEditable: false, isViolation: false, extraInfo: nil, hadExtraInfo: false)
    dailyLogDataArr.append(dailyLogObj)

    dailyLogObj = DailyLogInfo(logTitle: "Trailers", logValue: "363", isEditable: false, isViolation: false, extraInfo: nil, hadExtraInfo: false)
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

    dailyLogObj = DailyLogInfo(logTitle: "Co-Drivers", logValue: "Pankaj", isEditable: false, isViolation: false, extraInfo: nil, hadExtraInfo: false)
    dailyLogDataArr.append(dailyLogObj)

    dailyLogObj = DailyLogInfo(logTitle: "Carrier", logValue: "xyz carrier", isEditable: false, isViolation: false, extraInfo: nil, hadExtraInfo: false)
    dailyLogDataArr.append(dailyLogObj)

    dailyLogObj = DailyLogInfo(logTitle: "Home Terminal", logValue: "Home Terminal address", isEditable: false, isViolation: false, extraInfo: nil, hadExtraInfo: false)
    dailyLogDataArr.append(dailyLogObj)

    dailyLogObj = DailyLogInfo(logTitle: "Main office", logValue: "Main office address", isEditable: false, isViolation: false, extraInfo: nil, hadExtraInfo: false)
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

