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

  func requestLocationAccess() {
    locationManager.requestAlwaysAuthorization()
    locationManager.delegate = self
    locationManager.distanceFilter = 1
    // 2
    //locationManager.allowsBackgroundLocationUpdates = true
    // 3
    locationManager.startUpdatingLocation()
    //startMonitoringVisits()
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

    return (placeName + ", " + placeLocality)
  }

}

extension BldLocationManager: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager,
                                didUpdateLocations locations: [CLLocation]) {

    currentLocation = locations.first
    guard  let validLocation = currentLocation else {
      assertionFailure("invalid location")
      return
    }
    BldLocationManager.geoCoder.reverseGeocodeLocation(validLocation ) { placemarks, _ in
      if let place = placemarks?.first {
        self.currentLocationPlacemark = place
//        print("\(place.administrativeArea)")
        print("\(place.name)")
        print("\(place.locality)")
//        print("\(place.subLocality)")
//        print("\(place.country)")
//        print("\(place.postalCode)")
      }
    }

  }

  /*
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
*/
}
