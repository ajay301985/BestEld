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
    let imageFrame = graphImageView?.frameForImageInImageViewAspectFit()
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
      guard let startTime = dayData.startTimeStamp else {
        assertionFailure("In valid object")
        return
      }
      var endTime = dayData.endTimeStamp ?? Date()

      var yPosition = 75
      var xPosition = 0

      var currentColor: UIColor = .red
      let currentDutyStatus = DutyStatus(rawValue: dayData.dutyStatus)
      switch currentDutyStatus {
        case .OnDuty: //4
          print("ON Duty")
          yPosition = 170
          currentColor = .green
        case .OffDuty, .Yard, .Personal: // 1
          print("Off Duty")
          yPosition = 55
        case .Sleeper:  //2
          print("ON sleeper")
          yPosition = 85
          currentColor = .blue
        case .Driving:  //3
          print("ON Driving")
          yPosition = 120
          currentColor = .yellow
        default:
          currentColor = .black
          print("ON Duty")
      }

      let xPositionInGraph = imageXPosition(for: startTime)
      let startPoint = CGPoint(x: xPositionInGraph, y: yPosition)

      if (!lastPoint.equalTo(CGPoint.zero)) {
        drawLineFromPoint(start: lastPoint, toPoint: startPoint, ofColor: .orange, inView: currentImageView)
      }

      let xPositionInGraph1 = imageXPosition(for: endTime)
      let endPoint = CGPoint(x: xPositionInGraph1, y: yPosition)
      lastPoint = endPoint
      drawLineFromPoint(start: startPoint, toPoint: endPoint, ofColor: currentColor, inView: currentImageView)
    }
  }

  func imageXPosition(for inDate: Date) -> Int {
    var xPosition: CGFloat = 20.0
    let timeObj = BLDAppUtility.hourMinuteValues(for: inDate)
    let hours = timeObj.hour ?? 0
    let minute = timeObj.minute ?? 1
    let frameWidthObj = imageSize?.width ?? 120
    if (hours == 0) {
      xPosition = 20
    }else {
      let position = (hours * 4) + (minute/15)
      var frameWidth = (frameWidthObj/96)
     // frameWidth = (frameWidth * 1.12)
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
    shapeLayer.lineWidth = 1.0

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
