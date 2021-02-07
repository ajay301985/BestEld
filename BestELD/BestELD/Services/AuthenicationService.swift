//
//  AuthenicationService.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-02-04.
//

import Foundation

class AuthenicationService {
  typealias loginResult = (Result<Driver?, Error>) -> Void
  typealias eldResult = (Result<Eld?, Error>) -> Void

  static let shared = AuthenicationService()

  let defaultSession = URLSession(configuration: .default)
  var dataTask: URLSessionDataTask?

  func loginUser(emailId: String, password: String, completion: @escaping loginResult) {
    dataTask?.cancel()

    let emailID1 = "pankajsunal66@gmail.com"
    let password1 = "Pankaj@123"

    let url = URL(string: "http://52.53.153.62:8080/api/driver/login")!
    var request = URLRequest(url: url)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    let parameters: [String: Any] = [
      "email": emailID1,
      "password": password1
    ]
    let data = try? JSONSerialization.data(withJSONObject: parameters, options: [])
    request.httpBody = data
    // 3
    dataTask = defaultSession.dataTask(with: request) { data, response, error in
      // 5
      if let error = error {
        print(error.localizedDescription)
      } else if let data = data,
        let response = response as? HTTPURLResponse,
        response.statusCode == 200
      {
        do {
          if let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
            print(jsonArray) // use the json here
            let userProfile = jsonArray["profile"] as? [String: Any]
            if let user = jsonArray["user"] as? [String: Any] {
              let idToken = user["idToken"] as? [String: Any]
              if let idjwtToken = idToken?["jwtToken"] as? String {
                BLDAppUtility.saveIdToken(token: idjwtToken)
              }

              let accessToken = user["accessToken"] as? [String: Any]
              if let accessjwtToken = accessToken?["jwtToken"] as? String {
                BLDAppUtility.saveAccessToken(token: accessjwtToken)
              }
            }
            DispatchQueue.main.async {
              let currentDriver = DataHandeler.shared.updateDriverData(driverDataJson: userProfile)
              completion(.success(currentDriver))
            }
          } else {
            print("bad json")
          }
        } catch let error as NSError {
          print(error)
          completion(.failure(error))
        }
      }
    }

    // 7
    dataTask?.resume()
  }


  func fetchUserLogbookData(user: String) {
    let tempMacAdd = "36.434.434.43"

    let url = URL(string: "http://52.53.153.62:8080/api/eld/getEld")!
    var request = URLRequest(url: url)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    let parameters: [String: Any] = [
      "macAddress": tempMacAdd
    ]
//    let data = try? JSONSerialization.data(withJSONObject: parameters, options: [])
//    request.httpBody = data

    let dayDataDict = BLDAppUtility.testDicData()
    DataHandeler.shared.updateDriverLogbookData(driverLogbookData: dayDataDict)
    // 3
//    dataTask = defaultSession.dataTask(with: request) { data, response, error in
//    }
    //dataTask?.resume()
  }


  func fetchEldData(macAdd: String, completion: @escaping eldResult) {
    dataTask?.cancel()

    let tempMacAdd = "36.434.434.43"

    let url = URL(string: "http://52.53.153.62:8080/api/eld/getEld")!
    var request = URLRequest(url: url)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    let parameters: [String: Any] = [
      "macAddress": tempMacAdd
    ]
    let data = try? JSONSerialization.data(withJSONObject: parameters, options: [])
    request.httpBody = data
    // 3
    dataTask = defaultSession.dataTask(with: request) { data, response, error in
      if let error = error {
        print(error.localizedDescription)
      } else if let data = data,
        let response = response as? HTTPURLResponse,
        response.statusCode == 200
      {
        do {
          if let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
            print(jsonArray) // use the json here
            let userProfile = jsonArray["eld"] as? [String: Any]
            DispatchQueue.main.async {
              let currentEld = DataHandeler.shared.updateEldData(eldDataJson: userProfile)
              completion(.success(currentEld))
            }
          } else {
            print("bad json")
          }
        } catch let error as NSError {
          print(error)
          completion(.failure(error))
        }
      }
    }
    dataTask?.resume()
  }
}