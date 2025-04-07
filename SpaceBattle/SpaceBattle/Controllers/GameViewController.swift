//
//  GameViewController.swift
//  SpaceBattle
//
//  Created by Leonard Zgonjanin on 12.02.25.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as? SKView {
            // Lade die GameScene programmgesteuert
            let scene = StartScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill

            // Präsentiere die Szene
            view.presentScene(scene)

            // Performance-Optimierungen
            view.ignoresSiblingOrder = true
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
