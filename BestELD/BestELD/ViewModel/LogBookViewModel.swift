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
    return dayMetaDataArr[0].day
  }

  func dutyStatusChanged(status: DutyStatus, description:String? = nil, timeToStart: Date? = nil) {
    let dutyStatus = DutyStatus(rawValue: currentDayData?.dutyStatus ?? 0)
    if (dutyStatus == status) {
      print("Status is same")
      return
    }

    switch status {
      case .OnDuty:
        performOnDutyStatusChanged(description: description, startTime: timeToStart)
      case .OffDuty:
        performOffDutyStatusChanged()
      case .Sleeper:
        performSleeperStatusChanged(description: description, startTime: timeToStart)
      case .Yard:
        performYardStatusChanged(description: description, startTime: timeToStart)
      default:
        performPersonalStatusChanged(description: description, startTime: timeToStart)
    }
  }

  private func performOnDutyStatusChanged(description: String?, startTime: Date? = nil) {

    guard let dayData = currentDayData else {
      print("invalid day data")
      return
    }

    let currentTime = Date()
    dayData.endTimeStamp = startTime ?? currentTime
    let currentDayData1 = DataHandeler.shared.createDayData(start: startTime ?? currentTime, end: Date(), status: .OnDuty, desciption: description ?? "on Duty Now", for: currentDriver)
    currentDayData = currentDayData1
  }

  private func performOffDutyStatusChanged() {
    let driverMetaData = DataHandeler.shared.dayMetaData(dayStart: Date(), driverDL: currentDriver.dlNumber ?? "xyz12345")
    guard let metaData = driverMetaData, (metaData.dayData?.count ?? 0 > 0) else {
      let startDate = Date().startOfDay
      currentDayData = DataHandeler.shared.createDayData(start: startDate, end: Date(), status: .OffDuty, desciption: "off duty",for: currentDriver)
      return
    }

    currentDayData = metaData.dayData?.allObjects[0] as? DayData
    print("tetet")
    //getData()
  }

  private func performSleeperStatusChanged(description: String?, startTime: Date? = nil) {
    guard let dayData = currentDayData else {
      print("invalid day data")
      return
    }

    let currentTime = Date()
    dayData.endTimeStamp = startTime ?? currentTime
    let currentDayData1 = DataHandeler.shared.createDayData(start: startTime ?? currentTime, end: Date(), status: .Sleeper, desciption: description ?? "on Duty Now",for: currentDriver)
    currentDayData = currentDayData1
  }

  private func performYardStatusChanged(description: String?, startTime: Date? = nil) {
    guard let dayData = currentDayData else {
      print("invalid day data")
      return
    }

    let currentTime = Date()
    dayData.endTimeStamp = startTime ?? currentTime
    let currentDayData1 = DataHandeler.shared.createDayData(start: startTime ?? currentTime, end: Date(), status: .Yard, desciption: description ?? "on Duty Now",for: currentDriver)
    currentDayData = currentDayData1
  }

  private func performPersonalStatusChanged(description: String?, startTime: Date? = nil) {
    guard let dayData = currentDayData else {
      print("invalid day data")
      return
    }

    let currentTime = Date()
    dayData.endTimeStamp = startTime ?? currentTime
    let currentDayData1 = DataHandeler.shared.createDayData(start: startTime ?? currentTime, end: Date(), status: .Personal, desciption: description ?? "on Duty Now",for: currentDriver)
    currentDayData = currentDayData1
  }

  private func performDrivingStatusChanged(description: String?, startTime: Date? = nil) {
    guard let dayData = currentDayData else {
      print("invalid day data")
      return
    }

    let currentTime = Date()
    dayData.endTimeStamp = startTime ?? currentTime
    let currentDayData1 = DataHandeler.shared.createDayData(start: startTime ?? currentTime, end: Date(), status: .Driving, desciption: description ?? "on Duty Now",for: currentDriver)
    currentDayData = currentDayData1
  }

  private func getData() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DayMetaData")

    do {
      let dayMetaData = try context.fetch(fetchRequest)
      print("test")
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
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
