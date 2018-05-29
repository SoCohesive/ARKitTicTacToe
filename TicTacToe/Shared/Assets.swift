//
//  Assets.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/28/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import Foundation


enum Assets {
    
    case board
    case characterX
    case characterO
    case cell(position: Int)
    case piece(position: Int)
    case cellsParent
    case wonParticles
    case overLayTexture
    case backgroundGrid
    case dropBoardHelper
    
    
    static var basePath = "art.scnassets"
    
    var filePath: String {
        switch self {
        case .board, .cell(position: _), .cellsParent:   return "\(Assets.basePath)/board.scn"
        case .characterO:   return "\(Assets.basePath)/piece_o.dae"
        case .characterX:   return "\(Assets.basePath)/piece_x.dae"
        case .piece(position: _): return ""
        case .overLayTexture:   return "\(Assets.basePath)/Textures/overlay_surface_tex.jpg"
        case .wonParticles: return "\(Assets.basePath)/Particles/won_particle.scn"
        case .backgroundGrid: return "\(Assets.basePath)/Textures/background_grid.png"
        case .dropBoardHelper: return "\(Assets.basePath)/dropTarget.scn"
        }
    }
    
    var nodeChildName: String {
        switch self {
        case .board: return "boardParent"
        case .cellsParent:  return "cellsParent"
        case let .cell(position: position): return "cell_\(position)"
        case let .piece(position: position): return "piece_\(position)"
        case .characterX:   return "piece_x_root"
        case .characterO:   return "piece_o_root"
        case .overLayTexture: return ""
        case .wonParticles: return "particles"
        case .backgroundGrid: return ""
        case .dropBoardHelper: return "board_target_finder"
        }
    }
        
}
