//
//  DaysViewController.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-30.
//

import UIKit

struct DateData {
  var displayDate: String
  var dateCurrent: TimeInterval
  var dateUTC: TimeInterval
}

class DaysViewController: UIViewController {

  @IBOutlet weak var heightConstraint: NSLayoutConstraint!
  @IBOutlet weak var tableView: UITableView!

  private var numberOfDays = 7

  var dayArray: [DateData] = []

  var didSelectDate: ((_ index: Int) -> ())!
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
  func setTop(yOrigin: CGFloat) {
    heightConstraint.constant = yOrigin
  }

  func loadDays(dateFrom: Date, numOfDays: Int = 8) {
    numberOfDays = numOfDays
    dayArray = BLDAppUtility.generateDataSource(dateFrom: dateFrom, numOfDays: numOfDays)
  }

  @IBAction func closeButtonClicked(_ sender: Any) {
    dismiss(animated: true, completion: nil)
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

extension DaysViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dayArray.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var tableCell = tableView.dequeueReusableCell(withIdentifier: "daylistidentifier")
    if tableCell == nil {
      tableCell = UITableViewCell(style: .value1, reuseIdentifier: "daylistidentifier")
    }

    tableCell?.textLabel?.text = dayArray[indexPath.row].displayDate
    tableCell?.textLabel?.textAlignment = .left
//    tableCell?.detailTextLabel?.text = "Connected"
//    tableCell?.detailTextLabel?.textAlignment = .right
    return tableCell ?? UITableViewCell()
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let dayDataObj = dayArray[indexPath.row]
    UserPreferences.shared.currentSelectedDayData = dayDataObj
    self.didSelectDate(indexPath.row)
    dismiss(animated: true, completion: nil)
  }


}
