//
//  DriverApiRepository.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-17.
//

import Foundation

class DriverApiRepository {

  private init() {}
  static let shared = DriverApiRepository()

  private let urlSession = URLSession.shared
  private let baseURL = URL(string: "https://swapi.co/api/")!

  func getFilms(completion: @escaping(_ filmsDict: [[String: Any]]?, _ error: Error?) -> ()) {
    let filmURL = baseURL.appendingPathComponent("films")
    urlSession.dataTask(with: filmURL) { (data, response, error) in
      if let error = error {
        completion(nil, error)
        return
      }

      guard let data = data else {
        //let error = NSError(domain: dataErrorDomain, code: DataErrorCode.networkUnavailable.rawValue, userInfo: nil)
        completion(nil, nil)
        return
      }

      do {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let jsonDictionary = jsonObject as? [String: Any], let result = jsonDictionary["results"] as? [[String: Any]] else {
          //throw NSError(domain: dataErrorDomain, code: DataErrorCode.wrongDataFormat.rawValue, userInfo: nil)
          return
        }
        completion(result, nil)
      } catch {
        completion(nil, error)
      }
    }.resume()
  }

}
