//
//  SelectNextPlayerState.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/26/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import GameplayKit
import SpriteKit

class SelectNextPlayerState: InPlayState {
    
    override func didEnter(from previousState: GKState?) {
        guard let machine = self.stateMachine as? InPlayStateMachine else { return }
        
        guard let players = scene.model.players as? [Player] else { return }
        let playerX = players.filter { $0.pieceSelected == Piece.x }.first!
        let playerO = players.filter { $0.pieceSelected == Piece.o }.first!
        
        if previousState is GameOverState {
            scene.statusText = ""
        }
        
        if machine.lastPlayerState is PlayerXTurnState.Type {
            let title = NSLocalizedString("AI's turn", comment: "Next move, Player O")
            scene.statusText = title
            scene.model.currentPlayer = playerO
            machine.lastPlayerState = PlayerOTurnState.self
            machine.enter(PlayerOTurnState.self)
        
        } else if machine.lastPlayerState is PlayerOTurnState.Type {
            let title = NSLocalizedString("Your turn!", comment: "Next move, Player X")
            scene.statusText = title
            scene.model.currentPlayer = playerX
            machine.lastPlayerState = PlayerXTurnState.self
            machine.enter(PlayerXTurnState.self)

        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is PlayerXTurnState.Type || stateClass is PlayerOTurnState.Type
    }
}
