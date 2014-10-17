//
//  GameScene.swift
//  rush
//
//  Created by Rui Du on 9/25/14.
//  Copyright (c) 2014 cgcorp. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    
    var rushingCube: Cube = Cube()
    var floor: Floor = Floor() // floor is an array of floorPieces.
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        /*
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.addChild(myLabel)
        */
        
        let viewWidth = CGRectGetWidth(self.frame)
        let viewHeight = CGRectGetHeight(self.frame)
        
        
        
        rushingCube = Cube(color: UIColor.blackColor(), size: CGSize(width: viewWidth / 16, height: viewHeight / 16))
        rushingCube.position.x = viewWidth / 16 * 3
        rushingCube.position.y = viewHeight / 16 * 7
        //rushingCube.position.x = 100
        //rushingCube.position.y = 100
    
        println("rushingCube \(rushingCube.position.x) \(rushingCube.position.y) ")
        self.addChild(rushingCube)
        
        
        floor = Floor(width: viewWidth / 5, height: viewHeight / 36)
        
        let loc_x = rushingCube.position.x - rushingCube.size.width / 2
        let loc_y = rushingCube.position.y - rushingCube.size.height / 2 - viewHeight / 36 / 2
        var firstPiece = floor.addPiece(loc_x, y: loc_y)
        
        self.addChild(firstPiece)
        
        if let newPiece = floor.addNextPiece() {
            self.addChild(newPiece)
        }
        
        if let newPiece = floor.addNextPiece() {
            self.addChild(newPiece)
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            /*
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            println("loc \(location.x) \(location.y)")
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
            */
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if let newPiece = floor.update(1) {
            self.addChild(newPiece)
        }
    }
}
