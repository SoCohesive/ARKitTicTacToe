//
//  Theme.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/28/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import Foundation
import UIKit

struct Theme {
    struct Colors {
        static let background = UIColor(red: 38/255, green: 197/255, blue: 143/255, alpha: 1.0)
        static let text = UIColor.white
        static let statusText = UIColor(red: 38/255, green: 197/255, blue: 143/255, alpha: 1.0)
        static let backgroundButton = UIColor(red:0.92, green:0.34, blue:0.42, alpha:1.0)
        
    }
    
    struct Font {
        static let piece = (name: "MarkerFelt-Wide", size: 24.0)
        static let debug = (name: "Helvetica", size: 12.0)
        static let playerStatus = (name: "Helvetica", size: 14.0)

    }
}

