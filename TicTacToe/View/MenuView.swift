//
//  MenuView.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/26/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import Foundation
import UIKit

protocol MenuHandlingDelegate: class {
    func didTapStart()
    func didTapReset()
    func didTapQuit()
}

enum MenuState {
    case start, gameOver, playing
}

class MenuView: UIView {
    
    weak var delegate: MenuHandlingDelegate?
    private let playButton = MenuButton(frame: .zero)
    private let restartButton = MenuButton(frame: .zero)
    private let quitButton = MenuButton(frame: .zero)
    
    init(frame: CGRect, state: MenuState = .start) {
        super.init(frame: frame)
        setupInitialUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupInitialUI() {
        addSubview(playButton)
        playButton.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.width.equalTo(self.snp.width).dividedBy(3)
            make.height.equalTo(60)
            make.bottom.equalTo(self).offset(-30)
        }
        playButton.setTitle("Play", for: .normal)
        playButton.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
        
        
        addSubview(restartButton)
        addSubview(quitButton)

        restartButton.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(quitButton.snp.left).offset(-10)
            make.height.equalTo(60)
            make.width.equalTo(self.snp.width).dividedBy(2)
            make.centerY.equalTo(self.snp.centerY)
        }
        restartButton.setTitle("Play again", for: .normal)
        restartButton.addTarget(self, action: #selector(didTapRestart), for: .touchUpInside)

        
        quitButton.snp.makeConstraints { (make) in
            make.left.equalTo(restartButton.snp.right).offset(10)
            make.right.equalTo(self).offset(-10)
            make.top.bottom.equalTo(restartButton)
            make.height.equalTo(restartButton)
        }
        quitButton.setTitle("Quit", for: .normal)
        quitButton.addTarget(self, action: #selector(didTapQuit), for: .touchUpInside)

        configureUI(for: .start)
    }
    
    func configureUI(for state: MenuState) {
        
        // Typically would not have state handling in uiview
        switch state {
        case .start:
            playButton.isHidden = false
            restartButton.isHidden = true
            quitButton.isHidden = true

        case .gameOver:
            playButton.isHidden = true
            restartButton.isHidden = false
            quitButton.isHidden = false
        case .playing:
            playButton.isHidden = true
            restartButton.isHidden = true
            quitButton.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @objc func didTapPlay() {
        delegate?.didTapStart()
    }
    
    @objc func didTapRestart() {
        delegate?.didTapReset()
    }
    
    @objc func didTapQuit() {
        delegate?.didTapQuit()
    }
}
