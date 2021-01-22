//
//  ViewController.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-16.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var loginLabel: UILabel!
  @IBOutlet weak var helpSectionView: UIView!

  var viewModel = ViewViewModel()
  override func viewDidLoad() {
    super.viewDidLoad()
    helpSectionView.isHidden = true
    // Do any additional setup after loading the view.
  }

  override func viewWillAppear(_ animated: Bool) {
    loginLabel.text = "hello".localiseText
  }

  @IBAction func showExtraOptions(_ sender: Any) {
    helpSectionView.isHidden = false
  }

  @IBAction func showDemo(_ sender: Any) {
  }

  @IBAction func loggedInAsATestUser(_ sender: Any) {
    let currentDriver = viewModel.testUser()
    let driverMetaData = viewModel.testUserDayMetaData()
    guard  let driver = currentDriver, let metaData = driverMetaData else {
      assertionFailure("failed to create objects")
      return
    }

    let bookViewModel = LogBookViewModel(driver: driver, metaData: [metaData])
    let logBookViewController = viewModel.logBookStoryboardInstance()
    logBookViewController.setViewModel(dataViewModel: bookViewModel)
    navigationController?.pushViewController(logBookViewController, animated: true)
  }

  @IBAction func launchRadio(_ sender: Any) {
  }

}

