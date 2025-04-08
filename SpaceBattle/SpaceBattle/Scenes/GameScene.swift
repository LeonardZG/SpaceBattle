//
//  GameScene.swift
//  SpaceBattle
//
//  Created by Leonard Zgonjanin on 12.02.25.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    var spaceship: Spaceship!
    var scoreLabel: SKLabelNode!
    var livesLabel: SKLabelNode!

    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        GameManager.shared.resetGame()
        Ufo.scene = self // Setzt die Szene für die UFO-Klasse
        setupScene()
        Ufo.startSpawning() // Startet das UFO-Spawning
        DifficulityIncrease.startDifficultyIncrease() // Startet die Schwierigkeitserhöhung
    }
    
    func setupScene() {
        setupBackground()
        setupSpaceship()
        setupUI()
    }
    
    // MARK: - Hintergrund
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = CGSize(width: size.width, height: size.height)
        background.zPosition = -1
        addChild(background)
    }
    
    // MARK: - Spieler Setup
    func setupSpaceship() {
        spaceship = Spaceship()
        addChild(spaceship)
        spaceship.startFiring(scene: self, laserCategory: 0x1 << 0, ufoCategory: 0x1 << 1)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            spaceship.move(to: location)
        }
    }
    
    // MARK: - UI Setup
    func setupUI() {
        // Lebensanzeige
        livesLabel = SKLabelNode(fontNamed: "Arial")
        livesLabel.text = "Leben: \(GameManager.shared.lives)"
        livesLabel.fontSize = 24
        livesLabel.fontColor = .white
        livesLabel.position = CGPoint(x: size.width - 80, y: size.height - 40)
        addChild(livesLabel)

        // Punktestand
        scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.text = "Punkte: \(GameManager.shared.score)"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 80, y: size.height - 40)
        addChild(scoreLabel)
    }
    
    // MARK: - Punkte & Leben
    func addScore() {
        GameManager.shared.addScore()
        scoreLabel.text = "Punkte: \(GameManager.shared.score)"
    }
    
    func loseLife() {
        GameManager.shared.loseLife()
        livesLabel.text = "Leben: \(GameManager.shared.lives)"
        if GameManager.shared.lives <= 0 {
            gameOver()
        }
    }
    
    func updateHighScore() {
        scoreLabel.text = "Highscore: \(GameManager.shared.highScore)"
    }
    
    // Lässt das Raumschiff nach einem Treffer blinken
    func flashSpaceship() {
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.1)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        spaceship.run(SKAction.sequence([fadeOut, fadeIn, fadeOut, fadeIn]))
    }

    // MARK: - Spielende
    func gameOver() {
        updateHighScore()
        spaceship.removeFromParent()
        spaceship.stopFiring()
        scoreLabel.isHidden = true
        livesLabel.isHidden = true

        Ufo.stopSpawning() // Stoppt das UFO-Spawning
        DifficulityIncrease.stopDifficultyIncrease() // Stoppt die Schwierigkeitserhöhung

        let gameOverLabel = createLabel(text: "Game Over", fontSize: 40, position: CGPoint(x: size.width / 2, y: size.height / 2 + 60))
        gameOverLabel.fontColor = UIColor.red
        addChild(gameOverLabel)

        let scoreLabel = createLabel(text: "Punkte: \(GameManager.shared.score)", fontSize: 30, position: CGPoint(x: size.width / 2, y: size.height / 2 + 20))
        scoreLabel.fontColor = UIColor.white
        addChild(scoreLabel)

        let highScoreLabel = createLabel(text: "Highscore: \(GameManager.shared.highScore)", fontSize: 30, position: CGPoint(x: size.width / 2, y: size.height / 2 - 20))
        highScoreLabel.fontColor = UIColor.yellow
        addChild(highScoreLabel)

        let restartButton = SKLabelNode(fontNamed: "Arial")
        restartButton.text = "Neustarten"
        restartButton.fontSize = 28
        restartButton.fontColor = UIColor.green
        restartButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 60)
        restartButton.name = "restartButton"
        addChild(restartButton)
    }
    
    func createLabel(text: String, fontSize: CGFloat, position: CGPoint) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Arial")
        label.text = text
        label.fontSize = fontSize
        label.fontColor = UIColor.white
        label.position = position
        label.zPosition = 1
        return label
    }
    
    func restartGame() {
        let newScene = GameScene(size: self.size)
        newScene.scaleMode = self.scaleMode
        let transition = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(newScene, transition: transition)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)

            if touchedNode.name == "restartButton" {
                restartGame()
            }
        }
    }

    // MARK: - Kollisionserkennung
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }

        if (nodeA.name == "laser" && nodeB.name == "ufo") || (nodeA.name == "ufo" && nodeB.name == "laser") {
            let laser = nodeA.name == "laser" ? nodeA : nodeB
            let ufo = nodeA.name == "ufo" ? nodeA : nodeB
            laser.removeFromParent()
            ufo.removeFromParent()
            Ufo.removeUFO(ufo as! Ufo)
            addScore()
        }

        if (nodeA.name == "ufoLaser" && nodeB.name == "spaceship") || (nodeA.name == "spaceship" && nodeB.name == "ufoLaser") {
            let ufoLaser = nodeA.name == "ufoLaser" ? nodeA : nodeB
            ufoLaser.removeFromParent()
            flashSpaceship()
            loseLife()
        }
    }
}
