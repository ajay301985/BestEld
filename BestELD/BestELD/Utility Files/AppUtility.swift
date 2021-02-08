//
//  AppUtility.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-16.
//

import Foundation
import UIKit

let testDriverDLNumber = "xyz12345"

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

  var dayBefore: Date {
    return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
  }
  var dayAfter: Date {
    return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
  }
  var noon: Date {
    return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
  }
  var month: Int {
    return Calendar.current.component(.month,  from: self)
  }
  var isLastDayOfMonth: Bool {
    return dayAfter.month != month
  }
}

extension UIView {

  @IBInspectable var cornerRadiusV: CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
      layer.masksToBounds = newValue > 0
    }
  }

  @IBInspectable var borderWidthV: CGFloat {
    get {
      return layer.borderWidth
    }
    set {
      layer.borderWidth = newValue
    }
  }

  @IBInspectable var borderColorV: UIColor? {
    get {
      return UIColor(cgColor: layer.borderColor!)
    }
    set {
      layer.borderColor = newValue?.cgColor
    }
  }
}


extension Date {
  func toLocalTime() -> Date {
    let tz = NSTimeZone.local
    let seconds = tz.secondsFromGMT(for: self)
    return Date(timeInterval: TimeInterval(seconds), since: self)
  }


    func to(timeZone outputTimeZone: TimeZone, from inputTimeZone: TimeZone) -> Date {
      let teset = outputTimeZone.secondsFromGMT(for: self)
      let fdfd = inputTimeZone.secondsFromGMT(for: self)
      let delta = TimeInterval(outputTimeZone.secondsFromGMT(for: self))
      return addingTimeInterval(delta)
    }

/*  -(NSDate *) toGlobalTime
  {
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
  } */
}
