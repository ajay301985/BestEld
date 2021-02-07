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
    let driverMetaData = dayMetaData(dayStart: Date(), driverDL: driver.dlNumber ?? testDriverDLNumber)
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
    let dutyStatus = DutyStatus(rawValue: currentDayData?.dutyStatus ?? "OFFDUTY")
    if (dutyStatus == status) {
      print("Status is same")
      return
    }

    switch status {
      case .OnDuty:
        performDutyStatusChanged(description: description, startTime: timeToStart,dutyStatus: .OnDuty)
      case .OffDuty:
        performOffDutyStatusChanged(description: description, startTime: timeToStart)
      case .Sleeper:
        performDutyStatusChanged(description: description, startTime: timeToStart,dutyStatus: .Sleeper)
      case .Yard:
        performDutyStatusChanged(description: description, startTime: timeToStart,dutyStatus: .Yard)
      case .Driving:
        performDutyStatusChanged(description: description, startTime: timeToStart,dutyStatus: .Driving)
      default:
        performDutyStatusChanged(description: description, startTime: timeToStart,dutyStatus: .Personal)
    }

    let dayMetaDataObj = userDayMetaData(dayStart: Date(), driverDL: currentDriver.dlNumber ?? testDriverDLNumber)
    let dayDataArr = dayMetaDataObj?.dayData?.allObjects as! [DayData]
    let sortedData = dayDataArr.sorted(by: { $0.startTime ?? Date() < $1.startTime ?? Date()})
    GraphGenerator.shared.generatePath(dayDataArr: sortedData)
  }

  private func performOnDutyStatusChanged(description: String?, startTime: Date? = nil) {

    guard let dayData = currentDayData else {
      print("invalid day data")
      return
    }

    let currentTime = Date()
    dayData.endTime = startTime ?? currentTime
    let currentDayData1 = DataHandeler.shared.createDayData(start: startTime ?? currentTime, end: Date(), status: .OnDuty, desciption: description ?? "on Duty Now", for: currentDriver)
    currentDayData = currentDayData1
  }

  private func performOffDutyStatusChanged(description: String?, startTime: Date? = nil) {
    let driverMetaData = DataHandeler.shared.dayMetaData(dayStart: Date(), driverDL: currentDriver.dlNumber ?? testDriverDLNumber)
    guard let metaData = driverMetaData, (metaData.dayData?.count ?? 0 > 0) else {
      let startDate = Date().startOfDay //enter a test object
      currentDayData = DataHandeler.shared.createDayData(start: startDate, end: Date(), status: .OffDuty, desciption: description ?? "off duty",for: currentDriver)
      return
    }
    performDutyStatusChanged(description: description, startTime: startTime,dutyStatus: .OffDuty)
  }

  private func performDutyStatusChanged(description: String?, startTime: Date? = nil, dutyStatus: DutyStatus) {
    guard let dayData = currentDayData else {
      print("invalid day data")
      return
    }

    let currentTime = Date()
    dayData.endTime = startTime ?? currentTime
    let currentDayData1 = DataHandeler.shared.createDayData(start: startTime ?? currentTime, end: Date(), status: dutyStatus, desciption: description ?? "",for: currentDriver)
    currentDayData = currentDayData1
  }
}

//MARK: Driver Data
extension DataHandeler {
  func testUser() -> Driver? {
    let testDriverLicenceNumber = testDriverDLNumber
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


  func getEldData(for macAddress: String)  -> Eld? {
    let context = BLDAppUtility.dataContext()

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Eld")
    fetchRequest.predicate = NSPredicate(format: "macAddress == %@", macAddress)

    do {
      let eldData = try context.fetch(fetchRequest)
      if eldData.isEmpty {
        return nil
      }
      return eldData.first as? Eld
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
    testDriver.setValue(testDriverDLNumber, forKey: "dlNumber")
    testDriver.setValue("test driver", forKey: "firstName")

    do {
      try context.save()
    }catch let error {
      print("Failed to save driver data\(error)")
    }
    return testDriver as? Driver
  }


  func updateEldData(eldDataJson: [String: Any]?) -> Eld? {
    guard let eldData = eldDataJson else {
      assertionFailure("invalid eld data")
      return nil
    }

    var currentEld = getEldData(for: eldData["macAddress"] as! String)
    let context = BLDAppUtility.dataContext()
    if (currentEld == nil) {
      let entity = NSEntityDescription.entity(forEntityName: "Eld", in: context)
      currentEld = NSManagedObject(entity: entity!, insertInto: context) as? Eld

      guard let currentEldObj = currentEld else {
        print("wrong object")
        return nil
      }
      currentEldObj.setValue(eldData["eldId"] as! String, forKey: "eldId")
      currentEldObj.setValue(eldData["macAddress"] as! String, forKey: "macAddress")
      currentEldObj.setValue(eldData["fleetDotNumber"] as! String, forKey: "fleetDotNumber")
      currentEldObj.setValue(eldData["remarks"] as! String, forKey: "remarks")
      currentEldObj.setValue(eldData["status"] as! String, forKey: "status")

      do {
        try context.save()
      }catch let error {
        print("Failed to save driver data\(error)")
      }
      return currentEldObj

    } else {
      guard let currentEldObj = currentEld else {
        print("wrong object")
        return nil
      }
      currentEldObj.setValue(eldData["fleetDotNumber"] as! String, forKey: "fleetDotNumber")
      currentEldObj.setValue(eldData["remarks"] as! String, forKey: "remarks")
      currentEldObj.setValue(eldData["status"] as! String, forKey: "status")

      do {
        try context.save()
      }catch let error {
        print("Failed to save driver data\(error)")
      }
      return currentEldObj

    }
  }


  func updateDriverLogbookData(driverLogbookData: [String: Any]?)  {
    guard let logbookData = driverLogbookData else {
      assertionFailure("invalid drive data")
      return
    }
//DJHDS324234
    DispatchQueue.main.async {
      self.deleteDayMetaData(dayStart: "Feb 7, 2021", driverDL: "DJHDS324234")

      if let userMetaData = self.getDayMetadata(for: "Feb 7, 2021", driverDL: "DJHDS324234") {
        let dataArray = logbookData["Feb 7, 2021"] as! Array<[String : Any]>
        for data in dataArray {
          let currentDayData = data as! [String : Any]
          self.storeDayData(dataDict: currentDayData, for: self.currentDriver)
        }
      }else {
        self.createUserMetaData(for: "DJHDS324234", data: Date(), dayText: "Feb 7, 2021")
        let dataArray = logbookData["Feb 7, 2021"] as! Array<[String : Any]>
        for data in dataArray {
          let currentDayData = data as! [String : Any]
          self.storeDayData(dataDict: currentDayData, for: self.currentDriver)
        }
      }
    }
  }

  func storeDayData(dataDict: [String: Any], for driver: Driver) -> DayData? {
    let context = BLDAppUtility.dataContext()
    let entity = NSEntityDescription.entity(forEntityName: "DayData", in: context)
    let dayMetaDataObj = NSManagedObject(entity: entity!, insertInto: context)
    dayMetaDataObj.setValue("Feb 7, 2021", forKey: "day")
    dayMetaDataObj.setValue(dataDict["dlnumber"], forKey: "dlNumber")
    dayMetaDataObj.setValue(dataDict["dutystatus"], forKey: "dutyStatus")
    let endTimeString = dataDict["endtime"] as! String
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z" //2021-02-06 13:05:50 +0000
    let endDate = dateFormatter.date(from:endTimeString)!
    dayMetaDataObj.setValue(endDate, forKey: "endTime")
    dayMetaDataObj.setValue(endTimeString, forKey: "endTimeString")
    dayMetaDataObj.setValue(dataDict["id"], forKey: "id")
//    dayMetaDataObj.setValue(Double(dataDict["startlocationlatitude"]), forKey: "startLatitude")
//    dayMetaDataObj.setValue(dataDict["startlocationlongitude"], forKey: "startLongitude")
//    dayMetaDataObj.setValue(dataDict["endlocationlatitude"], forKey: "endLatitude")
//    dayMetaDataObj.setValue(dataDict["endlocationlongitude"], forKey: "endLongitude")
    dayMetaDataObj.setValue(dataDict["ridedescription"], forKey: "rideDescription")
    let startTimeString = dataDict["starttime"] as! String
    let startDate = dateFormatter.date(from:startTimeString)!
    dayMetaDataObj.setValue(startTimeString, forKey: "startTimeString")
    dayMetaDataObj.setValue(startDate, forKey: "startTime")
    dayMetaDataObj.setValue(dataDict["startlocation"], forKey: "startLocation")
    dayMetaDataObj.setValue(dataDict["endlocation"], forKey: "endLocation")
    dayMetaDataObj.setValue(Int(dataDict["startodometer"] as! String), forKey: "startOdometer")
    dayMetaDataObj.setValue(Int(dataDict["endodometer"] as! String), forKey: "endOdometer")
    //let driverMetaData = dayMetaData(dayStart: Date(), driverDL: driver.dlNumber ?? testDriverDLNumber)
    let driverMetaData = self.getDayMetadata(for: "Feb 7, 2021", driverDL: "DJHDS324234")
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

  func updateDriverData(driverDataJson: [String: Any]?) -> Driver? {
    guard let driverData = driverDataJson else {
      assertionFailure("invalid drive data")
      return nil
    }

    var currentDriver = getDriverData(for: driverData["dlNumber"] as! String)
    let context = BLDAppUtility.dataContext()
    if (currentDriver == nil) {
      //create driver data
      let entity = NSEntityDescription.entity(forEntityName: "Driver", in: context)
      currentDriver = NSManagedObject(entity: entity!, insertInto: context) as? Driver

      guard let currentDriverObj = currentDriver else {
        print("wrong object")
        return nil
      }
      currentDriverObj.setValue(driverData["city"] as! String, forKey: "city")
      currentDriverObj.setValue(driverData["country"] as! String, forKey: "country")
      currentDriverObj.setValue(driverData["dlBackPic"] as! String, forKey: "dlBackPic")
      currentDriverObj.setValue(driverData["dlExpiryDate"] as! String, forKey: "dlExpiryDate")
      currentDriverObj.setValue(driverData["dlFrontPic"] as! String, forKey: "dlFrontPic")
      currentDriverObj.setValue(driverData["dlNumber"] as! String, forKey: "dlNumber")
      currentDriverObj.setValue(driverData["email"] as! String, forKey: "email")
      currentDriverObj.setValue(driverData["firstName"] as! String, forKey: "firstName")
      currentDriverObj.setValue(driverData["fleetDOTNumber"] as! String, forKey: "fleetDOTNumber")
      currentDriverObj.setValue(driverData["id"] as! String, forKey: "id")
      currentDriverObj.setValue(driverData["lastName"] as! String, forKey: "lastName")
      currentDriverObj.setValue(driverData["primaryPhone"] as! String, forKey: "primaryPhone")
      currentDriverObj.setValue(driverData["secondaryPhone"] as! String, forKey: "secondaryPhone")
      currentDriverObj.setValue(driverData["state"] as! String, forKey: "state")
      currentDriverObj.setValue(driverData["strAddress1"] as! String, forKey: "strAddress1")
      currentDriverObj.setValue(driverData["strAddress2"] as! String, forKey: "strAddress2")
      currentDriverObj.setValue(driverData["zip"] as! String, forKey: "zip")
      do {
        try context.save()
      }catch let error {
        print("Failed to save driver data\(error)")
      }
      return currentDriverObj
    }else {
      //update driver data
      currentDriver?.setValue(driverData["city"] as! String, forKey: "city")
      currentDriver?.setValue(driverData["country"] as! String, forKey: "country")
      currentDriver?.setValue(driverData["dlBackPic"] as! String, forKey: "dlBackPic")
      currentDriver?.setValue(driverData["dlExpiryDate"] as! String, forKey: "dlExpiryDate")
      currentDriver?.setValue(driverData["dlFrontPic"] as! String, forKey: "dlFrontPic")
//      currentDriver?.setValue(driverData["dlNumber"] as! String, forKey: "dlNumber")
//      currentDriver?.setValue(driverData["email"] as! String, forKey: "email")
      currentDriver?.setValue(driverData["firstName"] as! String, forKey: "firstName")
      currentDriver?.setValue(driverData["fleetDOTNumber"] as! String, forKey: "fleetDOTNumber")
//      currentDriver?.setValue(driverData["id"] as! String, forKey: "id")
      currentDriver?.setValue(driverData["lastName"] as! String, forKey: "lastName")
      currentDriver?.setValue(driverData["primaryPhone"] as! String, forKey: "primaryPhone")
      currentDriver?.setValue(driverData["secondaryPhone"] as! String, forKey: "secondaryPhone")
      currentDriver?.setValue(driverData["state"] as! String, forKey: "state")
      currentDriver?.setValue(driverData["strAddress1"] as! String, forKey: "strAddress1")
      currentDriver?.setValue(driverData["strAddress2"] as! String, forKey: "strAddress2")
      currentDriver?.setValue(driverData["zip"] as! String, forKey: "zip")
      do {
        try context.save()
      }catch let error {
        print("Failed to save driver data\(error)")
      }
      return currentDriver
    }
  }
}

extension DataHandeler {

  func getDayMetadata(for inDate: String, driverDL: String)  -> DayMetaData? {
    let context = BLDAppUtility.dataContext()

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DayMetaData")
    fetchRequest.predicate = NSPredicate(format: "(dlNumber == %@) AND (dayText == %@)", driverDL,inDate)

    do {
      let eldData = try context.fetch(fetchRequest)
      if eldData.isEmpty {
        return nil
      }
      return eldData.first as? DayMetaData
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }

    return nil
  }


  func deleteDayMetaData(dayStart: String, driverDL: String) {
    let context = BLDAppUtility.dataContext()

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DayMetaData")
    fetchRequest.predicate = NSPredicate(format: "(dlNumber == %@) AND (dayText == %@)", driverDL,dayStart)

    do {
      let testDriverMetaData = try context.fetch(fetchRequest)
      if testDriverMetaData.isEmpty {
        return
      }

      if let optionArray = testDriverMetaData.first?.mutableSetValue(forKey: "dayData") {
        for object in optionArray {
          context.delete(object as! NSManagedObject)
        }
      }
      if let optionArray = testDriverMetaData.first?.mutableSetValue(forKey: "inspection") {
        for object in optionArray {
          context.delete(object as! NSManagedObject)
        }
      }

      context.delete(testDriverMetaData.first!)
      do {
        try context.save()
      }catch let error {
        print("Failed to save driver data\(error)")
      }
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }

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


  func createUserMetaData(for driverLicence: String, data: Date, dayText: String) -> DayMetaData? {
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
