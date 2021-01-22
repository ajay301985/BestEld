//
//  LogBookViewModel.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-19.
//

import Foundation


class LogBookViewModel {
  private var currentDriver: Driver
  private var dayMetaDataArr: [DayMetaData]

  init(driver:Driver, metaData:[DayMetaData]) {
    currentDriver = driver
    dayMetaDataArr = metaData
  }

  var driverName: String? {
      return currentDriver.firstName
  }

  var currentDay: Date? {
    return dayMetaDataArr[0].day
  }
}
