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
  private var currentDriver: Driver
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
        performSleeperStatusChanged()
      case .Yard:
        performYardStatusChanged()
      default:
        performPersonalStatusChanged()
    }
  }

  private func performOnDutyStatusChanged(description: String?, startTime: Date? = nil) {

    guard let dayData = currentDayData else {
      print("invalid day data")
      return
    }

    let currentTime = Date()
    dayData.endTimeStamp = startTime ?? currentTime
    let currentDayData1 = createDayData(start: startTime ?? currentTime, end: Date(), status: .OnDuty, desciption: description ?? "on Duty Now")
  }

  private func performOffDutyStatusChanged() {
    let driverMetaData = testUserDayMetaData(dayStart: Date(), driverDL: currentDriver.dlNumber ?? "xyz12345")
    guard let metaData = driverMetaData, (metaData.dayData?.count ?? 0 > 0) else {
      let startDate = Date().startOfDay
      currentDayData = createDayData(start: startDate, end: Date(), status: .OffDuty, desciption: "off duty")
      return
    }

    currentDayData = metaData.dayData?.allObjects[0] as? DayData
    print("tetet")
    //getData()
  }

  private func performSleeperStatusChanged() {
    getData()
  }

  private func performYardStatusChanged() {
    getData()
  }

  private func performPersonalStatusChanged() {
    getData()
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


  func createDayData(start: Date, end: Date, status: DutyStatus, desciption: String?) -> DayData? {
    let context = BLDAppUtility.dataContext()
    let entity = NSEntityDescription.entity(forEntityName: "DayData", in: context)
    let dayMetaDataObj = NSManagedObject(entity: entity!, insertInto: context)
    dayMetaDataObj.setValue("string", forKey: "day")
    dayMetaDataObj.setValue(currentDriver.dlNumber, forKey: "dlNumber")
    dayMetaDataObj.setValue(status.dutyIndex, forKey: "dutyStatus")
    dayMetaDataObj.setValue(end, forKey: "endTimeStamp")
    dayMetaDataObj.setValue("1009", forKey: "id")
    dayMetaDataObj.setValue(1010101, forKey: "latitude")
    dayMetaDataObj.setValue(1010505, forKey: "longitude")
    dayMetaDataObj.setValue(desciption ?? "", forKey: "rideDescription")
    dayMetaDataObj.setValue(start, forKey: "startTimeStamp")
    dayMetaDataObj.setValue("USA, SA", forKey: "userLocation")
    let driverMetaData = testUserDayMetaData(dayStart: Date(), driverDL: currentDriver.dlNumber ?? "xyz12345")
    if (driverMetaData?.dayData?.count ?? 0 < 1) {
      driverMetaData?.dayData = Set(arrayLiteral: dayMetaDataObj) as NSSet
    } else {
      //driverMetaData?.mutableSetValue(forKey: "DayData").add(dayMetaDataObj)
      driverMetaData?.dayData?.adding(dayMetaDataObj)
      //driverMetaData?.dayData?.adding(dayMetaDataObj)
    }
    do {
      try context.save()
    }catch let error {
      print("Failed to save driver data\(error)")
    }

    return dayMetaDataObj as? DayData

  }

  func testUserDayMetaData(dayStart: Date, driverDL: String) -> DayMetaData? {
    let context = BLDAppUtility.dataContext()

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DayMetaData")
    let startDay = dayStart.startOfDay
    fetchRequest.predicate = NSPredicate(format: "(dlNumber == %@) AND (day == %@)", driverDL,startDay as CVarArg)

    do {
      let testDriverMetaData = try context.fetch(fetchRequest)
      return testDriverMetaData.first as! DayMetaData
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    return nil
  }

  var shouldSetDefaultOffDuty: Bool {
    return true
    //TODO: add conditions
  }
}
