//
//  AppDelegate.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-16.
//

import UIKit
import CoreData
import AWSCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.

    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    print(paths[0])
    let introStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let controller = introStoryboard.instantiateViewController(withIdentifier: "NavController")
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.backgroundColor = .red
    window?.rootViewController = controller
    window?.makeKeyAndVisible()

    BldLocationManager.shared.requestLocationAccess()
////ap-south-1_intkrexXe")//ap-south-1_
    
    let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USWest1, identityPoolId: "us-west-1_Mu9qLOLFG") //us-west-1_Mu9qLOLFG
    let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
    AWSServiceManager.default().defaultServiceConfiguration = configuration


    //For cognito ap-south-1
    //For amplify us-west-2
    //For SQS us-west-1
    return true
  }

  // MARK: - Core Data stack

  lazy var persistentContainer: NSPersistentContainer = {
      /*
       The persistent container for the application. This implementation
       creates and returns a container, having loaded the store for the
       application to it. This property is optional since there are legitimate
       error conditions that could cause the creation of the store to fail.
      */
      let container = NSPersistentContainer(name: "BestELD")
      container.loadPersistentStores(completionHandler: { (storeDescription, error) in
          if let error = error as NSError? {
              // Replace this implementation with code to handle the error appropriately.
              // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
               
              /*
               Typical reasons for an error here include:
               * The parent directory does not exist, cannot be created, or disallows writing.
               * The persistent store is not accessible, due to permissions or data protection when the device is locked.
               * The device is out of space.
               * The store could not be migrated to the current model version.
               Check the error message to determine what the actual problem was.
               */
              fatalError("Unresolved error \(error), \(error.userInfo)")
          }
      })
      return container
  }()

  // MARK: - Core Data Saving support

  func saveContext () {
      let context = persistentContainer.viewContext
      if context.hasChanges {
          do {
              try context.save()
          } catch {
              // Replace this implementation with code to handle the error appropriately.
              // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
              let nserror = error as NSError
              fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
          }
      }
  }

}

