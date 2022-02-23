//
//  CollisionNode.swift
//  Crazy_Road
//
//  Created by Mert Çelik on 23.02.2022.
//

import UIKit
import SceneKit

class CollisionNode: SCNNode {

    let front: SCNNode
    let right: SCNNode
    let left: SCNNode
    let down: SCNNode
    
    override init() {
        front = SCNNode()
        right = SCNNode()
        left = SCNNode()
        down = SCNNode()
        
        super.init()
        createPhysicsBodies()
    }
    
    func createPhysicsBodies() {
        let boxGeometry = SCNBox(width: 0.25, height: 0.25, length: 0.25, chamferRadius: 0)
        boxGeometry.firstMaterial?.diffuse.contents = UIColor.clear
        
        let shape = SCNPhysicsShape(geometry: boxGeometry, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox])
        
        front.geometry = boxGeometry
        right.geometry = boxGeometry
        left.geometry = boxGeometry
        down.geometry = boxGeometry
        
        front.physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
        front.physicsBody?.categoryBitMask = PhysicsCategory.collisionTestFront
        front.physicsBody?.contactTestBitMask = PhysicsCategory.vegetation
        
        right.physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
        right.physicsBody?.categoryBitMask = PhysicsCategory.collisionTestRight
        right.physicsBody?.contactTestBitMask = PhysicsCategory.vegetation
        
        left.physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
        left.physicsBody?.categoryBitMask = PhysicsCategory.collisionTestLeft
        left.physicsBody?.contactTestBitMask = PhysicsCategory.vegetation
        
        down.physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
        down.physicsBody?.categoryBitMask = PhysicsCategory.collisionTestDown
        down.physicsBody?.contactTestBitMask = PhysicsCategory.vegetation
        
        front.position = SCNVector3(x: 0, y: 0.5, z: -1)
        right.position = SCNVector3(x: 1, y: 0.5, z: 0)
        left.position = SCNVector3(x: -1, y: 0.5, z: 0)
        down.position = SCNVector3(x: 0, y: 0.5, z: 1)

        addChildNode(front)
        addChildNode(right)
        addChildNode(left)
        addChildNode(down)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
