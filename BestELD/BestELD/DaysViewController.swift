//
//  DaysViewController.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-30.
//

import UIKit

class DaysViewController: UIViewController {

  @IBOutlet weak var heightConstraint: NSLayoutConstraint!
  @IBOutlet weak var tableView: UITableView!

  private var numberOfDays = 7

  var dayArray: [String] = []

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
    dayArray = generateDataSource(dateFrom: dateFrom, numOfDays: numOfDays)
  }

  @IBAction func closeButtonClicked(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }

  private func generateDataSource(dateFrom: Date, numOfDays: Int = 8) -> [String] {

    var currentDate = dateFrom
    var days:  [String] = []
    for _ in 0..<numberOfDays {
      //if currentDate
      let dateString = BLDAppUtility.textForDate(date: currentDate)
      days.insert(dateString, at: days.count)
      currentDate = currentDate.dayAfter
      // render the tick mark each minute (60 times)
    }

    return days
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

    tableCell?.textLabel?.text = dayArray[indexPath.row]
    tableCell?.textLabel?.textAlignment = .left
//    tableCell?.detailTextLabel?.text = "Connected"
//    tableCell?.detailTextLabel?.textAlignment = .right
    return tableCell ?? UITableViewCell()
  }


}
