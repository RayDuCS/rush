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

class Floor {
    
    init () {
    }
    
    init(width: CGFloat, height: CGFloat) {
        floorPieces = []
        sampleFloorPiece = SKSpriteNode(color: UIColor.blueColor(), size: CGSize(width: width, height: height))
    }
    
    func addLine(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> SKSpriteNode {
        floorLine = SKSpriteNode(color: UIColor.blackColor(), size: CGSize(width: width, height: height))
        floorLine.position.x = x
        floorLine.position.y = y
        
        return floorLine
    }
    
    func fillPieces(x: CGFloat, y: CGFloat) -> [SKSpriteNode] {
        let amount = Int(1 / RATIO_FLOOR_PIECE_WIDTH)
        
        addPiece(x, y: y)
        for i in 1...(amount - 1) {
            addNextPiece()
        }
        
        return floorPieces
    }
    
    func addPiece(x: CGFloat, y: CGFloat) -> SKSpriteNode {
        var piece = (sampleFloorPiece as SKSpriteNode).copy() as SKSpriteNode
        piece.position.x = x
        piece.position.y = y
        
        floorPieces.append(piece)
        
        return piece
    }
    
    func addNextPiece() -> SKSpriteNode? {
        if let lastPiece = floorPieces.last {
            let nextPiece = (sampleFloorPiece as SKSpriteNode).copy() as SKSpriteNode
            
            nextPiece.position.x = lastPiece.position.x + sampleFloorPiece.size.width + 50
            nextPiece.position.y = lastPiece.position.y
            floorPieces.append(nextPiece)
            return nextPiece
        }
        
        return nil
    }
    
    func update(speed: CGFloat) ->SKSpriteNode? {
        for piece in floorPieces {
            piece.position.x -= speed
        }
        
        if let piece = floorPieces.first {
            if CGRectGetMaxX(piece.frame) <= 0 {
                if let newPiece = self.addNextPiece() {
                    floorPieces.removeAtIndex(0)
                    piece.removeFromParent()
                    
                    return newPiece
                }
            }

        }
        
        return nil
    }
    
    var floorPieces: [SKSpriteNode] = []
    var sampleFloorPiece: SKSpriteNode = SKSpriteNode()
    var floorLine: SKSpriteNode = SKSpriteNode()
}