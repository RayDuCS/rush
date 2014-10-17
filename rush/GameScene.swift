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
        
        println("\(viewWidth) \(viewHeight)")
        
        
        
        rushingCube = Cube(color: UIColor.clearColor(), size: CGSize(width: viewWidth * RATIO_CUBE_WIDTH, height: viewHeight * RATIO_CUBE_HEIGHT))
        rushingCube.position = CGPointMake(viewWidth * RATIO_CUBE_X, viewHeight * RATIO_CUBE_Y)
    
        println("rushingCube \(rushingCube.position.x) \(rushingCube.position.y) ")
        self.addChild(rushingCube)
        
        
        floor = Floor(width: viewWidth * RATIO_FLOOR_PIECE_WIDTH, height: viewHeight * RATIO_FLOOR_PIECE_HEIGHT)
        var lineY = rushingCube.position.y - rushingCube.size.height / 2 - viewHeight * RATIO_FLOOR_LINE_HEIGHT / 2
        var floorLine = floor.addLine(viewWidth / 2, y: lineY, width: viewWidth * RATIO_FLOOR_LINE_WIDTH, height: viewHeight * RATIO_FLOOR_LINE_HEIGHT)
        self.addChild(floorLine)
        
        let loc_x = CGFloat(0)
        let loc_y = floorLine.position.y - floorLine.size.height / 2 - viewHeight * RATIO_FLOOR_PIECE_HEIGHT / 2
        let pieces = floor.fillPieces(loc_x, y: loc_y)
        for piece in pieces {
            self.addChild(piece)
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        rushingCube.userTapped()
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            println("loc \(location.x) \(location.y)")
            
            
            /*
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
            */
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        rushingCube.jump()
        if let newPiece = floor.update(3) {
            self.addChild(newPiece)
        }
    }
}
