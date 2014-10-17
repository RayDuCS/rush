//
//  Cube.swift
//  rush
//
//  Created by Rui Du on 10/13/14.
//  Copyright (c) 2014 cgcorp. All rights reserved.
//

import Foundation
import SpriteKit

let CUBE_JUMP_HEIGHT_MAX = CGFloat(80.0)
let CUBE_JUMP_SPEED = CGFloat(4.0)

let RATIO_CUBE_WIDTH = CGFloat(0.08)
let RATIO_CUBE_HEIGHT = CGFloat(0.08)
let RATIO_CUBE_X = CGFloat(0.3)
let RATIO_CUBE_Y = CGFloat(0.5)

// CubeState describes the state of Cube
enum CubeState {
    case CUBESTATE_IDLE
    case CUBESTATE_JUMPING
    case CUBESTATE_FALLING
}

class Cube: SKSpriteNode {
    
    init(color: UIColor!, size: CGSize) {
        //oldPos = CGPoint()
        let texture = SKTexture(imageNamed: "images.jpeg")
        state = .CUBESTATE_IDLE
        super.init(texture: texture, color: color, size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience override init() {
        let texture = SKTexture(imageNamed: "images.jpeg")
        self.init(color: UIColor.clearColor(), size: CGSize(width: 40, height: 40))
    }
    
    func userTapped() {
        tapped = true;
    }
    
    func jump() {
        if (!tapped) {
            return
        }
        
        switch (state) {
        case .CUBESTATE_IDLE:
            state = .CUBESTATE_JUMPING
            oldPos.x = position.x
            oldPos.y = position.y
            self.runAction(SKAction.rotateByAngle(CGFloat(-2 * M_PI), duration: NSTimeInterval(0.1)))
            
        case .CUBESTATE_JUMPING:
            if (position.y + CUBE_JUMP_SPEED > oldPos.y + CUBE_JUMP_HEIGHT_MAX ) {
                // Time to fall
                state = .CUBESTATE_FALLING
                position.y -= CUBE_JUMP_SPEED
            } else {
                position.y += CUBE_JUMP_SPEED
            }
            
            
        case .CUBESTATE_FALLING:
            if (position.y - CUBE_JUMP_SPEED < oldPos.y) {
                // Done falling
                position.y = oldPos.y
                state = .CUBESTATE_IDLE
                tapped = false
            } else {
                position.y -= CUBE_JUMP_SPEED
            }
        }
    }
    
    var oldPos: CGPoint = CGPoint()
    var state: CubeState = .CUBESTATE_IDLE
    var tapped = false
    
    
}