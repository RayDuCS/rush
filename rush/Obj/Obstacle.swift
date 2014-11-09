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
let RATIO_OBSTACLE_TRIANGLE_CLASH_WIDTH = CGFloat(0.6)
let RATIO_OBSTACLE_TRIANGLE_CLASH_HEIGHT = CGFloat(0.6)
let RATIO_OBSTACLE_TRIANGLE_WIDTH = CGFloat(0.06)
let RATIO_OBSTACLE_TRIANGLE_HEIGHT = CGFloat(0.08)
let RATIO_OBSTACLE_TRIANGLE_DISTANCE = CGFloat(0.5)
let RATIO_OBSTACLE_RECT_DISTANCE = CGFloat(0.5)
let RATIO_OBSTACLE_RECT_WIDTH = CGFloat(0.06)
let RATIO_OBSTACLE_RECT_HEIGHT = CGFloat(0.08)
let RATIO_OBSTACLE_RECT_CLASH_SAFEZONE = CGFloat(0.02)
let RATIO_OBSTACLE_RECT_CLASH_WIDTH = CGFloat(0.6)
let RATIO_OBSTACLE_RECT_CLASH_HEIGHT = CGFloat(0.6)

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

enum ObstacleClashType {
    case OBSTACLE_CLASH_TYPE_CLASHED
    case OBSTACLE_CLASH_TYPE_OK
    case OBSTACLE_CLASH_TYPE_OK_TO_FALL
}

class Obstacle : SKSpriteNode {
    init(texture: SKTexture, size: CGSize, type: ObstacleType) {
        //oldPos = CGPoint()
        self.type = type
        super.init(texture: texture, color: UIColor.clearColor(), size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func isFirstOfPattern() -> Bool {
        return firstOfPattern
    }
    
    func setFirstOfPattern() {
        firstOfPattern = true
    }
    
    func setPosition(x:CGFloat, y:CGFloat) {
        position.x = x
        position.y = y
        
        var clashWidth = frame.width * RATIO_OBSTACLE_TRIANGLE_CLASH_WIDTH
        var clashHeight = frame.height * RATIO_OBSTACLE_TRIANGLE_CLASH_HEIGHT
        clashCheckFrame = CGRectMake(x - clashWidth / 2, y - clashHeight / 2, clashWidth, clashHeight)
    }
    
    func move(x:CGFloat, y:CGFloat) {
        position.x -= x
        position.y -= y
        clashCheckFrame.origin.x -= x
        clashCheckFrame.origin.y -= y
    }
    
    func setRelativePos(x:CGFloat, y:CGFloat) {
        reviveRelativePosition.x = x
        reviveRelativePosition.y = y
    }
    
    func getRevivePoint() -> CGPoint {
        return CGPointMake(reviveRelativePosition.x + position.x, reviveRelativePosition.y + position.y)
    }
    
    func performClashCheck(cube: Cube) -> ObstacleClashType {
        if CGRectIntersectsRect(cube.frame, clashCheckFrame) {
            return .OBSTACLE_CLASH_TYPE_CLASHED
        }
        
        return .OBSTACLE_CLASH_TYPE_OK
    }
    
    var firstOfPattern = false
    var type: ObstacleType = .OBSTACLE_TYPE_TRIANGLE
    var reviveRelativePosition = CGPointMake(0, 0)
    var clashCheckFrame = CGRectMake(0, 0, 0, 0)
}

class ObstacleTriangle: Obstacle {
    init() {
        //oldPos = CGPoint()
        let texture = SKTexture(imageNamed: "triangle.png")
        super.init(texture: texture,
            size: CGSize(width: viewWidth * RATIO_OBSTACLE_TRIANGLE_WIDTH, height: viewHeight * RATIO_OBSTACLE_TRIANGLE_HEIGHT),
            type: .OBSTACLE_TYPE_TRIANGLE)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func performClashCheck(cube: Cube) -> ObstacleClashType {
        return super.performClashCheck(cube)
    }
}

class ObstacleBackTriangle: Obstacle {
    init() {
        //oldPos = CGPoint()
        let texture = SKTexture(imageNamed: "back_triangle.png")
        super.init(texture: texture,
            size: CGSize(width: viewWidth * RATIO_OBSTACLE_TRIANGLE_WIDTH, height: viewHeight * RATIO_OBSTACLE_TRIANGLE_HEIGHT),
            type: .OBSTACLE_TYPE_BACK_TRIANGLE)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func performClashCheck(cube: Cube) -> ObstacleClashType {
        return super.performClashCheck(cube)
    }
}


class ObstacleRect: Obstacle {
    
    init() {
        //oldPos = CGPoint()
        let texture = SKTexture(imageNamed: "rect.jpeg")
        super.init(texture: texture,
            size: CGSize(width: viewWidth * RATIO_OBSTACLE_RECT_WIDTH, height: viewHeight * RATIO_OBSTACLE_RECT_HEIGHT),
            type: .OBSTACLE_TYPE_RECT)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setPosition(x: CGFloat, y: CGFloat) {
        position.x = x
        position.y = y
        
        var clashWidth = frame.width * RATIO_OBSTACLE_RECT_CLASH_WIDTH
        var clashHeight = frame.height * RATIO_OBSTACLE_RECT_CLASH_HEIGHT
        clashCheckFrame = CGRectMake(x - clashWidth / 2, y - clashHeight / 2, clashWidth, clashHeight)
    }
    
    override func performClashCheck(cube: Cube) -> ObstacleClashType {
        
        if (CGRectGetMaxX(cube.frame) >= CGRectGetMinX(frame)) &&
            (CGRectGetMinX(cube.frame) <= CGRectGetMaxX(frame)) &&
            (CGRectGetMinY(cube.frame) <= CGRectGetMaxY(frame)) &&
            (CGRectGetMinY(cube.frame) >= CGRectGetMaxY(frame) - RATIO_OBSTACLE_RECT_CLASH_SAFEZONE * viewHeight) {
            return .OBSTACLE_CLASH_TYPE_OK_TO_FALL
        }
        
        return super.performClashCheck(cube)
    }
    
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
        let distanceBetweenObsX = CGFloat(viewWidth * RATIO_OBSTACLE_TRIANGLE_DISTANCE)
        var obs: [Obstacle] = []
        var prevX = CGFloat(0)
        var prevY = CGFloat(0)
        var firstObsTriangle = ObstacleTriangle()
        
        prevX = x + firstObsTriangle.size.width / 2
        prevY = firstObsTriangle.size.height / 2 + y
        firstObsTriangle.setPosition(prevX, y: prevY)
        firstObsTriangle.setFirstOfPattern()
        firstObsTriangle.setRelativePos(2 * distanceBetweenObsX + 100, y: 0)
        obs.append(firstObsTriangle)
        
        for i in 1...2 {
            prevX += distanceBetweenObsX
            
            var obsTriangle = ObstacleTriangle()
            obsTriangle.setPosition(prevX, y: prevY)
            let distance = (CGFloat)(2 - i) * distanceBetweenObsX + 100
            obsTriangle.setRelativePos(distance, y: 0)
            obs.append(obsTriangle)
        }
        
        
        return obs
    }
    
    func generateObsPress(x: CGFloat, y: CGFloat) -> [Obstacle] {
        let distanceBetweenObsX = CGFloat(viewWidth * RATIO_OBSTACLE_RECT_DISTANCE)
        var obs: [Obstacle] = []
        var prevX = CGFloat(0)
        var prevY = CGFloat(0)
        var firstObsRect = ObstacleRect()
        
        
        firstObsRect.type = .OBSTACLE_TYPE_RECT
        prevX = x + firstObsRect.size.width / 2
        prevY = firstObsRect.size.height / 2 + y
        firstObsRect.setPosition(prevX, y: prevY)
        firstObsRect.setFirstOfPattern()
        firstObsRect.setRelativePos(2 * distanceBetweenObsX + 100, y: 0)
        obs.append(firstObsRect)
        
        var y_scale = CGFloat(2)
        for i in 1...2 {
            var obsRect = ObstacleRect()
            obsRect.type = .OBSTACLE_TYPE_RECT
            obsRect.yScale = y_scale // resize the rect
            
            prevX += distanceBetweenObsX
            prevY = obsRect.size.height / 2 + y
            obsRect.setPosition(prevX, y: prevY)
            let distance = (CGFloat)(2 - i) * distanceBetweenObsX + 100
            obsRect.setRelativePos(distance, y: 0)
            obs.append(obsRect)
            y_scale++
        }
        
        
        return obs
    }
    
    func generateObsFreeze(x: CGFloat, y: CGFloat) -> [Obstacle] {
        let distanceBetweenObsX = CGFloat(viewWidth * RATIO_OBSTACLE_TRIANGLE_WIDTH)
        var obs: [Obstacle] = []
        var prevX = CGFloat(0)
        var prevY = CGFloat(0)
        var firstObsTriangle = ObstacleBackTriangle()
        
        prevX = x + firstObsTriangle.size.width / 2
        prevY = firstObsTriangle.size.height / 2 + y + CUBE_JUMP_HEIGHT_MAX * 2 / 3
        firstObsTriangle.setPosition(prevX, y: prevY)
        firstObsTriangle.setFirstOfPattern()
        firstObsTriangle.setRelativePos(2 * distanceBetweenObsX + 100, y: 0)
        obs.append(firstObsTriangle)
        
        for i in 1...2 {
            prevX += distanceBetweenObsX
            
            var obsTriangle = ObstacleBackTriangle()
            obsTriangle.setPosition(prevX, y: prevY)
            let distance = (CGFloat)(2 - i) * distanceBetweenObsX + 100
            obsTriangle.setRelativePos(distance, y: 0)
            obs.append(obsTriangle)
        }
        
        
        return obs
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
