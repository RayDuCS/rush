//
//  Cube.swift
//  rush
//
//  Created by Rui Du on 10/13/14.
//  Copyright (c) 2014 cgcorp. All rights reserved.
//

import Foundation
import SpriteKit

let CUBE_JUMP_SPEED = CGFloat(4.0)
let CUBE_JUMP_HEIGHT_MAX = CGFloat(0.25) * viewHeight
let CUBE_ANIMATION_ROTATION_TIME = (CUBE_JUMP_HEIGHT_MAX / CUBE_JUMP_SPEED * 2 / 60)
let CUBE_ANIMATION_ROTATION_KEY = "CUBE_ANIMATION_ROTATION_KEY"
let CUBE_ANIMATION_BURST_KEY = "CUBE_ANIMATION_BURST_KEY"


let RATIO_CUBE_WIDTH = CGFloat(0.06)
let RATIO_CUBE_HEIGHT = CGFloat(0.10)
let RATIO_CUBE_X = CGFloat(0.3)
let RATIO_CUBE_Y = CGFloat(0.35)

// CubeState describes the state of Cube
enum CubeState {
    case CUBESTATE_SLIDE
    case CUBESTATE_JUMPING
    case CUBESTATE_FALLING
    case CUBESTATE_CLASHED
}

class Cube: GameNode {
    
    init() {
        //oldPos = CGPoint()
        let texture = SKTexture(imageNamed: "images.png")
        let size = CGSize(width: viewWidth * RATIO_CUBE_WIDTH,
            height: viewHeight * RATIO_CUBE_HEIGHT)
        
        super.init(texture: texture, size: size)
        
        state = .CUBESTATE_SLIDE
        position = CGPointMake(viewWidth * RATIO_CUBE_X, viewHeight * RATIO_CUBE_Y)
        initialPos.x = position.x
        initialPos.y = position.y
        oldPos.x = position.x
        oldPos.y = position.y
        zPosition = ZPOSITION_CUBE
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func doJump() {
        // Can only do jump when sliding
        if state != .CUBESTATE_SLIDE {
            println("Can't jump now \(state == .CUBESTATE_JUMPING) \(state == .CUBESTATE_FALLING) \(state == .CUBESTATE_CLASHED)")
            return
        }
        
        oldPos.x = position.x
        oldPos.y = position.y
        state = .CUBESTATE_JUMPING
        doAnimationRotation()
    }
    
    func shallFall() {
        // Only fall if the cube is sliding.
        if state == .CUBESTATE_SLIDE && position.y > initialPos.y {
            doFall()
        }
    }
    
    func doFall() {
        state = .CUBESTATE_FALLING
    }
    
    func stopFall(y: CGFloat) {
        position.y = y
        state = .CUBESTATE_SLIDE
        stopAllAnimations()
        
        oldPos.x = position.x
        oldPos.y = position.y
        
        // Jump again if pressed
        if pressed {
            doJump()
        }
    }
    
    func userTapped() {
        doJump()
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
    
    func doRevive() {
        stopAnimationBurst()
        position.y = viewHeight * RATIO_CUBE_Y
        zRotation = 0
        state = .CUBESTATE_SLIDE
        pressed = false
    }
    
    func runClashCheck(obs: Obstacle) -> Bool {
        if state == .CUBESTATE_CLASHED {
            return false
        }
        
        let ret = obs.performClashCheck(self)
        //println("\(ret == .OBSTACLE_CLASH_TYPE_CLASHED)/\(ret == .OBSTACLE_CLASH_TYPE_OK)/\(ret == .OBSTACLE_CLASH_TYPE_OK_TO_FALL)")
        switch (ret) {
        case .OBSTACLE_CLASH_TYPE_CLASHED:
            state = .CUBESTATE_CLASHED
            revivePos = obs.getRevivePoint()
            
            // Stop all animation
            stopAllAnimations()
            doAnimationBurst()
            return true
            
        case .OBSTACLE_CLASH_TYPE_OK:
            // The Obstacle does not clide, 3 possibilities
            // 1. The cube is jumping or falling. - do nothing
            // 2. The cube was sliding on top of a RectObstacle. - should fall
            // 3. The cube is sliding and no action input yet. - do nothing
            if state == .CUBESTATE_SLIDE && position.y > initialPos.y {
                doFall()
            }
            
            return false
            
        case .OBSTACLE_CLASH_TYPE_OK_TO_FALL:
            // Only RectObstacle will return this code, this means the cube collide with the top of RectObstacle
            // If the cube is not sliding, make it slide
            if state != .CUBESTATE_SLIDE {
                stopFall(CGRectGetMaxY(obs.clashCheckFrame) + frame.height / 2)
            }
            
            return false
        }
        
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
            let imageName = "gl_burst_0" + String(i) + ".png"
            let texture = SKTexture(imageNamed: imageName)
            textures.append(texture)
        }
        
        for i in 10...24 {
            let imageName = "gl_burst_" + String(i) + ".png"
            let texture = SKTexture(imageNamed: imageName)
            textures.append(texture)
        }
        
        var burst = SKAction.animateWithTextures(textures, timePerFrame: 0.01, resize: true, restore: false)
        runAction(burst, withKey: CUBE_ANIMATION_BURST_KEY)
    }
    
    func stopAnimationBurst() {
        removeActionForKey(CUBE_ANIMATION_BURST_KEY)
        size = CGSizeMake(viewWidth * RATIO_CUBE_WIDTH, viewHeight * RATIO_CUBE_HEIGHT)
        texture = SKTexture(imageNamed: "images.png")
    }
    
    
    func stopAllAnimations() {
        stopAnimationRotation()
        stopAnimationBurst()
    }
    
    
    override func update(x: CGFloat) {
        switch (state) {
        case .CUBESTATE_SLIDE:
            // do nothing
            break
            
        case .CUBESTATE_JUMPING:
            if (position.y + CUBE_JUMP_SPEED > oldPos.y + CUBE_JUMP_HEIGHT_MAX ) {
                // Time to fall
                doFall()
                position.y -= CUBE_JUMP_SPEED
            } else {
                position.y += CUBE_JUMP_SPEED
            }
            
            
        case .CUBESTATE_FALLING:
            if position.y - CUBE_JUMP_SPEED < initialPos.y {
                // Done falling
                stopFall(initialPos.y)
            } else {
                position.y -= CUBE_JUMP_SPEED
            }
            
        case .CUBESTATE_CLASHED:
            // do nothing
            break
        }
        
        
    }
    
    var oldPos: CGPoint = CGPoint()
    var initialPos: CGPoint = CGPoint()
    var revivePos: CGPoint = CGPoint()
    var state: CubeState = .CUBESTATE_SLIDE
    var pressed = false
    var restartCountdown = 60
}