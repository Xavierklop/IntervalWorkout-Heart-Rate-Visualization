//
//  HeartRateDetailController.swift
//  IntervalWorkout WatchKit Extension
//
//  Created by Hao Wu on 2017/11/20.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import Foundation
import WatchKit
import HealthKit
import SpriteKit

class HeartRateDetailInterfaceController: WKInterfaceController {
  
  private let userHealthProfile = UserHealthProfile()
  
  @IBOutlet var currentHeartRateLabel: WKInterfaceLabel!
  @IBOutlet var skInterface: WKInterfaceSKScene!
  
  var scene: GameScene!
  private var seconds = 0
  private var timer: Timer?
  // MARK: test for current HR datas
  var heartRateDatasArray = [Int]()
  var points = [CGPoint]()
  var hrDataSamples = [Int]()
  // MARK: test 递加心率
  var a = 0
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    scene = GameScene(size: contentFrame.size)
    skInterface.presentScene(scene)
    skInterface.preferredFramesPerSecond = 30
    
    
  }
  
  override func didAppear() {
    updateDisplay()
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      self.eachSecond()
    }
    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
      self.updateChart()
    }
    timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
      self.updateMaxMinMeanValue()
    }
  }
  
  
  
  private func updateDisplay() {
    // Use HealthKit to create the Heart Rate Sample Type
    guard let heartRateSampleType = HKSampleType.quantityType(forIdentifier: .heartRate) else {
      print("Heart rate Sample Type is no longer available in HealthKit")
      return
    }
    
    ProfileDataStore.getMostRecentSample(for: heartRateSampleType) { (sample, error) in
      guard let sample = sample else {
        if let error = error {
          self.displayAlert(for: error)
        }
        return
      }
      
      self.loadRestingHeartRate()
      guard let restingHeartRate = self.userHealthProfile.restingHeartRate else {
        if let error = error {
          self.displayAlert(for: error)
        }
        return
      }
      
      let currentHeartRate = sample.quantity.doubleValue(for: hrUnit)
      // MARK: test 递加心率
      let currentHeartRateInt = Int(currentHeartRate) + self.a
//      let currentHeartRateInt = Int(currentHeartRate)
      let cHRInString = String(currentHeartRateInt)
      
      self.loadAgeAndBiologicalSex()
      if let age = self.userHealthProfile.age {
        let doubleAge = Double(age)
        let maxHeartRate = 206.9 - doubleAge*0.67
        // MARK: test 递增心率
        let value = (Double(currentHeartRateInt) - restingHeartRate)/(maxHeartRate - restingHeartRate)
//        let value = currentHeartRate/maxHeartRate
        
        // set and display the text, heart image
        if value < 0.6 {
          self.currentHeartRateLabel.setTextColor(UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1.0))
          self.currentHeartRateLabel.setText(cHRInString + " bpm")
          let index = CGFloat(1)
          let actionMove = SKAction.move(to: CGPoint(x: self.scene.size.width*0.1*index, y:self.scene.size.height*0.9 ), duration: TimeInterval(1.0))
          self.scene.heart.run(actionMove)
          self.scene.heart.color = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1.0)
          self.scene.heart.colorBlendFactor = 1
        }else if value < 0.7 {
          self.currentHeartRateLabel.setTextColor(UIColor(red: 79/255, green: 176/255, blue: 240/255, alpha: 1.0))
          self.currentHeartRateLabel.setText(cHRInString + " bpm")
          let index = CGFloat(3)
          let actionMove = SKAction.move(to: CGPoint(x: self.scene.size.width*0.1*index, y:self.scene.size.height*0.9 ), duration: TimeInterval(1.0))
          self.scene.heart.run(actionMove)
          self.scene.heart.color = UIColor(red: 79/255, green: 176/255, blue: 240/255, alpha: 1.0)
          self.scene.heart.colorBlendFactor = 1
        }else if value < 0.8 {
          self.currentHeartRateLabel.setTextColor(UIColor(red: 146/255, green: 208/255, blue: 80/255, alpha: 1.0))
          self.currentHeartRateLabel.setText(cHRInString + " bpm")
          let index = CGFloat(5)
          let actionMove = SKAction.move(to: CGPoint(x: self.scene.size.width*0.1*index, y:self.scene.size.height*0.9 ), duration: TimeInterval(1.0))
          self.scene.heart.run(actionMove)
          self.scene.heart.color = UIColor(red: 146/255, green: 208/255, blue: 80/255, alpha: 1.0)
          self.scene.heart.colorBlendFactor = 1
        }else if value < 0.9 {
          self.currentHeartRateLabel.setTextColor(UIColor(red: 241/255, green: 148/255, blue: 51/255, alpha: 1.0))
          self.currentHeartRateLabel.setText(cHRInString + " bpm")
          let index = CGFloat(7)
          let actionMove = SKAction.move(to: CGPoint(x: self.scene.size.width*0.1*index, y:self.scene.size.height*0.9 ), duration: TimeInterval(1.0))
          self.scene.heart.run(actionMove)
          self.scene.heart.color = UIColor(red: 241/255, green: 148/255, blue: 51/255, alpha: 1.0)
          self.scene.heart.colorBlendFactor = 1
        }else {
          self.currentHeartRateLabel.setTextColor(UIColor(red: 233/255, green: 65/255, blue: 51/255, alpha: 1.0))
          self.currentHeartRateLabel.setText(cHRInString + " bpm")
          let index = CGFloat(9)
          let actionMove = SKAction.move(to: CGPoint(x: self.scene.size.width*0.1*index, y:self.scene.size.height*0.9 ), duration: TimeInterval(1.0))
          self.scene.heart.run(actionMove)
          self.scene.heart.color = UIColor(red: 233/255, green: 65/255, blue: 51/255, alpha: 1.0)
          self.scene.heart.colorBlendFactor = 1
        }
        
        // MARK: heart rate array add members
        print("current heart rate is ", currentHeartRateInt)
        self.heartRateDatasArray.append(currentHeartRateInt)
        print("heartRateDatasArray is ", self.heartRateDatasArray)

      }
    }
  }
  
  private func loadRestingHeartRate() {
    
    //1. Use HealthKit to create the Resting Heart Rate Sample Type
    guard let restingHeartRateSampleType = HKSampleType.quantityType(forIdentifier: .restingHeartRate) else {
      print("Resting Heart Rate Sample Type is no longer available in HealthKit")
      return
    }
    
    ProfileDataStore.getMostRecentSample(for: restingHeartRateSampleType) { (sample, error) in
      
      guard let sample = sample else {
        if let error = error {
          self.displayAlert(for: error)
        }
        return
      }
      let restingHeartRate = sample.quantity.doubleValue(for: hrUnit)
      self.userHealthProfile.restingHeartRate = restingHeartRate
    }
  }
  
  private func updateMaxMinMeanValue() {
    if let maxHR = self.heartRateDatasArray.max(), let minHR = self.heartRateDatasArray.min() {
      print("now maxHR is ", maxHR, " minHR is ", minHR)
      let max = SKLabelNode(fontNamed: "AppleSDGothicNeo-Thin")
      max.text = String(maxHR)
      max.fontSize = 8
      max.fontColor = SKColor.lightGray
      max.position = CGPoint(x: self.scene.size.width*0.95, y: self.scene.size.height*0.8)
      self.scene.addChild(max)
      let min = SKLabelNode(fontNamed: "AppleSDGothicNeo-Thin")
      min.text = String(minHR)
      min.fontSize = 8
      min.fontColor = SKColor.lightGray
      min.position = CGPoint(x: self.scene.size.width*0.95, y: self.scene.size.height*0.3)
      self.scene.addChild(min)
      
      let meanValue = (maxHR+minHR)/2
      let mean = SKLabelNode(fontNamed: "AppleSDGothicNeo-UltraLight")
      mean.text = String(meanValue)
      mean.fontSize = 8
      mean.fontColor = SKColor.white
      mean.position = CGPoint(x: self.scene.size.width*0.95, y: self.scene.size.height*0.525)
      self.scene.addChild(mean)

      var points = [CGPoint(x: 0, y: self.scene.size.height*0.55),
                    CGPoint(x: self.scene.size.width*0.9, y: self.scene.size.height*0.55)]
      let linearShapeNode = SKShapeNode(points: &points, count: points.count)
      linearShapeNode.strokeColor = .gray
      self.scene.addChild(linearShapeNode)
      
      DispatchQueue.main.asyncAfter(deadline: .now()+0.4, execute:{
        max.removeFromParent()
        min.removeFromParent()
        mean.removeFromParent()
      })
    }
  }
  
  private func updateChart() {
    getChartPoints()
    // MARK: test
    print("Number of poins is ", points.count)
    print("points are ",points)
    
    let splineShapeNode = SKShapeNode(splinePoints: &points, count: points.count)
    splineShapeNode.strokeColor = .red
    splineShapeNode.lineWidth = 3.0
    self.scene.addChild(splineShapeNode)
    // MARK: 可能要调参数，因为图标显示有间隔，不好！but 0.49 seems good!!
    DispatchQueue.main.asyncAfter(deadline: .now()+0.49, execute:{
        splineShapeNode.removeFromParent()
    })
  }
  
  private func getChartPoints() {
    let scaleY = self.scene.size.height*0.5
    let baseY = self.scene.size.height*0.3
    let baseX = self.scene.size.width
    
    if self.heartRateDatasArray.count < 10 {
      if points.count > 0 {
        points.removeAll()
      }
      let point = CGPoint(x: 0, y: baseY)
      // points.count = 1
      points.append(point)
      
    }else if self.heartRateDatasArray.count > 9 && self.heartRateDatasArray.count < 15 {
      if hrDataSamples.count > 0 {
        hrDataSamples.removeAll()
      }
      // hrDateSamples.count = 2
      let hr5 = self.heartRateDatasArray[4]
      let hr10 = self.heartRateDatasArray[9]
      hrDataSamples = [hr5, hr10]
      // test
      print("hrDSs should be 2, now is ", hrDataSamples.count)
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          points.removeAll()
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05, y: y2)
          points = [point1, point2]
          // test
          print("1 nr of points should be 2, now it is", points.count)
        }else {
          let point = CGPoint(x: baseX*0.05, y: scaleY)
          // points.count = 2
          if points.count > 1{
            points.removeFirst(1)
          }
            // MARK: test do not display two points chart
          points.append(point)
          // test
          print("2 nr of points should be 2, now it is", points.count)
        }
      }
      
    }else if self.heartRateDatasArray.count > 14 && self.heartRateDatasArray.count < 20 {
      let hr15 = self.heartRateDatasArray[14]
      // hrDateSamples.count = 3
      if hrDataSamples.count > 2 {
        hrDataSamples.removeLast()
      }
      hrDataSamples.append(hr15)
      // test
      print("hrDSs should be 3, now is ", hrDataSamples.count)
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          points.removeAll()
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05, y: y2)
          let d3 = CGFloat(hrDataSamples[2] - min)/diffValue
          let y3 = scaleY*CGFloat(d3) + baseY
          let point3 = CGPoint(x: baseX*0.1, y: y3)
          points = [point1, point2, point3]
          // test
          print("1 nr of points should be 3, now it is", points.count)
        }else {
          let point = CGPoint(x: baseX*0.1, y: scaleY)
          // points.count = 3
          if points.count > 2{
            points.removeLast()
          }
          points.append(point)
          // test
          print("2 nr of points should be 3, now it is", points.count)
        }
      }
      
    }
      else if self.heartRateDatasArray.count > 19 && self.heartRateDatasArray.count < 25 {
      let hr20 = self.heartRateDatasArray[19]
      // hrDateSamples.count = 4
      if hrDataSamples.count > 3 {
        hrDataSamples.removeLast()
      }
      hrDataSamples.append(hr20)
      // test
      print("hrDSs should be 4, now is ", hrDataSamples.count)
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          points.removeAll()
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05, y: y2)
          let d3 = CGFloat(hrDataSamples[2] - min)/diffValue
          let y3 = scaleY*CGFloat(d3) + baseY
          let point3 = CGPoint(x: baseX*0.1, y: y3)
          let d4 = CGFloat(hrDataSamples[3] - min)/diffValue
          let y4 = scaleY*CGFloat(d4) + baseY
          let point4 = CGPoint(x: baseX*0.15, y: y4)
          points = [point1, point2, point3, point4]
          // test
          print("1 nr of points should be 4, now it is", points.count)
        }else {
          let point = CGPoint(x: baseX*0.15, y: scaleY)
          // points.count = 4
          if points.count > 3{
            points.removeLast()
          }
          points.append(point)
          // test
          print("2 nr of points should be 4, now it is", points.count)
        }
      }

    }else if self.heartRateDatasArray.count > 24 && self.heartRateDatasArray.count < 30 {
      let hr25 = self.heartRateDatasArray[24]
      // hrDateSamples.count = 5
      if hrDataSamples.count > 4 {
        hrDataSamples.removeLast()
      }
      hrDataSamples.append(hr25)
      // test
      print("hrDSs should be 5, now is ", hrDataSamples.count)
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          points.removeAll()
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05, y: y2)
          let d3 = CGFloat(hrDataSamples[2] - min)/diffValue
          let y3 = scaleY*CGFloat(d3) + baseY
          let point3 = CGPoint(x: baseX*0.1, y: y3)
          let d4 = CGFloat(hrDataSamples[3] - min)/diffValue
          let y4 = scaleY*CGFloat(d4) + baseY
          let point4 = CGPoint(x: baseX*0.15, y: y4)
          let d5 = CGFloat(hrDataSamples[4] - min)/diffValue
          let y5 = scaleY*CGFloat(d5) + baseY
          let point5 = CGPoint(x: baseX*0.2, y: y5)
          points = [point1, point2, point3, point4, point5]
          // test
          print("1 nr of points should be 5, now it is", points.count)
        }else {
          let point = CGPoint(x: baseX*0.2, y: scaleY)
          // points.count = 5
          if points.count > 4{
            points.removeLast()
          }
          points.append(point)
          // test
          print("2 nr of points should be 5, now it is", points.count)
        }
      }
      
    }else if self.heartRateDatasArray.count > 29 && self.heartRateDatasArray.count < 35 {
      let hr30 = self.heartRateDatasArray[29]
      // hrDateSamples.count = 6
      if hrDataSamples.count > 5 {
        hrDataSamples.removeLast()
      }
      hrDataSamples.append(hr30)
      // test
      print("hrDSs should be 6, now is ", hrDataSamples.count)
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          points.removeAll()
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05, y: y2)
          let d3 = CGFloat(hrDataSamples[2] - min)/diffValue
          let y3 = scaleY*CGFloat(d3) + baseY
          let point3 = CGPoint(x: baseX*0.1, y: y3)
          let d4 = CGFloat(hrDataSamples[3] - min)/diffValue
          let y4 = scaleY*CGFloat(d4) + baseY
          let point4 = CGPoint(x: baseX*0.15, y: y4)
          let d5 = CGFloat(hrDataSamples[4] - min)/diffValue
          let y5 = scaleY*CGFloat(d5) + baseY
          let point5 = CGPoint(x: baseX*0.2, y: y5)
          let d6 = CGFloat(hrDataSamples[5] - min)/diffValue
          let y6 = scaleY*CGFloat(d6) + baseY
          let point6 = CGPoint(x: baseX*0.25, y: y6)
          points = [point1, point2, point3, point4, point5, point6]
          // test
          print("1 nr of points should be 6, now it is", points.count)
        }else {
          let point = CGPoint(x: baseX*0.25, y: scaleY)
          // points.count = 6
          if points.count > 5{
            points.removeLast()
          }
          points.append(point)
          // test
          print("2 nr of points should be 6, now it is", points.count)
        }
      }
      
    }else if self.heartRateDatasArray.count > 34 && self.heartRateDatasArray.count < 40 {
      let hr35 = self.heartRateDatasArray[34]
      // hrDateSamples.count = 7
      if hrDataSamples.count > 6 {
        hrDataSamples.removeLast()
      }
      hrDataSamples.append(hr35)
      // test
      print("hrDSs should be 7, now is ", hrDataSamples.count)
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          points.removeAll()
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05, y: y2)
          let d3 = CGFloat(hrDataSamples[2] - min)/diffValue
          let y3 = scaleY*CGFloat(d3) + baseY
          let point3 = CGPoint(x: baseX*0.1, y: y3)
          let d4 = CGFloat(hrDataSamples[3] - min)/diffValue
          let y4 = scaleY*CGFloat(d4) + baseY
          let point4 = CGPoint(x: baseX*0.15, y: y4)
          let d5 = CGFloat(hrDataSamples[4] - min)/diffValue
          let y5 = scaleY*CGFloat(d5) + baseY
          let point5 = CGPoint(x: baseX*0.2, y: y5)
          let d6 = CGFloat(hrDataSamples[5] - min)/diffValue
          let y6 = scaleY*CGFloat(d6) + baseY
          let point6 = CGPoint(x: baseX*0.25, y: y6)
          let d7 = CGFloat(hrDataSamples[6] - min)/diffValue
          let y7 = scaleY*CGFloat(d7) + baseY
          let point7 = CGPoint(x: baseX*0.3, y: y7)
          points = [point1, point2, point3, point4, point5, point6, point7]
          // test
          print("1 nr of points should be 7, now it is", points.count)
        }else {
          let point = CGPoint(x: baseX*0.3, y: scaleY)
          // points.count = 7
          if points.count > 6{
            points.removeLast()
          }
          points.append(point)
          // test
          print("2 nr of points should be 7, now it is", points.count)
        }
      }
      
    }else if self.heartRateDatasArray.count > 39 && self.heartRateDatasArray.count < 45 {
      let hr40 = self.heartRateDatasArray[39]
      // hrDateSamples.count = 8
      if hrDataSamples.count > 7 {
        hrDataSamples.removeLast()
      }
      hrDataSamples.append(hr40)
      // test
      print("hrDSs should be 8, now is ", hrDataSamples.count)
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          points.removeAll()
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05, y: y2)
          let d3 = CGFloat(hrDataSamples[2] - min)/diffValue
          let y3 = scaleY*CGFloat(d3) + baseY
          let point3 = CGPoint(x: baseX*0.1, y: y3)
          let d4 = CGFloat(hrDataSamples[3] - min)/diffValue
          let y4 = scaleY*CGFloat(d4) + baseY
          let point4 = CGPoint(x: baseX*0.15, y: y4)
          let d5 = CGFloat(hrDataSamples[4] - min)/diffValue
          let y5 = scaleY*CGFloat(d5) + baseY
          let point5 = CGPoint(x: baseX*0.2, y: y5)
          let d6 = CGFloat(hrDataSamples[5] - min)/diffValue
          let y6 = scaleY*CGFloat(d6) + baseY
          let point6 = CGPoint(x: baseX*0.25, y: y6)
          let d7 = CGFloat(hrDataSamples[6] - min)/diffValue
          let y7 = scaleY*CGFloat(d7) + baseY
          let point7 = CGPoint(x: baseX*0.3, y: y7)
          let d8 = CGFloat(hrDataSamples[7] - min)/diffValue
          let y8 = scaleY*CGFloat(d8) + baseY
          let point8 = CGPoint(x: baseX*0.35, y: y8)
          points = [point1, point2, point3, point4, point5, point6, point7, point8]
          // test
          print("1 nr of points should be 8, now it is", points.count)
        }else {
          let point = CGPoint(x: baseX*0.35, y: scaleY)
          // points.count = 8
          if points.count > 7{
            points.removeLast()
          }
          points.append(point)
          // test
          print("2 nr of points should be 8, now it is", points.count)
        }
      }
      
    }else if self.heartRateDatasArray.count > 44 && self.heartRateDatasArray.count < 50 {
      let hr45 = self.heartRateDatasArray[44]
      // hrDateSamples.count = 9
      if hrDataSamples.count > 8 {
        hrDataSamples.removeLast()
      }
      hrDataSamples.append(hr45)
      // test
      print("hrDSs should be 9, now is ", hrDataSamples.count)
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          points.removeAll()
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05, y: y2)
          let d3 = CGFloat(hrDataSamples[2] - min)/diffValue
          let y3 = scaleY*CGFloat(d3) + baseY
          let point3 = CGPoint(x: baseX*0.1, y: y3)
          let d4 = CGFloat(hrDataSamples[3] - min)/diffValue
          let y4 = scaleY*CGFloat(d4) + baseY
          let point4 = CGPoint(x: baseX*0.15, y: y4)
          let d5 = CGFloat(hrDataSamples[4] - min)/diffValue
          let y5 = scaleY*CGFloat(d5) + baseY
          let point5 = CGPoint(x: baseX*0.2, y: y5)
          let d6 = CGFloat(hrDataSamples[5] - min)/diffValue
          let y6 = scaleY*CGFloat(d6) + baseY
          let point6 = CGPoint(x: baseX*0.25, y: y6)
          let d7 = CGFloat(hrDataSamples[6] - min)/diffValue
          let y7 = scaleY*CGFloat(d7) + baseY
          let point7 = CGPoint(x: baseX*0.3, y: y7)
          let d8 = CGFloat(hrDataSamples[7] - min)/diffValue
          let y8 = scaleY*CGFloat(d8) + baseY
          let point8 = CGPoint(x: baseX*0.35, y: y8)
          let d9 = CGFloat(hrDataSamples[8] - min)/diffValue
          let y9 = scaleY*CGFloat(d9) + baseY
          let point9 = CGPoint(x: baseX*0.4, y: y9)
          points = [point1, point2, point3, point4, point5, point6, point7, point8, point9]
          // test
          print("1 nr of points should be 9, now it is", points.count)
        }else {
          let point = CGPoint(x: baseX*0.4, y: scaleY)
          // points.count = 9
          if points.count > 8{
            points.removeLast()
          }
          points.append(point)
          // test
          print("2 nr of points should be 9, now it is", points.count)
        }
      }
      
    }else if self.heartRateDatasArray.count > 49 && self.heartRateDatasArray.count < 55 {
      let hr50 = self.heartRateDatasArray[49]
      // hrDateSamples.count = 10
      if hrDataSamples.count > 9 {
        hrDataSamples.removeLast()
      }
      hrDataSamples.append(hr50)
      // test
      print("hrDSs should be 10, now is ", hrDataSamples.count)
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          points.removeAll()
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05, y: y2)
          let d3 = CGFloat(hrDataSamples[2] - min)/diffValue
          let y3 = scaleY*CGFloat(d3) + baseY
          let point3 = CGPoint(x: baseX*0.1, y: y3)
          let d4 = CGFloat(hrDataSamples[3] - min)/diffValue
          let y4 = scaleY*CGFloat(d4) + baseY
          let point4 = CGPoint(x: baseX*0.15, y: y4)
          let d5 = CGFloat(hrDataSamples[4] - min)/diffValue
          let y5 = scaleY*CGFloat(d5) + baseY
          let point5 = CGPoint(x: baseX*0.2, y: y5)
          let d6 = CGFloat(hrDataSamples[5] - min)/diffValue
          let y6 = scaleY*CGFloat(d6) + baseY
          let point6 = CGPoint(x: baseX*0.25, y: y6)
          let d7 = CGFloat(hrDataSamples[6] - min)/diffValue
          let y7 = scaleY*CGFloat(d7) + baseY
          let point7 = CGPoint(x: baseX*0.3, y: y7)
          let d8 = CGFloat(hrDataSamples[7] - min)/diffValue
          let y8 = scaleY*CGFloat(d8) + baseY
          let point8 = CGPoint(x: baseX*0.35, y: y8)
          let d9 = CGFloat(hrDataSamples[8] - min)/diffValue
          let y9 = scaleY*CGFloat(d9) + baseY
          let point9 = CGPoint(x: baseX*0.4, y: y9)
          let d10 = CGFloat(hrDataSamples[9] - min)/diffValue
          let y10 = scaleY*CGFloat(d10) + baseY
          let point10 = CGPoint(x: baseX*0.45, y: y10)
          points = [point1, point2, point3, point4, point5, point6, point7, point8, point9, point10]
          // test
          print("1 nr of points should be 10, now it is", points.count)
        }else {
          let point = CGPoint(x: baseX*0.45, y: scaleY)
          // points.count = 10
          if points.count > 9{
            points.removeLast()
          }
          points.append(point)
          // test
          print("2 nr of points should be 10, now it is", points.count)
        }
      }
      
    }else if self.heartRateDatasArray.count > 54 && self.heartRateDatasArray.count < 60 {
      let hr55 = self.heartRateDatasArray[54]
      // hrDateSamples.count = 11
      if hrDataSamples.count > 10 {
        hrDataSamples.removeLast()
      }
      hrDataSamples.append(hr55)
      // test
      print("hrDSs should be 11, now is ", hrDataSamples.count)
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          points.removeAll()
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05, y: y2)
          let d3 = CGFloat(hrDataSamples[2] - min)/diffValue
          let y3 = scaleY*CGFloat(d3) + baseY
          let point3 = CGPoint(x: baseX*0.1, y: y3)
          let d4 = CGFloat(hrDataSamples[3] - min)/diffValue
          let y4 = scaleY*CGFloat(d4) + baseY
          let point4 = CGPoint(x: baseX*0.15, y: y4)
          let d5 = CGFloat(hrDataSamples[4] - min)/diffValue
          let y5 = scaleY*CGFloat(d5) + baseY
          let point5 = CGPoint(x: baseX*0.2, y: y5)
          let d6 = CGFloat(hrDataSamples[5] - min)/diffValue
          let y6 = scaleY*CGFloat(d6) + baseY
          let point6 = CGPoint(x: baseX*0.25, y: y6)
          let d7 = CGFloat(hrDataSamples[6] - min)/diffValue
          let y7 = scaleY*CGFloat(d7) + baseY
          let point7 = CGPoint(x: baseX*0.3, y: y7)
          let d8 = CGFloat(hrDataSamples[7] - min)/diffValue
          let y8 = scaleY*CGFloat(d8) + baseY
          let point8 = CGPoint(x: baseX*0.35, y: y8)
          let d9 = CGFloat(hrDataSamples[8] - min)/diffValue
          let y9 = scaleY*CGFloat(d9) + baseY
          let point9 = CGPoint(x: baseX*0.4, y: y9)
          let d10 = CGFloat(hrDataSamples[9] - min)/diffValue
          let y10 = scaleY*CGFloat(d10) + baseY
          let point10 = CGPoint(x: baseX*0.45, y: y10)
          let d11 = CGFloat(hrDataSamples[10] - min)/diffValue
          let y11 = scaleY*CGFloat(d11) + baseY
          let point11 = CGPoint(x: baseX*0.5, y: y11)
          points = [point1, point2, point3, point4, point5, point6, point7, point8, point9, point10, point11]
          // test
          print("1 nr of points should be 11, now it is", points.count)
        }else {
          let point = CGPoint(x: baseX*0.5, y: scaleY)
          // points.count = 11
          if points.count > 10{
            points.removeLast()
          }
          points.append(point)
          // test
          print("2 nr of points should be 11, now it is", points.count)
        }
      }
      
    }else if self.heartRateDatasArray.count > 59 && self.heartRateDatasArray.count < 65 {
      let hr60 = self.heartRateDatasArray[59]
      // hrDateSamples.count = 12
      if hrDataSamples.count > 11 {
        hrDataSamples.removeLast()
      }
      hrDataSamples.append(hr60)
      // test
      print("hrDSs should be 12, now is ", hrDataSamples.count)
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          points.removeAll()
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05, y: y2)
          let d3 = CGFloat(hrDataSamples[2] - min)/diffValue
          let y3 = scaleY*CGFloat(d3) + baseY
          let point3 = CGPoint(x: baseX*0.1, y: y3)
          let d4 = CGFloat(hrDataSamples[3] - min)/diffValue
          let y4 = scaleY*CGFloat(d4) + baseY
          let point4 = CGPoint(x: baseX*0.15, y: y4)
          let d5 = CGFloat(hrDataSamples[4] - min)/diffValue
          let y5 = scaleY*CGFloat(d5) + baseY
          let point5 = CGPoint(x: baseX*0.2, y: y5)
          let d6 = CGFloat(hrDataSamples[5] - min)/diffValue
          let y6 = scaleY*CGFloat(d6) + baseY
          let point6 = CGPoint(x: baseX*0.25, y: y6)
          let d7 = CGFloat(hrDataSamples[6] - min)/diffValue
          let y7 = scaleY*CGFloat(d7) + baseY
          let point7 = CGPoint(x: baseX*0.3, y: y7)
          let d8 = CGFloat(hrDataSamples[7] - min)/diffValue
          let y8 = scaleY*CGFloat(d8) + baseY
          let point8 = CGPoint(x: baseX*0.35, y: y8)
          let d9 = CGFloat(hrDataSamples[8] - min)/diffValue
          let y9 = scaleY*CGFloat(d9) + baseY
          let point9 = CGPoint(x: baseX*0.4, y: y9)
          let d10 = CGFloat(hrDataSamples[9] - min)/diffValue
          let y10 = scaleY*CGFloat(d10) + baseY
          let point10 = CGPoint(x: baseX*0.45, y: y10)
          let d11 = CGFloat(hrDataSamples[10] - min)/diffValue
          let y11 = scaleY*CGFloat(d11) + baseY
          let point11 = CGPoint(x: baseX*0.5, y: y11)
          let d12 = CGFloat(hrDataSamples[11] - min)/diffValue
          let y12 = scaleY*CGFloat(d12) + baseY
          let point12 = CGPoint(x: baseX*0.55, y: y12)
          points = [point1, point2, point3, point4, point5, point6, point7, point8, point9, point10, point11, point12]
          // test
          print("1 nr of points should be 12, now it is", points.count)
        }else {
          let point = CGPoint(x: baseX*0.55, y: scaleY)
          // points.count = 12
          if points.count > 11{
            points.removeLast()
          }
          points.append(point)
          // test
          print("2 nr of points should be 12, now it is", points.count)
        }
      }
      
    }else if self.heartRateDatasArray.count > 64 && self.heartRateDatasArray.count < 70 {
      let hr65 = self.heartRateDatasArray[64]
      // hrDateSamples.count = 13
      if hrDataSamples.count > 12 {
        hrDataSamples.removeLast()
      }
      hrDataSamples.append(hr65)
      // test
      print("hrDSs should be 13, now is ", hrDataSamples.count)
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          points.removeAll()
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05, y: y2)
          let d3 = CGFloat(hrDataSamples[2] - min)/diffValue
          let y3 = scaleY*CGFloat(d3) + baseY
          let point3 = CGPoint(x: baseX*0.1, y: y3)
          let d4 = CGFloat(hrDataSamples[3] - min)/diffValue
          let y4 = scaleY*CGFloat(d4) + baseY
          let point4 = CGPoint(x: baseX*0.15, y: y4)
          let d5 = CGFloat(hrDataSamples[4] - min)/diffValue
          let y5 = scaleY*CGFloat(d5) + baseY
          let point5 = CGPoint(x: baseX*0.2, y: y5)
          let d6 = CGFloat(hrDataSamples[5] - min)/diffValue
          let y6 = scaleY*CGFloat(d6) + baseY
          let point6 = CGPoint(x: baseX*0.25, y: y6)
          let d7 = CGFloat(hrDataSamples[6] - min)/diffValue
          let y7 = scaleY*CGFloat(d7) + baseY
          let point7 = CGPoint(x: baseX*0.3, y: y7)
          let d8 = CGFloat(hrDataSamples[7] - min)/diffValue
          let y8 = scaleY*CGFloat(d8) + baseY
          let point8 = CGPoint(x: baseX*0.35, y: y8)
          let d9 = CGFloat(hrDataSamples[8] - min)/diffValue
          let y9 = scaleY*CGFloat(d9) + baseY
          let point9 = CGPoint(x: baseX*0.4, y: y9)
          let d10 = CGFloat(hrDataSamples[9] - min)/diffValue
          let y10 = scaleY*CGFloat(d10) + baseY
          let point10 = CGPoint(x: baseX*0.45, y: y10)
          let d11 = CGFloat(hrDataSamples[10] - min)/diffValue
          let y11 = scaleY*CGFloat(d11) + baseY
          let point11 = CGPoint(x: baseX*0.5, y: y11)
          let d12 = CGFloat(hrDataSamples[11] - min)/diffValue
          let y12 = scaleY*CGFloat(d12) + baseY
          let point12 = CGPoint(x: baseX*0.55, y: y12)
          let d13 = CGFloat(hrDataSamples[12] - min)/diffValue
          let y13 = scaleY*CGFloat(d13) + baseY
          let point13 = CGPoint(x: baseX*0.6, y: y13)
          points = [point1, point2, point3, point4, point5, point6, point7, point8, point9, point10, point11, point12, point13]
          // test
          print("1 nr of points should be 13, now it is", points.count)
        }else {
          let point = CGPoint(x: baseX*0.6, y: scaleY)
          // points.count = 13
          if points.count > 12{
            points.removeLast()
          }
          points.append(point)
          // test
          print("2 nr of points should be 13, now it is", points.count)
        }
      }
      
    }else if self.heartRateDatasArray.count > 69 && self.heartRateDatasArray.count < 75 {
      let hr70 = self.heartRateDatasArray[69]
      // hrDateSamples.count = 14
      if hrDataSamples.count > 13 {
        hrDataSamples.removeLast()
      }
      hrDataSamples.append(hr70)
      // test
      print("hrDSs should be 14, now is ", hrDataSamples.count)
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          points.removeAll()
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05, y: y2)
          let d3 = CGFloat(hrDataSamples[2] - min)/diffValue
          let y3 = scaleY*CGFloat(d3) + baseY
          let point3 = CGPoint(x: baseX*0.1, y: y3)
          let d4 = CGFloat(hrDataSamples[3] - min)/diffValue
          let y4 = scaleY*CGFloat(d4) + baseY
          let point4 = CGPoint(x: baseX*0.15, y: y4)
          let d5 = CGFloat(hrDataSamples[4] - min)/diffValue
          let y5 = scaleY*CGFloat(d5) + baseY
          let point5 = CGPoint(x: baseX*0.2, y: y5)
          let d6 = CGFloat(hrDataSamples[5] - min)/diffValue
          let y6 = scaleY*CGFloat(d6) + baseY
          let point6 = CGPoint(x: baseX*0.25, y: y6)
          let d7 = CGFloat(hrDataSamples[6] - min)/diffValue
          let y7 = scaleY*CGFloat(d7) + baseY
          let point7 = CGPoint(x: baseX*0.3, y: y7)
          let d8 = CGFloat(hrDataSamples[7] - min)/diffValue
          let y8 = scaleY*CGFloat(d8) + baseY
          let point8 = CGPoint(x: baseX*0.35, y: y8)
          let d9 = CGFloat(hrDataSamples[8] - min)/diffValue
          let y9 = scaleY*CGFloat(d9) + baseY
          let point9 = CGPoint(x: baseX*0.4, y: y9)
          let d10 = CGFloat(hrDataSamples[9] - min)/diffValue
          let y10 = scaleY*CGFloat(d10) + baseY
          let point10 = CGPoint(x: baseX*0.45, y: y10)
          let d11 = CGFloat(hrDataSamples[10] - min)/diffValue
          let y11 = scaleY*CGFloat(d11) + baseY
          let point11 = CGPoint(x: baseX*0.5, y: y11)
          let d12 = CGFloat(hrDataSamples[11] - min)/diffValue
          let y12 = scaleY*CGFloat(d12) + baseY
          let point12 = CGPoint(x: baseX*0.55, y: y12)
          let d13 = CGFloat(hrDataSamples[12] - min)/diffValue
          let y13 = scaleY*CGFloat(d13) + baseY
          let point13 = CGPoint(x: baseX*0.6, y: y13)
          let d14 = CGFloat(hrDataSamples[13] - min)/diffValue
          let y14 = scaleY*CGFloat(d14) + baseY
          let point14 = CGPoint(x: baseX*0.65, y: y14)
          points = [point1, point2, point3, point4, point5, point6, point7, point8, point9, point10, point11, point12, point13, point14]
          // test
          print("1 nr of points should be 14, now it is", points.count)
        }else {
          let point = CGPoint(x: baseX*0.65, y: scaleY)
          // points.count = 14
          if points.count > 13{
            points.removeLast()
          }
          points.append(point)
          // test
          print("2 nr of points should be 14, now it is", points.count)
        }
      }
      
    }else if self.heartRateDatasArray.count > 74 && self.heartRateDatasArray.count < 80 {
      let hr75 = self.heartRateDatasArray[74]
      // hrDateSamples.count = 15
      if hrDataSamples.count > 14 {
        hrDataSamples.removeLast()
      }
      hrDataSamples.append(hr75)
      // test
      print("hrDSs should be 15, now is ", hrDataSamples.count)
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          points.removeAll()
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05, y: y2)
          let d3 = CGFloat(hrDataSamples[2] - min)/diffValue
          let y3 = scaleY*CGFloat(d3) + baseY
          let point3 = CGPoint(x: baseX*0.1, y: y3)
          let d4 = CGFloat(hrDataSamples[3] - min)/diffValue
          let y4 = scaleY*CGFloat(d4) + baseY
          let point4 = CGPoint(x: baseX*0.15, y: y4)
          let d5 = CGFloat(hrDataSamples[4] - min)/diffValue
          let y5 = scaleY*CGFloat(d5) + baseY
          let point5 = CGPoint(x: baseX*0.2, y: y5)
          let d6 = CGFloat(hrDataSamples[5] - min)/diffValue
          let y6 = scaleY*CGFloat(d6) + baseY
          let point6 = CGPoint(x: baseX*0.25, y: y6)
          let d7 = CGFloat(hrDataSamples[6] - min)/diffValue
          let y7 = scaleY*CGFloat(d7) + baseY
          let point7 = CGPoint(x: baseX*0.3, y: y7)
          let d8 = CGFloat(hrDataSamples[7] - min)/diffValue
          let y8 = scaleY*CGFloat(d8) + baseY
          let point8 = CGPoint(x: baseX*0.35, y: y8)
          let d9 = CGFloat(hrDataSamples[8] - min)/diffValue
          let y9 = scaleY*CGFloat(d9) + baseY
          let point9 = CGPoint(x: baseX*0.4, y: y9)
          let d10 = CGFloat(hrDataSamples[9] - min)/diffValue
          let y10 = scaleY*CGFloat(d10) + baseY
          let point10 = CGPoint(x: baseX*0.45, y: y10)
          let d11 = CGFloat(hrDataSamples[10] - min)/diffValue
          let y11 = scaleY*CGFloat(d11) + baseY
          let point11 = CGPoint(x: baseX*0.5, y: y11)
          let d12 = CGFloat(hrDataSamples[11] - min)/diffValue
          let y12 = scaleY*CGFloat(d12) + baseY
          let point12 = CGPoint(x: baseX*0.55, y: y12)
          let d13 = CGFloat(hrDataSamples[12] - min)/diffValue
          let y13 = scaleY*CGFloat(d13) + baseY
          let point13 = CGPoint(x: baseX*0.6, y: y13)
          let d14 = CGFloat(hrDataSamples[13] - min)/diffValue
          let y14 = scaleY*CGFloat(d14) + baseY
          let point14 = CGPoint(x: baseX*0.65, y: y14)
          let d15 = CGFloat(hrDataSamples[14] - min)/diffValue
          let y15 = scaleY*CGFloat(d15) + baseY
          let point15 = CGPoint(x: baseX*0.7, y: y15)
          points = [point1, point2, point3, point4, point5, point6, point7, point8, point9, point10, point11, point12, point13, point14, point15]
          // test
          print("1 nr of points should be 15, now it is", points.count)
        }else {
          let point = CGPoint(x: baseX*0.7, y: scaleY)
          // points.count = 15
          if points.count > 14{
            points.removeLast()
          }
          points.append(point)
          // test
          print("2 nr of points should be 15, now it is", points.count)
        }
      }
      
    }else if self.heartRateDatasArray.count > 79 && self.heartRateDatasArray.count < 85 {
      let hr80 = self.heartRateDatasArray[79]
      // hrDateSamples.count = 16
      if hrDataSamples.count > 15 {
        hrDataSamples.removeLast()
      }
      hrDataSamples.append(hr80)
      // test
      print("hrDSs should be 16, now is ", hrDataSamples.count)
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          points.removeAll()
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05, y: y2)
          let d3 = CGFloat(hrDataSamples[2] - min)/diffValue
          let y3 = scaleY*CGFloat(d3) + baseY
          let point3 = CGPoint(x: baseX*0.1, y: y3)
          let d4 = CGFloat(hrDataSamples[3] - min)/diffValue
          let y4 = scaleY*CGFloat(d4) + baseY
          let point4 = CGPoint(x: baseX*0.15, y: y4)
          let d5 = CGFloat(hrDataSamples[4] - min)/diffValue
          let y5 = scaleY*CGFloat(d5) + baseY
          let point5 = CGPoint(x: baseX*0.2, y: y5)
          let d6 = CGFloat(hrDataSamples[5] - min)/diffValue
          let y6 = scaleY*CGFloat(d6) + baseY
          let point6 = CGPoint(x: baseX*0.25, y: y6)
          let d7 = CGFloat(hrDataSamples[6] - min)/diffValue
          let y7 = scaleY*CGFloat(d7) + baseY
          let point7 = CGPoint(x: baseX*0.3, y: y7)
          let d8 = CGFloat(hrDataSamples[7] - min)/diffValue
          let y8 = scaleY*CGFloat(d8) + baseY
          let point8 = CGPoint(x: baseX*0.35, y: y8)
          let d9 = CGFloat(hrDataSamples[8] - min)/diffValue
          let y9 = scaleY*CGFloat(d9) + baseY
          let point9 = CGPoint(x: baseX*0.4, y: y9)
          let d10 = CGFloat(hrDataSamples[9] - min)/diffValue
          let y10 = scaleY*CGFloat(d10) + baseY
          let point10 = CGPoint(x: baseX*0.45, y: y10)
          let d11 = CGFloat(hrDataSamples[10] - min)/diffValue
          let y11 = scaleY*CGFloat(d11) + baseY
          let point11 = CGPoint(x: baseX*0.5, y: y11)
          let d12 = CGFloat(hrDataSamples[11] - min)/diffValue
          let y12 = scaleY*CGFloat(d12) + baseY
          let point12 = CGPoint(x: baseX*0.55, y: y12)
          let d13 = CGFloat(hrDataSamples[12] - min)/diffValue
          let y13 = scaleY*CGFloat(d13) + baseY
          let point13 = CGPoint(x: baseX*0.6, y: y13)
          let d14 = CGFloat(hrDataSamples[13] - min)/diffValue
          let y14 = scaleY*CGFloat(d14) + baseY
          let point14 = CGPoint(x: baseX*0.65, y: y14)
          let d15 = CGFloat(hrDataSamples[14] - min)/diffValue
          let y15 = scaleY*CGFloat(d15) + baseY
          let point15 = CGPoint(x: baseX*0.7, y: y15)
          let d16 = CGFloat(hrDataSamples[15] - min)/diffValue
          let y16 = scaleY*CGFloat(d16) + baseY
          let point16 = CGPoint(x: baseX*0.75, y: y16)
          points = [point1, point2, point3, point4, point5, point6, point7, point8, point9, point10, point11, point12, point13, point14, point15, point16]
          // test
          print("1 nr of points should be 16, now it is", points.count)
        }else {
          let point = CGPoint(x: baseX*0.75, y: scaleY)
          // points.count = 16
          if points.count > 15{
            points.removeLast()
          }
          points.append(point)
          // test
          print("2 nr of points should be 16, now it is", points.count)
        }
      }
      
    }else if self.heartRateDatasArray.count > 84 && self.heartRateDatasArray.count < 90 {
      let hr85 = self.heartRateDatasArray[84]
      // hrDateSamples.count = 17
      if hrDataSamples.count > 16 {
        hrDataSamples.removeLast()
      }
      hrDataSamples.append(hr85)
      // test
      print("hrDSs should be 17, now is ", hrDataSamples.count)
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          points.removeAll()
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05, y: y2)
          let d3 = CGFloat(hrDataSamples[2] - min)/diffValue
          let y3 = scaleY*CGFloat(d3) + baseY
          let point3 = CGPoint(x: baseX*0.1, y: y3)
          let d4 = CGFloat(hrDataSamples[3] - min)/diffValue
          let y4 = scaleY*CGFloat(d4) + baseY
          let point4 = CGPoint(x: baseX*0.15, y: y4)
          let d5 = CGFloat(hrDataSamples[4] - min)/diffValue
          let y5 = scaleY*CGFloat(d5) + baseY
          let point5 = CGPoint(x: baseX*0.2, y: y5)
          let d6 = CGFloat(hrDataSamples[5] - min)/diffValue
          let y6 = scaleY*CGFloat(d6) + baseY
          let point6 = CGPoint(x: baseX*0.25, y: y6)
          let d7 = CGFloat(hrDataSamples[6] - min)/diffValue
          let y7 = scaleY*CGFloat(d7) + baseY
          let point7 = CGPoint(x: baseX*0.3, y: y7)
          let d8 = CGFloat(hrDataSamples[7] - min)/diffValue
          let y8 = scaleY*CGFloat(d8) + baseY
          let point8 = CGPoint(x: baseX*0.35, y: y8)
          let d9 = CGFloat(hrDataSamples[8] - min)/diffValue
          let y9 = scaleY*CGFloat(d9) + baseY
          let point9 = CGPoint(x: baseX*0.4, y: y9)
          let d10 = CGFloat(hrDataSamples[9] - min)/diffValue
          let y10 = scaleY*CGFloat(d10) + baseY
          let point10 = CGPoint(x: baseX*0.45, y: y10)
          let d11 = CGFloat(hrDataSamples[10] - min)/diffValue
          let y11 = scaleY*CGFloat(d11) + baseY
          let point11 = CGPoint(x: baseX*0.5, y: y11)
          let d12 = CGFloat(hrDataSamples[11] - min)/diffValue
          let y12 = scaleY*CGFloat(d12) + baseY
          let point12 = CGPoint(x: baseX*0.55, y: y12)
          let d13 = CGFloat(hrDataSamples[12] - min)/diffValue
          let y13 = scaleY*CGFloat(d13) + baseY
          let point13 = CGPoint(x: baseX*0.6, y: y13)
          let d14 = CGFloat(hrDataSamples[13] - min)/diffValue
          let y14 = scaleY*CGFloat(d14) + baseY
          let point14 = CGPoint(x: baseX*0.65, y: y14)
          let d15 = CGFloat(hrDataSamples[14] - min)/diffValue
          let y15 = scaleY*CGFloat(d15) + baseY
          let point15 = CGPoint(x: baseX*0.7, y: y15)
          let d16 = CGFloat(hrDataSamples[15] - min)/diffValue
          let y16 = scaleY*CGFloat(d16) + baseY
          let point16 = CGPoint(x: baseX*0.75, y: y16)
          let d17 = CGFloat(hrDataSamples[16] - min)/diffValue
          let y17 = scaleY*CGFloat(d17) + baseY
          let point17 = CGPoint(x: baseX*0.8, y: y17)
          points = [point1, point2, point3, point4, point5, point6, point7, point8, point9, point10, point11, point12, point13, point14, point15, point16, point17]
          // test
          print("1 nr of points should be 17, now it is", points.count)
        }else {
          let point = CGPoint(x: baseX*0.8, y: scaleY)
          // points.count = 17
          if points.count > 16{
            points.removeLast()
          }
          points.append(point)
          // test
          print("2 nr of points should be 17, now it is", points.count)
        }
      }
      
    }else if self.heartRateDatasArray.count > 89 && self.heartRateDatasArray.count < 95 {
      let hr90 = self.heartRateDatasArray[89]
      // hrDateSamples.count = 18
      if hrDataSamples.count > 17 {
        hrDataSamples.removeLast()
      }
      hrDataSamples.append(hr90)
      // test
      print("hrDSs should be 18, now is ", hrDataSamples.count)
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          points.removeAll()
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05, y: y2)
          let d3 = CGFloat(hrDataSamples[2] - min)/diffValue
          let y3 = scaleY*CGFloat(d3) + baseY
          let point3 = CGPoint(x: baseX*0.1, y: y3)
          let d4 = CGFloat(hrDataSamples[3] - min)/diffValue
          let y4 = scaleY*CGFloat(d4) + baseY
          let point4 = CGPoint(x: baseX*0.15, y: y4)
          let d5 = CGFloat(hrDataSamples[4] - min)/diffValue
          let y5 = scaleY*CGFloat(d5) + baseY
          let point5 = CGPoint(x: baseX*0.2, y: y5)
          let d6 = CGFloat(hrDataSamples[5] - min)/diffValue
          let y6 = scaleY*CGFloat(d6) + baseY
          let point6 = CGPoint(x: baseX*0.25, y: y6)
          let d7 = CGFloat(hrDataSamples[6] - min)/diffValue
          let y7 = scaleY*CGFloat(d7) + baseY
          let point7 = CGPoint(x: baseX*0.3, y: y7)
          let d8 = CGFloat(hrDataSamples[7] - min)/diffValue
          let y8 = scaleY*CGFloat(d8) + baseY
          let point8 = CGPoint(x: baseX*0.35, y: y8)
          let d9 = CGFloat(hrDataSamples[8] - min)/diffValue
          let y9 = scaleY*CGFloat(d9) + baseY
          let point9 = CGPoint(x: baseX*0.4, y: y9)
          let d10 = CGFloat(hrDataSamples[9] - min)/diffValue
          let y10 = scaleY*CGFloat(d10) + baseY
          let point10 = CGPoint(x: baseX*0.45, y: y10)
          let d11 = CGFloat(hrDataSamples[10] - min)/diffValue
          let y11 = scaleY*CGFloat(d11) + baseY
          let point11 = CGPoint(x: baseX*0.5, y: y11)
          let d12 = CGFloat(hrDataSamples[11] - min)/diffValue
          let y12 = scaleY*CGFloat(d12) + baseY
          let point12 = CGPoint(x: baseX*0.55, y: y12)
          let d13 = CGFloat(hrDataSamples[12] - min)/diffValue
          let y13 = scaleY*CGFloat(d13) + baseY
          let point13 = CGPoint(x: baseX*0.6, y: y13)
          let d14 = CGFloat(hrDataSamples[13] - min)/diffValue
          let y14 = scaleY*CGFloat(d14) + baseY
          let point14 = CGPoint(x: baseX*0.65, y: y14)
          let d15 = CGFloat(hrDataSamples[14] - min)/diffValue
          let y15 = scaleY*CGFloat(d15) + baseY
          let point15 = CGPoint(x: baseX*0.7, y: y15)
          let d16 = CGFloat(hrDataSamples[15] - min)/diffValue
          let y16 = scaleY*CGFloat(d16) + baseY
          let point16 = CGPoint(x: baseX*0.75, y: y16)
          let d17 = CGFloat(hrDataSamples[16] - min)/diffValue
          let y17 = scaleY*CGFloat(d17) + baseY
          let point17 = CGPoint(x: baseX*0.8, y: y17)
          let d18 = CGFloat(hrDataSamples[17] - min)/diffValue
          let y18 = scaleY*CGFloat(d18) + baseY
          let point18 = CGPoint(x: baseX*0.85, y: y18)
          points = [point1, point2, point3, point4, point5, point6, point7, point8, point9, point10, point11, point12, point13, point14, point15, point16, point17, point18]
          // test
          print("1 nr of points should be 18, now it is", points.count)
        }else {
          let point = CGPoint(x: baseX*0.85, y: scaleY)
          // points.count = 18
          if points.count > 17{
            points.removeLast()
          }
          points.append(point)
          // test
          print("2 nr of points should be 18, now it is", points.count)
        }
      }
      
    }else if self.heartRateDatasArray.count > 94 && self.heartRateDatasArray.count < 100 {
      let hr95 = self.heartRateDatasArray[94]
      // hrDateSamples.count = 19
      if hrDataSamples.count > 18 {
        hrDataSamples.removeLast()
      }
      hrDataSamples.append(hr95)
      // test
      print("hrDSs should be 19, now is ", hrDataSamples.count)
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          points.removeAll()
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05, y: y2)
          let d3 = CGFloat(hrDataSamples[2] - min)/diffValue
          let y3 = scaleY*CGFloat(d3) + baseY
          let point3 = CGPoint(x: baseX*0.1, y: y3)
          let d4 = CGFloat(hrDataSamples[3] - min)/diffValue
          let y4 = scaleY*CGFloat(d4) + baseY
          let point4 = CGPoint(x: baseX*0.15, y: y4)
          let d5 = CGFloat(hrDataSamples[4] - min)/diffValue
          let y5 = scaleY*CGFloat(d5) + baseY
          let point5 = CGPoint(x: baseX*0.2, y: y5)
          let d6 = CGFloat(hrDataSamples[5] - min)/diffValue
          let y6 = scaleY*CGFloat(d6) + baseY
          let point6 = CGPoint(x: baseX*0.25, y: y6)
          let d7 = CGFloat(hrDataSamples[6] - min)/diffValue
          let y7 = scaleY*CGFloat(d7) + baseY
          let point7 = CGPoint(x: baseX*0.3, y: y7)
          let d8 = CGFloat(hrDataSamples[7] - min)/diffValue
          let y8 = scaleY*CGFloat(d8) + baseY
          let point8 = CGPoint(x: baseX*0.35, y: y8)
          let d9 = CGFloat(hrDataSamples[8] - min)/diffValue
          let y9 = scaleY*CGFloat(d9) + baseY
          let point9 = CGPoint(x: baseX*0.4, y: y9)
          let d10 = CGFloat(hrDataSamples[9] - min)/diffValue
          let y10 = scaleY*CGFloat(d10) + baseY
          let point10 = CGPoint(x: baseX*0.45, y: y10)
          let d11 = CGFloat(hrDataSamples[10] - min)/diffValue
          let y11 = scaleY*CGFloat(d11) + baseY
          let point11 = CGPoint(x: baseX*0.5, y: y11)
          let d12 = CGFloat(hrDataSamples[11] - min)/diffValue
          let y12 = scaleY*CGFloat(d12) + baseY
          let point12 = CGPoint(x: baseX*0.55, y: y12)
          let d13 = CGFloat(hrDataSamples[12] - min)/diffValue
          let y13 = scaleY*CGFloat(d13) + baseY
          let point13 = CGPoint(x: baseX*0.6, y: y13)
          let d14 = CGFloat(hrDataSamples[13] - min)/diffValue
          let y14 = scaleY*CGFloat(d14) + baseY
          let point14 = CGPoint(x: baseX*0.65, y: y14)
          let d15 = CGFloat(hrDataSamples[14] - min)/diffValue
          let y15 = scaleY*CGFloat(d15) + baseY
          let point15 = CGPoint(x: baseX*0.7, y: y15)
          let d16 = CGFloat(hrDataSamples[15] - min)/diffValue
          let y16 = scaleY*CGFloat(d16) + baseY
          let point16 = CGPoint(x: baseX*0.75, y: y16)
          let d17 = CGFloat(hrDataSamples[16] - min)/diffValue
          let y17 = scaleY*CGFloat(d17) + baseY
          let point17 = CGPoint(x: baseX*0.8, y: y17)
          let d18 = CGFloat(hrDataSamples[17] - min)/diffValue
          let y18 = scaleY*CGFloat(d18) + baseY
          let point18 = CGPoint(x: baseX*0.85, y: y18)
          let d19 = CGFloat(hrDataSamples[18] - min)/diffValue
          let y19 = scaleY*CGFloat(d19) + baseY
          let point19 = CGPoint(x: baseX*0.9, y: y19)
          points = [point1, point2, point3, point4, point5, point6, point7, point8, point9, point10, point11, point12, point13, point14, point15, point16, point17, point18, point19]
          // test
          print("1 nr of points should be 19, now it is", points.count)
        }else {
          let point = CGPoint(x: baseX*0.9, y: scaleY)
          // points.count = 19
          if points.count > 18{
            points.removeLast()
          }
          points.append(point)
          // test
          print("2 nr of points should be 19, now it is", points.count)
        }
      }
      
    }else if self.heartRateDatasArray.count > 99 && self.heartRateDatasArray.count < 105 {
      let hr100 = self.heartRateDatasArray[99]
      // hrDateSamples.count = 20
      if hrDataSamples.count > 19 {
        hrDataSamples.removeLast()
      }
      hrDataSamples.append(hr100)
      // test
      print("hrDSs should be 20, now is ", hrDataSamples.count)
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          points.removeAll()
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05*0.9, y: y2)
          let d3 = CGFloat(hrDataSamples[2] - min)/diffValue
          let y3 = scaleY*CGFloat(d3) + baseY
          let point3 = CGPoint(x: baseX*0.1*0.9, y: y3)
          let d4 = CGFloat(hrDataSamples[3] - min)/diffValue
          let y4 = scaleY*CGFloat(d4) + baseY
          let point4 = CGPoint(x: baseX*0.15*0.9, y: y4)
          let d5 = CGFloat(hrDataSamples[4] - min)/diffValue
          let y5 = scaleY*CGFloat(d5) + baseY
          let point5 = CGPoint(x: baseX*0.2*0.9, y: y5)
          let d6 = CGFloat(hrDataSamples[5] - min)/diffValue
          let y6 = scaleY*CGFloat(d6) + baseY
          let point6 = CGPoint(x: baseX*0.25*0.9, y: y6)
          let d7 = CGFloat(hrDataSamples[6] - min)/diffValue
          let y7 = scaleY*CGFloat(d7) + baseY
          let point7 = CGPoint(x: baseX*0.3*0.9, y: y7)
          let d8 = CGFloat(hrDataSamples[7] - min)/diffValue
          let y8 = scaleY*CGFloat(d8) + baseY
          let point8 = CGPoint(x: baseX*0.35*0.9, y: y8)
          let d9 = CGFloat(hrDataSamples[8] - min)/diffValue
          let y9 = scaleY*CGFloat(d9) + baseY
          let point9 = CGPoint(x: baseX*0.4*0.9, y: y9)
          let d10 = CGFloat(hrDataSamples[9] - min)/diffValue
          let y10 = scaleY*CGFloat(d10) + baseY
          let point10 = CGPoint(x: baseX*0.45*0.9, y: y10)
          let d11 = CGFloat(hrDataSamples[10] - min)/diffValue
          let y11 = scaleY*CGFloat(d11) + baseY
          let point11 = CGPoint(x: baseX*0.5*0.9, y: y11)
          let d12 = CGFloat(hrDataSamples[11] - min)/diffValue
          let y12 = scaleY*CGFloat(d12) + baseY
          let point12 = CGPoint(x: baseX*0.55*0.9, y: y12)
          let d13 = CGFloat(hrDataSamples[12] - min)/diffValue
          let y13 = scaleY*CGFloat(d13) + baseY
          let point13 = CGPoint(x: baseX*0.6*0.9, y: y13)
          let d14 = CGFloat(hrDataSamples[13] - min)/diffValue
          let y14 = scaleY*CGFloat(d14) + baseY
          let point14 = CGPoint(x: baseX*0.65*0.9, y: y14)
          let d15 = CGFloat(hrDataSamples[14] - min)/diffValue
          let y15 = scaleY*CGFloat(d15) + baseY
          let point15 = CGPoint(x: baseX*0.7*0.9, y: y15)
          let d16 = CGFloat(hrDataSamples[15] - min)/diffValue
          let y16 = scaleY*CGFloat(d16) + baseY
          let point16 = CGPoint(x: baseX*0.75*0.9, y: y16)
          let d17 = CGFloat(hrDataSamples[16] - min)/diffValue
          let y17 = scaleY*CGFloat(d17) + baseY
          let point17 = CGPoint(x: baseX*0.8*0.9, y: y17)
          let d18 = CGFloat(hrDataSamples[17] - min)/diffValue
          let y18 = scaleY*CGFloat(d18) + baseY
          let point18 = CGPoint(x: baseX*0.85*0.9, y: y18)
          let d19 = CGFloat(hrDataSamples[18] - min)/diffValue
          let y19 = scaleY*CGFloat(d19) + baseY
          let point19 = CGPoint(x: baseX*0.9*0.9, y: y19)
          let d20 = CGFloat(hrDataSamples[19] - min)/diffValue
          let y20 = scaleY*CGFloat(d20) + baseY
          let point20 = CGPoint(x: baseX*0.95*0.9, y: y20)
          points = [point1, point2, point3, point4, point5, point6, point7, point8, point9, point10, point11, point12, point13, point14, point15, point16, point17, point18, point19, point20]
          // test
          print("1 nr of points should be 20, now it is", points.count)
        }else {
          let point = CGPoint(x: baseX*0.95, y: scaleY)
          // points.count = 20
          if points.count > 19{
            points.removeLast()
          }
          points.append(point)
          // test
          print("2 nr of points should be 20, now it is", points.count)
        }
      }
      
    }else {
      // 1. hrDataSample remove all the samples, add new samples from heart rate data array to it
      hrDataSamples.removeAll()
      let n1 = heartRateDatasArray.count-1
      let n2 = heartRateDatasArray.count-6
      let n3 = heartRateDatasArray.count-11
      let n4 = heartRateDatasArray.count-16
      let n5 = heartRateDatasArray.count-21
      let n6 = heartRateDatasArray.count-26
      let n7 = heartRateDatasArray.count-31
      let n8 = heartRateDatasArray.count-36
      let n9 = heartRateDatasArray.count-41
      let n10 = heartRateDatasArray.count-46
      let n11 = heartRateDatasArray.count-51
      let n12 = heartRateDatasArray.count-56
      let n13 = heartRateDatasArray.count-61
      let n14 = heartRateDatasArray.count-66
      let n15 = heartRateDatasArray.count-71
      let n16 = heartRateDatasArray.count-76
      let n17 = heartRateDatasArray.count-81
      let n18 = heartRateDatasArray.count-86
      let n19 = heartRateDatasArray.count-91
      let n20 = heartRateDatasArray.count-96
      
      let hr1 = self.heartRateDatasArray[n20]
      let hr2 = self.heartRateDatasArray[n19]
      let hr3 = self.heartRateDatasArray[n18]
      let hr4 = self.heartRateDatasArray[n17]
      let hr5 = self.heartRateDatasArray[n16]
      let hr6 = self.heartRateDatasArray[n15]
      let hr7 = self.heartRateDatasArray[n14]
      let hr8 = self.heartRateDatasArray[n13]
      let hr9 = self.heartRateDatasArray[n12]
      let hr10 = self.heartRateDatasArray[n11]
      let hr11 = self.heartRateDatasArray[n10]
      let hr12 = self.heartRateDatasArray[n9]
      let hr13 = self.heartRateDatasArray[n8]
      let hr14 = self.heartRateDatasArray[n7]
      let hr15 = self.heartRateDatasArray[n6]
      let hr16 = self.heartRateDatasArray[n5]
      let hr17 = self.heartRateDatasArray[n4]
      let hr18 = self.heartRateDatasArray[n3]
      let hr19 = self.heartRateDatasArray[n2]
      let hr20 = self.heartRateDatasArray[n1]
      
      hrDataSamples = [hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12, hr13, hr14, hr15, hr16, hr17, hr18, hr19, hr20]
      // test, hrDataSamples should be 20
      print("now hrDataSample", hrDataSamples)
      // 2. set points of hr chart
      points.removeAll()
      
      if let max = hrDataSamples.max(), let min = hrDataSamples.min() {
        let diffValue = CGFloat(max - min)
        if diffValue > 0 {
          let d1 = CGFloat(hrDataSamples[0] - min)/diffValue
          let y1 = scaleY*CGFloat(d1) + baseY
          let point1 = CGPoint(x: 0, y: y1)
          let d2 = CGFloat(hrDataSamples[1] - min)/diffValue
          let y2 = scaleY*CGFloat(d2) + baseY
          let point2 = CGPoint(x: baseX*0.05*0.9, y: y2)
          let d3 = CGFloat(hrDataSamples[2] - min)/diffValue
          let y3 = scaleY*CGFloat(d3) + baseY
          let point3 = CGPoint(x: baseX*0.1*0.9, y: y3)
          let d4 = CGFloat(hrDataSamples[3] - min)/diffValue
          let y4 = scaleY*CGFloat(d4) + baseY
          let point4 = CGPoint(x: baseX*0.15*0.9, y: y4)
          let d5 = CGFloat(hrDataSamples[4] - min)/diffValue
          let y5 = scaleY*CGFloat(d5) + baseY
          let point5 = CGPoint(x: baseX*0.2*0.9, y: y5)
          let d6 = CGFloat(hrDataSamples[5] - min)/diffValue
          let y6 = scaleY*CGFloat(d6) + baseY
          let point6 = CGPoint(x: baseX*0.25*0.9, y: y6)
          let d7 = CGFloat(hrDataSamples[6] - min)/diffValue
          let y7 = scaleY*CGFloat(d7) + baseY
          let point7 = CGPoint(x: baseX*0.3*0.9, y: y7)
          let d8 = CGFloat(hrDataSamples[7] - min)/diffValue
          let y8 = scaleY*CGFloat(d8) + baseY
          let point8 = CGPoint(x: baseX*0.35*0.9, y: y8)
          let d9 = CGFloat(hrDataSamples[8] - min)/diffValue
          let y9 = scaleY*CGFloat(d9) + baseY
          let point9 = CGPoint(x: baseX*0.4*0.9, y: y9)
          let d10 = CGFloat(hrDataSamples[9] - min)/diffValue
          let y10 = scaleY*CGFloat(d10) + baseY
          let point10 = CGPoint(x: baseX*0.45*0.9, y: y10)
          let d11 = CGFloat(hrDataSamples[10] - min)/diffValue
          let y11 = scaleY*CGFloat(d11) + baseY
          let point11 = CGPoint(x: baseX*0.5*0.9, y: y11)
          let d12 = CGFloat(hrDataSamples[11] - min)/diffValue
          let y12 = scaleY*CGFloat(d12) + baseY
          let point12 = CGPoint(x: baseX*0.55*0.9, y: y12)
          let d13 = CGFloat(hrDataSamples[12] - min)/diffValue
          let y13 = scaleY*CGFloat(d13) + baseY
          let point13 = CGPoint(x: baseX*0.6*0.9, y: y13)
          let d14 = CGFloat(hrDataSamples[13] - min)/diffValue
          let y14 = scaleY*CGFloat(d14) + baseY
          let point14 = CGPoint(x: baseX*0.65*0.9, y: y14)
          let d15 = CGFloat(hrDataSamples[14] - min)/diffValue
          let y15 = scaleY*CGFloat(d15) + baseY
          let point15 = CGPoint(x: baseX*0.7*0.9, y: y15)
          let d16 = CGFloat(hrDataSamples[15] - min)/diffValue
          let y16 = scaleY*CGFloat(d16) + baseY
          let point16 = CGPoint(x: baseX*0.75*0.9, y: y16)
          let d17 = CGFloat(hrDataSamples[16] - min)/diffValue
          let y17 = scaleY*CGFloat(d17) + baseY
          let point17 = CGPoint(x: baseX*0.8*0.9, y: y17)
          let d18 = CGFloat(hrDataSamples[17] - min)/diffValue
          let y18 = scaleY*CGFloat(d18) + baseY
          let point18 = CGPoint(x: baseX*0.85*0.9, y: y18)
          let d19 = CGFloat(hrDataSamples[18] - min)/diffValue
          let y19 = scaleY*CGFloat(d19) + baseY
          let point19 = CGPoint(x: baseX*0.9*0.9, y: y19)
          let d20 = CGFloat(hrDataSamples[19] - min)/diffValue
          let y20 = scaleY*CGFloat(d20) + baseY
          let point20 = CGPoint(x: baseX*0.95*0.9, y: y20)
          points = [point1, point2, point3, point4, point5, point6, point7, point8, point9, point10, point11, point12, point13, point14, point15, point16, point17, point18, point19, point20]
          // test
          print("1 nr of points should be 20, now it is", points.count)
        }else {
          let point1 = CGPoint(x: 0, y: scaleY)
          let point2 = CGPoint(x: baseX*0.95, y: scaleY)
         
          points = [point1, point2]
          // test
          print("2 nr of points should be 3, now it is", points.count)
        }
      }
      
    }
  }
  
  private func displayAlert(for error: Error) {
    
    let action = WKAlertAction(title: "Error", style: WKAlertActionStyle.default) {
      print("Ok")
    }
    presentAlert(withTitle: "Message", message: error.localizedDescription, preferredStyle: WKAlertControllerStyle.alert, actions:[action])
  }
  
  func eachSecond() {
    seconds += 1
    // MARK: test important point !!!!递加心率
    a += 0
    updateDisplay()
  }
  
  // MARK: MaxHeartRate part
  private func loadAgeAndBiologicalSex() {
    do {
      let userAgeSexAndBloodType = try ProfileDataStore.getAgeSex()
      userHealthProfile.age = userAgeSexAndBloodType.age
      userHealthProfile.biologicalSex = userAgeSexAndBloodType.biologicalSex
    } catch let error {
      self.displayAlert(for: error)
    }
  }
  


  // TODO: 大问题，功能无法使用，而且用了后更加麻烦!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!可能的解决方案：或许可以用一个button在左上角返回？
//    @IBAction func swipeToActiveWorkoutInterfaceController(_ sender: Any) {
//      HeartRateDetailInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: "ActiveWorkoutInterfaceController", context: seconds as AnyObject)]) // why cannot set context to nil?
//    }
  
}


















