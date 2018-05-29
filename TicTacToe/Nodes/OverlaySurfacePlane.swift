//
//  OverlaySurfacePlane.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/28/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

enum CollisionType : Int {
    case plane = 1
    case cell = 2
    case piece = 3
}

class OverlaySurfacePlane: SCNNode {
    
    var anchor: ARPlaneAnchor
    private(set) var planeGeometry = SCNPlane(width: 0, height: 0) // Default state 
    
    init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        super.init()
        setup()
    }
    
    func update(anchor :ARPlaneAnchor) {
        
        planeGeometry.width = CGFloat(anchor.extent.x);
        planeGeometry.height = CGFloat(anchor.extent.z);
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        guard let planeNode = self.childNodes.first else {
            assertionFailure("Unable to get plane node")
            return
        }
        
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
    }
    
    private func setup() {
        
        self.planeGeometry = SCNPlane(width: CGFloat(self.anchor.extent.x), height: CGFloat(self.anchor.extent.z))
        
        let material = SCNMaterial()
        let image = UIImage(contentsOfFile: Assets.overLayTexture.filePath)
        print(" image is \(image)")
        material.diffuse.contents = image
        self.planeGeometry.materials = [material]
        
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        planeNode.physicsBody?.categoryBitMask = CollisionType.plane.rawValue
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0);
        
        // add to the parent
        self.addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
