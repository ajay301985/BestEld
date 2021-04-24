//
//  GraphGenerator.swift
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-24.
//

import Foundation
import UIKit




class GraphGenerator {

  struct imageConstants {
    static let imageColumn = 95
    static let imageRow = 4
  }

  static let shared = GraphGenerator()

  var graphImageView: UIImageView?


  var imageSize: CGSize? {
    let imageFrame = graphImageView?.frame //frameForImageInImageViewAspectFit()
    return imageFrame?.size
  }

  func setupImageView(imageView: UIImageView) {
    graphImageView = imageView
  }

  func generatePath(imageView: UIImageView? = nil, dayDataArr: [DayData]) {
    guard let currentImageView = graphImageView else {
      assertionFailure("invalid image object")
      return
    }

    if let layerArr = currentImageView.layer.sublayers {
      for layers in layerArr {
        layers.removeFromSuperlayer()
      }
    }

    var lastPoint: CGPoint = CGPoint.zero
    var currentIndex = 0
    for dayData in dayDataArr {
      guard let startTimeObj = dayData.startTime else {
        assertionFailure("In valid object")
        return
      }
//      let startTime = BLDAppUtility.timezoneDate(from: startTimeObj)

      guard let currentDateData = UserPreferences.shared.currentSelectedDayData else {
        return
      }

//      let currentDateText = BLDAppUtility.textForDate(date: currentDateData.dateValue)
//      let currentStartText = BLDAppUtility.textForDate(date: startTime)

      let endTimeObj = dayData.endTime ?? Date()
//      let endTime = BLDAppUtility.timezoneDate(from: endTimeObj)
//      let currentEndText = BLDAppUtility.textForDate(date: endTime)
      var yPosition: CGFloat = 75
      let xPositionInGraph = imageXPosition(for: startTimeObj)

/*      if (currentDateText != currentStartText) {
        let currentDateText1 = BLDAppUtility.textForDate(date: currentDateData.dateValue.dayBefore)
        if (currentDateText1 == currentStartText) {
          xPositionInGraph = 0 //start time is on previous day
        }
      } */

      let currentColor: UIColor = .blue
      let currentDutyStatus = DutyStatus(rawValue: dayData.dutyStatus ?? "OFFDUTY")
      switch currentDutyStatus {
        case .ONDUTY, .YARD: //4
          yPosition = 165
        case .OFFDUTY, .PERSONAL: // 1
          yPosition = 61
        case .SLEEPER:  //2
          yPosition = 100
        case .DRIVING:  //3
          yPosition = 135
        default:
          print("ON Duty")
      }

      var startPoint = CGPoint(x: xPositionInGraph, y: yPosition)
      let startTimeInterval = startTimeObj.timeIntervalSince1970
      if startTimeInterval < dayData.day {
        startPoint.x = 0
      }

      if (!lastPoint.equalTo(CGPoint.zero)) {
        drawLineFromPoint(start: lastPoint, toPoint: startPoint, ofColor: .blue, inView: currentImageView)
      }

      let xPositionInGraph1 = imageXPosition(for: endTimeObj)
      let endTimeInterval = endTimeObj.timeIntervalSince1970
      var endPoint = CGPoint(x: xPositionInGraph1, y: yPosition)
      let dayTimeInterval = TimeInterval(60 * 60 * 24 * 1)
      if dayData.day > 0 {
        if endTimeInterval > (dayData.day + dayTimeInterval) {
          endPoint.x = imageSize?.width ?? 120
        }
      }
      /*if endPoint.x < startPoint.x {
        if currentIndex == 0 {
          startPoint.x = 0
        } else {
          endPoint.x = imageSize?.width ?? 120
        }
      }
      if endPoint.x == startPoint.x { //Assuming this is the last event
        if currentIndex == (dayDataArr.count - 1) {
          endPoint.x = imageSize?.width ?? 120
        }
      }*/
      lastPoint = endPoint
      drawLineFromPoint(start: startPoint, toPoint: endPoint, ofColor: currentColor, inView: currentImageView)
      currentIndex += 1
    }
  }

  func imageXPosition(for inDate: Date) -> CGFloat {
    var xPosition: CGFloat = 0.0
   // let timeObj = BLDAppUtility.hourMinuteValues(for: inDate)
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: UserPreferences.shared.currentTimeZone)!
    let timeObj=calendar.dateComponents([.hour,.minute,.second], from: inDate)
    print("\(timeObj.hour!):\(timeObj.minute!):\(timeObj.second!)")

    let hours = timeObj.hour ?? 0
    let minute = timeObj.minute ?? 1
    let frameWidthObj = (imageSize?.width ?? 120)
    let position = (hours * 4) + (minute/15)
    let frameWidth = (frameWidthObj/95)
    let finalPosition = CGFloat(position) * frameWidth
    xPosition = finalPosition
    return xPosition
  }

  func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, inView view:UIView) {

    //design the path
    let path = UIBezierPath()
    path.move(to: start)
    path.addLine(to: end)

    //design path in layer
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = path.cgPath
    shapeLayer.strokeColor = lineColor.cgColor
    shapeLayer.lineWidth = 1.3

    view.layer.addSublayer(shapeLayer)
  }

}


extension UIImageView{
  func frameForImageInImageViewAspectFit() -> CGRect
  {
    if  let img = self.image {
      let imageRatio = img.size.width / img.size.height;

      let viewRatio = self.frame.size.width / self.frame.size.height;

      if(imageRatio < viewRatio)
      {
        let scale = self.frame.size.height / img.size.height;

        let width = scale * img.size.width;

        let topLeftX = (self.frame.size.width - width) * 0.5;

        return CGRect(x: topLeftX, y: 0, width: width, height: self.frame.size.height);
      }
      else
      {
        let scale = self.frame.size.width / img.size.width;

        let height = scale * img.size.height;

        let topLeftY = (self.frame.size.height - height) * 0.5;

        return CGRect(x: 0, y: topLeftY, width: self.frame.size.width, height: height);
      }
    }

    return CGRect(x: 0, y: 0, width: 0, height: 0)
  }
}
