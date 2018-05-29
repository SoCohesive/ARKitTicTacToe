//
//  Board.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/26/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import Foundation
import GameplayKit

// Data Model of a cell on the board. Data backing for placement of a node on the UI  //
struct CellModel {
    let value: Int
    let state: CellState
}

struct Combo {
    let valueOne: Int
    let valueTwo: Int
    let valueThree: Int
    
    var sum: Int {
        return valueOne + valueTwo + valueThree
    }
}


enum GameResult {
    case win(combo: [Int], player: Player)
    case draw
    case undetermined
    
    var debugDescription: String {
        switch self {
        case let .win(combo: win, player: winningPlayer):
            return "Win with combo: \(win), for player: \(winningPlayer)"
        case .draw:
            return "Draw"
        case .undetermined:
            return "Undetermined"
        }
    }
}

class Board: NSObject, GKGameModel {
    
    /*
     0 | 1 | 2
     ---------
     3 | 4 | 5
     ---------
     6 | 7 | 8
     */
    
    private static let rows = 3
    private static let columns = 3
    var allMoves = [CellModel]()
    var players: [GKGameModelPlayer]? = {
        return Player.allPlayers
    }()
    
    var humanPlayerPiecePreference: Piece {
        guard   let players = self.players as? [Player],
                let humanPlayer = players.first(where: { $0.type == .human }) else { return .x }
        return humanPlayer.pieceSelected
    }
    
    var currentPlayer: Player
    
   static let defaultHumanPlayer = Player.allPlayers[0]
    
    var gameResults: GameResult = .undetermined
    var activePlayer: GKGameModelPlayer? {
        return currentPlayer
    }
    
    var hasEmptySpaces: Bool {
        let empty = self.allMoves.filter { $0.state == .empty }
        return empty.count > 0
    }
    
    fileprivate var winningCombos: [[Int]] {
        return [
            [0,1,2],[3,4,5],[6,7,8], /* horizontals */
            [0,3,6],[1,4,7],[2,5,8], /* verticals */
            [0,4,8],[2,4,6]          /* diagonals */
        ]
    }
    
    static var emptyBoardPositions: [CellModel] {
        var _emptyPositions = [CellModel]()
        for index in 0...((Board.rows * Board.columns) - 1) {
            _emptyPositions.append(CellModel(value: index, state: CellState.empty))
        }
        
        return _emptyPositions
    }
    
    init(positions: [CellModel] = Board.emptyBoardPositions) {
        self.allMoves = positions
        self.currentPlayer = Board.defaultHumanPlayer
    }
    
    override init() {
        self.allMoves = Board.emptyBoardPositions
        self.currentPlayer = Board.defaultHumanPlayer // TODO - Clean up - always assumes human first
        super.init()
    }
    
    func reset() {
        self.allMoves = Board.emptyBoardPositions
        self.currentPlayer = Board.defaultHumanPlayer
    }
    
    func isWin(for player: GKGameModelPlayer) -> Bool {
        guard let player = player as? Player else { return false }
        let gameResult = evaluateBoard()

        switch gameResult {
        case .draw, .undetermined:
            return false
        case let .win(combo: _, player: winningPlayer) where winningPlayer == player:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Protocol
    func setGameModel(_ gameModel: GKGameModel) {
        guard let board = gameModel as? Board else { return }
        allMoves = board.allMoves
        currentPlayer = board.currentPlayer
    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        guard let player = player as? Player else { return nil }
        if isWin(for: player) || isWin(for: player.opponent) {
            return nil
        }
    
        // Generate the possible moves that the AI can take
        let emptyCells = self.allMoves.filter { $0.state == .empty }
        if emptyCells.isEmpty { return nil } // No available moves left
        
        // check the available moves that the AI can then choose from. Return the avail moves
        let possibleMoves: [Move] = emptyCells.map { Move(gridPosition: $0.value, with: player.pieceSelected) }

        player.possibleMoves = player.possibleMoves + possibleMoves.count        
        return possibleMoves.count > 0 ? possibleMoves : nil
    }
    
    // Is space empty
    func isSpaceEmpty(at position: Int) -> Bool {
        let cellModel = self.allMoves[position]
        return cellModel.state == CellState.empty
    }
    
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        if let move = gameModelUpdate as? Move {
            
            self.add(piece: currentPlayer.pieceSelected, at: move.gridPosition)
            self.currentPlayer = currentPlayer.opponent
        }
    }
    
    func add(piece: Piece?, at position: Int) {
        guard let safePiece = piece else { return }
        if isSpaceEmpty(at: position) {
            self.allMoves[position] = CellModel(value: position, state: CellState.filled(piece: safePiece))
        }
    }
    
    func score(for player: GKGameModelPlayer) -> Int {
        guard let player = player as? Player else { return 0 }
        if isWin(for: player) {
            return 300
        } else if isWin(for: player.opponent) {
            return -300
        }
        
        return 0
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Board() // TODO - CLEAN UP
        copy.setGameModel(self)
        return copy
    }
    
    // MARK: - LOGIC
    
    func evaluateBoard() -> GameResult {
        
        var winners: [Int]? = nil
        var winningPiece: Piece?
        
        // Check each winning combo
        // [ [1,2,3] .. etc ]
        for combo in winningCombos {
            //combo = [1,2,3]
            if isWinCombo(combo, forPiece: .o) {
                winners = combo
                winningPiece = .o
            } else if isWinCombo(combo, forPiece: .x) {
                winners = combo
                winningPiece = .x
                break
            }
        }
        
        if let validWinningCombo = winners, let validWinningPiece = winningPiece {
            return GameResult.win(combo: validWinningCombo, player: player(for: validWinningPiece))
        }
        
        // If the board is full, and no winning combos have been found... its a draw
        // Otherwise, not enough information to determine a result yet
        return hasEmptySpaces == false ? .draw : .undetermined
    }
    
    
    // For each potential combo for a piece
    func isWinCombo(_ combo: [Int], forPiece piece: Piece) -> Bool {
        var accumulated: Int = 0
        
        // [1,4,7]
        
        // Check each value in the combo
        combo.forEach { index in
            
            // Evaluate the cell model at that space on the grid
            let cellModel = self.allMoves[index]
            
            // Make sure it is filled
            switch cellModel.state {
            case let .filled(piece: currentPiece) where currentPiece == piece: // Does the filled piece match the one passed in ?
                accumulated += 1
            default:
                break
            }
        }
        
        return accumulated == 3
    }
    
    func player(for piece: Piece) -> Player {
        guard
            let safePlayers = players as? [Player],
            let playerWithPiece = safePlayers.lazy.first(where: { $0.pieceSelected == piece }) else {
            return Player(type: .human, pieceSelected: piece)
        }
        
        return playerWithPiece
    }

}
