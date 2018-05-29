//
//  InPlayState.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/26/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

protocol InPlayStateType {
    var scene: GameScene { get }
    var board: Board { get }

    init(scene: GameScene)
}

extension InPlayStateType where Self: GKState {
    var board: Board {
        return scene.model
    }
}


class InPlayState: GKState, InPlayStateType {
    
    let scene: GameScene

    required init(scene: GameScene) {
        self.scene = scene
    }
    
}
