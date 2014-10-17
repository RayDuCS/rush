//
//  Cube.swift
//  rush
//
//  Created by Rui Du on 10/13/14.
//  Copyright (c) 2014 cgcorp. All rights reserved.
//

import Foundation
import SpriteKit

class Cube: SKSpriteNode {
    
    override init() {
        let texture = SKTexture(imageNamed: "bubble")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }
    
    init(color: UIColor!, size: CGSize) {
        //oldPos = CGPoint()
        let texture = SKTexture(imageNamed: "bubble")
        super.init(texture: texture, color: color, size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    var oldPos: CGPoint = CGPoint()
    
}