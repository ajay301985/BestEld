//
//  LogBookViewModel.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-19.
//

import Foundation
import CoreData
import UIKit


class LogBookViewModel {
  var currentDriver: Driver
  private var dayMetaDataArr: [DayMetaData]
  private var currentDayData: DayData?

  init(driver:Driver, metaData:[DayMetaData]) {
    currentDriver = driver
    dayMetaDataArr = metaData
  }

  var driverName: String? {
      return currentDriver.firstName
  }

  var currentDay: Date? {
    let logDate = Date(timeIntervalSince1970: dayMetaDataArr[0].day)
    return logDate
  }
  
  var shouldSetDefaultOffDuty: Bool {
    return true
    //TODO: add conditions
  }

  func drivingStoryboardInstance() -> DrivingViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: "DrivingViewController") as! DrivingViewController
  }
}
