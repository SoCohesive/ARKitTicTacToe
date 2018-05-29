//
//  GameOverState.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/26/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import GameplayKit
import SpriteKit

class GameOverState: InPlayState {
    
    override func didEnter(from previousState: GKState?) {
        
        let board = scene.model
        let gameResults = board.gameResults
        
        switch gameResults {
        case .draw:
            let title = NSLocalizedString("It's a Draw!", comment: "It's a Draw!")
            scene.statusText = title
        case let .win(combo: _, player: winningPlayer):
            let message = "Player \(winningPlayer.pieceSelected.rawValue.uppercased()) wins!"
            let title = NSLocalizedString(message, comment: "Got a winner!")
            scene.statusText = title
        case .undetermined:
            break
        }
    }
}
