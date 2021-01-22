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
