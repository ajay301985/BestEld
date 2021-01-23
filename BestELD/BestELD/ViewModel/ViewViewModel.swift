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

  func logBookStoryboardInstance() -> LogBookViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: "LogBookViewController") as! LogBookViewController
  }

}
