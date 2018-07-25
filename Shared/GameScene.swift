//
//  GameScene.swift
//  IntervalWorkout WatchKit Extension
//
//  Created by Hao Wu on 2017/11/21.
//  Copyright © 2017年 Hao Wu. All rights reserved.
//

import SpriteKit
import HealthKit
import WatchKit

class GameScene: SKScene {
  
  let heart = SKSpriteNode(imageNamed: "heartImage")
  let background = SKSpriteNode(imageNamed: "background")
  
  override func sceneDidLoad() {
    backgroundColor = SKColor.black
    background.position = CGPoint(x: size.width * 0.5, y: size.height * 0.9)
    addChild(background)
    heart.position = CGPoint(x: size.width * 0.5, y: size.height * 0.9)
    addChild(heart)
    
  }
  
}
