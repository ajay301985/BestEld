//
//  DataHandeler.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-22.
//

import Foundation
import CoreData

class DataHandeler {

  static let shared = DataHandeler()

  var currentDriver: Driver!
  private var dayMetaDataArr: [DayMetaData]!
  var currentDayData: DayData!

  func setupData(for driverLicence:String) {
    currentDriver = getDriverData(for: driverLicence)
  }

  func createDayData(start: Date, end: Date, status: DutyStatus, desciption: String?, for driver: Driver) -> DayData? {
    let context = BLDAppUtility.dataContext()
    let entity = NSEntityDescription.entity(forEntityName: "DayData", in: context)
    let dayMetaDataObj = NSManagedObject(entity: entity!, insertInto: context)
    dayMetaDataObj.setValue("string", forKey: "day")
    dayMetaDataObj.setValue(driver.dlNumber, forKey: "dlNumber")
    dayMetaDataObj.setValue(status.dutyIndex, forKey: "dutyStatus")
    dayMetaDataObj.setValue(end, forKey: "endTimeStamp")
    dayMetaDataObj.setValue("1009", forKey: "id")
    let currentLocationObj = BldLocationManager.shared.currentLocation
    dayMetaDataObj.setValue(currentLocationObj?.coordinate.latitude, forKey: "startLatitude")
    dayMetaDataObj.setValue(currentLocationObj?.coordinate.longitude, forKey: "startLongitude")
    dayMetaDataObj.setValue(desciption ?? "", forKey: "rideDescription")
    dayMetaDataObj.setValue(start, forKey: "startTimeStamp")
    let userLocation = BldLocationManager.shared.locationText
    dayMetaDataObj.setValue(userLocation, forKey: "startUserLocation")
    let driverMetaData = dayMetaData(dayStart: Date(), driverDL: driver.dlNumber ?? "xyz12345")
    //driverMetaData.mutableva
    if (driverMetaData?.dayData?.count ?? 0 < 1) {
      driverMetaData?.setValue(NSSet(object: dayMetaDataObj), forKey: "DayData")
    } else {
      let dayDataArr = driverMetaData?.mutableSetValue(forKey: "DayData")
      dayDataArr?.add(dayMetaDataObj)
    }
    do {
      try context.save()
    }catch let error {
      print("Failed to save driver data\(error)")
    }

    return dayMetaDataObj as? DayData
  }

  func dayMetaData(dayStart: Date, driverDL: String) -> DayMetaData? {
    let context = BLDAppUtility.dataContext()

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DayMetaData")
    let startDay = dayStart.startOfDay
    fetchRequest.predicate = NSPredicate(format: "(dlNumber == %@) AND (day == %@)", driverDL,startDay as CVarArg)

    do {
      let testDriverMetaData = try context.fetch(fetchRequest)
      return testDriverMetaData.first as? DayMetaData
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    return nil
  }

}

extension DataHandeler {
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
        performOffDutyStatusChanged(description: description, startTime: timeToStart)
      case .Sleeper:
        performSleeperStatusChanged(description: description, startTime: timeToStart)
      case .Yard:
        performYardStatusChanged(description: description, startTime: timeToStart)
      case .Driving:
        performDrivingStatusChanged(description: description, startTime: timeToStart)
      default:
        performPersonalStatusChanged(description: description, startTime: timeToStart)
    }

    let dayMetaDataObj = userDayMetaData(dayStart: Date(), driverDL: "xyz12345")
    let dayDataArr = dayMetaDataObj?.dayData?.allObjects as! [DayData]
    let sortedData = dayDataArr.sorted(by: { $0.startTimeStamp ?? Date() < $1.startTimeStamp ?? Date()})
    GraphGenerator.shared.generatePath(dayDataArr: sortedData)
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

  private func performOffDutyStatusChanged(description: String?, startTime: Date? = nil) {
    let driverMetaData = DataHandeler.shared.dayMetaData(dayStart: Date(), driverDL: currentDriver.dlNumber ?? "xyz12345")
    guard let metaData = driverMetaData, (metaData.dayData?.count ?? 0 > 0) else {
      let startDate = Date().startOfDay //enter a test object
      currentDayData = DataHandeler.shared.createDayData(start: startDate, end: Date(), status: .OffDuty, desciption: description ?? "off duty",for: currentDriver)
      return
    }

    currentDayData = metaData.dayData?.allObjects[0] as? DayData
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
//    performDutyStatusChanged(description: description, startTime: startTime,dutyStatus: .Driving)
  }

  private func performDutyStatusChanged(description: String?, startTime: Date? = nil, dutyStatus: DutyStatus) {
    guard let dayData = currentDayData else {
      print("invalid day data")
      return
    }

    let currentTime = Date()
    dayData.endTimeStamp = startTime ?? currentTime
    let currentDayData1 = DataHandeler.shared.createDayData(start: startTime ?? currentTime, end: Date(), status: dutyStatus, desciption: description ?? "",for: currentDriver)
    currentDayData = currentDayData1
  }
}

extension DataHandeler {
  func testUser() -> Driver? {
    let testDriverLicenceNumber = "xyz12345"
    let driverDataObj = getDriverData(for: testDriverLicenceNumber)
    guard  driverDataObj != nil else {
      return createTestDriverData()
    }
    return driverDataObj
  }

  func getDriverData(for licence: String)  -> Driver? {
    let context = BLDAppUtility.dataContext()

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Driver")
    fetchRequest.predicate = NSPredicate(format: "dlNumber == %@", licence)

    do {
      let testDriverData = try context.fetch(fetchRequest)
      if testDriverData.isEmpty {
        return nil
      }
      return testDriverData.first as? Driver
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }

    return nil
  }

  func createTestDriverData() -> Driver? {
    let context = BLDAppUtility.dataContext()

    let entity = NSEntityDescription.entity(forEntityName: "Driver", in: context)
    let testDriver = NSManagedObject(entity: entity!, insertInto: context)

    guard (testDriver != nil), testDriver is Driver else {
      print("wrong object")
      return nil
    }
    testDriver.setValue("xyz12345", forKey: "dlNumber")
    testDriver.setValue("test driver", forKey: "firstName")

    do {
      try context.save()
    }catch let error {
      print("Failed to save driver data\(error)")
    }
    return testDriver as? Driver
  }


  func userDayMetaData(dayStart: Date, driverDL: String) -> DayMetaData? {
    let context = BLDAppUtility.dataContext()

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DayMetaData")
    let startDay = dayStart.startOfDay
    fetchRequest.predicate = NSPredicate(format: "(dlNumber == %@) AND (day == %@)", driverDL,startDay as CVarArg)

    do {
      let testDriverMetaData = try context.fetch(fetchRequest)
      if testDriverMetaData.isEmpty {
        return nil
      }
      return testDriverMetaData.first as? DayMetaData
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    return nil
  }


  func createTestUserMetaData(for driverLicence: String, data: Date) -> DayMetaData? {
    let context = BLDAppUtility.dataContext()
    let entity = NSEntityDescription.entity(forEntityName: "DayMetaData", in: context)
    let dayMetaDataObj = NSManagedObject(entity: entity!, insertInto: context)

    guard (dayMetaDataObj != nil), dayMetaDataObj is DayMetaData else {
      print("wrong object")
      return nil
    }

    let dayTextValue = BLDAppUtility.textForDate(date: data)
    dayMetaDataObj.setValue(data.startOfDay, forKey: "day")
    dayMetaDataObj.setValue(dayTextValue, forKey: "dayText")
    dayMetaDataObj.setValue(driverLicence, forKey: "dlNumber")

    do {
      try context.save()
    }catch let error {
      print("Failed to save driver data\(error)")
    }
    return dayMetaDataObj as? DayMetaData
  }

  func cleanupData(for driverLicence: String) {
    let context = BLDAppUtility.dataContext()
    let dayMetaDataObj = userDayMetaData(dayStart: Date(), driverDL: driverLicence)
    guard let metaDataToDelete = dayMetaDataObj else{
      //assertionFailure("invalid data to delete")
      return
    }
    context.delete(metaDataToDelete)
    do {
      try context.save()
    }catch let error {
      print("Failed to save driver data\(error)")
    }
  }
}
