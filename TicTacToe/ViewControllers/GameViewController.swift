//
//  ViewController.swift
//  TicTacToe
//
//  Created by Sonam Dhingra on 5/26/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import GameplayKit
import SnapKit
import MBProgressHUD

class GameViewController: UIViewController {

    // UI
    @IBOutlet var sceneView: ARSCNView!
    private var statusLabel = UILabel(frame: .zero)
    private let menuView =  MenuView(frame: .zero)
    private var gameScene: GameScene?
    private var planes = [OverlaySurfacePlane]() // Will not use. For simplicity and usability we do not force the user to find a surface before playing the game

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        //sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        setupUI()
        
        gameScene = GameScene(model: Board(), menuView: menuView)
        guard let safeGameScene = gameScene else {
            assertionFailure("game scene could not be loaded")
            return
        }
        
        safeGameScene.viewProgressDelegate = self
        sceneView.scene = safeGameScene
        addTap(to: safeGameScene)
        safeGameScene.onStatusChange = { [weak self] newStatus in
            guard let `self` = self else { return }
            self.statusLabel.text = newStatus
        }
    }
    
    func setupUI() {
        
        view.addSubview(menuView)
        menuView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        view.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(30)
            make.left.equalTo(self.view).offset(30)
            make.right.equalTo(self.view).offset(-30)
            make.height.equalTo(100)
        }
        statusLabel.text = "Tap Play!"
        statusLabel.textColor = Theme.Colors.statusText
        statusLabel.font = UIFont.boldSystemFont(ofSize: 28.0)
        statusLabel.numberOfLines = 2
        statusLabel.layer.cornerRadius = 8.0
    }
    
    func addTap(to scene: GameScene) {
        let tapGesture = UITapGestureRecognizer(target: scene , action: #selector(scene.humanPlayerDidTap(sender:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        //configuration.planeDetection = .vertical
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}


extension GameViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        gameScene?.render(self.sceneView, at: time)
    }
    
    // Unused
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Create the plane
        let plane = OverlaySurfacePlane(anchor: planeAnchor)
        planes.append(plane)
        node.addChildNode(plane)
    }
    
    
    
    // TODO (S) - Handle AR session error
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required

        
    }
}

extension GameViewController: ViewProgressDelegate {
    
    func onShowHud() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    func onHideHud() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
}
