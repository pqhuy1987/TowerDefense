//
//  SpriteComponent.swift
//  TookaDefense
//
//  Created by Antoine Beneteau on 10/11/2015.
//  Copyright © 2015 Tastyapp. All rights reserved.
//

import SpriteKit
import GameplayKit

class EntityNode: SKSpriteNode {
	weak var entity: GKEntity!
}

class SpriteComponent: GKComponent {
	
	let node: EntityNode
	
	init(entity: GKEntity, texture: SKTexture, size: CGSize, name: String) {
		node = EntityNode(texture: texture, color: SKColor.whiteColor(), size: size)
		node.name = name
		node.entity = entity
		
		if name == "Slow" || name == "Boost" || name == "Teleport" || name == "Repair" {
			node.alpha = 0.7
			node.zPosition = 0
		}
		if name == "Enemy" {
			node.zPosition = 1
		}
	}
}

