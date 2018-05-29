//
//  MenuButton.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/29/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import UIKit

class MenuButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func style() {
        backgroundColor = Theme.Colors.backgroundButton
        layer.cornerRadius = 8.0
        titleLabel?.textColor = .white
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        self.setTitleColor(.lightGray, for: .highlighted)
    }
}
