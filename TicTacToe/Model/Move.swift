//
//  Move.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/26/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import Foundation
import GameplayKit



enum Piece: String {
    case x
    case o
    
    var opposite: Piece {
        switch self {
        case .x:
            return .o
        case .o:
            return .x
        }
    }
}

/// ___Cell State___  for board cell
enum CellState: Equatable {
    case empty
    case filled(piece: Piece)
}

func ==(lhs: CellState, rhs: CellState) -> Bool {
    switch (lhs, rhs) {
    case (.empty, .empty):
        return true
    case (let .filled(p1), let .filled(p2)):
        return p1 == p2
    default: return false
    }
}

class Move: NSObject, GKGameModelUpdate {
    
    var value = 0
    let gridPosition: Int
    let piece: Piece?
    
    init(gridPosition: Int, with piece: Piece?) {
        self.gridPosition = gridPosition
        self.piece = piece
    }
}
