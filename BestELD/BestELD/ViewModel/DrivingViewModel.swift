//
//  DrivingViewModel.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-22.
//

import Foundation

class DrivingViewModel {
  private var currentDriver: Driver
  private var dayMetaDataArr: [DayMetaData]

  init(driver:Driver, metaData:[DayMetaData]) {
    currentDriver = driver
    dayMetaDataArr = metaData
  }

}
