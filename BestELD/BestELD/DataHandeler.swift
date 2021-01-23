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


  func createDayData(start: Date, end: Date, status: DutyStatus, desciption: String?, for driver: Driver) -> DayData? {
    let context = BLDAppUtility.dataContext()
    let entity = NSEntityDescription.entity(forEntityName: "DayData", in: context)
    let dayMetaDataObj = NSManagedObject(entity: entity!, insertInto: context)
    dayMetaDataObj.setValue("string", forKey: "day")
    dayMetaDataObj.setValue(driver.dlNumber, forKey: "dlNumber")
    dayMetaDataObj.setValue(status.dutyIndex, forKey: "dutyStatus")
    dayMetaDataObj.setValue(end, forKey: "endTimeStamp")
    dayMetaDataObj.setValue("1009", forKey: "id")
    dayMetaDataObj.setValue(1010101, forKey: "latitude")
    dayMetaDataObj.setValue(1010505, forKey: "longitude")
    dayMetaDataObj.setValue(desciption ?? "", forKey: "rideDescription")
    dayMetaDataObj.setValue(start, forKey: "startTimeStamp")
    dayMetaDataObj.setValue("USA, SA", forKey: "userLocation")
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
