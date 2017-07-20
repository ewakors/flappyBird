//
//  GameOverScene.swift
//  FlappyBird
//
//  Created by Ewa Korszaczuk on 14.07.2017.
//  Copyright © 2017 Ewa Korszaczuk. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameOverScene: SKScene {

    let gameOverLabel = SKLabelNode()
    let scoreLabel = SKLabelNode()
    let highScoreLabel = SKLabelNode()
    var restartButton = SKSpriteNode()
    var duration = CFTimeInterval()
    var distanceBetweenWalls = CGFloat()
    var widthWall = CGFloat()
    var heightWall = CGFloat()
    
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
    
    func startGame(duration: CFTimeInterval, distanceBetweenWalls: CGFloat, widthWall: CGFloat, heightWall: CGFloat) {
        self.duration = duration
        self.distanceBetweenWalls = distanceBetweenWalls
        self.widthWall = widthWall
        self.heightWall = heightWall
    }
    
    func createBackground() {
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: StaticValue.backgroundImageField)
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i) * self.frame.width, y: 0)
            background.name = StaticValue.backgroundName
            background.size = CGSize(width: self.frame.width, height: self.frame.height)
            self.addChild(background)
        }
    }
    
    func createGameOverLabel() {
        gameOverLabel.fontName = StaticValue.fontNameField
        gameOverLabel.text = StaticValue.gameOverMessageField
        gameOverLabel.fontColor = SKColor.black
        gameOverLabel.fontSize = 60
        gameOverLabel.zPosition = 1
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + 100)
        self.addChild(gameOverLabel)
    }
    
    func createScoreLabel() {
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + 30)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.text = "\(GameScene.score)"
        scoreLabel.fontName = StaticValue.fontNameField
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = SKColor.black
        scoreLabel.zPosition = 5
        self.addChild(scoreLabel)
    }
    
    func createHighScoreLabel() {
        highScoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - 50)
        highScoreLabel.horizontalAlignmentMode = .center
        highScoreLabel.text = "\(StaticValue.highScoreTextField) \(GameScene.highScore)"
        highScoreLabel.fontName = StaticValue.fontNameField
        highScoreLabel.fontSize = 50
        highScoreLabel.fontColor = SKColor.black
        highScoreLabel.zPosition = 5
        self.addChild(highScoreLabel)
    }
    
    func createRestartButton() {
        restartButton = SKSpriteNode(imageNamed: StaticValue.restartBtnImageField)
        restartButton.size = CGSize(width: 100, height: 50)
        restartButton.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - 150)
        restartButton.zPosition = 6
        restartButton.setScale(0)
        self.addChild(restartButton)
        restartButton.run(SKAction.scale(to: 1.0, duration: 0.3))
        playGameMusic(filename: StaticValue.gameOverMusicField, autoPlayLooped: false)
    }
    
    func playGameMusic(filename: String, autoPlayLooped: Bool) {
        if let musicURL = Bundle.main.url(forResource: filename, withExtension: "mp3") {
            GameScene.musicGame = SKAudioNode(url: musicURL)
            GameScene.musicGame.autoplayLooped = autoPlayLooped
            self.addChild(GameScene.musicGame)
            GameScene.musicGame.run(SKAction.play())
        } else {
            print("could not find file \(filename)")
            return
        }
    }
    
}
