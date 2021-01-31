//
//  ViewController.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-16.
//

import UIKit
import AWSDynamoDB
import Amplify
import AmplifyPlugins
import AWSSQS

class ViewController: UIViewController {

  @IBOutlet weak var loginLabel: UILabel!

  var viewModel = ViewViewModel()
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.isHidden = true

    addItemSQS()
    //configureAmplify()
    // Do any additional setup after loading the view.
  }

  func addItemSQS() {
    let sqs = AWSSQS.default()
    let req = AWSSQSSendMessageRequest()
    req?.queueUrl = "https://sqs.us-west-1.amazonaws.com/025273162973/bestsqsqueue"
      //"https://sqs.us-west-1.amazonaws.com/025273162973/fifosqsqueue.fifo"
      //"https://sqs.us-west-1.amazonaws.com/025273162973/bestsqsqueue"
    //https://sqs.us-west-1.amazonaws.com/025273162973/bestsqsqueue"
    req?.messageBody = """
{
    "Id": 1,
    "MessageBody": {
      "Id": 1,
      "DL_Number": "ddjjdd",
    },
  }
"""
    sqs.sendMessage(req!) { (result, err) in
      if let result = result {
        print("SQS result: \(result)")
      }
      if let err = err {
        print("SQS error: \(err)")
      }
    }
  }

  private func saveEldDataToServer() {
    let item = Todo(name: "Build iOS Application",
                    description: "Build an iOS application using Amplify")
    Amplify.DataStore.save(item) { result in
      switch(result) {
        case .success(let savedItem):
          print("Saved item: \(savedItem.name)")
        case .failure(let error):
          print("Could not save item to datastore: \(error)")
      }
    }
  }

  private func configureAmplify() {
    let dataStorePlugin = AWSDataStorePlugin(modelRegistration: AmplifyModels())
    do {
      try Amplify.add(plugin: dataStorePlugin)
      try Amplify.configure()
      print("Initialized Amplify");
    } catch {
      // simplified error handling for the tutorial
      print("Could not initialize Amplify: \(error)")
    }
  }

  override func viewWillAppear(_ animated: Bool) {
  }

  @IBAction func showExtraOptions(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let menuViewControllerObj =  storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
    let menuItems = BLDAppUtility.menuItems(loggedInUser: false)
    menuViewControllerObj.setup(menuItemArr: menuItems)
    menuViewControllerObj.didSelectMenuItem = { [weak self] selectMenuItem, itemIndex in
      self?.loggedInAsATestUser()
    }
    menuViewControllerObj.modalPresentationStyle = .overCurrentContext
    present(menuViewControllerObj, animated: true, completion: nil)
  }

  func loggedInAsATestUser() {

    addItemSQS()
    DataHandeler.shared.setupData(for: "xyz12345")
    var currentDriver = DataHandeler.shared.currentDriver
    DataHandeler.shared.cleanupData(for: "xyz12345") //clean up existing data
    if (currentDriver == nil) {
      currentDriver = DataHandeler.shared.createTestDriverData()
    }
    var driverMetaData = DataHandeler.shared.userDayMetaData(dayStart: Date(), driverDL: currentDriver?.dlNumber ?? "xyz12345")
    if ((driverMetaData == nil)) {
      driverMetaData = DataHandeler.shared.createTestUserMetaData(for: "xyz12345", data: Date())
    }
    guard  let driver = currentDriver, let metaData = driverMetaData else {
      assertionFailure("failed to create objects")
      return
    }
    DataHandeler.shared.currentDriver = driver
    let bookViewModel = LogBookViewModel(driver: driver, metaData: [metaData])
    let logBookViewController = viewModel.logBookStoryboardInstance()
    logBookViewController.setViewModel(dataViewModel: bookViewModel)
    navigationController?.pushViewController(logBookViewController, animated: true)
  }


  func setupDynamoDB() {
    let DynamoDB = AWSDynamoDB.default()
    let updateInput = AWSDynamoDBUpdateItemInput()

    let hashKeyValue = AWSDynamoDBAttributeValue()
    hashKeyValue?.s = "4567890123"

    updateInput?.tableName = "Books"
    updateInput?.key = ["ISBN": hashKeyValue!]

    let oldPrice = AWSDynamoDBAttributeValue()
    oldPrice?.n = "999"

    let expectedValue = AWSDynamoDBExpectedAttributeValue()
    expectedValue?.value = oldPrice

    let newPrice = AWSDynamoDBAttributeValue()
    newPrice?.n = "1199"

    let valueUpdate = AWSDynamoDBAttributeValueUpdate()
    valueUpdate?.value = newPrice
    valueUpdate?.action = .put

    updateInput?.attributeUpdates = ["Price": valueUpdate!]
    updateInput?.expected = ["Price": expectedValue!]
    updateInput?.returnValues = .updatedNew

    DynamoDB.updateItem(updateInput!).continueWith { (task:AWSTask<AWSDynamoDBUpdateItemOutput>) -> Any? in
      if let error = task.error as? NSError {
        print("The request failed. Error: \(error)")
        return nil
      }

      // Do something with task.result

      return nil
    }
  }

  
}

