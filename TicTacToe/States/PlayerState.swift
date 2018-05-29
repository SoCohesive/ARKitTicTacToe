//
//  PlayerState.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/26/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//
import Foundation
import GameplayKit


class PlayerState: InPlayState {
    
    private let isComputerPlayer: Bool
    private let strategist: Strategist
    
    required init(scene: GameScene, isComputerPlayer: Bool) {
        self.isComputerPlayer = isComputerPlayer
        self.strategist = Strategist(model: scene.model)
        super.init(scene: scene)
    }
    
    required init(scene: GameScene) {
        self.isComputerPlayer = false
        self.strategist = Strategist(model: scene.model)
        super.init(scene: scene)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    override func didEnter(from previousState: GKState?) {

        if isComputerPlayer {
            scene.statusText = "The AI is making a move..."
            scene.showHud()
            
            let delay = DispatchTime.now() + 2.0
            DispatchQueue.main.asyncAfter(deadline: delay) {
                if let moveUpdate = self.strategist.bestMoveForAI() {
                    self.scene.makeMoveForPlayer(moveUpdate)
                    self.scene.hideHud()
                } else {
                    assertionFailure("The AI failed you")
                }
            }
        } else {
            // human player move
            scene.statusText = "Your turn!"
        }
    }
}

class PlayerOTurnState: PlayerState { }
class PlayerXTurnState: PlayerState { }
