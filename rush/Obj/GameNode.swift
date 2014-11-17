//
//  GameNode.swift
//  rush
//
//  Created by Rui Du on 11/9/14.
//  Copyright (c) 2014 cgcorp. All rights reserved.
//

import Foundation
import SpriteKit

let RATIO_PATH_STONE_HEIGHT = CGFloat(0.188)

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
    convenience init() {
        self.init(id: 1)
    }
    
    init(id: Int) {
        self.id = id
        if id == 0 {
            self.id = 3
        }
        
        let texture = SKTexture(imageNamed: "bg_cave" + String(self.id) + ".png")
        let size = CGSize(width: viewWidth, height: viewHeight)
        super.init(texture: texture, size: size)
        zPosition = ZPOSITION_BACKGROUND
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addNextBackground() -> GameBackground {
        
        var background = GameBackground(id: ((id + 1) % 3))
        background.position.x = position.x + size.width
        background.position.y = position.y
        
        return background
    }
    
    var id = 1
}


class GamePath: GameNode {
    convenience init() {
        let texture = SKTexture(imageNamed: "path.png")
        let size = CGSize(width: viewWidth, height: viewHeight)
        self.init(texture: texture, size: size)
        println("\(viewWidth):\(viewHeight)")
        zPosition = ZPOSITION_PATH
    }
    
    override init(texture:SKTexture, size: CGSize) {
        super.init(texture: texture, size: size)
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


class GameStonePath: GamePath {
    init() {
        let texture = SKTexture(imageNamed: "path_stone.png")
        let size = CGSize(width: viewWidth, height: viewHeight * RATIO_PATH_STONE_HEIGHT)
        super.init(texture: texture, size: size)
        zPosition = ZPOSITION_PATH
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func addNextPath() -> GameStonePath {
        var path = GameStonePath()
        path.position.x = position.x + size.width
        path.position.y = position.y
        
        return path
    }
}