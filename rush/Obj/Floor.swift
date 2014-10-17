//
//  Floor.swift
//  rush
//
//  Created by Rui Du on 10/13/14.
//  Copyright (c) 2014 cgcorp. All rights reserved.
//

import Foundation
import SpriteKit

class Floor {
    
    init () {
    }
    
    init(width: CGFloat, height: CGFloat) {
        floorPieces = []
        sampleFloorPiece = SKSpriteNode(color: UIColor.blueColor(), size: CGSize(width: width, height: height))
        
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
        println()
        for piece in floorPieces {
            piece.position.x -= speed
            println("piece \(piece.position.x)")
        }
        
        if let piece = floorPieces.first {
            if CGRectGetMinX(piece.frame) <= 0 {
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
}