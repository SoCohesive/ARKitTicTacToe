//
//  PieceNode.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/27/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import Foundation
import SceneKit

class PieceNode: SCNNode {
    
    let row: Int
    let column: Int
    
    init(row: Int, column: Int, size: CGSize) {
        self.row = row
        self.column = column
        super.init()
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
