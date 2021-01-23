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

class LogBookViewController: UIViewController {

  @IBOutlet weak var dutyStatusStackView: UIStackView!
  @IBOutlet weak var dutyStatusButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  private var viewModel: LogBookViewModel!  //TODO: fix it

  var currentStatus: DutyStatus = .OffDuty {
    didSet {
      dutyStatusButton.setTitle(currentStatus.title, for: .normal)
    }
  }

    override func viewDidLoad() {
        super.viewDidLoad()
        let currentDriver = viewModel.driverName
        let currentDriver1 = viewModel.currentDay
        print("driver name is = \(currentDriver) and driving on \(currentDriver1)")

        dutyStatusStackView.isHidden = true
        performLoggedIn()

      if(DataHandeler.shared.currentDayData == nil) {
        DataHandeler.shared.dutyStatusChanged(status: .OffDuty,description: "off duty from start of the day", timeToStart: Date())
      }
       // tableView.register(DayDataTableViewCell.self, forCellReuseIdentifier: "dayDataTableCellIdentifier")
        // Do any additional setup after loading the view.
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
    dutyStatusStackView.isHidden.toggle()
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
