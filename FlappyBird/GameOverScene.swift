//
//  GameOverScene.swift
//  FlappyBird
//
//  Created by Ewa Korszaczuk on 14.07.2017.
//  Copyright © 2017 Ewa Korszaczuk. All rights reserved.
//

import SpriteKit
import AVFoundation

protocol RestartGame {
    
}

class GameOverScene: SKScene {

    let gameOverLabel = SKLabelNode()
    let scoreLabel = SKLabelNode()
    let highScoreLabel = SKLabelNode()
    var restartButton = SKSpriteNode()
    
    override init(size: CGSize) {
        super.init(size: size)
        createBackground()
        createGameOverLabel()
        createScoreLabel()
        createHighScoreLabel()
        createRestartButton()       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            if restartButton.contains(location) {
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: self.size)
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene, transition: reveal)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createBackground() {
        var background = SKSpriteNode(imageNamed: StaticValue.backgroundImageField)
        background = SKSpriteNode(imageNamed: StaticValue.backgroundImageField)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = frame.size
        addChild(background)
    }
    
    func createGameOverLabel() {
        gameOverLabel.fontName = StaticValue.fontNameField
        gameOverLabel.text = StaticValue.gameOverMessageField
        gameOverLabel.fontColor = SKColor.black
        gameOverLabel.fontSize = CGFloat(StaticValue.levelLabelFontSize)
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY * 1.5)
        gameOverLabel.zPosition = 1
        addChild(gameOverLabel)
    }
    
    func createHighScoreLabel() {
        highScoreLabel.position = CGPoint(x: frame.midX, y: frame.midY * 1.2)
        highScoreLabel.text = "\(StaticValue.highScoreTextField)\(GameScene.highScore)"
        highScoreLabel.fontName = StaticValue.fontNameField
        highScoreLabel.fontSize = CGFloat(StaticValue.highScoreLabelFontSize)
        highScoreLabel.fontColor = SKColor.black
        highScoreLabel.zPosition = 1
        addChild(highScoreLabel)
    }
    
    func createScoreLabel() {
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        scoreLabel.text = "\(StaticValue.scoreTextField)\(GameScene.score)"
        scoreLabel.fontName = StaticValue.fontNameField
        scoreLabel.fontSize = CGFloat(StaticValue.scoreLabelFontSize)
        scoreLabel.fontColor = SKColor.black
        scoreLabel.zPosition = 1
        addChild(scoreLabel)
    }
    
    func createRestartButton() {
        restartButton = SKSpriteNode(imageNamed: StaticValue.restartBtnImageField)
        restartButton.size = CGSize(width: frame.midX / 2, height: frame.midY / 4 )
        restartButton.position = CGPoint(x: frame.midX, y: frame.midY * 0.75)
        restartButton.zPosition = 1
        addChild(restartButton)
        restartButton.run(SKAction.scale(to: 1.0, duration: 0.3))
        playGameMusic(filename: StaticValue.gameOverMusicField, autoPlayLooped: false)
    }
    
    func playGameMusic(filename: String, autoPlayLooped: Bool) {
        if let musicURL = Bundle.main.url(forResource: filename, withExtension: StaticValue.musicFileExtensionFiled) {
            GameScene.musicGame = SKAudioNode(url: musicURL)
            GameScene.musicGame.autoplayLooped = autoPlayLooped
            self.addChild(GameScene.musicGame)
            GameScene.musicGame.run(SKAction.stop())
        } else {
            print("could not find file \(filename)")
            return
        }
    }
}
