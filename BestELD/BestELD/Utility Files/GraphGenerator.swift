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
    return graphImageView?.frame.size
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
          yPosition = 190
          currentColor = .green
        case .OffDuty, .Yard, .Personal: // 1
          print("Off Duty")
          yPosition = 75
        case .Sleeper:  //2
          print("ON sleeper")
          yPosition = 115
          currentColor = .blue
        case .Driving:  //3
          print("ON Driving")
          yPosition = 140
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
    var xPosition: CGFloat = 0.0
    let timeObj = BLDAppUtility.hourMinuteValues(for: inDate)
    let hours = timeObj.hour ?? 0
    let minute = timeObj.minute ?? 1
    let frameWidthObj = imageSize?.width ?? 120
    if (hours == 0) {
      xPosition = 0
    }else {
      let position = (hours * 4) + (minute/15)
      let frameWidth = (frameWidthObj/96)
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
