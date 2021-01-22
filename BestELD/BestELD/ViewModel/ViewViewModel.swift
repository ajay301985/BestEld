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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext

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

  func logBookStoryboardInstance() -> LogBookViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: "LogBookViewController") as! LogBookViewController
  }

  func testUserDayMetaData() -> DayMetaData? {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext

    let entity = NSEntityDescription.entity(forEntityName: "DayMetaData", in: context)
    let dayMetaDataObj = NSManagedObject(entity: entity!, insertInto: context)

    guard (dayMetaDataObj != nil), dayMetaDataObj is DayMetaData else {
      print("wrong object")
      return nil
    }
    dayMetaDataObj.setValue(Date(), forKey: "day")
    dayMetaDataObj.setValue("test driver", forKey: "driverDLNumber")

    do {
      try context.save()
    }catch let error {
      print("Failed to save driver data\(error)")
    }
    return dayMetaDataObj as? DayMetaData
  }
}
