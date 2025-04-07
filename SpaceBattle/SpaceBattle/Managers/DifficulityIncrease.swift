//
//  DifficulityIncrease.swift
//  SpaceBattle
//
//  Created by Leonard Zgonjanin on 12.02.25.
//
import SpriteKit

class DifficulityIncrease {
    
    static var difficultyTimer: Timer?
    static var ufoSpeedMultiplier: CGFloat = 1.0

    static func startDifficultyIncrease() {
        difficultyTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { _ in
            increaseDifficulty()
        }
    }

    static func increaseDifficulty() {
        if Ufo.ufoSpawnInterval > 0.5 {
            Ufo.ufoSpawnInterval -= 0.2
            print("Neue UFO-Spawn-Zeit: \(Ufo.ufoSpawnInterval)")
        }

        ufoSpeedMultiplier += 0.1
        print("Neue UFO-Geschwindigkeit: \(ufoSpeedMultiplier)")

        Ufo.stopSpawning()
        Ufo.startSpawning()
    }

    static func stopDifficultyIncrease() {
        difficultyTimer?.invalidate()
        difficultyTimer = nil
    }
}
