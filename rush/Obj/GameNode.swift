//
//  GameNode.swift
//  rush
//
//  Created by Rui Du on 11/9/14.
//  Copyright (c) 2014 cgcorp. All rights reserved.
//

import Foundation
import SpriteKit


class GameNode : SKSpriteNode {
    init(texture: SKTexture, size: CGSize) {
        super.init(texture: texture, color: UIColor.clearColor(), size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(x: CGFloat) {
        position.x -= x
    }
}

// The background is composed by three images.
class GameBackground: GameNode {
    init() {
        let texture = SKTexture(imageNamed: "path.png")
        let size = CGSize(width: viewWidth, height: viewHeight)
        super.init(texture: texture, size: size)
        zPosition = ZPOSITION_BACKGROUND
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Fill the backgrounds during init
    func fillBackground() -> [GameBackground] {
        return []
    }
    
    func addNextBackgrounds() -> [GameBackground] {
        var backgrounds:[GameBackground] = []
        
        var background = GameBackground()
        background.position.x = position.x + size.width
        background.position.y = position.y
        backgrounds.append(background)
        
        return backgrounds
    }
}


class GamePath: GameNode {
    init() {
        let texture = SKTexture(imageNamed: "path.png")
        let size = CGSize(width: viewWidth, height: viewHeight)
        super.init(texture: texture, size: size)
        println("\(viewWidth):\(viewHeight)")
        zPosition = ZPOSITION_PATH
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addNextPath() -> GamePath {
        var path = GamePath()
        path.position.x = position.x + size.width
        path.position.y = position.y
        
        return path
    }
}