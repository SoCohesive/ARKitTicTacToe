//
//  SCNNode+Load.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/28/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    
    
    public static func node(from filePath: String, name: String, skeletonName: String? = nil) -> SCNNode? {
        guard
            let animScene = SCNScene(named: filePath, inDirectory: nil, options: nil),
            let node = animScene.rootNode.childNode(withName: name, recursively: false) else {
                assertionFailure("could not get the file")
                return nil
        }
        
        if let skeletonName = skeletonName, let skeletonObject = animScene.rootNode.childNode(withName: skeletonName, recursively: true) {
            node.addChildNode(skeletonObject)
        }
        
        if let animPlayer = topLevelAnimation(from: animScene) {
            node.addAnimationPlayer(animPlayer, forKey: "idle")
            animPlayer.play()
        }
        return node
    }
    
    class func topLevelAnimation(from scene: SCNScene) -> SCNAnimationPlayer? {

        var animationPlayer: SCNAnimationPlayer?
        
        scene.rootNode.enumerateChildNodes { (child, stop) in
            if !child.animationKeys.isEmpty {
                animationPlayer = child.animationPlayer(forKey: child.animationKeys[0])
                stop.pointee = true
            }
        }
        return animationPlayer
    }
}

extension SCNScene {
    
    // Extracted from Apple sample code 
    func loadParticleSystems(at path: String) -> [SCNParticleSystem] {
        let url = URL(fileURLWithPath: path)
        let directory = url.deletingLastPathComponent()
        let fileName = url.lastPathComponent
        let ext: String = url.pathExtension
        
        if ext == "scnp" {
            return [SCNParticleSystem(named: fileName, inDirectory: directory.relativePath)!]
        } else {
            var particles = [SCNParticleSystem]()
            let scene = SCNScene(named: fileName, inDirectory: directory.relativePath, options: nil)
            scene!.rootNode.enumerateHierarchy({(_ node: SCNNode, _ _: UnsafeMutablePointer<ObjCBool>) -> Void in
                if node.particleSystems != nil {
                    particles += node.particleSystems!
                }
            })
            return particles
        }
    }
}
