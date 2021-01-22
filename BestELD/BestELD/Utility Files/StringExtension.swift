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
