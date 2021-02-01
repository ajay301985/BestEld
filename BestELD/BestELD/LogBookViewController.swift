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

  var title: String {
    switch self {
      case .OnDuty:
        return "On Duty"
      case .OffDuty:
        return "Off Duty"
      case .Sleeper:
        return "Sleeper"
      case .Yard:
        return "Yard"
      case .Driving:
        return "Driving"
      default:
        return "Personal"
    }
  }
}

class LogBookViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    eldList.count
  }

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    eldList[row]
  }

  @IBOutlet weak var dutyStatusButton: UIButton!
  @IBOutlet weak var dayButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var graphImageView: UIImageView!
  private var viewModel: LogBookViewModel!  //TODO: fix it

  private var eldList: Array<String> = []
  var currentStatus: DutyStatus = .OffDuty {
    didSet {
      dutyStatusButton.setTitle(currentStatus.title, for: .normal)
    }
  }

    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationController?.navigationBar.isHidden = false
        let currentDriver = viewModel.driverName
        let currentDriver1 = viewModel.currentDay
        print("driver name is = \(currentDriver) and driving on \(currentDriver1)")

        GraphGenerator.shared.setupImageView(imageView: graphImageView)
        performLoggedIn()

//      addButtonToNavationBar()
      if(DataHandeler.shared.currentDayData == nil) {
        DataHandeler.shared.dutyStatusChanged(status: .OffDuty,description: "off duty from start of the day", timeToStart: Date())
      }
    }

  private func addButtonToNavationBar()
  {
//    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Connect Eld", style: .done, target: self, action: #selector(connectEld))
//    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Driving Mode", style: .done, target: self, action: #selector(drivingMode))
  }


  @IBAction func showMenuOptions(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let menuViewControllerObj =  storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
    let menuItems = BLDAppUtility.menuItems(loggedInUser: false)
    menuViewControllerObj.setup(menuItemArr: menuItems)
    menuViewControllerObj.didSelectMenuItem = { [weak self] selectMenuItem, itemIndex in
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
          let userSettingsController =  storyboard.instantiateViewController(withIdentifier: "UserPreferencesViewController") as! UserPreferencesViewController
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
    EldManager.sharedInstance()?.scan(forElds: { (deviceIds, error) in
      print("get some devices")
      if (error != nil) {
        self.showDefaultAlert(title: "Error", message: "Unable to find list of Elds \(error.debugDescription)", handler: nil)
        #warning("Debug Mode settings")
//        return
       // self.eldList = ["ELD1","ELD2","ELD3","ELD4","ELD5","ELD6","ELD7","ELD8","ELD9"]
      } else {
        self.eldList = deviceIds as! Array<String>
      }

      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let listController =  storyboard.instantiateViewController(withIdentifier: "DeviceListViewController") as! DeviceListViewController
      listController.setup(bldDeviceList: self.eldList)
      listController.didSelectDevice = {[weak self] index in
        let currentDeviceId = self?.eldList[index]
        EldManager.sharedInstance()?.connect(toEld: { (dataRecord, type, error) in
          if (type == .ELD_DATA_RECORD) {
            EldDeviceManager.shared.currentEldDataRecord = dataRecord as! EldDataRecord
          }
        }, .ELD_DATA_RECORD, { (connectionState, error) in
          print("connection status change ")
        }, currentDeviceId)
      }
      listController.modalPresentationStyle = .overCurrentContext
      self.present(listController, animated: true, completion: nil)
    })
  }

  @IBAction func dutyModeChanged(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let dutyStatusController =  storyboard.instantiateViewController(withIdentifier: "DutyStatusViewController") as! DutyStatusViewController
    dutyStatusController.modalPresentationStyle = .overCurrentContext
    present(dutyStatusController, animated: true, completion: nil)
  }

  override func viewWillAppear(_ animated: Bool) {
    tableView.reloadData()
  }

  func performLoggedIn() {
    if (viewModel.shouldSetDefaultOffDuty) {
     // self.viewModel?.dutyStatusChanged(status: .OffDuty)
    }
  }

  func setViewModel(dataViewModel: LogBookViewModel) {
    viewModel = dataViewModel
  }

  @IBAction func addEditEventClicked(_ sender: Any) {
  }
  @IBAction func dateDidSelected(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let dayController =  storyboard.instantiateViewController(withIdentifier: "DaysViewController") as! DaysViewController
    dayController.loadDays(dateFrom: Date(), numOfDays: 8)
    dayController.didSelectDate = { itemIndex in
      //self?.loggedInAsATestUser()
    }
    dayController.modalPresentationStyle = .overCurrentContext
    present(dayController, animated: true, completion: nil)
    dayController.setTop(yOrigin: (dayButton.frame.origin.y + dayButton.frame.height))
  }

  @IBAction func violenceOnlyModeClicked(_ sender: Any) {
  }

  @IBAction func dayProfileClicked(_ sender: Any) {
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
        if status == .OnDuty {
          let drivingController = self.viewModel.drivingStoryboardInstance()
          drivingController.currentDriver = self.viewModel.currentDriver
          drivingController.modalPresentationStyle = .fullScreen
          self.navigationController?.pushViewController(drivingController, animated: true)
          //self.present(drivingController, animated: true) {
            print("present")
          }
      }),
      cancelAction: (title: nil, handler: { description,date in
      }))

  }

  @IBAction func dutyStatusButtonClicked(_ sender: Any) {
  }

}


extension LogBookViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let driverMetaData = DataHandeler.shared.dayMetaData(dayStart: Date(), driverDL: viewModel.currentDriver.dlNumber ?? "xyz12345")
    return driverMetaData?.dayData?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let driverMetaData = DataHandeler.shared.dayMetaData(dayStart: Date(), driverDL: viewModel.currentDriver.dlNumber ?? "xyz12345")
    let dayDataArr = driverMetaData?.dayData?.allObjects as! [DayData]
    let sortedData = dayDataArr.sorted(by: { $0.startTimeStamp ?? Date() < $1.startTimeStamp ?? Date()})

    let tableCell = tableView.dequeueReusableCell(withIdentifier: "dayDataTableCellIdentifier") as! DayDataTableViewCell
    
    let currentDayData = sortedData[indexPath.row]
    tableCell.dutyStatusLabel.text = DutyStatus(rawValue: currentDayData.dutyStatus)?.title
    tableCell.descriptionLabel.text = currentDayData.rideDescription
    tableCell.locationLabel.text = currentDayData.userLocation
    let eventDate = currentDayData.startTimeStamp
    let eventDateEnd = currentDayData.endTimeStamp
    guard let dutyTime = eventDate else {
      tableCell.timeLabel.text = "Invalid date"
      return tableCell
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    let currentDateString = dateFormatter.string(from: dutyTime)
    var endTime = ""
    if eventDateEnd != nil {
      endTime = dateFormatter.string(from: eventDateEnd!)
    }

    tableCell.timeLabel.text = "\(currentDateString) - \(endTime)"
    return tableCell
  }


}
