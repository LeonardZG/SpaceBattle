//
//  GameManager.swift
//  SpaceBattle
//
//  Created by Leonard Zgonjanin on 12.02.25.
//
import Foundation

class GameManager {
    
    static let shared = GameManager() // Singleton-Instanz
    
    var score = 0
    var lives = 3
    var highScore: Int {
        return UserDefaults.standard.integer(forKey: "HighScore")
    }
    
    private init() {} // Verhindert externe Instanziierung
    
    // MARK: - Punkteverwaltung
    func addScore() {
        score += 1
        updateHighScore()
    }
    
    func resetScore() {
        score = 0
    }
    
    // MARK: - Leben verwalten
    func loseLife() {
        lives -= 1
    }
    
    func resetLives() {
        lives = 3
    }
    
    // MARK: - Highscore speichern
    private func updateHighScore() {
        if score > highScore {
            UserDefaults.standard.set(score, forKey: "HighScore")
        }
    }
    
    // MARK: - Reset für ein neues Spiel
    func resetGame() {
        resetScore()
        resetLives()
    }
}

