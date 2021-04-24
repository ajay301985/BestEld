//
//  DataHandeler.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-22.
//

import CoreData
import Foundation

class DataHandler {

  // MARK: Internal

  static let shared = DataHandler()

  var currentDriver: Driver!
  var currentDayData: DayData!
  var currentEldData: Eld!

  func setupData(for driverLicence: String) {
    currentDriver = getDriverData(for: driverLicence)
  }

  func createDayData(start: Date, end: Date, status: DutyStatus, desciption: String?, for driver: Driver) -> DayData? {
    let context = BLDAppUtility.dataContext()
    let entity = NSEntityDescription.entity(forEntityName: "DayData", in: context)
    let dayMetaDataObj = NSManagedObject(entity: entity!, insertInto: context)
    let driverMetaData = dayMetaData(dayStart: BLDAppUtility.startOfTheDayTimeInterval(for: Date()), driverDL: driver.dlNumber ?? TEST_DRIVER_DL_NUMBER)
    dayMetaDataObj.setValue(driverMetaData?.day ?? 0.0, forKey: "day")
    dayMetaDataObj.setValue(driver.dlNumber, forKey: "dlNumber")
    dayMetaDataObj.setValue(status.rawValue, forKey: "dutyStatus")
    dayMetaDataObj.setValue(end, forKey: "endTime")
    dayMetaDataObj.setValue(end.description, forKey: "endTimeString")
    // #warning generate Id
    dayMetaDataObj.setValue("1009", forKey: "id") //
    let currentLocationObj = BldLocationManager.shared.currentLocation
    dayMetaDataObj.setValue(currentLocationObj?.coordinate.latitude, forKey: "startLatitude")
    dayMetaDataObj.setValue(currentLocationObj?.coordinate.longitude, forKey: "startLongitude")
    dayMetaDataObj.setValue(desciption ?? "", forKey: "rideDescription")
    dayMetaDataObj.setValue(start, forKey: "startTime")
    dayMetaDataObj.setValue(start.description, forKey: "startTimeString")
    let userLocation = BldLocationManager.shared.locationText
    dayMetaDataObj.setValue(userLocation, forKey: "startLocation")

    let eldDataRecord = EldDeviceManager.shared.currentEldDataRecord
    if ((eldDataRecord != nil) && (status == DutyStatus.DRIVING || status == DutyStatus.ONDUTY)) {
      dayMetaDataObj.setValue(eldDataRecord?.odometer ?? 0, forKey: "startOdometer")
    }

    if driverMetaData?.dayData?.count ?? 0 < 1 {
      driverMetaData?.setValue(NSSet(object: dayMetaDataObj), forKey: "DayData")
    } else {
      let dayDataArr = driverMetaData?.mutableSetValue(forKey: "DayData")
      dayDataArr?.add(dayMetaDataObj)
    }
    do {
      try context.save()
    } catch {
      print("Failed to save driver data\(error)")
    }

    return dayMetaDataObj as? DayData
  }

  // MARK: Private

  private var dayMetaDataArr: [DayMetaData]!
}

extension DataHandler {
  #warning("if data is being added for another day then add a metadata for that")
  func dutyStatusChanged(status: DutyStatus, description: String? = nil, timeToStart: Date? = nil) {
    let dutyStatus = DutyStatus(rawValue: currentDayData?.dutyStatus ?? "OFFDUTY")
    if currentDayData != nil, dutyStatus == status {
      print("Status is same")
      return
    }

    switch status {
      case .ONDUTY:
        performDutyStatusChanged(description: description, startTime: timeToStart, dutyStatus: .ONDUTY)
      case .OFFDUTY:
        performOffDutyStatusChanged(description: description, startTime: timeToStart)
      case .SLEEPER:
        performDutyStatusChanged(description: description, startTime: timeToStart, dutyStatus: .SLEEPER)
      case .YARD:
        performDutyStatusChanged(description: description, startTime: timeToStart, dutyStatus: .YARD)
      case .DRIVING:
        performDutyStatusChanged(description: description, startTime: timeToStart, dutyStatus: .DRIVING)
      default:
        performDutyStatusChanged(description: description, startTime: timeToStart, dutyStatus: .PERSONAL)
    }

    //let dayMetaDataObj = dayMetaData(dayStart: BLDAppUtility.startOfTheDayTimeInterval(for: Date()), driverDL: currentDriver.dlNumber ?? TEST_DRIVER_DL_NUMBER, createOnDemand: true)
    //let dayDataArr = dayMetaDataObj?.dayData?.allObjects as! [DayData]
   // let sortedData = dayDataArr.sorted(by: { $0.startTime ?? Date() < $1.startTime ?? Date() })
  //  GraphGenerator.shared.generatePath(dayDataArr: sortedData)
  }

  private func performOffDutyStatusChanged(description: String?, startTime: Date? = nil) {
    let driverMetaData = DataHandler.shared.dayMetaData(dayStart: BLDAppUtility.startOfTheDayTimeInterval(for: Date()), driverDL: currentDriver.dlNumber ?? TEST_DRIVER_DL_NUMBER, createOnDemand: true)
    guard let metaData = driverMetaData, metaData.dayData?.count ?? 0 > 0 else {
      let startDate = Date().startOfDayWithTimezone // enter a test object
      currentDayData = DataHandler.shared.createDayData(start: startDate, end: Date(), status: .OFFDUTY, desciption: description ?? "off duty", for: currentDriver)
      if UserPreferences.shared.shouldSyncDataToServer {
        DailyLogRepository.shared.sendDailyLogsToServer(fromDate: Date(), numberOfDays: 1) { result in
          let dayMetaDataObj = DataHandler.shared.dayMetaData(dayStart: BLDAppUtility.startOfTheDayTimeInterval(for: Date()), driverDL: self.currentDriver.dlNumber ?? TEST_DRIVER_DL_NUMBER)
          if dayMetaDataObj != nil {
            if let dayDataArr = dayMetaDataObj?.dayData?.allObjects as? [DayData], dayDataArr.count > 0 {
              let sortedData = dayDataArr.sorted(by: { $0.startTime ?? Date() < $1.startTime ?? Date() })
              let latestDayData = sortedData.last
              self.currentDayData = latestDayData
              NotificationCenter.default.post(NSNotification(name: NSNotification.Name(rawValue: "DatabaseDidChanged"), object: self) as Notification)
            }
          }
        }
      } else {
        NotificationCenter.default.post(NSNotification(name: NSNotification.Name(rawValue: "DatabaseDidChanged"), object: self) as Notification)
      }
      return
    }

    guard let dayData = currentDayData else {
      print("invalid day data")
      return
    }

    dayData.endTime = startTime ?? Date()
    dayData.endTimeString = startTime?.description ?? Date().description

    let eldDataRecord = EldDeviceManager.shared.currentEldDataRecord
    let preDutyStatus = DutyStatus(rawValue: dayData.dutyStatus ?? "OFFDUTY")
    if ((eldDataRecord != nil) && (preDutyStatus == DutyStatus.DRIVING || preDutyStatus == DutyStatus.ONDUTY)) {
      dayData.endOdometer = eldDataRecord?.odometer ?? 0
    }

    performDutyStatusChanged(description: description, startTime: startTime, dutyStatus: .OFFDUTY)
  }

  private func performDutyStatusChanged(description: String?, startTime: Date? = nil, dutyStatus: DutyStatus) {
    guard let dayData = currentDayData else {
      print("invalid day data")
      return
    }

    let currentTime = Date()
    dayData.endTime = startTime ?? Date()
    dayData.endTimeString = startTime?.description ?? Date().description
    let eldDataRecord = EldDeviceManager.shared.currentEldDataRecord
    let preDutyStatus = DutyStatus(rawValue: dayData.dutyStatus ?? "OFFDUTY")
    if ((eldDataRecord != nil) && (preDutyStatus == DutyStatus.DRIVING || preDutyStatus == DutyStatus.ONDUTY)) {
      dayData.endOdometer = eldDataRecord?.odometer ?? 0
    }

    let currentDayData1 = DataHandler.shared.createDayData(start: startTime ?? currentTime, end: Date(), status: dutyStatus, desciption: description ?? "", for: currentDriver)
    currentDayData = currentDayData1
    if UserPreferences.shared.shouldSyncDataToServer {
      DailyLogRepository.shared.sendDailyLogsToServer(fromDate: Date(), numberOfDays: 1) { result in
        let dayMetaDataObj = DataHandler.shared.dayMetaData(dayStart: BLDAppUtility.startOfTheDayTimeInterval(for: Date()), driverDL: self.currentDriver.dlNumber ?? TEST_DRIVER_DL_NUMBER)
        if dayMetaDataObj != nil {
          if let dayDataArr = dayMetaDataObj?.dayData?.allObjects as? [DayData], dayDataArr.count > 0 {
            let sortedData = dayDataArr.sorted(by: { $0.startTime ?? Date() < $1.startTime ?? Date() })
            let latestDayData = sortedData.last
            self.currentDayData = latestDayData
            NotificationCenter.default.post(NSNotification(name: NSNotification.Name(rawValue: "DatabaseDidChanged"), object: self) as Notification)
          }
        }
      }
    } else {
      NotificationCenter.default.post(NSNotification(name: NSNotification.Name(rawValue: "DatabaseDidChanged"), object: self) as Notification)
    }
  }
}

// MARK: Driver Data

extension DataHandler {
  func testUser() -> Driver? {
    let testDriverLicenceNumber = TEST_DRIVER_DL_NUMBER
    let driverDataObj = getDriverData(for: testDriverLicenceNumber)
    guard driverDataObj != nil else {
      return createTestDriverData()
    }
    return driverDataObj
  }

  func getDriverData(for licence: String) -> Driver? {
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

  func getEldData(for macAddress: String) -> Eld? {
    let context = BLDAppUtility.dataContext()

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Eld")
    fetchRequest.predicate = NSPredicate(format: "vin == %@", macAddress)

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

    guard testDriver != nil, testDriver is Driver else {
      print("wrong object")
      return nil
    }
    testDriver.setValue(TEST_DRIVER_DL_NUMBER, forKey: "dlNumber")
    testDriver.setValue("test driver", forKey: "firstName")

    do {
      try context.save()
    } catch {
      print("Failed to save driver data\(error)")
    }
    return testDriver as? Driver
  }

  func updateEldData(eldDataJson: [String: Any]?) -> Eld? {
    guard let eldData = eldDataJson else {
      assertionFailure("invalid eld data")
      return nil
    }

    var currentEld = getEldData(for: eldData["vin"] as! String)
    let context = BLDAppUtility.dataContext()
    if currentEld == nil {
      let entity = NSEntityDescription.entity(forEntityName: "Eld", in: context)
      currentEld = NSManagedObject(entity: entity!, insertInto: context) as? Eld
    }

    guard let currentEldObj = currentEld else {
      print("wrong object")
      return nil
    }

    currentEldObj.setValue(eldData["cargoInsurance"] as! String, forKey: "cargoInsurance")
    currentEldObj.setValue(eldData["carrierName"] as! String, forKey: "carrierName")
    currentEldObj.setValue(eldData["expiryDate"] as! String, forKey: "expiryDate")
    currentEldObj.setValue(eldData["fleetDOTNumber"] as! String, forKey: "fleetDOTNumber")
    currentEldObj.setValue(eldData["fuelType"] as! String, forKey: "fuelType")
    currentEldObj.setValue(eldData["id"] as! String, forKey: "id")
    currentEldObj.setValue(eldData["liabilityInsurance"] as! String, forKey: "liabilityInsurance")
    currentEldObj.setValue(eldData["licensePlate"] as! String, forKey: "licensePlate")
    currentEldObj.setValue(eldData["make"] as! String, forKey: "make")
    currentEldObj.setValue(eldData["model"] as! String, forKey: "model")
    currentEldObj.setValue(eldData["odometer"] as! String, forKey: "odometer")
    currentEldObj.setValue(eldData["policyNumber"] as! String, forKey: "policyNumber")
    currentEldObj.setValue(eldData["regNumber"] as! String, forKey: "regNumber")
    currentEldObj.setValue(eldData["registration"] as! String, forKey: "registration")
    currentEldObj.setValue(eldData["truckNumber"] as! String, forKey: "truckNumber")
    currentEldObj.setValue(eldData["vin"] as! String, forKey: "vin")
    currentEldObj.setValue(eldData["year"] as! String, forKey: "year")

    do {
      try context.save()
    } catch {
      print("Failed to save driver data\(error)")
    }
    return currentEldObj

    /*
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
       } catch {
         print("Failed to save driver data\(error)")
       }
       return currentEldObj
     } */
  }

  func getLastTrackedEvent(driverDLNumber: String, inDate: Date, numberOfDays: Int = 3) -> DayData? {

    let dayMetaDataObj = DataHandler.shared.getLastMetaData(driverDL: driverDLNumber)
      if dayMetaDataObj != nil {
        if let dayDataArr = dayMetaDataObj?.dayData?.allObjects as? [DayData], dayDataArr.count > 0 {
          let sortedData = dayDataArr.sorted(by: { $0.startTime ?? Date() < $1.startTime ?? Date() })
          let latestDayData = sortedData.last
          return latestDayData
      }
      }
    return nil
  }

  func updateDriverLogbookData(driverLogbookData: [[String: Any]]) {
//    guard let logbookData = driverLogbookData else {
//      assertionFailure("invalid drive data")
//      return
//    }
    // DJHDS324234
//    DispatchQueue.main.async {

    let context = BLDAppUtility.dataContext()
    let driverDL = currentDriver.dlNumber ?? ""
    for logData in driverLogbookData {
      let logBookDate = logData["createdDate"] as! Double
      let driverId = logData["driverId"] as! String
      let logDataId = logData["id"] as! String
      // self.deleteDayMetaData(dayStart: logBookDate, driverDL: self.currentDriver.dlNumber ?? "")
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DayMetaData")
      fetchRequest.predicate = NSPredicate(format: "(dlNumber == %@) AND (day == %lf)", driverDL, logBookDate)

    //  var dayMetaDataObj: DayMetaData?
      if let testDriverMetaData = try? context.fetch(fetchRequest), let dayMetaDataObj = testDriverMetaData.first as? DayMetaData {
        let optionArray = dayMetaDataObj.mutableSetValue(forKey: "dayData")
        for object in optionArray {
          context.delete(object as! NSManagedObject)
        }
        let inspectionArray = dayMetaDataObj.mutableSetValue(forKey: "inspection")
        for inspectionObj in inspectionArray {
          context.delete(inspectionObj as! NSManagedObject)
        }
        context.delete(testDriverMetaData.first!)
        do {
          try context.save()
        } catch {
          print("Failed to save driver data\(error)")
        }
        /*
         if (dayMetaDataObj.dayData?.count ?? 0 < 1) {
           dayMetaDataObj.setValue(NSSet(object: dayDataArray), forKey: "dayData")
         } else {
           let dayDataArr = dayMetaDataObj.mutableSetValue(forKey: "dayData")
           dayDataArr.add(dayDataArray)
         } */
      }
        // let entity = NSEntityDescription.entity(forEntityName: "DayMetaData", in: context)
        // let dayMetaDataObj = NSManagedObject(entity: entity!, insertInto: context) as! DayMetaData

        let dayMetaDataObj = createTestUserMetaData(for: driverDL, dayData: logBookDate, driverId: driverId, logbookId: logDataId)
      //a(for: driverDL, dayData: logBookDate, )

        if dayMetaDataObj != nil {
//            let dayTextValue = BLDAppUtility.textForDate(date: data)
          if let logBookDayData = logData["dayData"] as? [[String: Any]] {
            for inLogData in logBookDayData {
              if let currentDayData = createDayData(with: inLogData) {
                if dayMetaDataObj?.dayData?.count ?? 0 < 1 {
                  dayMetaDataObj?.setValue(NSSet(object: currentDayData), forKey: "DayData")
                } else {
                  let dayDataArr = dayMetaDataObj?.mutableSetValue(forKey: "DayData")
                  dayDataArr?.add(currentDayData)
                }
              }
            }
          }
        }
    }

    do {
      try context.save()
    } catch {
      print("Failed to save driver data\(error)")
    }

    /*

     if let userMetaData = self.getDayMetadata(for: currentDateAsText, driverDL: self.currentDriver.dlNumber ?? "") {
       let dataArray = logbookData[currentDateAsText] as! Array<[String : Any]>
       for data in dataArray {
         let currentDayData = data as! [String : Any]
         self.storeDayData(dataDict: currentDayData, for: self.currentDriver, inDayData: Date())
       }
     }else {
       self.createUserMetaData(for: self.currentDriver.dlNumber ?? "", data: Date(), dayText: currentDateAsText)
       guard let dataArray = logbookData[currentDateAsText] as? Array<[String : Any]> else {
         return
       }
       for data in dataArray {
         let currentDayData = data as! [String : Any]
         self.storeDayData(dataDict: currentDayData, for: self.currentDriver, inDayData: Date())
       }
     }*/
    // }
  }

  func createDayData(with dataDict: [String: Any]) -> DayData? {
    let currentDateAsText = BLDAppUtility.textForDate(date: Date())
    let context = BLDAppUtility.dataContext()
    let entity = NSEntityDescription.entity(forEntityName: "DayData", in: context)
    let dayMetaDataObj = NSManagedObject(entity: entity!, insertInto: context)
    if let dayObj = dataDict["day"] as? Double {
      dayMetaDataObj.setValue(dayObj, forKey: "day")
    }else {
      dayMetaDataObj.setValue(0, forKey: "day")
    }

    dayMetaDataObj.setValue(dataDict["dlnumber"], forKey: "dlNumber")
    dayMetaDataObj.setValue(dataDict["dutystatus"], forKey: "dutyStatus")
    guard let endTimeString = dataDict["endtime"] as? String else {
      return nil
    }
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z" // 2021-02-06 13:05:50 +0000
    guard let endDate = dateFormatter.date(from: endTimeString) else { return nil }
    dayMetaDataObj.setValue(endDate, forKey: "endTime")
    dayMetaDataObj.setValue(endTimeString, forKey: "endTimeString")
    dayMetaDataObj.setValue(dataDict["id"], forKey: "id")
    //    dayMetaDataObj.setValue(Double(dataDict["startlocationlatitude"]), forKey: "startLatitude")
    //    dayMetaDataObj.setValue(dataDict["startlocationlongitude"], forKey: "startLongitude")
    //    dayMetaDataObj.setValue(dataDict["endlocationlatitude"], forKey: "endLatitude")
    //    dayMetaDataObj.setValue(dataDict["endlocationlongitude"], forKey: "endLongitude")
    dayMetaDataObj.setValue(dataDict["ridedescription"], forKey: "rideDescription")
    let startTimeString = dataDict["starttime"] as! String
    guard let startDate = dateFormatter.date(from: startTimeString) else { return nil }
    dayMetaDataObj.setValue(startTimeString, forKey: "startTimeString")
    dayMetaDataObj.setValue(startDate, forKey: "startTime")
    dayMetaDataObj.setValue(dataDict["startlocation"], forKey: "startLocation")
    dayMetaDataObj.setValue(dataDict["endlocation"], forKey: "endLocation")
    dayMetaDataObj.setValue(dataDict["startodometer"] as! Int, forKey: "startOdometer")
    dayMetaDataObj.setValue(dataDict["endodometer"] as! Int, forKey: "endOdometer")
    // let driverMetaData = dayMetaData(dayStart: Date(), driverDL: driver.dlNumber ?? testDriverDLNumber)
    /*    let driverMetaData = self.getDayMetadata(for: currentDateAsText, driverDL: driver.dlNumber ?? "")
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
     }*/

    return dayMetaDataObj as! DayData
  }

  func storeDayData(dataDict: [String: Any], for driver: Driver, inDayData: Date) -> DayData? {
    let currentDateAsText = BLDAppUtility.textForDate(date: Date())
    let context = BLDAppUtility.dataContext()
    let entity = NSEntityDescription.entity(forEntityName: "DayData", in: context)
    let dayMetaDataObj = NSManagedObject(entity: entity!, insertInto: context)
    dayMetaDataObj.setValue(dataDict["day"], forKey: "day")
    dayMetaDataObj.setValue(dataDict["dlnumber"], forKey: "dlNumber")
    dayMetaDataObj.setValue(dataDict["dutystatus"], forKey: "dutyStatus")
    let endTimeString = dataDict["endtime"] as! String
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z" // 2021-02-06 13:05:50 +0000
    let endDate = dateFormatter.date(from: endTimeString)!
    dayMetaDataObj.setValue(endDate, forKey: "endTime")
    dayMetaDataObj.setValue(endTimeString, forKey: "endTimeString")
    dayMetaDataObj.setValue(dataDict["id"], forKey: "id")
//    dayMetaDataObj.setValue(Double(dataDict["startlocationlatitude"]), forKey: "startLatitude")
//    dayMetaDataObj.setValue(dataDict["startlocationlongitude"], forKey: "startLongitude")
//    dayMetaDataObj.setValue(dataDict["endlocationlatitude"], forKey: "endLatitude")
//    dayMetaDataObj.setValue(dataDict["endlocationlongitude"], forKey: "endLongitude")
    dayMetaDataObj.setValue(dataDict["ridedescription"], forKey: "rideDescription")
    let startTimeString = dataDict["starttime"] as! String
    let startDate = dateFormatter.date(from: startTimeString)!
    dayMetaDataObj.setValue(startTimeString, forKey: "startTimeString")
    dayMetaDataObj.setValue(startDate, forKey: "startTime")
    dayMetaDataObj.setValue(dataDict["startlocation"], forKey: "startLocation")
    dayMetaDataObj.setValue(dataDict["endlocation"], forKey: "endLocation")
    dayMetaDataObj.setValue(Int(dataDict["startodometer"] as! String), forKey: "startOdometer")
    dayMetaDataObj.setValue(Int(dataDict["endodometer"] as! String), forKey: "endOdometer")
    // let driverMetaData = dayMetaData(dayStart: Date(), driverDL: driver.dlNumber ?? testDriverDLNumber)
    let driverMetaData = getDayMetadata(for: currentDateAsText, driverDL: driver.dlNumber ?? "")
    if driverMetaData?.dayData?.count ?? 0 < 1 {
      driverMetaData?.setValue(NSSet(object: dayMetaDataObj), forKey: "DayData")
    } else {
      let dayDataArr = driverMetaData?.mutableSetValue(forKey: "DayData")
      dayDataArr?.add(dayMetaDataObj)
    }
    do {
      try context.save()
    } catch {
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
    if currentDriver == nil {
      // create driver data
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
      if let homeTerminalData = driverData["homeTerminal"] as? String {
        currentDriverObj.setValue(homeTerminalData, forKey: "homeTerminal")
      }

      if let mainOffice = driverData["mainOffice"] as? String {
        currentDriverObj.setValue(mainOffice, forKey: "mainOffice")
      }

      currentDriverObj.setValue(driverData["zip"] as! String, forKey: "zip")
      do {
        try context.save()
      } catch {
        print("Failed to save driver data\(error)")
      }
      return currentDriverObj
    } else {
      // update driver data
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
      } catch {
        print("Failed to save driver data\(error)")
      }
      return currentDriver
    }
  }
}

extension DataHandler {
  func saveTripData(status: TripStatus, notes: String? = "", location: String? = "", inDayData: Date) -> Inspection? {
    let context = BLDAppUtility.dataContext()
    let entity = NSEntityDescription.entity(forEntityName: "Inspection", in: context)
    let inspectionObj = NSManagedObject(entity: entity!, insertInto: context) as? Inspection

    guard let currentInsepectionObj = inspectionObj else {
      print("wrong object")
      return nil
    }
    let currentLocationObj = BldLocationManager.shared.currentLocation
    currentInsepectionObj.setValue(currentLocationObj?.coordinate.latitude, forKey: "latitude")
    currentInsepectionObj.setValue(currentLocationObj?.coordinate.longitude, forKey: "longitude")
    currentInsepectionObj.setValue(currentDriver.dlNumber, forKey: "dlNumber")
    currentInsepectionObj.setValue(location, forKey: "location")
    currentInsepectionObj.setValue(notes, forKey: "notes")
    currentInsepectionObj.setValue(status.rawValue, forKey: "type")

    let driverMetaData = dayMetaData(dayStart: BLDAppUtility.startOfTheDayTimeInterval(for: inDayData), driverDL: currentDriver.dlNumber ?? "")
    if driverMetaData?.inspection?.count ?? 0 < 1 {
      driverMetaData?.setValue(NSSet(object: currentInsepectionObj), forKey: "Inspection")
    } else {
      let dayDataArr = driverMetaData?.mutableSetValue(forKey: "Inspection")
      dayDataArr?.add(currentInsepectionObj)
    }

    do {
      try context.save()
    } catch {
      print("Failed to save driver data\(error)")
    }
    return currentInsepectionObj
  }
}

extension DataHandler {
  func deleteDayMetaData(dayStart: Double, driverDL: String) {
    let context = BLDAppUtility.dataContext()

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DayMetaData")
    fetchRequest.predicate = NSPredicate(format: "(dlNumber == %@) AND (day == %lf)", driverDL, dayStart)

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
      } catch {
        print("Failed to save driver data\(error)")
      }
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
  }

  func getLastMetaData(driverDL: String) -> DayMetaData? {
    let context = BLDAppUtility.dataContext()

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DayMetaData")
    //    let currentDateAsText = BLDAppUtility.textForDate(date: dayStart)
    fetchRequest.predicate = NSPredicate(format: "(dlNumber == %@)", driverDL)

    do {
      guard let testDriverMetaData = try context.fetch(fetchRequest) as? [DayMetaData] else {
        return nil
      }

      let sortedMetaData = testDriverMetaData.sorted(by: { $0.day < $1.day})
      guard sortedMetaData.count > 0, let metaDataObj = sortedMetaData.last else {
        return nil
      }

      return metaDataObj
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    return nil
  }

  func dayMetaData(dayStart: TimeInterval, driverDL: String, createOnDemand: Bool = false) -> DayMetaData? {
    let context = BLDAppUtility.dataContext()

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DayMetaData")
//    let currentDateAsText = BLDAppUtility.textForDate(date: dayStart)
    fetchRequest.predicate = NSPredicate(format: "(dlNumber == %@) AND (day == %lf)", driverDL, dayStart)

    do {
      let testDriverMetaData = try context.fetch(fetchRequest)
      guard let metaDataObj = testDriverMetaData.first as? DayMetaData else {
        if createOnDemand {
          let newMetaDataObj = createTestUserMetaData(for: driverDL, dayData: dayStart)
          return newMetaDataObj
        }
        return nil
      }

      return metaDataObj
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    return nil
  }

  /*
   func userDayMetaData(dayStart: Date, driverDL: String) -> DayMetaData? {
     let context = BLDAppUtility.dataContext()

     let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DayMetaData")
     let currentDateAsText = BLDAppUtility.textForDate(date: dayStart)
     fetchRequest.predicate = NSPredicate(format: "(dlNumber == %@) AND (dayText == %@)", driverDL,currentDateAsText)

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
   */

  func getDayMetadata(for inDate: String, driverDL: String) -> DayMetaData? {
    let context = BLDAppUtility.dataContext()

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DayMetaData")
    fetchRequest.predicate = NSPredicate(format: "(dlNumber == %@) AND (dayText == %@)", driverDL, inDate)

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

  func createTestUserMetaData(for driverLicence: String, dayData: TimeInterval, driverId: String? = nil, logbookId: String? = nil) -> DayMetaData? {
    let context = BLDAppUtility.dataContext()
    let entity = NSEntityDescription.entity(forEntityName: "DayMetaData", in: context)
    let dayMetaDataObj = NSManagedObject(entity: entity!, insertInto: context)

    guard dayMetaDataObj != nil, dayMetaDataObj is DayMetaData else {
      print("wrong object")
      return nil
    }

    dayMetaDataObj.setValue(dayData, forKey: "day")
    dayMetaDataObj.setValue(driverLicence, forKey: "dlNumber")
    if driverId != nil {
      dayMetaDataObj.setValue(driverId!, forKey: "driverId")
    }
    if logbookId != nil {
      dayMetaDataObj.setValue(logbookId!, forKey: "id")
    }

    do {
      try context.save()
    } catch {
      print("Failed to save driver data\(error)")
    }
    return dayMetaDataObj as? DayMetaData
  }

  func createUserMetaData(for driverLicence: String, inDate: Date) -> DayMetaData? {
    let context = BLDAppUtility.dataContext()
    let entity = NSEntityDescription.entity(forEntityName: "DayMetaData", in: context)
    let dayMetaDataObj = NSManagedObject(entity: entity!, insertInto: context)

    guard dayMetaDataObj != nil, dayMetaDataObj is DayMetaData else {
      print("wrong object")
      return nil
    }

    let timeIntervalDate = BLDAppUtility.startOfTheDayTimeInterval(for: inDate)
    dayMetaDataObj.setValue(timeIntervalDate, forKey: "day")
    dayMetaDataObj.setValue(driverLicence, forKey: "dlNumber")

    do {
      try context.save()
    } catch {
      print("Failed to save driver data\(error)")
    }
    return dayMetaDataObj as? DayMetaData
  }

  func cleanupData(for driverLicence: String) {
    let context = BLDAppUtility.dataContext()
    let dayMetaDataObj = dayMetaData(dayStart: BLDAppUtility.startOfTheDayTimeInterval(for: Date()), driverDL: driverLicence)
    guard let metaDataToDelete = dayMetaDataObj else {
      // assertionFailure("invalid data to delete")
      return
    }
    context.delete(metaDataToDelete)
    do {
      try context.save()
    } catch {
      print("Failed to save driver data\(error)")
    }
  }
}
