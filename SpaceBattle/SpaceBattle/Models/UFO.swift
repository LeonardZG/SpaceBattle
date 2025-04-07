//
//  UFO.swift
//  SpaceBattle
//
//  Created by Leonard Zgonjanin on 12.02.25.
//
import SpriteKit

class Ufo: SKSpriteNode {
    
    let ufoCategory: UInt32 = 0x1 << 1
    let laserCategory: UInt32 = 0x1 << 0
    let ufoLaserCategory: UInt32 = 0x1 << 2
    let spaceshipCategory: UInt32 = 0x1 << 3
    
    static weak var scene: GameScene?  // Referenz zur GameScene
    static var ufos: [Ufo] = []        // Liste aller aktiven UFOs
    static var spawnTimer: Timer?      // Timer für das UFO-Spawning
    static var ufoSpawnInterval: TimeInterval = 2.0 // Standard-Spawn-Intervall

    // Initialisiert ein UFO an einer bestimmten Position
    init(position: CGPoint) {
        let texture = SKTexture(imageNamed: "ufo")
        super.init(texture: texture, color: .clear, size: CGSize(width: 40, height: 40))
        self.position = position
        self.zPosition = 1
        self.name = "ufo"

        // Physik für Kollisionen
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.categoryBitMask = ufoCategory
        self.physicsBody?.contactTestBitMask = laserCategory
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false

        moveWithRandomPattern()
        startShooting()
        startCheckingOffScreen()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Startet das UFO-Schießen
    func startShooting() {
        let shootAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: 1.5 / Double(DifficulityIncrease.ufoSpeedMultiplier)),
                SKAction.run { self.shootLaser() }
            ])
        )
        self.run(shootAction)
    }
    
    // Erstellt und feuert einen Laser
    func shootLaser() {
            let ufoLaser = SKSpriteNode(color: .yellow, size: CGSize(width: 5, height: 20))
            ufoLaser.position = CGPoint(x: self.position.x, y: self.position.y - self.size.height / 2)
            ufoLaser.zPosition = 1
            ufoLaser.name = "ufoLaser"

            // Setzt die Physik für den Laser
            ufoLaser.physicsBody = SKPhysicsBody(rectangleOf: ufoLaser.size)
            ufoLaser.physicsBody?.categoryBitMask = ufoLaserCategory
            ufoLaser.physicsBody?.contactTestBitMask = spaceshipCategory
            ufoLaser.physicsBody?.collisionBitMask = 0
            ufoLaser.physicsBody?.isDynamic = true
            ufoLaser.physicsBody?.affectedByGravity = false

            self.parent?.addChild(ufoLaser)

            let moveDown = SKAction.moveBy(x: 0, y: -UIScreen.main.bounds.height, duration: 1.5)
            let removeLaser = SKAction.removeFromParent()
            let sequence = SKAction.sequence([moveDown, removeLaser])
            ufoLaser.run(sequence)
        }

    // Bewegt das UFO zufällig
    func moveWithRandomPattern() {
        let leftBoundary: CGFloat = 50
        let rightBoundary: CGFloat = UIScreen.main.bounds.width - 50

        let randomPattern = Int.random(in: 1...3)
        switch randomPattern {
        case 1:
            let moveLeft = SKAction.moveTo(x: leftBoundary, duration: 2.0 / DifficulityIncrease.ufoSpeedMultiplier)
            let moveRight = SKAction.moveTo(x: rightBoundary, duration: 2.0 / DifficulityIncrease.ufoSpeedMultiplier)
            let sequence = SKAction.sequence([moveLeft, moveRight])
            self.run(SKAction.repeatForever(sequence))
        case 2:
            let zickzack = SKAction.sequence([
                SKAction.moveBy(x: 50, y: -20, duration: 1.0 / DifficulityIncrease.ufoSpeedMultiplier),
                SKAction.moveBy(x: -50, y: -20, duration: 1.0 / DifficulityIncrease.ufoSpeedMultiplier)
            ])
            self.run(SKAction.repeatForever(zickzack))
        default:
            let moveLeft = SKAction.moveTo(x: leftBoundary, duration: 2.0 / DifficulityIncrease.ufoSpeedMultiplier)
            let moveRight = SKAction.moveTo(x: rightBoundary, duration: 2.0 / DifficulityIncrease.ufoSpeedMultiplier)
            let sequence = SKAction.sequence([moveLeft, moveRight])
            self.run(SKAction.repeatForever(sequence))
        }
    }

    // Überprüft, ob das UFO aus dem Bildschirm geflogen ist
    func checkIfOffScreen() {
        if self.position.y < -self.size.height {
            self.removeFromParent()
            Ufo.removeUFO(self)
        }
    }

    func startCheckingOffScreen() {
        let checkAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: 0.1),
                SKAction.run { self.checkIfOffScreen() }
            ])
        )
        self.run(checkAction)
    }

    // MARK: - UFO Spawning
    static func startSpawning() {
        spawnTimer = Timer.scheduledTimer(withTimeInterval: ufoSpawnInterval, repeats: true) { _ in
            spawnUFO()
        }
    }

    static func stopSpawning() {
        spawnTimer?.invalidate()
        spawnTimer = nil
    }

    static func spawnUFO() {
        guard let scene = scene, ufos.count < 8 else { return }
        let randomX = CGFloat.random(in: 50...scene.size.width - 50)
        let randomY = CGFloat.random(in: scene.size.height - 200...scene.size.height - 100)
        let position = CGPoint(x: randomX, y: randomY)

        let ufo = Ufo(position: position)
        scene.addChild(ufo)
        ufos.append(ufo)
    }

    static func removeUFO(_ ufo: Ufo) {
        if let index = ufos.firstIndex(where: { $0 === ufo }) {
            ufos.remove(at: index)
        }
    }
}
