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
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = SKColor.yellow
        
        
        
        createGameOverLabel()
        createScoreLabel()
        createHighScoreLabel()
        createRestartButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            if restartButton.contains(location) {
                GameScene.playGameMusic(filename: StaticValue.gameOverMusicField, autoPlayLooped: false)
                let reveal: SKTransition = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: self.view!.bounds.size)
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene, transition: reveal)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createRestartButton() {
        restartButton = SKSpriteNode(imageNamed: StaticValue.restartBtnImageField)
        restartButton.size = CGSize(width: 150, height: 50)
        restartButton.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - 150)
        restartButton.zPosition = 6
        restartButton.setScale(0)
        self.addChild(restartButton)
        restartButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func createGameOverLabel() {
        gameOverLabel.fontName = StaticValue.fontNameField
        gameOverLabel.text = StaticValue.gameOverMessageField
        gameOverLabel.fontColor = SKColor.black
        gameOverLabel.fontSize = 60
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
    
}
