//
//  Player.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/26/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import Foundation
import GameplayKit

enum PlayerType: Int {
    case human, ai
    
    var displayName: String {
        switch self {
        case .human: return "You"
        case .ai: return "AI"
        }
    }
}

///__Player__ is the model object for driving the Player nodes in the game
class Player: NSObject, GKGameModelPlayer {
        
    let playerId: Int
    let type: PlayerType
    var possibleMoves: Int = 0 
    
    var opponent: Player {
        switch type {
        case .human: return Player.allPlayers[1] // TODO: (S) make smarter.
        case .ai: return Player.allPlayers[0]
        }
    }
    
    let pieceSelected: Piece
    static var allPlayers = [Player(type: .human, pieceSelected: .x), Player(type: .ai, pieceSelected: .o)]

    init(type: PlayerType, pieceSelected: Piece) {
        self.type = type
        self.pieceSelected = pieceSelected
        self.playerId = type.rawValue
        super.init()
    }
}

