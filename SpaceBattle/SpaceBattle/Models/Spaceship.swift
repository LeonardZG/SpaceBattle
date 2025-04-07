//
//  Spaceship.swift
//  SpaceBattle
//
//  Created by Leonard Zgonjanin on 12.02.25.
//
import SpriteKit

class Spaceship: SKSpriteNode {
    
    // Physik-Kategorie für das Raumschiff
    let spaceshipCategory: UInt32 = 0x1 << 3
    let ufoLaserCategory: UInt32 = 0x1 << 2
    
    // Timer für das automatische Schießen
    var fireTimer: Timer?

    // Initialisierung des Raumschiffs
    init() {
        let texture = SKTexture(imageNamed: "spaceship")
        super.init(texture: texture, color: .clear, size: CGSize(width: 50, height: 50))
        self.name = "spaceship"
        self.zPosition = 0
        self.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: 100)
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Setzt die Physik für das Raumschiff
    private func setupPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.categoryBitMask = spaceshipCategory
        self.physicsBody?.contactTestBitMask = ufoLaserCategory
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.isDynamic = false
    }
    
    // Bewegt das Raumschiff basierend auf der Berührung
    func move(to position: CGPoint) {
        self.position.x = position.x
    }
    
    // Startet das automatische Schießen
    func startFiring(scene: SKScene, laserCategory: UInt32, ufoCategory: UInt32) {
        fireTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.shootLaser(scene: scene, laserCategory: laserCategory, ufoCategory: ufoCategory)
        }
    }
    
    // Stoppt das Schießen
    func stopFiring() {
        fireTimer?.invalidate()
        fireTimer = nil
    }
    
    // Erstellt und feuert einen Laser
    private func shootLaser(scene: SKScene, laserCategory: UInt32, ufoCategory: UInt32) {
        let laser = SKSpriteNode(color: .red, size: CGSize(width: 5, height: 20))
        laser.position = CGPoint(x: self.position.x, y: self.position.y + self.size.height / 2)
        laser.zPosition = 1
        laser.name = "laser"

        // Setzt die Physik für den Laser
        laser.physicsBody = SKPhysicsBody(rectangleOf: laser.size)
        laser.physicsBody?.categoryBitMask = laserCategory
        laser.physicsBody?.contactTestBitMask = ufoCategory
        laser.physicsBody?.collisionBitMask = 0
        laser.physicsBody?.isDynamic = true
        laser.physicsBody?.affectedByGravity = false

        scene.addChild(laser)

        // Bewegung nach oben + Entfernen
        let moveUp = SKAction.moveBy(x: 0, y: scene.size.height, duration: 1.0)
        let removeLaser = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveUp, removeLaser])
        laser.run(sequence)
    }
}
