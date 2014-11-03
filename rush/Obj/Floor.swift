//
//  Floor.swift
//  rush
//
//  Created by Rui Du on 10/13/14.
//  Copyright (c) 2014 cgcorp. All rights reserved.
//

import Foundation
import SpriteKit

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
        floorPieces = []
        Floor.sampleFloorPiece.size = CGSize(width: viewWidth * RATIO_FLOOR_PIECE_WIDTH,
                                             height: viewHeight * RATIO_FLOOR_PIECE_HEIGHT)
    }
    
    
    // Initialize the floor, returns a set of nodes to be added
    func initialize() -> [SKSpriteNode] {
        var newNodes: [SKSpriteNode] = []
        
        // init rushing cube
        rushingCube = Cube(color: UIColor.clearColor())
        rushingCube.zPosition = 1 //make sure cube is always getting rendered
        newNodes.append(rushingCube)
        
        // init floor line
        newNodes.append(addLine())
        let pieces = fillPieces()
        for piece in pieces {
            newNodes.append(piece)
        }
        
        // init obstacles
        obstaclesInFront = obstacleGenerator.generateObstables(viewWidth * RATIO_OBSTACLE_START_POS_X,
                                                               y: CGRectGetMaxY(floorLine.frame))
        for obs in obstaclesInFront {
            newNodes.append(obs)
        }
        
        
        return newNodes
    }
    
    func advanceAllObj(x: CGFloat) {
        // Advance all obj by x, except the cube
        for piece in floorPieces {
            piece.position.x -= x
        }
        
        for obs in obstaclesPassed {
            obs.move(x, y: 0)
        }
        for obs in obstaclesMayClash {
            obs.move(x, y: 0)
        }
        for obs in obstaclesInFront {
            obs.move(x, y: 0)
        }
    }
    
    func runClashCheck() {
        if (frameNumber % 5 != 0) {
            // Perform the clash check every 10 frames.
            return
        }
        
        if (rushingCube.isClashed()) {
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
        
        return viewWidth
    }
    
    // Invoked at each frame, update all nodes
    func update(speed: CGFloat) -> [SKSpriteNode] {
        // Update frameNumber
        frameNumber++
        frameNumber = frameNumber % 1000
        
        if (rushingCube.isClashed()) {
            restartCountdown--
            if (restartCountdown > 0) {
                return [];
            }
            
            // Restarting state
            advanceAllObj(rushingCube.getAdvanceX())
            rushingCube.revive()
            restartCountdown = GAME_RESTART_COUNTDOWN
        }
        
        var newNodes: [SKSpriteNode] = []
        
        // Update cube
        rushingCube.jump()
        
        // Update floor pieces.
        for piece in floorPieces {
            piece.position.x -= speed
        }
        
        if let piece = floorPieces.first {
            if CGRectGetMaxX(piece.frame) <= 0 {
                if let newPiece = self.addNextPiece() {
                    floorPieces.removeAtIndex(0)
                    piece.removeFromParent()
                    
                    newNodes.append(newPiece)
                }
            }
        }
        
        // Update obstacles.
        for obs in obstaclesPassed {
            obs.move(speed, y: 0)
        }
        
        for obs in obstaclesMayClash {
            obs.move(speed, y: 0)
        }
        
        for obs in obstaclesInFront {
            obs.move(speed, y: 0)
            // may need to add to obstaclesMayClash
        }
        
        // Move obs between slots.
        if let obs = obstaclesInFront.first {
            if CGRectGetMinX(obs.frame) <= CGRectGetMaxX(rushingCube.frame) + speed {
                obstaclesInFront.removeAtIndex(0)
                obstaclesMayClash.append(obs)
            }
        }
        
        if let obs = obstaclesMayClash.first {
            if CGRectGetMaxX(obs.frame) <= CGRectGetMinX(rushingCube.frame) {
                obstaclesMayClash.removeAtIndex(0)
                obstaclesPassed.append(obs)
            }
        }
        
        if let obs = obstaclesPassed.first {
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
            }
        }
        
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
    
    func fillPieces() -> [SKSpriteNode] {
        let x = CGFloat(0)
        let y = floorLine.position.y - floorLine.size.height / 2 - viewHeight * RATIO_FLOOR_PIECE_HEIGHT / 2
        let amount = Int(1 / RATIO_FLOOR_PIECE_WIDTH)
        
        addPiece(x, y: y)
        for i in 1...(amount - 1) {
            addNextPiece()
        }
        
        return floorPieces
    }
    
    func addPiece(x: CGFloat, y: CGFloat) -> SKSpriteNode {
        var piece = (Floor.sampleFloorPiece as SKSpriteNode).copy() as SKSpriteNode
        piece.position.x = x
        piece.position.y = y
        
        floorPieces.append(piece)
        
        return piece
    }
    
    func addNextPiece() -> SKSpriteNode? {
        if let lastPiece = floorPieces.last {
            let nextPiece = (Floor.sampleFloorPiece as SKSpriteNode).copy() as SKSpriteNode
            
            nextPiece.position.x = lastPiece.position.x + Floor.sampleFloorPiece.size.width + 50
            nextPiece.position.y = lastPiece.position.y
            floorPieces.append(nextPiece)
            return nextPiece
        }
        
        return nil
    }
    
    
    
    class var sampleFloorPiece: SKSpriteNode {
    struct Static {
        static var instance: SKSpriteNode?
        static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = SKSpriteNode(color: UIColor.blueColor(), size: CGSize(width: 40, height: 40))
        }
        
        return Static.instance!
    }
    
    var floorPieces: [SKSpriteNode] = [] // the moving pieces under the floor.
    var floorLine: SKSpriteNode = SKSpriteNode() // the floor
    var rushingCube: Cube = Cube() // the cube.
    
    var obstaclesPassed: [Obstacle] = [] // passed obstacles, should be cleaned.
    var obstaclesMayClash: [Obstacle] = [] // obstacles those are close to the cube!
    var obstaclesInFront: [Obstacle] = [] // obstacles in front.
    
    var obstacleGenerator: ObstacleGenerator = ObstacleGenerator() // Generate obstacles.
    var restartCountdown = GAME_RESTART_COUNTDOWN // Timer for restart the game.
    var frameNumber = 0 // Tracks the amount of update() getting called, used for optimization.
}