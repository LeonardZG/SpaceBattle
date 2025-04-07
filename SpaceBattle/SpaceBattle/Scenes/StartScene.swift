//
//  startscene.swift
//  SpaceBattle
//
//  Created by Leonard Zgonjanin on 04.02.25.
//
import SpriteKit

class StartScene: SKScene {
    
    override func didMove(to view: SKView) {
        // Setze den Hintergrund
        setupBackground()
        
        //Setze den Start Button
        setupStartButton()
    }
    // Erstellt und fügt den Hintergrund hinzu
    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = CGSize(width: size.width, height: size.height)
        background.zPosition = -1
        addChild(background)
    }
    
    // Erstellt und fügt den Start Button hinzu
    func setupStartButton() {
        let startButton = SKLabelNode(fontNamed: "Arial")
        startButton.text = "Start Game"
        startButton.fontSize = 40
        startButton.fontColor = UIColor.green
        startButton.position = CGPoint(x: size.width / 2, y: size.height / 2)
        startButton.name = "startButton"
        addChild(startButton)
    }
    
    // Benutzerinteraktionen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            // Prüft ob der Start-Button angeklickt wurde 
            if touchedNode.name == "startButton" {
                let gameScene = GameScene(size: size)
                gameScene.scaleMode = .aspectFill
                let transition = SKTransition.fade(withDuration: 1.0)
                view?.presentScene(gameScene, transition: transition)
            }
        }
    }
}

