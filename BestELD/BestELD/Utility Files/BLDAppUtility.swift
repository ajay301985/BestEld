//
//  BLDAppUtility.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-20.
//

import Foundation
import UIKit
import CoreData

class BLDAppUtility {
  
  static func dataContext() -> NSManagedObjectContext {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    return context
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
    let calendar = Calendar.current
    let time=calendar.dateComponents([.hour,.minute,.second], from: inDate)
    print("\(time.hour!):\(time.minute!):\(time.second!)")
    return (time.hour, time.minute)
  }

  static func menuItems(loggedInUser: Bool) -> [MenuItem] {
    var menuItems: [MenuItem] = []
    let dmeoMenuItemObj = MenuItem(imageName: "demo1", isEnable: loggedInUser, title: "Demo")
    menuItems.append(dmeoMenuItemObj)

    let testMenuItemObj = MenuItem(imageName: "demo1", isEnable: loggedInUser, title: "Test")
    menuItems.append(testMenuItemObj)

    let radioMenuItemObj = MenuItem(imageName: "demo1", isEnable: loggedInUser, title: "Radio")
    menuItems.append(radioMenuItemObj)

    let helpMenuItemObj = MenuItem(imageName: "demo1", isEnable: loggedInUser, title: "Help")
    menuItems.append(helpMenuItemObj)

    let messageMenuItemObj = MenuItem(imageName: "demo1", isEnable: loggedInUser, title: "Message")
    menuItems.append(messageMenuItemObj)

    let dotMenuItemObj = MenuItem(imageName: "demo1", isEnable: loggedInUser, title: "DOT Ins")
    menuItems.append(dotMenuItemObj)

    let settingMenuItemObj = MenuItem(imageName: "demo1", isEnable: loggedInUser, title: "Settings")
    menuItems.append(settingMenuItemObj)

    let logbookMenuItemObj = MenuItem(imageName: "demo1", isEnable: loggedInUser, title: "Logbook")
    menuItems.append(logbookMenuItemObj)

    let sosMenuItemObj = MenuItem(imageName: "demo1", isEnable: loggedInUser, title: "SOS")
    menuItems.append(sosMenuItemObj)

    return menuItems
  }

}
