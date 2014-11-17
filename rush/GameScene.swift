//
//  GameScene.swift
//  rush
//
//  Created by Rui Du on 9/25/14.
//  Copyright (c) 2014 cgcorp. All rights reserved.
//

import SpriteKit

// This is the main body of the game.
// The game is like Genometry Rush, where a cube is moving fast on the floor with obstacles. User can control the cube to avoid clash.
//
// Game Control: Tap and Press.
//               Tap makes the Cube jump once.
//               Press makes the Cube continuous jump, until the press released.
//
// A GameScene has a rushingCube, and a floor.
// A floor should have three sets of obstacles.
// The first set of obstacles stores the closest obstacles for clash checking, and second set stores the obstacles in front, and the third in back.
//
// On each frame, the GameScene calculates the new positions of all objects.
// When a user makes a Tap, the state of the cube is updated and the cube should perform a jump.
// When a user makes a Press, each time the cube launches from the jump, if the user has not yet release the press, then the cube will jump again.
//
// Every 5 frame, we check if the cube is clashed with a obstacle.
// Each obstacle will have a body, which is used to check if the cube is interset with. This body
// is smaller than the image of the obstacle.


// Global var
var viewWidth = CGFloat(0)
var viewHeight = CGFloat(0)
var moveSpeed = CGFloat(3)

class GameScene: SKScene {
    
    var floor: Floor = Floor() // floor is the entry points of all nodes.
    
    
    override func didMoveToView(view: SKView) {
        viewWidth = CGRectGetWidth(self.frame)
        viewHeight = CGRectGetHeight(self.frame)
        
        println("\(viewWidth) \(viewHeight)")
        
        self.view?.ignoresSiblingOrder = true
        // Init the floor
        floor = Floor()
        let nodes = floor.initialize()
        for node in nodes {
            self.addChild(node)
        }
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        floor.rushingCube.userPressed()
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            println("loc \(location.x) \(location.y)")
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        floor.rushingCube.userPressReleased()
        for touch: AnyObject in touches {
            println("Touch ended!!!")
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        let newNodes = floor.update(moveSpeed)
        for newNode in newNodes {
            self.addChild(newNode)
        }
    }
}
