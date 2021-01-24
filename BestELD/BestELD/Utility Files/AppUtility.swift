//
//  AppUtility.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-16.
//

import Foundation
import UIKit

enum Storyboards: String {
  case Main

  // MARK: Internal

  func value() -> UIStoryboard {
    UIStoryboard(name: rawValue, bundle: nil)
  }
}

protocol ControllerValue {
  var storyboard: Storyboards { get }
  var rawValue: String { get }
}

extension ControllerValue {

  func value() -> UIViewController? {
    storyboard.value().instantiateViewController(withIdentifier: rawValue)
  }

  func value<T>() -> T? {
    value() as? T
  }
}

struct StoryboardItems {
  enum Main: String, ControllerValue {
    case BaseNav = "ViewController"

    // MARK: Internal

    var storyboard: Storyboards {
      Storyboards.Main
    }
  }
}

extension Date {
  var startOfDay: Date {
    return Calendar.current.startOfDay(for: self)
  }

  var endOfDay: Date {
    var components = DateComponents()
    components.day = 1
    components.second = -1
    return Calendar.current.date(byAdding: components, to: startOfDay)!
  }

  var startOfMonth: Date {
    let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
    return Calendar.current.date(from: components)!
  }

  var endOfMonth: Date {
    var components = DateComponents()
    components.month = 1
    components.second = -1
    return Calendar.current.date(byAdding: components, to: startOfMonth)!
  }
}

