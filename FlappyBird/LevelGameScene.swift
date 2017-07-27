//
//  LevelGameScene.swift
//  FlappyBird
//
//  Created by Ewa Korszaczuk on 24.07.2017.
//  Copyright © 2017 Ewa Korszaczuk. All rights reserved.
//

import SpriteKit
import AVFoundation

class LevelGameScene: SKScene {

   /* let levelGameLabel = SKLabelNode()
    let scoreLabel = SKLabelNode()
    let highScoreLabel = SKLabelNode()
    var continueButton = SKSpriteNode()
    var quitButton = SKSpriteNode()
    var quitGame: Bool = false
    var score = Int()
    var highScore = Int()
    var gameLevel = Int()
    
    override init(size: CGSize) {
        super.init(size: size)
        createBackground()
        createLevelGameLabel()
        createScoreLabel()
        createHighScoreLabel()
        createContinueButton()
        createQuitButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let loctaion = touch.location(in: self)
            if continueButton.contains(loctaion) {
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: self.size)
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene, transition: reveal)
            } else if quitButton.contains(loctaion) {
                quitGame = true
                self.scene?.removeFromParent()
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    
    
    func createBackground() {
        let background = SKSpriteNode(imageNamed: StaticValue.backgroundImageField)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = frame.size
        addChild(background)
    }
    
    func createLevelGameLabel() {
        levelGameLabel.fontName = StaticValue.fontNameField
        levelGameLabel.text = "\(StaticValue.levelGameMessageField)\(GameScene.gameLevel)"
        levelGameLabel.fontColor = SKColor.black
        levelGameLabel.fontSize = CGFloat(StaticValue.levelLabelFontSize)
        levelGameLabel.zPosition = 1
        levelGameLabel.position = CGPoint(x: frame.midX, y: frame.midY * 1.5)
        addChild(levelGameLabel)
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
    
    func createContinueButton() {
        continueButton = SKSpriteNode(imageNamed: StaticValue.startBtnImageField)
        continueButton.size = CGSize(width: frame.midX / 2, height: frame.midY / 6 )
        continueButton.position = CGPoint(x: frame.midX, y: frame.midY * 0.75)
        continueButton.zPosition = 1
        addChild(continueButton)
        continueButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func createQuitButton() {
        quitButton = SKSpriteNode(imageNamed: StaticValue.quitGameBtnImageField)
        quitButton.size = CGSize(width: frame.midX / 2, height: frame.midY / 6 )
        quitButton.position = CGPoint(x: frame.midX, y: frame.midY * 0.45)
        quitButton.zPosition = 1
        addChild(quitButton)
        quitButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }   */
}
