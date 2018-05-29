//
//  InPlayStateMachine.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/26/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import GameplayKit


class InPlayStateMachine: GKStateMachine {
    
    var lastPlayerState: GKState.Type?
    fileprivate(set) var moveCount: Int = 0
    
    func resetToInitialState() {
        self.moveCount = 0
        self.lastPlayerState = nil
        self.enter(SelectNextPlayerState.self)
    }
}
