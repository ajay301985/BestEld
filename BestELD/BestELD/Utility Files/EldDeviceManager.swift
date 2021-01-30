//
//  EldDeviceManager.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-30.
//

import Foundation

class EldDeviceManager {

  static let shared = EldDeviceManager()

  var currentEldDataRecord: EldDataRecord?
  var currentEldFuelRecord: EldFuelRecord?
}
