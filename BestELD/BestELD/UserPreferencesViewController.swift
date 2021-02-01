//
//  UserPreferencesViewController.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-16.
//

import UIKit
import L10n_swift

class UserPreferencesViewController: UIViewController {

  let tableViewData = [
    ["Home terminal zone","Cycle type","Cargo type","Restart hours","Rest break"],
    ["Home terminal zone","Cycle type","Cargo type","Restart hours","Rest break"],
    ["Langauge","Date","Distance","Temprature"],
    ["Compliance References"],
    ["About"],
  ]

  let tableViewSectionHeader = [
    "PRIMARY",
    "SECONDRY",
    "PREFERENCES",
    "Compliance References",
    "About",
  ]

  @IBOutlet weak var tableView: UITableView!
  var hiddenSections = Set<Int>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
  @IBAction func changeLanguage(_ sender: Any) {
    L10n.shared.language = "hi"
  }

  @IBAction func changeLanguageToPunjabi(_ sender: Any) {
    L10n.shared.language = "pa"
  }
  /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = false
  }

  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = true
  }
}

extension UserPreferencesViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // 1
    if self.hiddenSections.contains(section) {
      return 0
    }

    // 2
    return self.tableViewData[section].count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    cell.textLabel?.text = self.tableViewData[indexPath.section][indexPath.row]

    return cell
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    self.tableViewData.count
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    // 1
    let sectionButton = UIButton()

    // 2
    sectionButton.setTitle(String(tableViewSectionHeader[section]),
                           for: .normal)

    // 3
    sectionButton.backgroundColor = .systemBlue

    // 4
    sectionButton.tag = section

    // 5
    sectionButton.addTarget(self,
                            action: #selector(self.hideSection(sender:)),
                            for: .touchUpInside)

    return sectionButton
  }

  @objc
  private func hideSection(sender: UIButton) {
    let section = sender.tag

    func indexPathsForSection() -> [IndexPath] {
      var indexPaths = [IndexPath]()

      for row in 0..<self.tableViewData[section].count {
        indexPaths.append(IndexPath(row: row,
                                    section: section))
      }

      return indexPaths
    }

    if self.hiddenSections.contains(section) {
      self.hiddenSections.remove(section)
      self.tableView.insertRows(at: indexPathsForSection(),
                                with: .fade)
    } else {
      self.hiddenSections.insert(section)
      self.tableView.deleteRows(at: indexPathsForSection(),
                                with: .fade)
    }
  }
}
