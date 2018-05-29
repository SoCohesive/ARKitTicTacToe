//
//  CheckBoardState.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/26/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import GameplayKit

class CheckBoardState: InPlayState {
    
    override func didEnter(from previousState: GKState?) {
        let gameResults = scene.model.evaluateBoard()        
        switch gameResults {
            
        case let .win(combo: winningCombo, player: player):
            scene.statusText = "Game Over! - \(player.type.displayName) won!"
            scene.handleWin(for: winningCombo)
            scene.handleGameComplete()
            self.stateMachine?.enter(GameOverState.self)
        case .draw:
            scene.statusText = "Its a draw"
            scene.handleGameComplete()
            self.stateMachine?.enter(GameOverState.self)
        case .undetermined:
            self.stateMachine?.enter(SelectNextPlayerState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass is GameOverState.Type || stateClass is SelectNextPlayerState.Type)
    }

}
