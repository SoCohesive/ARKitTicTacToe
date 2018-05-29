//
//  SCNVector3+Extensions.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/28/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

// Convenience
public func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
    return degrees * CGFloat.pi / 180
}

public func radiansToDegress(_ radians: CGFloat) -> CGFloat {
    return radians * 180 / CGFloat.pi
}

public func degreesToRadians(_ degrees: Float) -> Float {
    return degrees * Float.pi / 180
}

public func radiansToDegress(_ radians: Float) -> Float {
    return radians * 180 / Float.pi
}

public func degreesToRadians(_ degrees: Double) -> Double {
    return degrees * Double.pi / 180
}

public func radiansToDegress(_ radians: Double) -> Double {
    return radians * 180 / Double.pi
}


func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    
}
