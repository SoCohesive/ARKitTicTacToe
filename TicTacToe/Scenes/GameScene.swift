//
//  GameScene.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/27/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import UIKit
import SceneKit
import GameplayKit
import SpriteKit
import ARKit

protocol ViewProgressDelegate: class {
    func onShowHud()
    func onHideHud()
}

protocol ARHandling {
    func render(_ arView: ARSCNView, at time: TimeInterval)
}

class GameScene: SCNScene {
    
    // Model
    let model: Board
    
    // Callbacks
    var onStatusChange: ((String) -> ())?
    weak var viewProgressDelegate: ViewProgressDelegate?
    
    // Should come from view model
    var statusText: String = "" {
        didSet {
            self.onStatusChange?(statusText)
        }
    }

    // UI
    private let menuView: MenuView
    
    // Feedback
    let hapticFeedback = UIImpactFeedbackGenerator()
    
    // Nodes
    private var cellNodes = [SCNNode]()
    private var pieceNodes = [SCNNode]()
    private var wonParticleSystems = [SCNParticleSystem]()
    private var backgroundPlaneNode = SCNNode()
    private(set) var boardNode: SCNNode? {
        didSet {
            guard let _boardNode = boardNode, let cellsParent = _boardNode.childNode(withName: "cellsParent", recursively: false) else {
                print("no cells parent found ")
                return
            }
            self.cellNodes = cellsParent.childNodes
        }
    }

    private var boardScene: SCNScene? {
       return SCNScene(named: Assets.board.filePath)
    }
    
    private var targetFinderScene: SCNScene? {
        return SCNScene(named: Assets.dropBoardHelper.filePath)
    }
    
    private var dropBoardHelper: SCNNode?
    
    
    
    // Let the human select which player they want to be (Feature TBD)
    let humanPlayerPieceSelection: Piece
    lazy var onePlayerStates: [GKState] = {
        let _states = [
            SelectNextPlayerState(scene: self),
            PlayerXTurnState(scene: self, isComputerPlayer: false),
            PlayerOTurnState(scene: self, isComputerPlayer: true),
            CheckBoardState(scene: self),
            GameOverState(scene: self)
        ]
        
        return _states
    }()
    
    lazy var gameStateMachine: InPlayStateMachine = {
        let states = self.onePlayerStates  // Only support one player for now
        let machine = InPlayStateMachine(states: states)
        return machine
    }()
    
    init(model: Board, menuView: MenuView) {
        self.humanPlayerPieceSelection = model.humanPlayerPiecePreference
        self.model = model
        self.menuView = menuView
        super.init()
        
        // Clean this
        self.menuView.delegate = self
        self.wonParticleSystems = self.loadParticleSystems(at: Assets.wonParticles.filePath)
        self.dropBoardHelper = self.targetFinderScene?.rootNode.childNode(withName: Assets.dropBoardHelper.nodeChildName, recursively: false)
        guard let safeDropBoardNode = dropBoardHelper else { return }
        self.rootNode.addChildNode(safeDropBoardNode)
        
    }
    
    func addBackgroundUI() {
        
        // Only add the background if the board has been added
        guard let boardNode = self.boardNode else { return }
        
        //Scenekit and SpriteKit
        let backgroundPlaneGeo = SCNPlane(width: 1, height: 1)
        let materialScene = SKScene(size: CGSize(width: 50, height: 50))
        let backgroundSpriteNode =  SKSpriteNode(color: Theme.Colors.background, size: materialScene.size)
      
        backgroundSpriteNode.position = CGPoint(x: materialScene.size.width/2.0, y: materialScene.size.height/2.0)
        backgroundSpriteNode.alpha = 1.0
        materialScene.addChild(backgroundSpriteNode)

        materialScene.alpha = 1.0
    
        let blueAction = SKAction.colorize(with:.blue, colorBlendFactor: 1.0, duration: 1)
        let redAction = SKAction.colorize(with: .red, colorBlendFactor: 0.5, duration: 1)

        backgroundSpriteNode.run(SKAction.repeatForever(SKAction.sequence([blueAction, redAction])))

        // Add to 3D node
        let backgroundMaterial = SCNMaterial()
        backgroundMaterial.diffuse.contents = materialScene
        
        backgroundPlaneNode = SCNNode(geometry: backgroundPlaneGeo)
        backgroundPlaneNode.geometry?.firstMaterial = backgroundMaterial
        self.rootNode.addChildNode(backgroundPlaneNode)
        backgroundPlaneNode.position = SCNVector3(x: 0, y: 0, z: boardNode.position.z - 0.2 )
        backgroundPlaneNode.opacity = 0.8
      
    }

    //MARK: Board Actions
    
    // Show the board
    func revealBoard() {
        guard
            let scene = boardScene,
            let boardNode = scene.rootNode.childNode(withName: "boardParent", recursively: true),
            let dropBoardNodeHelper = dropBoardHelper else {
                assertionFailure("Could not get the board node")
                return
        }
        
        self.boardNode = boardNode
        rootNode.addChildNode(boardNode)
        boardNode.position = dropBoardNodeHelper.position
            //SCNVector3(x: 0, y: -0.3, z: -0.3)
        addBackgroundUI()
        
        hapticFeedback.prepare()
        hapticFeedback.impactOccurred()
    }
    
    //  MARK: - Board
    func resetBoard(with text: String) {
        statusText = text
        model.reset()
        let flyAwayAction = SCNAction.moveBy(x: 0, y: 0.0, z: -1.5, duration: 1.5)
        pieceNodes.forEach { (node) in
            node.runAction(flyAwayAction, completionHandler: {
                node.removeFromParentNode()
            })
        }
        
        pieceNodes.removeAll()
        boardNode?.runAction(SCNAction.scale(to: 0.0, duration: 0.5))
        boardNode?.removeFromParentNode()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Game Logic & Moves

    @objc func humanPlayerDidTap(sender: UITapGestureRecognizer) {
         guard let sceneViewTappedOn = sender.view as? SCNView else {
            return
        }
        
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        
        guard let topResult = hitTest.first else {
            print("didn't tap anything")
            return
        }
        
        //TODO: (S) - Clean this - Not production ready. *** Only for prototype ***
        let hitNode = topResult.node
        let baseCellString = "cell_"
        if let name = hitNode.name, name.contains(baseCellString) {
            let endIndex = name.index(name.startIndex, offsetBy: baseCellString.count)
            guard let endValue = Int(name[endIndex...]) else {
                assertionFailure("cannot transform string to Int")
                return
            }
        
            // Defaults with human player first always
            gameStateMachine.enter(PlayerXTurnState.self)
            gameStateMachine.lastPlayerState = PlayerXTurnState.self  // TODO - UPDATE
            makeMoveForPlayer(Move(gridPosition: endValue, with: model.currentPlayer.pieceSelected))
        } else if hitNode == dropBoardHelper {
            didTapStart() // Forcing a new state. Not best practice here * Should use state machine *
        }
    }
        
    func canAddPiece() -> Bool {
        let state = gameStateMachine.currentState
        return state is PlayerXTurnState || state is PlayerOTurnState
    }
    
    func makeMoveForPlayer(_ move: GKGameModelUpdate) {
        guard   let move = move as? Move,
                let piece = move.piece, canAddPiece() == true else {
                    assertionFailure("cannot add piece something is wrong")
                return
        }
        
        place(piece, in: move.gridPosition)
        model.apply(move)
        gameStateMachine.enter(CheckBoardState.self)
    }
    
    func cellNode(for position: Int) -> SCNNode? {
        guard let cellNode = cellNodes.first(where: { $0.name == Assets.cell(position: position).nodeChildName }) else {
            print(" piece not on a valid cell")
            return nil 
        }
        
        return cellNode
    }
    
    func place(_ piece: Piece, in position: Int) {
        
        guard let cellNode = cellNode(for: position) else { return }
        let rotateVector = SCNVector3Make(degreesToRadians(-90),
                                          degreesToRadians(0),
                                          degreesToRadians(0))
        
        
        hapticFeedback.prepare()
        hapticFeedback.impactOccurred()
        
        switch piece {
        case .x:
            
            guard let xNode = SCNNode.node(from: Assets.characterX.filePath, name: Assets.characterX.nodeChildName) else {
                assertionFailure("cannot get the x node")
                return
            }
            
            xNode.position = SCNVector3(x: 0, y: 0.0, z: -0.2)
            xNode.eulerAngles = rotateVector
            xNode.isHidden = true
            cellNode.insertChildNode(xNode, at: 0)
            animateAppear(for: xNode)
            pieceNodes.append(xNode)
            animateHover(for: xNode)

        case .o:
            guard let oNode = SCNNode.node(from: Assets.characterO.filePath, name: Assets.characterO.nodeChildName) else {
                assertionFailure("cannot get the x node")
                return
            }
            
            oNode.position = SCNVector3(x: 0, y: 0.0, z: -0.2)
            oNode.eulerAngles = rotateVector
            oNode.isHidden = true
            cellNode.insertChildNode(oNode, at: 0)
            animateAppear(for: oNode)
            pieceNodes.append(oNode)
            animateHover(for: oNode)
        }
    }
    
    func animateAppear(for node: SCNNode) {
        
        let origScale = node.scale
        node.isHidden = false
        
        node.scale = SCNVector3(0.01, 0.01, 0.01)
        let scaleAction = SCNAction.scale(to: CGFloat(origScale.x), duration: 0.8)
        scaleAction.timingMode = .linear
        node.runAction(scaleAction, forKey: "scaleAction")
    }
    
    func animateHover(for node: SCNNode) {
        let hoverUp = SCNAction.moveBy(x: 0, y: 0.0, z: 0.1, duration: 1.5)
        let hoverDown = SCNAction.moveBy(x: 0, y: 0.0, z: -0.1, duration: 1.5)
        let hoverSequence = SCNAction.sequence([hoverUp, hoverDown])
        let repeatForever = SCNAction.repeatForever(hoverSequence)
        node.runAction(repeatForever)
    }
    
    
    func handleWin(for combo: [Int]) {
        print("handling win")
        // ie combo = [1, 2, 3]
        // get the corresponding nodes from pieceNodes array
        var winningPieces = [SCNNode]()
        combo.forEach { (value) in
            guard let cellNode = cellNode(for: value) else { return }
            let pieceNode = cellNode.childNodes[0]
            print("piece node is \(pieceNode)")
            winningPieces.append(pieceNode)
        }
        
        winningPieces.forEach { (node) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: winningPieces.count)
                let particleSystem = self.wonParticleSystems[randomNumber]
                node.addParticleSystem(particleSystem)
                node.runAction(SCNAction.moveBy(x: 0, y: 0.0, z: -1.0, duration: 1.5))
            }
        }
    
        let losingPieces = Array(Set(pieceNodes).subtracting(winningPieces))
        losingPieces.forEach { (node) in
            node.runAction(SCNAction.scale(by: -0.25, duration: 1.0))
        }
    }
    
    func handleGameComplete() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.menuView.configureUI(for: .gameOver)
        }
    }
    
    func showHud() {
        viewProgressDelegate?.onShowHud()
    }
    
    func hideHud() {
        viewProgressDelegate?.onHideHud()
    }
}

extension GameScene: MenuHandlingDelegate {
    
    func didTapQuit() {
        resetBoard(with: "Tap Play!")
        menuView.configureUI(for: .start)
    }
    
    
    func didTapStart() {
        revealBoard()
        menuView.configureUI(for: .playing)
        statusText = "Your turn!"
    }
    
    func didTapReset() {
        resetBoard(with: "Your turn!") // Fix
        revealBoard()
        menuView.configureUI(for: .playing) // Clean up - should go into state machine
    }
}

extension GameScene: ARHandling {
    func render(_ arView: ARSCNView, at time: TimeInterval) {
        if boardNode == nil {

            // Get the point of view from the scene view camera
            guard
                let pointOfView = arView.pointOfView,
                let safeDropBoardHelperNode = dropBoardHelper else {
                return
            }

            // Get the transform of the cmaera
            let transform = pointOfView.transform
            
            // Get the orientation
            let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
            
            // Get the location
            let location = SCNVector3(transform.m41, transform.m42,transform.m43)
            
            // Current position = orientation + location
            let currentPositionOfCamera = orientation + location
            
            DispatchQueue.main.async {
                safeDropBoardHelperNode.position.x = currentPositionOfCamera.x
                safeDropBoardHelperNode.position.z = currentPositionOfCamera.z + 0.5
                safeDropBoardHelperNode.position.y = currentPositionOfCamera.y + 0.1
            }
        }
    }
}
