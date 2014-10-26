//
//  Obstacle.swift
//  rush
//
//  Created by Rui Du on 10/25/14.
//  Copyright (c) 2014 cgcorp. All rights reserved.
//

import Foundation
import SpriteKit

let RATIO_OBSTACLE_START_POS_X = CGFloat(0.7)
let RATIO_OBSTACLE_TRIANGLE_WIDTH = CGFloat(0.07)
let RATIO_OBSTACLE_TRIANGLE_HEIGHT = CGFloat(0.09)
let RATIO_OBSTACLE_TRIANGLE_DISTANCE = CGFloat(0.4)

enum ObstacleType {
    case OBSTACLE_TYPE_TRIANGLE
    case OBSTACLE_TYPE_BACK_TRIANGLE
    case OBSTACLE_TYPE_RECT
}

enum ObstaclePattern {
    case OBSTACLE_PATTERN_THREE_TRIANGLE  // Three triangles
    case OBSTACLE_PATTERN_PRESS           // One press should do it!
    case OBSTACLE_PATTERN_FREEZE          // Don't tap nor press!
}

class Obstacle : SKSpriteNode {
    init(texture: SKTexture, color: UIColor!, size: CGSize, type: ObstacleType) {
        //oldPos = CGPoint()
        self.type = type
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience override init() {
        let texture = SKTexture(imageNamed: "triangle.png")
        self.init(texture:texture, color: UIColor.clearColor(), size: CGSize(width: 40, height: 40), type:.OBSTACLE_TYPE_TRIANGLE)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func isFirstOfPattern() -> Bool {
        return firstOfPattern
    }
    
    func setFirstOfPattern() {
        firstOfPattern = true
    }
    
    class var sampleTriangle: Obstacle {
    struct Static {
        static var instance: Obstacle?
        static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = Obstacle(texture: SKTexture(imageNamed: "triangle.png"),
                                       color: UIColor.clearColor(),
                                       size: CGSize(width: viewWidth * RATIO_OBSTACLE_TRIANGLE_WIDTH,
                                                    height: viewHeight * RATIO_OBSTACLE_TRIANGLE_HEIGHT),
                                       type: .OBSTACLE_TYPE_TRIANGLE)
        }
        
        return Static.instance!
    }
    
    class var sampleBackTriangle: Obstacle {
    struct Static {
        static var instance: Obstacle?
        static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = Obstacle(texture: SKTexture(imageNamed: "back_triangle.png"),
                                       color: UIColor.clearColor(),
                                       size: CGSize(width: 40, height: 40),
                                       type: .OBSTACLE_TYPE_BACK_TRIANGLE)
        }
        
        return Static.instance!
    }
    
    class var sampleRect: Obstacle {
    struct Static {
        static var instance: Obstacle?
        static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = Obstacle(texture: SKTexture(imageNamed: "rect.png"),
                                       color: UIColor.clearColor(),
                                       size: CGSize(width: 40, height: 40),
                                       type: .OBSTACLE_TYPE_RECT)
        }
        
        return Static.instance!
    }
    
    var firstOfPattern = false
    var type: ObstacleType = .OBSTACLE_TYPE_TRIANGLE
}

// The obstacle pattern. Generate the next obstacle on the fly
class ObstacleGenerator {
    init () {
        currentPattern = .OBSTACLE_PATTERN_THREE_TRIANGLE
    }
    
    func getNextPattern() -> ObstaclePattern {
        switch (currentPattern) {
        case .OBSTACLE_PATTERN_THREE_TRIANGLE:
            return .OBSTACLE_PATTERN_PRESS
        case .OBSTACLE_PATTERN_PRESS:
            return .OBSTACLE_PATTERN_FREEZE
        case .OBSTACLE_PATTERN_FREEZE:
            return .OBSTACLE_PATTERN_THREE_TRIANGLE
        }
    }
    
    func generateObsThreeTriangle(x: CGFloat, y: CGFloat) -> [Obstacle] {
        var obs: [Obstacle] = []
        var prevX = CGFloat(0)
        var prevY = CGFloat(0)
        
        var firstObsTriangle = (Obstacle.sampleTriangle as Obstacle).copy() as Obstacle
        
        prevX = x + firstObsTriangle.size.width / 2
        prevY = firstObsTriangle.size.height / 2 + y
        firstObsTriangle.position = CGPointMake(prevX, prevY)
        firstObsTriangle.setFirstOfPattern()
        obs.append(firstObsTriangle)
        
        for i in 1...2 {
            prevX += viewWidth * RATIO_OBSTACLE_TRIANGLE_DISTANCE
            
            var obsTriangle = (Obstacle.sampleTriangle as Obstacle).copy() as Obstacle
            obsTriangle.position = CGPointMake(prevX, prevY)
            obs.append(obsTriangle)
        }
        
        
        return obs
    }
    
    func generateObsPress(x: CGFloat, y: CGFloat) -> [Obstacle] {
        return generateObsThreeTriangle(x, y: y)
    }
    
    func generateObsFreeze(x: CGFloat, y: CGFloat) -> [Obstacle] {
        return generateObsThreeTriangle(x, y: y)
    }
    
    func generateObstables(x: CGFloat, y: CGFloat) -> [Obstacle] {
        var obs : [Obstacle] = []
        
        switch (currentPattern) {
        case .OBSTACLE_PATTERN_THREE_TRIANGLE:
            obs = generateObsThreeTriangle(x, y: y)
        case .OBSTACLE_PATTERN_PRESS:
            obs = generateObsPress(x, y: y)
        case .OBSTACLE_PATTERN_FREEZE:
            obs = generateObsFreeze(x, y: y)
        }
        
        currentPattern = getNextPattern()
        return obs
    }
    
    var currentPattern : ObstaclePattern = .OBSTACLE_PATTERN_THREE_TRIANGLE
}

/* Sample Singleton
class Singleton {
    class var sharedInstance: Singleton {
    struct Static {
        static var instance: Singleton?
        static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = Singleton()
        }
        
        return Static.instance!
    }
}
*/
