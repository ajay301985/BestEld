//
//  DeviceListViewController.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-30.
//

import UIKit

class DeviceListViewController: UIViewController {
  // MARK: Internal

  @IBOutlet var deviceTitle: UILabel!
  @IBOutlet var tableview: UITableView!
  @IBOutlet var deviceDescription: UILabel!

  var didSelectDevice: ((_ index: Int) -> ())!

  var selectedEldIndex = 0

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  func setup(bldDeviceList: [String]) {
    deviceList = bldDeviceList
  }

  @IBAction func didClickCloseButton(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func didClickedConnectButton(_ sender: Any) {}

  @IBAction func connectClicked(_ sender: Any) {
    didSelectDevice(selectedEldIndex)
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

  // MARK: Private

  private var deviceList: [String] = []
}

extension DeviceListViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    deviceList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var tableCell = tableview.dequeueReusableCell(withIdentifier: "devicelistidentifier")
    if tableCell == nil {
      tableCell = UITableViewCell(style: .value2, reuseIdentifier: "devicelistidentifier")
    }

    tableCell?.textLabel?.text = deviceList[indexPath.row]
    tableCell?.textLabel?.textAlignment = .left
    tableCell?.detailTextLabel?.text = "Connected"
    tableCell?.detailTextLabel?.textAlignment = .right
    return tableCell ?? UITableViewCell()
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedEldIndex = indexPath.row
  }
}
