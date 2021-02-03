//
//  BldLocationManager.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-22.
//

import Foundation
import CoreLocation

class BldLocationManager: NSObject  {

  static let shared = BldLocationManager()

  static let geoCoder = CLGeocoder()
  let locationManager = CLLocationManager()

  var currentLocation: CLLocation?
  var currentLocationPlacemark: CLPlacemark?
  var currentLocationVisit: CLVisit?

  func requestLocationAccess() {
    locationManager.requestAlwaysAuthorization()
    locationManager.delegate = self
    locationManager.distanceFilter = 35
    // 2
    //locationManager.allowsBackgroundLocationUpdates = true
    // 3
    locationManager.startMonitoringVisits()
    //locationManager.startUpdatingLocation()
  }

  func deviceCurrentLocation() -> CLLocation? {
    return currentLocation
  }

  var locationLatitute: CLLocationDegrees? {
    currentLocation?.coordinate.latitude
  }

  var locationLongitude: CLLocationDegrees? {
    currentLocation?.coordinate.longitude
  }

  var locationText: String {
    guard let placemark = currentLocationPlacemark, let placeName = placemark.name, let placeLocality = placemark.locality  else {
      return ""
    }

    return (placeName + placeLocality)
  }

}

extension BldLocationManager: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
    // create CLLocation from the coordinates of CLVisit
    currentLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
    guard  let validLocation = currentLocation else {
      assertionFailure("invalid location")
      return
    }
    BldLocationManager.geoCoder.reverseGeocodeLocation(validLocation ) { placemarks, _ in
      if let place = placemarks?.first {
        let description = "\(place)"
        print("\(place.administrativeArea)")
        print("\(place.name)")
        print("\(place.locality)")
        print("\(place.subLocality)")
        print("\(place.country)")
        print("\(place.postalCode)")
        self.newVisitReceived(visit, description: description)
      }
    }

    // Get location description
  }

  func newVisitReceived(_ visit: CLVisit, description: String) {
    //let location = Location(visit: visit, descriptionString: description)
    currentLocationVisit = visit
    // Save location to disk
  }
}
