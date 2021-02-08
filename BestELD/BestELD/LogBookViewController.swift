//
//  LogBookViewController.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-19.
//

import UIKit

enum DutyStatus: String {
  case ONDUTY
  case OFFDUTY
  case SLEEPER
  case YARD
  case DRIVING
  case PERSONAL

  // MARK: Internal

  var dutyIndex: Int16 {
    switch self {
      case .ONDUTY:
        return 0
      case .OFFDUTY:
        return 1
      case .SLEEPER:
        return 2
      case .YARD:
        return 3
      case .DRIVING:
        return 4
      default:
        return 5
    }
  }

  var title: String {
    switch self {
      case .ONDUTY:
        return "On Duty"
      case .OFFDUTY:
        return "Off Duty"
      case .SLEEPER:
        return "Sleeper"
      case .YARD:
        return "Yard"
      case .DRIVING:
        return "Driving"
      default:
        return "Personal"
    }
  }

  var shortTitle: String {
    switch self {
      case .ONDUTY:
        return "ON"
      case .OFFDUTY:
        return "OFF"
      case .SLEEPER:
        return "SB"
      case .YARD:
        return "Y"
      case .DRIVING:
        return "D"
      default:
        return "P"
    }
  }
}

class LogBookViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  // MARK: Internal

  @IBOutlet var dutyStatusButton: UIButton!
  @IBOutlet var dayButton: UIButton!
  @IBOutlet var tableView: UITableView!
  @IBOutlet var graphImageView: UIImageView!
  @IBOutlet var dutyStatusTextField: UILabel!
  @IBOutlet var deviceTextField: UILabel!


  var userTripDataArray: [DayData] = []

  var currentStatus: DutyStatus = .OFFDUTY {
    didSet {
      dutyStatusTextField.text = currentStatus.title
    }
  }

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    eldList.count
  }

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    eldList[row]
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // navigationController?.navigationBar.isHidden = false
    let currentDriver = viewModel.driverName
    let currentDriver1 = viewModel.currentDay
    print("driver name is = \(currentDriver) and driving on \(currentDriver1)")

    GraphGenerator.shared.setupImageView(imageView: graphImageView)
    performLoggedIn()

    AuthenicationService.shared.fetchUserLogbookData(user: "")

    let utcTimeZone = TimeZone(abbreviation: "UTC")!
    let currentDate = Date().to(timeZone: TimeZone(abbreviation: UserPreferences.shared.currentTimeZone)!, from: utcTimeZone)
    let currentDateData = BLDAppUtility.generateDataSource(dateFrom: currentDate, numOfDays: 8)[0] //get todays data
    UserPreferences.shared.currentSelectedDayData = currentDateData
    if DataHandeler.shared.currentDayData == nil {
//        DataHandeler.shared.dutyStatusChanged(status: .OffDuty,description: "off duty from start of the day", timeToStart: Date())
    }
  }

  @IBAction func showMenuOptions(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let menuViewControllerObj = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
    let menuItems = BLDAppUtility.menuItems(loggedInUser: false)
    menuViewControllerObj.setup(menuItemArr: menuItems)
    menuViewControllerObj.didSelectMenuItem = { [weak self] _, itemIndex in
      switch itemIndex {
        case 0:
          print("")
        case 1:
          print("")
        case 2:
          print("")
        case 3:
          print("")
        case 4:
          print("")
        case 5:
          print("")
        case 6:
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let userSettingsController = storyboard.instantiateViewController(withIdentifier: "UserPreferencesViewController") as! UserPreferencesViewController
          self?.navigationController?.pushViewController(userSettingsController, animated: true)
        case 7:
          print("")
        case 8:
          print("")
        default:
          print("dd")
      }
    }
    menuViewControllerObj.modalPresentationStyle = .overCurrentContext
    present(menuViewControllerObj, animated: true, completion: nil)
  }

  @IBAction func scanEldDevices(_ sender: Any) {
    EldManager.sharedInstance()?.scan(forElds: { deviceIds, error in
      print("get some devices")
      if error != nil {
        self.showDefaultAlert(title: "Error", message: "Unable to find list of Elds \(error.debugDescription)", handler: nil)
        #warning("Debug Mode settings")
//        return
        // self.eldList = ["ELD1","ELD2","ELD3","ELD4","ELD5","ELD6","ELD7","ELD8","ELD9"]
      } else {
        self.eldList = deviceIds as! [String]
      }

      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let listController = storyboard.instantiateViewController(withIdentifier: "DeviceListViewController") as! DeviceListViewController
      listController.setup(bldDeviceList: self.eldList)
      listController.didSelectDevice = { [weak self] index in
        let currentDeviceId = self?.eldList[index]
        EldManager.sharedInstance()?.connect(toEld: { dataRecord, type, _ in
          if type == .ELD_DATA_RECORD {
            EldDeviceManager.shared.currentEldDataRecord = dataRecord as! EldDataRecord
          }
        }, .ELD_DATA_RECORD, { _, _ in
          print("connection status change ")
        }, currentDeviceId)
      }
      listController.modalPresentationStyle = .overCurrentContext
      self.present(listController, animated: true, completion: nil)
    })
  }

  @IBAction func dutyModeChanged(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let dutyStatusController = storyboard.instantiateViewController(withIdentifier: "DutyStatusViewController") as! DutyStatusViewController
    dutyStatusController.didChangedDutyStatus = { status, notes, _ in
      DataHandeler.shared.dutyStatusChanged(status: status, description: notes, timeToStart: Date())
      self.currentStatus = status
      if status == .ONDUTY {
        let drivingController = self.viewModel.drivingStoryboardInstance()
        drivingController.currentDriver = self.viewModel.currentDriver
        drivingController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(drivingController, animated: true)
      }
    }
    dutyStatusController.modalPresentationStyle = .overCurrentContext
    present(dutyStatusController, animated: true, completion: nil)
  }

  override func viewWillAppear(_ animated: Bool) {
    // tableView.reloadData()
  }

  override func viewDidAppear(_ animated: Bool) {
    guard let currentDateData = UserPreferences.shared.currentSelectedDayData else {
      return
    }
    let dayDataArray = generateData(for: currentDateData)
    GraphGenerator.shared.generatePath(dayDataArr: dayDataArray)
    userTripDataArray = dayDataArray
    tableView.reloadData()
  }

  func generateData(for dayDate: DateData) -> [DayData] {
    var dayDataArray: [DayData] = []
    let dayMetaDataObj = DataHandeler.shared.userDayMetaData(dayStart: dayDate.dateValue, driverDL: viewModel.currentDriver.dlNumber ?? testDriverDLNumber)
    if let dayDataArr = dayMetaDataObj?.dayData?.allObjects as? [DayData] {
      dayDataArray += dayDataArr
    }

    let dayMetaDataObj1 = DataHandeler.shared.userDayMetaData(dayStart: dayDate.dateValue.dayBefore, driverDL: viewModel.currentDriver.dlNumber ?? testDriverDLNumber)
    if let dayDataArr1 = dayMetaDataObj1?.dayData?.allObjects as? [DayData] {
      dayDataArray += dayDataArr1
    }

    let dayMetaDataObj2 = DataHandeler.shared.userDayMetaData(dayStart: dayDate.dateValue.dayAfter, driverDL: viewModel.currentDriver.dlNumber ?? testDriverDLNumber)
    if let dayDataArr2 = dayMetaDataObj2?.dayData?.allObjects as? [DayData] {
      dayDataArray += dayDataArr2
    }
    let sortedData = dayDataArray.sorted(by: { $0.startTime ?? Date() < $1.startTime ?? Date() })
    let currentDateText = BLDAppUtility.textForDate(date: dayDate.dateValue)
    var currentDayDataArray: [DayData] = []
    for data in sortedData {
      if let startTimeObj = data.startTime {
        let currentStartTime = BLDAppUtility.timezoneDate(from: startTimeObj)
        let startTimeText = BLDAppUtility.textForDate(date: currentStartTime)

        if let endTimeObj = data.endTime {
          let currentEndTime = BLDAppUtility.timezoneDate(from: endTimeObj)
          let endTimeText = BLDAppUtility.textForDate(date: currentEndTime)
          if ((startTimeText == currentDateText) || (endTimeText == currentDateText)) {
            currentDayDataArray.append(data)
          }
        }
      }
    }

    return currentDayDataArray
  }

  func performLoggedIn() {
    if viewModel.shouldSetDefaultOffDuty {
      // self.viewModel?.dutyStatusChanged(status: .OffDuty)
    }
  }

  func setViewModel(dataViewModel: LogBookViewModel) {
    viewModel = dataViewModel
  }

  @IBAction func addEditEventClicked(_ sender: Any) {}

  @IBAction func dateDidSelected(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let dayController = storyboard.instantiateViewController(withIdentifier: "DaysViewController") as! DaysViewController
    dayController.loadDays(dateFrom: Date(), numOfDays: 8)
    dayController.didSelectDate = { _ in
      guard let currentDateData = UserPreferences.shared.currentSelectedDayData else {
        return
      }
      DispatchQueue.main.async {
        self.dayButton.setTitle(currentDateData.displayDate, for: .normal)
        let dayDataArray = self.generateData(for: currentDateData)
        GraphGenerator.shared.generatePath(dayDataArr: dayDataArray)
        self.userTripDataArray = dayDataArray
        self.tableView.reloadData()
      }
    }
    dayController.modalPresentationStyle = .overCurrentContext
    present(dayController, animated: true, completion: nil)
    dayController.setTop(yOrigin: dayButton.frame.origin.y + dayButton.frame.height)
  }

  @IBAction func violenceOnlyModeClicked(_ sender: Any) {}

  @IBAction func dayProfileClicked(_ sender: Any) {}

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
    print("duty status")

    showAlertToUser(
      status: currentStatus,
      continueAction: (title: nil, handler: { description, date in
        DataHandeler.shared.dutyStatusChanged(status: status, description: description, timeToStart: date)
        self.currentStatus = status
        if status == .ONDUTY {
          let drivingController = self.viewModel.drivingStoryboardInstance()
          drivingController.currentDriver = self.viewModel.currentDriver
          drivingController.modalPresentationStyle = .fullScreen
          self.navigationController?.pushViewController(drivingController, animated: true)
          // self.present(drivingController, animated: true) {
          print("present")
        }
      }),
      cancelAction: (title: nil, handler: { _, _ in
      }))
  }

  @IBAction func dutyStatusButtonClicked(_ sender: Any) {}

  // MARK: Private

  private var viewModel: LogBookViewModel! // TODO: fix it

  private var eldList: [String] = []

  private func addButtonToNavationBar() {
//    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Connect Eld", style: .done, target: self, action: #selector(connectEld))
//    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Driving Mode", style: .done, target: self, action: #selector(drivingMode))
  }
}

extension LogBookViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return userTripDataArray.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let tableCell = tableView.dequeueReusableCell(withIdentifier: "dayDataTableCellIdentifier") as! DayDataTableViewCell

    let currentDayData = userTripDataArray[indexPath.row]
    let status = DutyStatus(rawValue: currentDayData.dutyStatus ?? "OFFDUTY")
    let sortTitleText = shortTitle(status: status ?? .OFFDUTY)
    tableCell.dutyStatusLabel.text = sortTitleText
    tableCell.dutyStatusLabel.backgroundColor = bgColor(status: status ?? .OFFDUTY)
    tableCell.descriptionLabel.text = currentDayData.rideDescription
    tableCell.locationLabel.text = currentDayData.startLocation
    let eventDate = currentDayData.startTime
    let eventDateEnd = currentDayData.endTime
    guard let dutyTime = eventDate else {
      tableCell.timeLabel.text = "Invalid date"
      return tableCell
    }
    let currentDateString = BLDAppUtility.timeString(from: dutyTime)
    var endTime = ""
    if eventDateEnd != nil {
      endTime = BLDAppUtility.timeString(from: eventDateEnd!)
    }

    tableCell.timeLabel.text = "\(currentDateString) - \(endTime)"
    return tableCell
  }

  func shortTitle(status: DutyStatus) -> String {
    switch status {
      case .ONDUTY:
        return "ON"
      case .OFFDUTY:
        return "OFF"
      case .SLEEPER:
        return "SB"
      case .YARD:
        return "Y"
      case .DRIVING:
        return "D"
      default:
        return "P"
    }
  }

  private func bgColor(status: DutyStatus) -> UIColor {
    switch status {
      case .DRIVING:
        return .magenta
      case .OFFDUTY,
           .PERSONAL:
        return .green
      case .ONDUTY,
           .YARD:
        return .red
      case .SLEEPER:
        return .orange
    }
  }
}
