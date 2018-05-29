//
//  Strategist.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/26/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import Foundation
import GameplayKit

struct Strategist {
        
    private let strategist: GKMinmaxStrategist = {
        let strategist = GKMinmaxStrategist()
        strategist.maxLookAheadDepth = 5
        strategist.randomSource = GKARC4RandomSource()  
        return strategist
    }()
    
    let boardModel: Board
    
    init(model: Board) {
        self.boardModel = model
        strategist.gameModel = model
    }
    
    func bestMoveForAI() -> GKGameModelUpdate? {
        print("strategist is \(strategist)")
        print("board current player is \(boardModel.currentPlayer.type)")
        return strategist.randomMove(for: boardModel.currentPlayer, fromNumberOfBestMoves: 5)
    }
}
