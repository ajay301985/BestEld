//
//  ViewViewModel.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-19.
//

import Foundation
import UIKit
import CoreData

class ViewViewModel {

/*  init(user: Activity, dayMetaData: [OccurrenceEntity]?) {
    super.init()
  } */

  func testUser() -> Driver? {
    let context = BLDAppUtility.dataContext()

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Driver")
    let testDriverLicenceNumber = "xyz12345"
    fetchRequest.predicate = NSPredicate(format: "dlNumber == %@", testDriverLicenceNumber)

    do {
      let testDriverData = try context.fetch(fetchRequest)
      if testDriverData.isEmpty {
        return createTestDriverData()
      }
      return testDriverData.first as! Driver
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }

    return nil
  }

  private func createTestDriverData() -> Driver? {
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
    return testDriver as! Driver
  }

  func logBookStoryboardInstance() -> LogBookViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: "LogBookViewController") as! LogBookViewController
  }

  func testUserDayMetaData(dayStart: Date, driverDL: String) -> DayMetaData? {
    let context = BLDAppUtility.dataContext()

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DayMetaData")
    let startDay = dayStart.startOfDay
    fetchRequest.predicate = NSPredicate(format: "(dlNumber == %@) AND (day == %@)", driverDL,startDay as CVarArg)

    do {
      let testDriverMetaData = try context.fetch(fetchRequest)
      if testDriverMetaData.isEmpty {
        return createTestUserMetaData()
      }
      return testDriverMetaData.first as! DayMetaData
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    return nil
  }


  func createTestUserMetaData() -> DayMetaData? {
    let context = BLDAppUtility.dataContext()
    let entity = NSEntityDescription.entity(forEntityName: "DayMetaData", in: context)
    let dayMetaDataObj = NSManagedObject(entity: entity!, insertInto: context)

    guard (dayMetaDataObj != nil), dayMetaDataObj is DayMetaData else {
      print("wrong object")
      return nil
    }

    let dayTextValue = BLDAppUtility.textForDate(date: Date())
    dayMetaDataObj.setValue(Date().startOfDay, forKey: "day")
    dayMetaDataObj.setValue(dayTextValue, forKey: "dayText")
    dayMetaDataObj.setValue("xyz12345", forKey: "dlNumber")

    do {
      try context.save()
    }catch let error {
      print("Failed to save driver data\(error)")
    }
    return dayMetaDataObj as? DayMetaData
  }

}
