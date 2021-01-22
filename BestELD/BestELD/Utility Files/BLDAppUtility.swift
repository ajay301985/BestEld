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

}
