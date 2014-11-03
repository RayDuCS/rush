//
//  Cube.swift
//  rush
//
//  Created by Rui Du on 10/13/14.
//  Copyright (c) 2014 cgcorp. All rights reserved.
//

import Foundation
import SpriteKit

let CUBE_JUMP_HEIGHT_MAX = CGFloat(200.0)
let CUBE_JUMP_SPEED = CGFloat(8.0)
let CUBE_ANIMATION_ROTATION_TIME = (CUBE_JUMP_HEIGHT_MAX / CUBE_JUMP_SPEED * 2 / 60)
let CUBE_ANIMATION_ROTATION_KEY = "CUBE_ANIMATION_ROTATION_KEY"
let CUBE_ANIMATION_BURST_KEY = "CUBE_ANIMATION_BURST_KEY"

let RATIO_CUBE_WIDTH = CGFloat(0.06)
let RATIO_CUBE_HEIGHT = CGFloat(0.08)
let RATIO_CUBE_X = CGFloat(0.3)
let RATIO_CUBE_Y = CGFloat(0.35)

// CubeState describes the state of Cube
enum CubeState {
    case CUBESTATE_IDLE
    case CUBESTATE_JUMPING
    case CUBESTATE_FALLING
    case CUBESTATE_CLASHED
}

class Cube: SKSpriteNode {
    
    init(color: UIColor!) {
        //oldPos = CGPoint()
        let texture = SKTexture(imageNamed: "images.jpeg")
        state = .CUBESTATE_IDLE
        super.init(texture: texture, color: color,
            size: CGSize(width: viewWidth * RATIO_CUBE_WIDTH, height: viewHeight * RATIO_CUBE_HEIGHT))
        position = CGPointMake(viewWidth * RATIO_CUBE_X, viewHeight * RATIO_CUBE_Y)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience override init() {
        let texture = SKTexture(imageNamed: "images.jpeg")
        self.init(color: UIColor.clearColor())
    }
    
    func userTapped() {
        tapped = true;
    }
    
    func userPressed() {
        pressed = true
        userTapped()
    }
    
    func userPressReleased() {
        pressed = false
    }
    
    func getAdvanceX() -> CGFloat {
        return (revivePos.x - position.x)
    }
    
    func isClashed() -> Bool {
        return (state == .CUBESTATE_CLASHED)
    }
    
    func revive() {
        stopAnimationBurst()
        position.y = viewHeight * RATIO_CUBE_Y
        zRotation = 0
        state = .CUBESTATE_IDLE
        tapped = false
        pressed = false
    }
    
    func runClashCheck(obs: Obstacle) -> Bool {
        if state == .CUBESTATE_CLASHED {
            return false
        }
        
        // Compare both boundary, if any interset, then crash
        //if intersectsNode(obs) && CGRectGetMinX(frame) <= CGRectGetMaxX(obs.frame) && CGRectGetMaxX(frame) >= CGRectGetMinX(obs.frame) {
        if CGRectIntersectsRect(frame, obs.clashCheckFrame) {
            state = .CUBESTATE_CLASHED
            revivePos = obs.getRevivePoint()
            
            // Stop all animation
            stopAllAnimations()
            doAnimationBurst()
            return true
        }
        
        return false
    }
    
    func doAnimationRotation() {
        var rotation = SKAction.rotateByAngle(CGFloat(-2 * M_PI),
                                              duration: NSTimeInterval(CUBE_ANIMATION_ROTATION_TIME))
        
        runAction(rotation, withKey: CUBE_ANIMATION_ROTATION_KEY)
    }
    
    func stopAnimationRotation() {
        removeActionForKey(CUBE_ANIMATION_ROTATION_KEY)
        zRotation = 0
    }
    
    func doAnimationBurst() {
        var textures:[SKTexture] = []
        for i in 1...9 {
            let imageName = "burst_0" + String(i) + ".jpg"
            let texture = SKTexture(imageNamed: imageName)
            textures.append(texture)
        }
        
        for i in 10...24 {
            let imageName = "burst_" + String(i) + ".jpg"
            let texture = SKTexture(imageNamed: imageName)
            textures.append(texture)
        }
        
        var burst = SKAction.animateWithTextures(textures, timePerFrame: 0.01, resize: true, restore: false)
        runAction(burst, withKey: CUBE_ANIMATION_BURST_KEY)
    }
    
    func stopAnimationBurst() {
        removeActionForKey(CUBE_ANIMATION_BURST_KEY)
        size = CGSizeMake(viewWidth * RATIO_CUBE_WIDTH, viewHeight * RATIO_CUBE_HEIGHT)
        texture = SKTexture(imageNamed: "images.jpeg")
    }
    
    
    func stopAllAnimations() {
        stopAnimationRotation()
        stopAnimationBurst()
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
            doAnimationRotation()
            
        case .CUBESTATE_JUMPING:
            if (position.y + CUBE_JUMP_SPEED > oldPos.y + CUBE_JUMP_HEIGHT_MAX ) {
                // Time to fall
                state = .CUBESTATE_FALLING
                position.y -= CUBE_JUMP_SPEED
            } else {
                position.y += CUBE_JUMP_SPEED
            }
            
            
        case .CUBESTATE_FALLING:
            if position.y - CUBE_JUMP_SPEED < oldPos.y {
                // Done falling
                position.y = oldPos.y
                state = .CUBESTATE_IDLE
                stopAllAnimations()
                if !pressed {
                    tapped = false
                }
                
            } else {
                position.y -= CUBE_JUMP_SPEED
            }
            
        case .CUBESTATE_CLASHED:
            // do nothing
            break
        }
        
        
    }
    
    var oldPos: CGPoint = CGPoint()
    var revivePos: CGPoint = CGPoint()
    var state: CubeState = .CUBESTATE_IDLE
    var tapped = false
    var pressed = false
    var restartCountdown = 60
}