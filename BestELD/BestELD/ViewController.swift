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
  @IBOutlet weak var userEmailTextField: UITextField!
  @IBOutlet weak var userPasswordTextField: UITextField!

  var viewModel = ViewViewModel()
  var selectedMenuItemIndex = 0
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.isHidden = true

    addItemSQS()
    userEmailTextField.applyBottomBorder()
    userPasswordTextField.applyBottomBorder()
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
  @IBAction func loginClicked(_ sender: Any) {
    #warning("Aj temporary disable")
/*    AuthenicationService.shared.loginUser(emailId: "userEmail", password: "userPassword") { [weak self] result in
      guard let self = self else { return }
      switch result {
        case .success(let driverObj):
          print("dddd")
        case .failure(_):
          print("ddd")
      }

      }
     */
    guard let userEmail = userEmailTextField.text, let userPassword = userPasswordTextField.text else {
      showDefaultAlert(title: "Error", message: "Email and password should not be empty", handler: nil)
      return
    }
    if (!isValidEmail(userEmail) || userPassword.count < 5) {
      showDefaultAlert(title: "Error", message: "User email and password is not valid", handler: nil)
      return
    }
    AuthenicationService.shared.loginUser(emailId: userEmail, password: userPassword) { [weak self] result in
      guard let self = self else { return }
      switch result {
        case .success(let driverObj):
          guard let driver = driverObj, let dlNumber = driverObj?.dlNumber else {
            return
          }
          DispatchQueue.main.async {
            DataHandeler.shared.setupData(for: dlNumber)
            self.loggedIn(user: driver)
          }
        case .failure(let error):
          print(error.localizedDescription)
          DispatchQueue.main.async {
            self.showDefaultAlert(title: "Error", message: error.localizedDescription, handler: nil)
          }
      }
    }
}

  private func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
  }

  @IBAction func showExtraOptions(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let menuViewControllerObj =  storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
    let menuItems = BLDAppUtility.menuItems(loggedInUser: false)
    menuViewControllerObj.setup(menuItemArr: menuItems, selectedIndex: selectedMenuItemIndex)
    menuViewControllerObj.didSelectMenuItem = { [weak self] selectMenuItem, itemIndex in
      self?.selectedMenuItemIndex = itemIndex
      self?.itemDidSelect(index: itemIndex)
    }
    menuViewControllerObj.modalPresentationStyle = .overCurrentContext
    present(menuViewControllerObj, animated: true, completion: nil)
  }


  func itemDidSelect(index: Int) {
    switch index {
      case 0:
        showDefaultAlert(title: "Alert", message: "Work in progress", handler: nil)
      case 1:
        loggedInAsATestUser()
      case 2:
        showDefaultAlert(title: "Alert", message: "Work in progress", handler: nil)
      case 3:
        showDefaultAlert(title: "Alert", message: "Only available for logged in users", handler: nil)
      case 4:
        showDefaultAlert(title: "Alert", message: "Only available for logged in users", handler: nil)
      case 5:
        showDefaultAlert(title: "Alert", message: "Only available for logged in users", handler: nil)
      case 6:
        showDefaultAlert(title: "Alert", message: "Only available for logged in users", handler: nil)
      case 7:
        showDefaultAlert(title: "Alert", message: "Only available for logged in users", handler: nil)
      case 8:
        showDefaultAlert(title: "Alert", message: "Only available for logged in users", handler: nil)

      default:
        print("default")
    }
  }

  func loggedInAsATestUser() {
    addItemSQS()
    DataHandeler.shared.cleanupData(for: testDriverDLNumber) //clean up existing data

    var currentDriver = DataHandeler.shared.getDriverData(for: testDriverDLNumber)
    if (currentDriver == nil) {
      currentDriver = DataHandeler.shared.createTestDriverData()
    }
    DataHandeler.shared.setupData(for: testDriverDLNumber)
    loggedIn(user: DataHandeler.shared.currentDriver)
/*    var driverMetaData = DataHandeler.shared.userDayMetaData(dayStart: Date(), driverDL: currentDriver?.dlNumber ?? testDriverDLNumber)
    if ((driverMetaData == nil)) {
      driverMetaData = DataHandeler.shared.createTestUserMetaData(for: currentDriver?.dlNumber ?? testDriverDLNumber, data: Date())
    }
    guard  let driver = currentDriver, let metaData = driverMetaData else {
      assertionFailure("failed to create objects")
      return
    }

    DataHandeler.shared.currentDriver = driver
    let bookViewModel = LogBookViewModel(driver: driver, metaData: [metaData])
    let logBookViewController = viewModel.logBookStoryboardInstance()
    logBookViewController.setViewModel(dataViewModel: bookViewModel)
    navigationController?.pushViewController(logBookViewController, animated: true) */
  }


  func loggedIn(user: Driver) {
    var driverMetaData = DataHandeler.shared.userDayMetaData(dayStart: Date(), driverDL: user.dlNumber ?? testDriverDLNumber)
    if ((driverMetaData == nil)) {
      driverMetaData = DataHandeler.shared.createTestUserMetaData(for: user.dlNumber ?? testDriverDLNumber, data: Date())
    }
    guard  let metaData = driverMetaData else {
      assertionFailure("failed to create objects")
      return
    }

    let bookViewModel = LogBookViewModel(driver: user, metaData: [metaData])
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

