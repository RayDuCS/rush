//
//  Floor.swift
//  rush
//
//  Created by Rui Du on 10/13/14.
//  Copyright (c) 2014 cgcorp. All rights reserved.
//

import Foundation
import SpriteKit

let ZPOSITION_CUBE = CGFloat(4)
let ZPOSITION_OBSTACLE = CGFloat(3)
let ZPOSITION_PATH = CGFloat(2)
let ZPOSITION_BACKGROUND = CGFloat(1)

let RATIO_FLOOR_PIECE_WIDTH = CGFloat(0.02)
let RATIO_FLOOR_PIECE_HEIGHT = CGFloat(0.01)
let RATIO_FLOOR_PIECE_X = CGFloat(0.4)
let RATIO_FLOOR_PIECE_Y = CGFloat(0.3)
let RATIO_FLOOR_LINE_WIDTH = CGFloat(1)
let RATIO_FLOOR_LINE_HEIGHT = CGFloat(0.01)
let GAME_RESTART_COUNTDOWN = 30
let GAME_OBSTACLE_SAFE_DISTANCE = CGFloat(500)


class Floor {
    
    init () {
    }
    
    // Initialize the floor, returns a set of nodes to be added
    func initialize() -> [SKSpriteNode] {
        var newNodes: [SKSpriteNode] = []
        
        // init rushing cube
        rushingCube = Cube()
        newNodes.append(rushingCube)
        
        // init floor line
        newNodes.append(addLine())
        
        // init obstacles
        obstaclesInFront = []
        for i in 1...2 {
            var obstacles = obstacleGenerator.generateObstables(getStartingXForNewObstacle(),
                y: CGRectGetMaxY(floorLine.frame))
            for obs in obstacles {
                obstaclesInFront.append(obs)
                newNodes.append(obs)
            }
        }
        
        
        // Add paths
        var firstPath = GamePath()
        firstPath.position.x = firstPath.size.width / 2
        firstPath.position.y = firstPath.size.height / 2
        paths.append(firstPath)
        newNodes.append(firstPath)
        var secondPath = firstPath.addNextPath()
        paths.append(secondPath)
        newNodes.append(secondPath)
        
        
        return newNodes
    }
    
    func updateAllObj(x: CGFloat) -> [SKSpriteNode]{
        var newNodes: [SKSpriteNode] = []
        
        // Advance all nodes by x
        rushingCube.update(x)
        
        for obs in obstaclesPassed {
            obs.update(x)
        }
        for obs in obstaclesMayClash {
            obs.update(x)
        }
        for obs in obstaclesInFront {
            obs.update(x)
        }
        
        // Move obs between slots.
        // Will move all obstacles that fails the condition check.
        while let obs = obstaclesInFront.first {
            if CGRectGetMinX(obs.frame) <= CGRectGetMaxX(rushingCube.frame) + x {
                obstaclesInFront.removeAtIndex(0)
                obstaclesMayClash.append(obs)
            } else {
                break
            }
        }
        
        while let obs = obstaclesMayClash.first {
            if CGRectGetMaxX(obs.frame) <= CGRectGetMinX(rushingCube.frame) {
                obstaclesMayClash.removeAtIndex(0)
                obstaclesPassed.append(obs)
            } else {
                break
            }
        }
        
        while let obs = obstaclesPassed.first {
            if CGRectGetMaxX(obs.frame) <= 0 {
                obstaclesPassed.removeAtIndex(0)
                obs.removeFromParent()
                if (obs.isFirstOfPattern()) {
                    // add a new pattern to obstacles in front
                    let newObss = obstacleGenerator.generateObstables(getStartingXForNewObstacle(), y: CGRectGetMaxY(floorLine.frame))
                    for newObs in newObss {
                        newNodes.append(newObs)
                        obstaclesInFront.append(newObs)
                    }
                }
            } else {
                break
            }
        }
        
        // Update path
        for path in paths {
            path.update(x)
        }
        
        while let path = paths.first {
            if CGRectGetMaxX(path.frame) <= 0 {
                paths.removeAtIndex(0)
                path.removeFromParent()
                let newPath = paths.last!.addNextPath()
                newNodes.append(newPath)
                paths.append(newPath)
            } else {
                break
            }
        }
        
        return newNodes
    }
    
    func runClashCheck() {
        //if (frameNumber % 3 != 0) {
            // Perform the clash check every 10 frames.
            //return
        //}
        
        if (rushingCube.isClashed()) {
            return
        }
        
        if obstaclesMayClash.isEmpty {
            rushingCube.shallFall()
            return
        }
        
        for obs in obstaclesMayClash {
            if rushingCube.runClashCheck(obs) {
                break
            }
        }
    }
    
    func getLastObstacle() -> Obstacle? {
        if !obstaclesInFront.isEmpty {
            return obstaclesInFront.last!
        }
        
        if !obstaclesMayClash.isEmpty {
            return obstaclesMayClash.last!
        }
        
        if !obstaclesPassed.isEmpty {
            return obstaclesPassed.last!
        }
        
        return nil
    }
    
    func getStartingXForNewObstacle() -> CGFloat {
        if let obs = getLastObstacle() {
            return CGRectGetMaxX(obs.frame) + GAME_OBSTACLE_SAFE_DISTANCE
        }
        
        return viewWidth * RATIO_OBSTACLE_START_POS_X
    }
    
    // Invoked at each frame, update all nodes
    func update(speed: CGFloat) -> [SKSpriteNode] {
        var newNodes: [SKSpriteNode] = []
        
        // Update frameNumber
        frameNumber++
        frameNumber = frameNumber % 1000
        
        if (rushingCube.isClashed()) {
            restartCountdown--
            if (restartCountdown > 0) {
                return newNodes;
            }
            
            // Restarting state
            newNodes = updateAllObj(rushingCube.getAdvanceX())
            rushingCube.doRevive()
            restartCountdown = GAME_RESTART_COUNTDOWN
            return newNodes
        }
        
        // Update cube
        newNodes = updateAllObj(speed)
        // Update floor pieces.
                
        runClashCheck()
        
        return newNodes
    }


    func addLine() -> SKSpriteNode {
        let lineY = rushingCube.position.y - rushingCube.size.height / 2 - viewHeight * RATIO_FLOOR_LINE_HEIGHT / 2
        
        floorLine = SKSpriteNode(color: UIColor.blackColor(),
                                 size: CGSize(width: viewWidth * RATIO_FLOOR_LINE_WIDTH,
                                              height: viewHeight * RATIO_FLOOR_LINE_HEIGHT))
        floorLine.position.x = viewWidth / 2
        floorLine.position.y = lineY
        
        return floorLine
    }

    var backgrounds: [GameBackground] = [] // the backgrounds
    var paths: [GamePath] = [] // the paths
    
    var floorLine: SKSpriteNode = SKSpriteNode() // the floor
    var rushingCube: Cube = Cube() // the cube.
    
    var obstaclesPassed: [Obstacle] = [] // passed obstacles, should be cleaned.
    var obstaclesMayClash: [Obstacle] = [] // obstacles those are close to the cube!
    var obstaclesInFront: [Obstacle] = [] // obstacles in front.
    
    var obstacleGenerator: ObstacleGenerator = ObstacleGenerator() // Generate obstacles.
    var restartCountdown = GAME_RESTART_COUNTDOWN // Timer for restart the game.
    var frameNumber = 0 // Tracks the amount of update() getting called, used for optimization.
}