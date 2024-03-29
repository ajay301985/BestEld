//
//  BLDAppUtility.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-20.
//

import Foundation
import UIKit
import CoreData
import SwiftKeychainWrapper

class BLDAppUtility {

  static let timeZonedateFormatter = DateFormatter()
  static let timeZonedateTimeFormatter = DateFormatter()


  static func startOfTheDayTimeInterval(for inDate: Date) -> TimeInterval {
    return inDate.startOfDay.timeIntervalSince1970
  }


  static func timezoneDate(from dayDate: Date) -> Date {


/*    let utcTimeZone = TimeZone(abbreviation: "UTC")!
    let dateString = "2020-06-03T01:43:44.888Z"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    let date = dateFormatter.date(from: dateString)

    print(date)
    print(date?.to(timeZone: .autoupdatingCurrent, from: utcTimeZone))
    print(date?.to(timeZone: .current, from: utcTimeZone))
    print(date?.to(timeZone: TimeZone(abbreviation: "PDT")!, from: utcTimeZone)) */
    let utcTimeZone = TimeZone(abbreviation: "GMT")!
    let currentDate = dayDate.to(timeZone: TimeZone(abbreviation: UserPreferences.shared.currentTimeZone)!, from: utcTimeZone)
    print(currentDate)
    return currentDate ?? Date()
/*    NSDate *localDate = [formatter dateFromString:utcDateStr]; // get the date
    NSTimeInterval timeZoneOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT]; // You could also use the systemTimeZone method
    NSTimeInterval utcTimeInterval = [localDate timeIntervalSinceReferenceDate] - timeZoneOffset;
    NSDate *utcCurrentDate = [NSDate dateWithTimeIntervalSinceReferenceDate:utcTimeInterval];
    return [formatter stringFromDate:utcCurrentDate]; */
  }

  static func timeString(from dayDate: Date) -> String {
    timeZonedateTimeFormatter.timeZone = TimeZone(abbreviation: UserPreferences.shared.currentTimeZone)
    timeZonedateTimeFormatter.dateFormat = "HH:mm"
    let currentDateString = timeZonedateTimeFormatter.string(from: dayDate)
    return currentDateString
  }

  static func dataContext() -> NSManagedObjectContext {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    //context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    return context
  }

  static func timezoneTextForDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation:UserPreferences.shared.currentTimeZone)
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    let dateString = dateFormatter.string(from: date)
    return dateString
  }


  static func stringForDate(inDate: Date) -> String {
    let dateFormatter = DateFormatter()
//    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z" //2021-02-06 13:05:50 +0000
    let dateString = dateFormatter.string(from: inDate)
    return dateString
  }

  static func textForDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    let dateString = dateFormatter.string(from: date)
    return dateString
  }

  static func hourMinute(for inDate: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    let currentDateString = dateFormatter.string(from: inDate)
    return currentDateString
  }

  static func hourMinuteValues(for inDate: Date) -> (hour: Int?, minute: Int?) {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: UserPreferences.shared.currentTimeZone)!
    let time=calendar.dateComponents([.hour,.minute,.second], from: inDate)
    print("\(time.hour!):\(time.minute!):\(time.second!)")
    return (time.hour, time.minute)
  }

  static func menuItems(loggedInUser: Bool) -> [MenuItem] {
    var menuItems: [MenuItem] = []
    let dmeoMenuItemObj = MenuItem(imageName: "demo1", isEnable: loggedInUser, title: "Demo")
    menuItems.append(dmeoMenuItemObj)

    let testMenuItemObj = MenuItem(imageName: "testmenuitem", isEnable: loggedInUser, title: "Test")
    menuItems.append(testMenuItemObj)

    let radioMenuItemObj = MenuItem(imageName: "radiomenuitem", isEnable: loggedInUser, title: "Radio")
    menuItems.append(radioMenuItemObj)

    let helpMenuItemObj = MenuItem(imageName: "helpmenuitem", isEnable: loggedInUser, title: "Help")
    menuItems.append(helpMenuItemObj)

    let messageMenuItemObj = MenuItem(imageName: "messagemenuitem", isEnable: loggedInUser, title: "Message")
    menuItems.append(messageMenuItemObj)

    let dotMenuItemObj = MenuItem(imageName: "dotmenuitem", isEnable: loggedInUser, title: "DOT Ins")
    menuItems.append(dotMenuItemObj)

    let settingMenuItemObj = MenuItem(imageName: "settingmenuitem", isEnable: loggedInUser, title: "Settings")
    menuItems.append(settingMenuItemObj)

    let logbookMenuItemObj = MenuItem(imageName: "logbookmenuitem", isEnable: loggedInUser, title: "Logbook")
    menuItems.append(logbookMenuItemObj)

    let sosMenuItemObj = MenuItem(imageName: "sosmenuitem", isEnable: loggedInUser, title: "SOS")
    menuItems.append(sosMenuItemObj)

    return menuItems
  }


  static func saveAccessToken(token: String) {
    //NSKeyedArchiver.
    let saveSuccessful: Bool = KeychainWrapper.standard.set(token, forKey: "accesstoken")
  }

  static func accessToekn() -> String? {
    let retrievedString: String? = KeychainWrapper.standard.string(forKey: "accesstoken")
    return retrievedString
  }

  static func saveIdToken(token: String) {
    //NSKeyedArchiver.
    let saveSuccessful: Bool = KeychainWrapper.standard.set(token, forKey: "idToken")
  }

  static func idToekn() -> String? {
    let retrievedString: String? = KeychainWrapper.standard.string(forKey: "idToken")
    return retrievedString
  }


  static func testDicData() -> [String: Any] {
    var dic:[String: Any] = [:]
    var dayData: [String: Any] = [:]
    dayData["id"] = "1"
    dayData["dlnumber"] = "DJHDS324234"
    dayData["dutystatus"] = "OFFDUTY"
    dayData["startlocation"] = "US,NY"
    dayData["endlocation"] = "US,NY"
    dayData["startlocationlatitude"] = "US,NY"
    dayData["startlocationlongitude"] = "US,NY"
    dayData["startodometer"] = "34234324"
    dayData["starttime"] = "2021-02-08 00:05:50 +0000"
    dayData["endtime"] = "2021-02-08 11:05:50 +0000"
    dayData["endodometer"] = "78787878"
    dayData["ridedescription"] = "ride description off duty"
    var dayMetaData: Array<[String: Any]> = []
    dayMetaData.append(dayData)


    dayData["id"] = "2"
    dayData["dlnumber"] = "DJHDS324234"
    dayData["dutystatus"] = "ONDUTY"
    dayData["startlocation"] = "US,NY"
    dayData["endlocation"] = "US,NY"
    dayData["startlocationlatitude"] = "US,NY"
    dayData["startlocationlongitude"] = "US,NY"
    dayData["startodometer"] = "34234324"
    dayData["starttime"] = "2021-02-08 11:05:50 +0000"
    dayData["endtime"] = "2021-02-08 13:05:50 +0000"
    dayData["endodometer"] = "78787878"
    dayData["ridedescription"] = "ride description On duty"
    dayMetaData.append(dayData)


    dayData["id"] = "3"
    dayData["dlnumber"] = "DJHDS324234"
    dayData["dutystatus"] = "DRIVING"
    dayData["startlocation"] = "US,NY"
    dayData["endlocation"] = "US,NY"
    dayData["startlocationlatitude"] = "US,NY"
    dayData["startlocationlongitude"] = "US,NY"
    dayData["startodometer"] = "34234324"
    dayData["starttime"] = "2021-02-08 13:05:50 +0000"
    dayData["endtime"] = "2021-02-08 19:00:50 +0000"
    dayData["endodometer"] = "78787878"
    dayData["ridedescription"] = "ride description Driving duty"
    dayMetaData.append(dayData)


    dayData["id"] = "3"
    dayData["dlnumber"] = "DJHDS324234"
    dayData["dutystatus"] = "SLEEPER"
    dayData["startlocation"] = "US,NY"
    dayData["endlocation"] = "US,NY"
    dayData["startlocationlatitude"] = "US,NY"
    dayData["startlocationlongitude"] = "US,NY"
    dayData["startodometer"] = "34234324"
    dayData["starttime"] = "2021-02-08 19:00:50 +0000"
    dayData["endtime"] = "2021-02-08 23:59:50 +0000"
    dayData["endodometer"] = "78787878"
    dayData["ridedescription"] = "ride description Sleeper"
    dayMetaData.append(dayData)

    dic["Feb 8, 2021"] = dayMetaData
    return dic
  }

  static func generateDataSource(dateFrom: Date, numOfDays: Int = 8) -> [DateData] {

    var currentDate = dateFrom
    var days:  [DateData] = []
    let dayTimeInterval = TimeInterval(60 * 60 * 24 * 1)
    for index in 0..<numOfDays {
      //if currentDate
      let dateObj = currentDate.startOfDayWithTimezone
      let currentTimezoneTimeInterval = dateObj.timeIntervalSince1970
      let timezoneUTC = currentDate.startOfDay.timeIntervalSince1970
      var dateString = BLDAppUtility.textForDate(date: dateObj)
      if index == 0 {
        dateString = "Today"
      }else if (index == 1) {
        dateString = "Yesterday"
      }
      let dayData = DateData(displayDate: dateString, dateCurrent: currentTimezoneTimeInterval, dateUTC: timezoneUTC)
        //DateData(displayDate: dateString, actualDate: dateString, dateValue: dateObj)
      days.insert(dayData, at: days.count)
      currentDate = currentDate.addingTimeInterval(-dayTimeInterval)//currentDate.dayBefore
    }

    return days
  }
}


extension UIViewController {
  func disableDarkMode() {
    if #available(iOS 13.0, *) {
      self.overrideUserInterfaceStyle = .light
    }
  }

}

extension UIViewController: UITextFieldDelegate{
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true;
  }
}


extension UIColor{
  convenience init(rgb: UInt, alphaVal: CGFloat) {
    self.init(
      red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgb & 0x0000FF) / 255.0,
      alpha: alphaVal
    )
  }
}
