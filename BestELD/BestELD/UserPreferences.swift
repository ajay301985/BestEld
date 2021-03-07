//
//  UserPreferences.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-02-06.
//

import Foundation

class UserPreferences {
  static let shared = UserPreferences()
  var currentSelectedDayData: DateData?

  var currentTimeZone: String {
    return "PST"
  }


  var selecteDayDate: DateData? {
    return currentSelectedDayData
  }

  var shouldSyncDataToServer: Bool {
    return DataHandeler.shared.currentDriver.dlNumber != TEST_DRIVER_DL_NUMBER
  }

  /*
   Time zones represent the standard time policies for a geopolitical region. Time zones have identifiers like “America/Los_Angeles” and can also be identified by abbreviations, such as PST for Pacific Standard Time. You can create time zone objects by ID with init(name:) and by abbreviation with init(abbreviation:).
   */
}
