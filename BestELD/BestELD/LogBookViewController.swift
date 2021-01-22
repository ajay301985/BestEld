//
//  LogBookViewController.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-19.
//

import UIKit

class LogBookViewController: UIViewController {

    private var viewModel: LogBookViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentDriver = viewModel?.driverName
        let currentDriver1 = viewModel?.currentDay
        print("driver name is = \(currentDriver) and driving on \(currentDriver1)")
        // Do any additional setup after loading the view.
    }

  func setViewModel(dataViewModel: LogBookViewModel) {
    viewModel = dataViewModel
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
