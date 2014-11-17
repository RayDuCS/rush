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
let RATIO_OBSTACLE_TRIANGLE_CLASH_WIDTH = CGFloat(0.4)
let RATIO_OBSTACLE_TRIANGLE_CLASH_HEIGHT = CGFloat(0.4)
let RATIO_OBSTACLE_TRIANGLE_WIDTH = CGFloat(0.06)
let RATIO_OBSTACLE_TRIANGLE_HEIGHT = CGFloat(0.08)
let RATIO_OBSTACLE_TRIANGLE_DISTANCE = CGFloat(0.5)
let RATIO_OBSTACLE_RECT_DISTANCE = CGFloat(0.18)
let RATIO_OBSTACLE_RECT_WIDTH = CGFloat(0.06)
let RATIO_OBSTACLE_RECT_HEIGHT = CGFloat(0.0926)
let RATIO_OBSTACLE_RECT_CLASH_HEIGHT = CGFloat(0.065)
let RATIO_OBSTACLE_RECT_CLASH_HEIGHT_2 = CGFloat(0.13)
let RATIO_OBSTACLE_RECT_CLASH_HEIGHT_3 = CGFloat(0.19)
let RATIO_OBSTACLE_RECT_HEIGHT_INCR = CGFloat(0.06)
let RATIO_OBSTACLE_RECT_CLASH_SAFEZONE = CGFloat(0.03)

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

class Obstacle : GameNode {
    init(texture: SKTexture, size: CGSize, type: ObstacleType) {
        //oldPos = CGPoint()
        self.type = type
        super.init(texture: texture, size: size)
        self.zPosition = ZPOSITION_OBSTACLE
        clashWidth = frame.width * RATIO_OBSTACLE_TRIANGLE_CLASH_WIDTH
        clashHeight = frame.height * RATIO_OBSTACLE_TRIANGLE_CLASH_HEIGHT
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
        
        clashCheckFrame = CGRectMake(x - clashWidth / 2, y - clashHeight / 2, clashWidth, clashHeight)
        println("frame \(self.size.width)/\(self.size.height), clash \(self.clashCheckFrame.width)/\(self.clashCheckFrame.height)")
    }
    
    override func update(x: CGFloat) {
        position.x -= x
        clashCheckFrame.origin.x -= x
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
    var clashWidth = CGFloat(0)
    var clashHeight = CGFloat(0)
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

class ObstacleInverseTriangle: Obstacle {
    init() {
        //oldPos = CGPoint()
        let texture = SKTexture(imageNamed: "inversetriangle_body.png")
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
    
    convenience init() {
        let texture = SKTexture(imageNamed: "rectangular.png")
        self.init(texture:texture, height: viewHeight * RATIO_OBSTACLE_RECT_HEIGHT, clashHeight: viewHeight * RATIO_OBSTACLE_RECT_CLASH_HEIGHT)
    }
    
    init(texture: SKTexture, height: CGFloat, clashHeight: CGFloat) {
        super.init(texture: texture,
            size: CGSize(width: viewWidth * RATIO_OBSTACLE_RECT_WIDTH, height: height),
            type: .OBSTACLE_TYPE_RECT)
        
        self.clashWidth = viewWidth * RATIO_OBSTACLE_RECT_WIDTH
        self.clashHeight = clashHeight
        println("frame aaa \(height)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setClashFrame(width: CGFloat, height: CGFloat) {
        clashWidth = width
        clashHeight = height
    }
    
    override func performClashCheck(cube: Cube) -> ObstacleClashType {
        println("\(CGRectGetMaxX(cube.frame))/\(CGRectGetMinX(cube.frame))/\(CGRectGetMinY(cube.frame))")
        println("\(CGRectGetMaxX(clashCheckFrame))/\(CGRectGetMinX(clashCheckFrame))/\(CGRectGetMaxY(clashCheckFrame))")
        if (CGRectGetMaxX(cube.frame) >= CGRectGetMinX(clashCheckFrame)) &&
            (CGRectGetMinX(cube.frame) <= CGRectGetMaxX(clashCheckFrame)) &&
            (CGRectGetMinY(cube.frame) <= CGRectGetMaxY(clashCheckFrame)) &&
            (CGRectGetMinY(cube.frame) >= CGRectGetMaxY(clashCheckFrame) - RATIO_OBSTACLE_RECT_CLASH_SAFEZONE * viewHeight) {
            return .OBSTACLE_CLASH_TYPE_OK_TO_FALL
        }
        
        return super.performClashCheck(cube)
    }
}

// The obstacle pattern. Generate the next obstacle on the fly
class ObstacleGenerator {
    init () {
        currentPattern = .OBSTACLE_PATTERN_PRESS
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
        
        var obs = generateObsTriangles(x, y: y, distanceBetObsX: distanceBetweenObsX, amount: 3)
        obs[0].setFirstOfPattern()
        return obs
    }
    
    func generateObsTriangles(x: CGFloat, y: CGFloat, distanceBetObsX: CGFloat, amount: CGFloat) -> [Obstacle]{
        var obs: [Obstacle] = []
        var prevX = CGFloat(0)
        var prevY = CGFloat(0)
        var firstObsTriangle = ObstacleTriangle()
        
        prevX = x + firstObsTriangle.size.width / 2
        prevY = firstObsTriangle.size.height / 2 + y
        firstObsTriangle.setPosition(prevX, y: prevY)
        firstObsTriangle.setRelativePos((amount - 1) * distanceBetObsX + 100, y: 0)
        obs.append(firstObsTriangle)
        
        for var i = CGFloat(1); i < amount; i++ {
            prevX += distanceBetObsX
            
            var obsTriangle = ObstacleTriangle()
            obsTriangle.setPosition(prevX, y: prevY)
            let distance = (CGFloat)(amount - i - 1) * distanceBetObsX + 100
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
        for tri in generateObsTriangles(prevX + viewWidth * RATIO_OBSTACLE_TRIANGLE_WIDTH / 2, y: y, distanceBetObsX: viewWidth * RATIO_OBSTACLE_TRIANGLE_WIDTH, amount: 2) {
            tri.setRelativePos(2 * distanceBetweenObsX + 100, y: 0)
            obs.append(tri)
        }
        
        var heights:[CGFloat] = []
        heights.append(viewHeight * RATIO_OBSTACLE_RECT_CLASH_HEIGHT_2)
        heights.append(viewHeight * RATIO_OBSTACLE_RECT_CLASH_HEIGHT_3)
        for i in 1...2 {
            let imageName = "rectangular" + String(i+1) + ".png"
            var texture = SKTexture(imageNamed: imageName)
            var height_incr_ratio = RATIO_OBSTACLE_RECT_HEIGHT_INCR * CGFloat(i)
            var height = viewHeight * (RATIO_OBSTACLE_RECT_HEIGHT + height_incr_ratio)
            
            var obsRect = ObstacleRect(texture: texture, height: height, clashHeight: heights[i-1])
            obsRect.type = .OBSTACLE_TYPE_RECT
            
            prevX += distanceBetweenObsX
            prevY = obsRect.size.height / 2 + y
            obsRect.setPosition(prevX, y: prevY)
            let distance = (CGFloat)(2 - i) * distanceBetweenObsX + 100
            obsRect.setRelativePos(distance, y: 0)
            obs.append(obsRect)
            
            if i == 1 {
                for tri in generateObsTriangles(prevX + viewWidth * RATIO_OBSTACLE_TRIANGLE_WIDTH / 2, y: y, distanceBetObsX: viewWidth * RATIO_OBSTACLE_TRIANGLE_WIDTH, amount: 2) {
                    tri.setRelativePos(distance, y: 0)
                    obs.append(tri)
                }
            }
        }
        
        
        return obs
    }
    
    func generateObsFreeze(x: CGFloat, y: CGFloat) -> [Obstacle] {
        let distanceBetweenObsX = CGFloat(viewWidth * RATIO_OBSTACLE_TRIANGLE_WIDTH)
        let extraDistance = CGFloat(2)
        var obs: [Obstacle] = []
        var prevX = CGFloat(0)
        var prevY = CGFloat(0)
        var firstObsTriangle = ObstacleInverseTriangle()
        
        let amount = 9
        
        
        prevX = x + firstObsTriangle.size.width / 2
        prevY = firstObsTriangle.size.height / 2 + y + CUBE_JUMP_HEIGHT_MAX * 2 / 3
        firstObsTriangle.setPosition(prevX, y: prevY)
        firstObsTriangle.setFirstOfPattern()
        firstObsTriangle.setRelativePos(CGFloat(amount - 1) * distanceBetweenObsX + 100, y: 0)
        obs.append(firstObsTriangle)
        firstObsTriangle.texture! = SKTexture(imageNamed: "inversetriangle_head.png")
        
        for i in 1...(amount - 1) {
            prevX += distanceBetweenObsX + extraDistance
            
            var obsTriangle = ObstacleInverseTriangle()
            obsTriangle.setPosition(prevX, y: prevY)
            let distance = (CGFloat)(amount - i - 1) * distanceBetweenObsX + 100
            obsTriangle.setRelativePos(distance, y: 0)
            obsTriangle.texture! = SKTexture(imageNamed: "inversetriangle_body.png")
            obs.append(obsTriangle)
        }
        
        prevX += distanceBetweenObsX + extraDistance
        var lastObsTriangle = ObstacleInverseTriangle()
        lastObsTriangle.setPosition(prevX, y: prevY)
        let lastdistance = (CGFloat)(distanceBetweenObsX)
        lastObsTriangle.setRelativePos(lastdistance, y: 0)
        lastObsTriangle.texture! = SKTexture(imageNamed: "inversetriangle_tail.png")
        obs.append(lastObsTriangle)
        
        
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
