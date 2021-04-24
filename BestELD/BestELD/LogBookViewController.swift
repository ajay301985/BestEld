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

class LogBookViewController: UIViewController {
  // MARK: Internal

  @IBOutlet var dutyStatusButton: UIButton!
  @IBOutlet var dayButton: UIButton!
  @IBOutlet var tableView: UITableView!
  @IBOutlet var graphImageView: UIImageView!
  @IBOutlet var dutyStatusTextField: UILabel!
  @IBOutlet var deviceTextField: UILabel!

  @IBOutlet var onDutyLabel: UILabel!
  @IBOutlet var offDutyLabel: UILabel!
  @IBOutlet var drivingLabel: UILabel!
  @IBOutlet var sleeperLabel: UILabel!



  var selectedMenuItemIndex = 0
  var userTripDataArray: [DayData] = []

  var currentStatus: DutyStatus = .OFFDUTY {
    didSet {
      dutyStatusTextField.text = currentStatus.title
    }
  }

  fileprivate func registerCoreDataNotifications() {
    //    AuthenicationService.shared.fetchUserLogbookData(user: "")

    NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(contextWillSave(_:)), name: Notification.Name.NSManagedObjectContextWillSave, object: nil)
    //NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(_:)), name: Notification.Name.NSManagedObjectContextDidSave, object: nil)

    NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(_:)), name: NSNotification.Name(rawValue: "DatabaseDidChanged"), object: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    currentStatus = .OFFDUTY
    GraphGenerator.shared.setupImageView(imageView: graphImageView)
    performLoggedIn()

    registerCoreDataNotifications()

    let currentDateData = BLDAppUtility.generateDataSource(dateFrom: Date(), numOfDays: 8)[0] //get todays data
    UserPreferences.shared.currentSelectedDayData = currentDateData

    let dayMetaDataObj = DataHandler.shared.dayMetaData(dayStart: BLDAppUtility.startOfTheDayTimeInterval(for: Date()), driverDL: DataHandler.shared.currentDriver.dlNumber ?? "")
    if dayMetaDataObj == nil {
      if let lastDayDataObj = DataHandler.shared.getLastTrackedEvent(driverDLNumber: DataHandler.shared.currentDriver.dlNumber ?? "", inDate: Date()) {
        DataHandler.shared.currentDayData = lastDayDataObj
      }else {
        DataHandler.shared.dutyStatusChanged(status: .OFFDUTY,description: "off duty from start of the day", timeToStart: Date())
      }
    }else {
      if let dayDataArr = dayMetaDataObj?.dayData?.allObjects as? [DayData], dayDataArr.count > 0 {
        let sortedData = dayDataArr.sorted(by: { $0.startTime ?? Date() < $1.startTime ?? Date() })
        let latestDayData = sortedData.last
        DataHandler.shared.currentDayData = latestDayData
      } else {
        if let lastDayDataObj = DataHandler.shared.getLastTrackedEvent(driverDLNumber: DataHandler.shared.currentDriver.dlNumber ?? "", inDate: Date()) {
          DataHandler.shared.currentDayData = lastDayDataObj
        }else {
          DataHandler.shared.dutyStatusChanged(status: .OFFDUTY,description: "off duty from start of the day", timeToStart: Date())
          let dayMetaDataObj = DataHandler.shared.dayMetaData(dayStart: BLDAppUtility.startOfTheDayTimeInterval(for: Date()), driverDL: DataHandler.shared.currentDriver.dlNumber ?? "")
          if let dayDataArr = dayMetaDataObj?.dayData?.allObjects as? [DayData], dayDataArr.count > 0 {
            let sortedData = dayDataArr.sorted(by: { $0.startTime ?? Date() < $1.startTime ?? Date() })
            let latestDayData = sortedData.last
            DataHandler.shared.currentDayData = latestDayData
          }
        }
      }
    }
  }

  @objc func contextObjectsDidChange(_ notification: Notification) {
    print(notification)
  }
  @objc func contextWillSave(_ notification: Notification) {
    print(notification)
  }
  @objc func contextDidSave(_ notification: Notification) {
    print(notification)
    guard let currentDateData = UserPreferences.shared.currentSelectedDayData else {
      return
    }

    self.reloadLogBookData(currentDateData)
  }

  @IBAction func showMenuOptions(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let menuViewControllerObj = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
    let menuItems = BLDAppUtility.menuItems(loggedInUser: false)
    menuViewControllerObj.setup(menuItemArr: menuItems, selectedIndex: selectedMenuItemIndex)
    menuViewControllerObj.didSelectMenuItem = { [weak self] _, itemIndex in
      self?.selectedMenuItemIndex = itemIndex
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
    if let connectedDevice = selectedEldDevice {
      let alertController = UIAlertController(title: "Connected", message: "You are connected \(connectedDevice.deviceId ?? "")", preferredStyle: UIAlertController.Style.alert)
      alertController.addAction(UIAlertAction(title: "Disconnect", style: .cancel, handler: {_ in
        let isDisconnected = EldManager.sharedInstance()?.disconnectEld()
        if (true == isDisconnected) {
          self.deviceTextField.text = ""
          self.dutyStatusButton.isSelected.toggle()
        }
      }))
      DispatchQueue.main.async { [weak self] in
        self?.present(alertController, animated: true, completion: nil)
      }
      return
    }


    showAlertView()
    EldManager.sharedInstance()?.scan(forElds: { deviceIds, error in
      DispatchQueue.main.async {
        self.view.viewWithTag(997)?.removeFromSuperview()
      }

      if DEBUGMODE == true {
        AuthenicationService.shared.getEldTrukMapping(eldVinId: "1FTLR4FEXBPA98994") {[weak self] result in
          guard let self = self else { return }

          switch result {
            case .success(let eldObj):
              DataHandler.shared.currentEldData = eldObj
              DispatchQueue.main.async {
                self.updateViewForEld(inEld: eldObj)
              }
            case .failure(let error):
              print("Error in fetching \(error.localizedDescription)")
          }
        }
        return
      }

      if (deviceIds?.count ?? 0 > 0)
      {
        self.eldList = deviceIds as? [EldScanObject] ?? []
      }
      else {
        if (error != nil) {
          self.showDefaultAlert(title: "Error", message: "Unable to find list of Elds \(error.debugDescription)", handler: nil)
          return
        }else {
          self.showDefaultAlert(title: "Alert", message: "No Device found", handler: nil)
          return
        }
      }

      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let listController = storyboard.instantiateViewController(withIdentifier: "DeviceListViewController") as! DeviceListViewController
      listController.setup(bldDeviceList: self.eldList)
      listController.didSelectDevice = { [weak self] index in
        let currentDeviceId = self?.eldList[index].deviceId
        EldManager.sharedInstance()?.connect(toEld: { dataRecord, type, _ in
          self?.dutyStatusButton.isSelected.toggle()
          self?.deviceTextField.text = currentDeviceId
          self?.selectedEldDevice = self?.eldList[index]
          if type == .ELD_DATA_RECORD {
            EldDeviceManager.shared.currentEldDataRecord = dataRecord as? EldDataRecord
            if (DataHandler.shared.currentEldData == nil) { //fetch current Eld
              AuthenicationService.shared.getEldTrukMapping(eldVinId: EldDeviceManager.shared.currentEldDataRecord?.vin ?? "1FTLR4FEXBPA98994") {[weak self] result in
                guard let self = self else { return }

                switch result {
                  case .success(let eldObj):
                    DataHandler.shared.currentEldData = eldObj
                    DispatchQueue.main.async {
                      self.updateViewForEld(inEld: eldObj)
                    }
                  case .failure(let error):
                    print("Error in fetching \(error.localizedDescription)")
                }
              }
            }

            if (self?.currentStatus != .DRIVING) {
              let dataRecord = EldDeviceManager.shared.currentEldDataRecord
              if dataRecord?.speed ?? 100 > DRIVING_MODE_SPEED {
                self?.launchDrivingMode()
              }
            }
          }
        }, .ELD_DATA_RECORD, { _, _ in
          print("connection status change ")
        }, currentDeviceId)
      }
      listController.modalPresentationStyle = .overCurrentContext
      self.present(listController, animated: true, completion: nil)
    })
  }

  private func updateViewForEld(inEld: Eld?) {
    deviceTextField.text = inEld?.truckNumber ?? "Invalid truck data"
  }

  private func showAlertView() {
    let parentView = UIView(frame: view.frame)
    parentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    parentView.tag = 997
    parentView.alpha = 1.0
    let childView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
    childView.backgroundColor = .white
    let headerLabel = UILabel(frame: CGRect(x: 20, y: 85, width: 280, height: 20))
    headerLabel.text = "Searching for the devices"
    headerLabel.font = UIFont.boldSystemFont(ofSize: 18)
    headerLabel.baselineAdjustment = .alignCenters
    headerLabel.textAlignment = .center
    childView.addSubview(headerLabel)
    let descriptionLabel = UILabel(frame: CGRect(x: 20, y: 115, width: 280, height: 20))
    descriptionLabel.baselineAdjustment = .alignCenters
    descriptionLabel.text = "Please wait ...."
    descriptionLabel.textColor = .lightGray
    descriptionLabel.textAlignment = .center
    descriptionLabel.font = UIFont.systemFont(ofSize: 14)
    childView.addSubview(descriptionLabel)
    parentView.addSubview(childView)
    childView.layer.cornerRadius = 20
    childView.center = parentView.center
    view.addSubview(parentView)
  }

  private func launchDrivingMode() {
    currentStatus = .DRIVING
    DataHandler.shared.dutyStatusChanged(status: currentStatus, description: "Driving", timeToStart: Date())
    let drivingController = self.viewModel.drivingStoryboardInstance()
    drivingController.currentDriver = self.viewModel.currentDriver
    drivingController.modalPresentationStyle = .fullScreen
    self.navigationController?.pushViewController(drivingController, animated: true)
  }

  @IBAction func dutyModeChanged(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let dutyStatusController = storyboard.instantiateViewController(withIdentifier: "DutyStatusViewController") as! DutyStatusViewController
    dutyStatusController.didChangedDutyStatus = { status, notes, _ in
      DispatchQueue.main.async {
        DataHandler.shared.dutyStatusChanged(status: status, description: notes, timeToStart: Date())
        self.currentStatus = status
      }
/*        if status == .ONDUTY {
          let drivingController = self.viewModel.drivingStoryboardInstance()
          drivingController.currentDriver = self.viewModel.currentDriver
          drivingController.modalPresentationStyle = .fullScreen
          self.navigationController?.pushViewController(drivingController, animated: true)
        }else {
          guard let currentDateData = UserPreferences.shared.currentSelectedDayData else {
            return
          }
*/
//          self.reloadLogBookData(currentDateData)
//      }
//      }
    }
    dutyStatusController.modalPresentationStyle = .overCurrentContext
    present(dutyStatusController, animated: true, completion: nil)
  }

  fileprivate func reloadLogBookData(_ currentDateData: DateData) {
    let dayDataArray = generateData(for: currentDateData)
    GraphGenerator.shared.generatePath(dayDataArr: dayDataArray)
    userTripDataArray = dayDataArray
    tableView.reloadData()
  }


  override func viewDidAppear(_ animated: Bool) {
    guard let currentDateData = UserPreferences.shared.currentSelectedDayData else {
      return
    }
    reloadLogBookData(currentDateData)
    currentStatus = DutyStatus(rawValue: DataHandler.shared.currentDayData.dutyStatus ?? "OFFDUTY") ?? .OFFDUTY
  }

  func generateData(for dayDate: DateData) -> [DayData] {
    var dayDataArray: [DayData] = []


    //let dayTimeInterval = TimeInterval(60 * 60 * 24)
    let utcTimeIntervalNextDay = (dayDate.dateUTC - oneDayTimeInterval)

    let utdDateObj1 = Date(timeIntervalSince1970: dayDate.dateUTC)
    print("UTC START  \(utdDateObj1)")
    let utdDateObj2 = Date(timeIntervalSince1970: dayDate.dateCurrent)
    print("DATE CURRENT TIMEZONE START \(utdDateObj2)")
    let utdDateObj3 = Date(timeIntervalSince1970: utcTimeIntervalNextDay)
    print("UTC END \(utdDateObj3)")
    let dayMetaDataObj = DataHandler.shared.dayMetaData(dayStart: dayDate.dateUTC, driverDL: viewModel.currentDriver.dlNumber ?? TEST_DRIVER_DL_NUMBER)
    if let dayDataArr = dayMetaDataObj?.dayData?.allObjects as? [DayData] {
      dayDataArray += dayDataArr
    }

    let dayMetaDataObj1 = DataHandler.shared.dayMetaData(dayStart: utcTimeIntervalNextDay, driverDL: viewModel.currentDriver.dlNumber ?? TEST_DRIVER_DL_NUMBER)
    if let dayDataArr1 = dayMetaDataObj1?.dayData?.allObjects as? [DayData] {
      dayDataArray += dayDataArr1
    }

/*    let dayMetaDataObj2 = DataHandeler.shared.dayMetaData(dayStart: dayDate.dateUTC, driverDL: viewModel.currentDriver.dlNumber ?? testDriverDLNumber)
    if let dayDataArr2 = dayMetaDataObj2?.dayData?.allObjects as? [DayData] {
      dayDataArray += dayDataArr2
    } */
    let sortedData = dayDataArray.sorted(by: { $0.startTime ?? Date() < $1.startTime ?? Date() })
//    let currentDateText = BLDAppUtility.textForDate(date: dayDate.dateValue)
    var currentDayDataArray: [DayData] = []
    let currentTimezoneTimeIntervalStart = dayDate.dateCurrent//Calendar.current.date(byAdding: .hour, value: 24, to: dayDate.dateValue) ?? Date()
    let currentTimezoneTimeIntervalEnd = (dayDate.dateCurrent + oneDayTimeInterval)
    let utdDateObj4 = Date(timeIntervalSince1970: currentTimezoneTimeIntervalEnd)
    print("Current Time END \(utdDateObj4)")

    var onDutyInt = 0.0
    var offDutyInt = 0.0
    var sleeperInt = 0.0
    var drivingInt = 0.0
    for data in sortedData {
      if let startTimeObj = data.startTime, let endTimeObj = data.endTime {
        print("Event start  \(startTimeObj)")
        print("Event end  \(endTimeObj)")
        let startTimeTimeInterval = startTimeObj.timeIntervalSince1970
        let endTimeTimeInterval = endTimeObj.timeIntervalSince1970
        if (startTimeTimeInterval >= currentTimezoneTimeIntervalStart && startTimeTimeInterval < currentTimezoneTimeIntervalEnd) || (endTimeTimeInterval >= currentTimezoneTimeIntervalStart && endTimeTimeInterval < currentTimezoneTimeIntervalEnd) {
          let status = DutyStatus(rawValue: data.dutyStatus ?? "OFFDUTY")
          let timeDeff = endTimeObj.timeIntervalSince(startTimeObj)
          switch status {
            case .DRIVING:
              drivingInt += timeDeff
            case .ONDUTY, .YARD:
              onDutyInt += timeDeff
            case .OFFDUTY, .PERSONAL:
              offDutyInt += timeDeff
            case .SLEEPER:
              sleeperInt += timeDeff
            default:
              print("te")
          }
          currentDayDataArray.append(data)
        }

/*        let currentStartTime = BLDAppUtility.timezoneDate(from: startTimeObj)
        let startTimeText = BLDAppUtility.textForDate(date: currentStartTime)
          let currentEndTime = BLDAppUtility.timezoneDate(from: endTimeObj)
          let endTimeText = BLDAppUtility.textForDate(date: currentEndTime)
          if ((startTimeText == currentDateText) || (endTimeText == currentDateText)) {
            currentDayDataArray.append(data)
          } */
      } else {
        print("Invalid end time")
      }
    }

    onDutyLabel.text = "\(onDutyInt.stringFromTimeInterval())"
    offDutyLabel.text = "\(offDutyInt.stringFromTimeInterval())"
    sleeperLabel.text = "\(sleeperInt.stringFromTimeInterval())"
    drivingLabel.text = "\(drivingInt.stringFromTimeInterval())"

    return currentDayDataArray
  }

  func performLoggedIn() {
    if viewModel.shouldSetDefaultOffDuty {
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
        self.reloadLogBookData(currentDateData)
      }
    }
    dayController.modalPresentationStyle = .overCurrentContext
    present(dayController, animated: true, completion: nil)
    dayController.setTop(yOrigin: dayButton.frame.origin.y + dayButton.frame.height)
  }

  @IBAction func violenceOnlyModeClicked(_ sender: Any) {}

  @IBAction func dayProfileClicked(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let dayInfoController = storyboard.instantiateViewController(withIdentifier: "DailyInfoViewController") as! DailyInfoViewController
    dayInfoController.modalPresentationStyle = .overCurrentContext
    present(dayInfoController, animated: true, completion: nil)
  }

  @IBAction func dutyStatusButtonClicked(_ sender: Any) {}

  // MARK: Private

  private var viewModel: LogBookViewModel! // TODO: fix it

  
  private var eldList: [EldScanObject] = []
  private var selectedEldDevice: EldScanObject?

  private func addButtonToNavationBar() {
//    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Connect Eld", style: .done, target: self, action: #selector(connectEld))
//    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Driving Mode", style: .done, target: self, action: #selector(drivingMode))
  }


  private func checkELDConnection() {
    /*
     EldManager.sharedInstance()?.registerBleStateCallback( { error in
     if let errorObj = error as NSError? {
     switch errorObj.code {
     case 1003:
     self.showDefaultAlert(title: nil, message: "Device not connected", handler: nil)
     case 1005:
     self.showDefaultAlert(title: nil, message: "Device not supported", handler: nil)
     case 1006:
     self.showDefaultAlert(title: nil, message: "Device not authorized", handler: nil)
     case 1008:
     self.showDefaultAlert(title: nil, message: "Device powered off", handler: nil)
     case 1009:
     self.showDefaultAlert(title: nil, message: "Device powered on", handler: nil)
     default:
     print("test")
     }
     }
     }) */

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
    tableCell.descriptionLabel.text = currentDayData.startLocation
    tableCell.locationLabel.text = currentDayData.rideDescription
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

    if DEBUGMODE {
      tableCell.timeLabel.text = "\(currentDateString) - \(endTime)"
    } else {
      tableCell.timeLabel.text = currentDateString
    }


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
        return UIColor(rgb: 0xf34b4b, alphaVal: 1.0) //#F34B4B
      case .OFFDUTY,
           .PERSONAL:
        return UIColor(rgb: 0x93e868, alphaVal: 1.0)
      case .ONDUTY,
           .YARD:
        return UIColor(rgb: 0xff0000, alphaVal: 1.0)

      case .SLEEPER:
        return UIColor(rgb: 0xfdac5b, alphaVal: 1.0)
    }
  }
}


extension TimeInterval{

  func stringFromTimeInterval() -> String {

    let time = NSInteger(self)

    let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
    let seconds = time % 60
    let minutes = (time / 60) % 60
    let hours = (time / 3600)

    return String(format: "%0.2d:%0.2d",hours,minutes)

  }
}
