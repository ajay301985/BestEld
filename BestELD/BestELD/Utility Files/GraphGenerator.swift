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
    static let imageColumn = 96
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
    for dayData in dayDataArr {
      guard let startTimeObj = dayData.startTime else {
        assertionFailure("In valid object")
        return
      }
      let startTime = BLDAppUtility.timezoneDate(from: startTimeObj)

      guard let currentDateData = UserPreferences.shared.currentSelectedDayData else {
        return
      }

      let currentDateText = BLDAppUtility.textForDate(date: currentDateData.dateValue)
      let currentStartText = BLDAppUtility.textForDate(date: startTime)

      let endTimeObj = dayData.endTime ?? Date()
      let endTime = BLDAppUtility.timezoneDate(from: endTimeObj)
      var yPosition = 75
      var xPositionInGraph = imageXPosition(for: startTime)

      if (currentDateText != currentStartText) {
        let currentDateText1 = BLDAppUtility.textForDate(date: currentDateData.dateValue.dayBefore)
        if (currentDateText1 == currentStartText) {
          xPositionInGraph = 0 //start time is on previous day
        }
      }

      var currentColor: UIColor = .blue
  //    let currentDutyStatus = DutyStatus(rawValue: dayData.dutyStatus ?? "OFFDUTY")
      let currentDutyStatus = dayData.dutyStatus ?? "OFFDUTY"
      switch currentDutyStatus {
        case "ONDUTY", "YARD": //4
          print("ON Duty")
          yPosition = 165
          currentColor = .blue
        case "OFFDUTY", "PERSONAL": // 1
          print("Off Duty")
          yPosition = 61
        case "SLEEPER":  //2
          print("ON sleeper")
          yPosition = 100
          currentColor = .blue
        case "DRIVING":  //3
          print("ON Driving")
          yPosition = 135
          currentColor = .blue
        default:
          currentColor = .blue
          print("ON Duty")
      }
      /*
      switch currentDutyStatus {
        case .OnDuty, .Yard: //4
          print("ON Duty")
          yPosition = 155
          currentColor = .green
        case .OffDuty, .Personal: // 1
          print("Off Duty")
          yPosition = 61
        case .Sleeper:  //2
          print("ON sleeper")
          yPosition = 100
          currentColor = .blue
        case .Driving:  //3
          print("ON Driving")
          yPosition = 115
          currentColor = .yellow
        default:
          currentColor = .black
          print("ON Duty")
      } */


      let startPoint = CGPoint(x: xPositionInGraph, y: yPosition)

      if (!lastPoint.equalTo(CGPoint.zero)) {
        drawLineFromPoint(start: lastPoint, toPoint: startPoint, ofColor: .blue, inView: currentImageView)
      }

      let xPositionInGraph1 = imageXPosition(for: endTime)
      let endPoint = CGPoint(x: xPositionInGraph1, y: yPosition)
      lastPoint = endPoint
      drawLineFromPoint(start: startPoint, toPoint: endPoint, ofColor: currentColor, inView: currentImageView)
    }
  }

  func imageXPosition(for inDate: Date) -> Int {
    var xPosition: CGFloat = 0.0
    let timeObj = BLDAppUtility.hourMinuteValues(for: inDate)
    let hours = timeObj.hour ?? 0
    let minute = timeObj.minute ?? 1
    var frameWidthObj = (imageSize?.width ?? 120)
 //   frameWidthObj -= 40//20
    if (hours == 0) {
      xPosition = 0
    }else {
      let position = (hours * 4) + (minute/15)
      var frameWidth = (frameWidthObj/96)
      let finalPosition = CGFloat(position) * frameWidth
      xPosition = finalPosition
    }
    return Int(xPosition)
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
