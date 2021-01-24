//
//  StringExtension.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-16.
//

import Foundation
import L10n_swift

extension String {

  var localiseText: String {
    return self.l10n()
  }
}


enum Main: String, ControllerValue {
  case BaseNav = "BaseNavigationController"
  case PractOverviewNav = "MainNavigationController"
  case SplitController = "SplitViewController"
  case PlanViewNav = "PlanViewNavigationController"
  case PatientNav = "PatientNavigationController"
  case ActivityIndicator = "ActivityIndicatorViewController"
  case PlanController = "PlanViewController"
  case PatientList = "PatientListViewController"

  var storyboard: Storyboards {
    Storyboards.Main
  }

}


extension UIViewController {
  typealias AlertAction = (title: String?, handler: (_ desription: String, _ date: Date) -> Void)

  
  func showAlertToUser(status: DutyStatus, continueAction: AlertAction,
                       cancelAction: AlertAction) {

    let textField = UITextField(frame: CGRect(x: 10, y: 65, width: 200, height: 30))
    textField.backgroundColor = .lightGray

    let myDatePicker: UIDatePicker = UIDatePicker()
    // setting properties of the datePicker
    myDatePicker.timeZone = NSTimeZone.local
    myDatePicker.frame = CGRect(x: 50, y: 100, width: 270, height: 200)
    myDatePicker.minimumDate = Date()
    myDatePicker.datePickerMode = .time

    let alertController = UIAlertController(title: "Select Date \n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertController.Style.alert)
    alertController.view.addSubview(textField)
    alertController.view.addSubview(myDatePicker)
    let somethingAction = UIAlertAction(
      title: continueAction.title ?? "OK",
      style: .default,
      handler: { _ in
        let description = textField.text
        let datePickerValue = myDatePicker.date
        continueAction.handler(description ?? "", datePickerValue)
      })

    let cancelAction = UIAlertAction(
      title: cancelAction.title ?? "Cancel",
      style: .cancel,
      handler: { _ in
        cancelAction.handler("ds", Date())
      })

/*    let somethingAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {_ in
      self.viewModel?.dutyStatusChanged(status: status,description: description, timeToStart: datePickerValue)
      if status == .OnDuty {
        let drivingController = self.viewModel.drivingStoryboardInstance()
        drivingController.modalPresentationStyle = .fullScreen
        self.present(drivingController, animated: true) {
          print("present")
        }
      }
    })
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil) */
    alertController.addAction(somethingAction)
    alertController.addAction(cancelAction)
    self.present(alertController, animated: true, completion:{
    })
  }

}
