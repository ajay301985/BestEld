//
//  VoilationManager.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-03-25.
//

import Foundation

class VoilationManager {

  static let shared = VoilationManager()

  func validateVoilations()
  {
    let numOfDays = 8
    var currentDate = Date()
    var days:  [DateData] = []
    //var slots: Array<Dictionary> = [[String:Any]
    let dayTimeInterval = oneDayTimeInterval
    let driverDLNumber = DataHandler.shared.currentDriver.dlNumber
    var dayDataOnDuty: DayData?
    let timeInterval = BLDAppUtility.startOfTheDayTimeInterval(for: currentDate)
    var inPast = timeInterval - eightDayTimeInterval
    var slot1:Array<DayData> = []
    var slot2:Array<DayData> = []
    var slot3:Array<DayData> = []
    var currentSlot = 0
    var totalWorkHours = 60
    var dayOff = false
    //currentDate.addTimeInterval(<#T##timeInterval: TimeInterval##TimeInterval#>)
    while dayOff == true {
      let timeInterval = BLDAppUtility.startOfTheDayTimeInterval(for: currentDate)
      let dayMetaDataObj = DataHandler.shared.dayMetaData(dayStart: inPast, driverDL: driverDLNumber ?? TEST_DRIVER_DL_NUMBER)

    }

    var voilation:[String] = []
    var totalNumberOfWorkingHours: TimeInterval = 0
    var totalNumberOfDrivingHours: TimeInterval = 0
    var totalNumberOfCycleHours: TimeInterval = 0
    //var totalNumberOfDrivingHours = 0
    var startDayTimeInterval = (Date().timeIntervalSince1970 - oneDayTimeInterval)
    var endDayTimeInterval = Date().timeIntervalSince1970
    var dateObj = Date()
    for index in 0..<numOfDays {
      let timeInterval = BLDAppUtility.startOfTheDayTimeInterval(for: dateObj)
      let dayMetaDataObj = DataHandler.shared.dayMetaData(dayStart: timeInterval, driverDL: driverDLNumber ?? TEST_DRIVER_DL_NUMBER)
      if let dayDataArr = dayMetaDataObj?.dayData?.allObjects as? [DayData], dayDataArr.count > 0 {
        let sortedData = dayDataArr.sorted(by: { $0.startTime ?? Date() < $1.startTime ?? Date() })
        for data in sortedData {
          let dutyStatus = DutyStatus(rawValue: data.dutyStatus ?? "OFFDUTY")
          guard let endDateTime = data.endTime, let startDateTime = data.startTime else {
            assertionFailure("Invalid data")
            return
          }


          guard let currentEndTime = data.endTime, let currentStartTime = data.startTime else {
            assertionFailure("Invalid data")
            return
          }
          let currentTimeInterval = currentEndTime.timeIntervalSince(currentStartTime)

          if (dutyStatus == DutyStatus.ONDUTY) {
            if (dayDataOnDuty != nil) {
                guard let endDateTime1 = dayDataOnDuty?.endTime, let startDateTime1 = dayDataOnDuty?.startTime else {
                  assertionFailure("Invalid data")
                  return
                }
                let timeInteval = startDateTime.timeIntervalSince(endDateTime1)
                totalNumberOfWorkingHours += currentTimeInterval
              if (timeInteval >= thirtyFourTimeInterval) {
                if (currentSlot == 0) {
                  slot1.append(data)
                }else if currentSlot == 1 {
                  slot2.append(data)
                }else if currentSlot == 2 {
                  slot3.append(data)
                }
                currentSlot += 1
              }else if (timeInteval >= tenFourTimeInterval) {

              }
            }
            dayDataOnDuty = data
          }else if (dutyStatus == DutyStatus.DRIVING) {
            totalNumberOfDrivingHours += currentTimeInterval
          }
        }
      }

      inPast = inPast - oneDayTimeInterval
    }
  }

  func isEightHourVoilation(dayData: DayData) -> Bool {
    guard let endDateTime = dayData.endTime, let startDateTime = dayData.startTime else {
      assertionFailure("Invalid data")
      return false
    }
    let drivingTime = endDateTime.timeIntervalSince(startDateTime)
    if (drivingTime >= eightHourTimeInterval) { //if user is driving more than eight hours
      return true
    }

    return false
  }
}
