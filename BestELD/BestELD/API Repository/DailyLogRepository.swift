//
//  DailyLogRepository.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-02-19.
//

import Foundation


class DailyLogRepository {
  static let shared = DailyLogRepository()

  func sendDailyLogsToServer(fromDate: Date, numberOfDays: Int = 8) {
    var currentDate = fromDate
    let currentDriver = DataHandeler.shared.currentDriver
    guard let driverLicenseNumber = currentDriver?.dlNumber else {
      assertionFailure("invalid driver data")
      return
    }

    var logDayDataArray: Array<[String:Any]> = []
    var logDataDict:[String:Any] = [:]
    for _ in 1...numberOfDays {
      let metaData = DataHandeler.shared.dayMetaData(dayStart: TimeInterval(BLDAppUtility.startOfTheDayTimeInterval(for: currentDate)) , driverDL: driverLicenseNumber)

      if let logDayData = metaData?.dayData {
        var logDayDataArray: Array<[String:Any]> = []
        for dayData in logDayData {
          var dayDataDict:[String:Any] = [:]
          let currentDayData = dayData as! DayData
          dayDataDict["dlnumber"] = currentDayData.dlNumber
          dayDataDict["dutystatus"] = currentDayData.dutyStatus
          dayDataDict["startlocation"] = currentDayData.startLocation
          dayDataDict["endlocation"] = currentDayData.endLocation
          dayDataDict["startlocationlatitude"] = currentDayData.startLatitude
          dayDataDict["startlocationlongitude"] = currentDayData.startLongitude
          dayDataDict["endlocationlatitude"] = currentDayData.endLatitude
          dayDataDict["endlocationlongitude"] = currentDayData.endLongitude
          dayDataDict["starttime"] = currentDayData.startTimeString
          dayDataDict["endtime"] = currentDayData.endTimeString
          dayDataDict["startodometer"] = currentDayData.startOdometer
          dayDataDict["endodometer"] = currentDayData.endOdometer
          dayDataDict["ridedescription"] = currentDayData.rideDescription
          logDayDataArray.append(dayDataDict)
        }
        logDataDict["dayData"] = logDayDataArray
      }
      if let logInspection = metaData?.inspection {
        var inspectionArray: Array<[String:Any]> = []
        for inspectionObj in logInspection {
          let currentInspection = inspectionObj as! Inspection
          var dayDataInspection:[String:Any] = [:]
          dayDataInspection["notes"] = currentInspection.notes
          dayDataInspection["location"] = currentInspection.location
          dayDataInspection["latitude"] = currentInspection.latitude
          dayDataInspection["longitude"] = currentInspection.longitude
          dayDataInspection["accepted"] = true
          inspectionArray.append(dayDataInspection)
        }
        logDataDict["inspection"] = inspectionArray
      }
      logDataDict["date"] = metaData?.day ??  BLDAppUtility.startOfTheDayTimeInterval(for: currentDate)
      if metaData?.id != nil {
        logDataDict["id"] = metaData?.id
      }

      if metaData?.driverId != nil {
        logDataDict["driverId"] = metaData?.driverId
      }

      logDayDataArray.append(logDataDict)
      currentDate = currentDate.dayBefore
    }

    AuthenicationService.shared.saveLogDataToServer(dataDictArray: logDayDataArray) { [weak self] result in
      print("got some data")
    }

  }
}


/*
 {
 "date":1612882460653,
 "dayData":[{
 "dayDataId":"153",
 "dlnumber":"xyz",
 "dutystatus":"ONDUTY",
 "startlocation":"US,NY",
 "endlocation":"US,NY",
 "startlocationlatitude":"US,NY",
 "startlocationlongitude":"US,NY",
 "endlocationlatitude":"US,NY",
 "endlocationlongitude":"US,NY",
 "startodometer":"34234324",
 "starttime":"34234324",
 "endtime":"34234324",
 "endodometer":"78787878",
 "ridedescription":"ride description"}
 ],
 "inspection":[{
 "notes":"note for inspection",
 "location":"usa",
 "latitude":"110101",
 "longitude":"110101",
 "accepted":true
 }]
 }
 */
