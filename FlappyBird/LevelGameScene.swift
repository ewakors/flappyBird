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

    let levelGameLabel = SKLabelNode()
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
                print("quti game")
                quitGame = true
                self.scene?.removeFromParent()
                //self.view?.dis
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func createLevelGameLabel() {
        levelGameLabel.fontName = StaticValue.fontNameField
        levelGameLabel.text = "\(StaticValue.levelGameMessageField) \(gameLevel)"
        levelGameLabel.fontColor = SKColor.black
        levelGameLabel.fontSize = 60
        levelGameLabel.zPosition = 1
        levelGameLabel.horizontalAlignmentMode = .center
        levelGameLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + 100)
        self.addChild(levelGameLabel)
    }
    
    func createScoreLabel() {
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + 30)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.text = "\(score)"
        scoreLabel.fontName = StaticValue.fontNameField
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = SKColor.black
        scoreLabel.zPosition = 5
        self.addChild(scoreLabel)
    }
    
    func createHighScoreLabel() {
        highScoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - 50)
        highScoreLabel.horizontalAlignmentMode = .center
        highScoreLabel.text = "\(StaticValue.highScoreTextField) \(highScore)"
        highScoreLabel.fontName = StaticValue.fontNameField
        highScoreLabel.fontSize = 50
        highScoreLabel.fontColor = SKColor.black
        highScoreLabel.zPosition = 5
        self.addChild(highScoreLabel)
    }
    
    func createContinueButton() {
        continueButton = SKSpriteNode(imageNamed: StaticValue.startBtnImageField)
        continueButton.size = CGSize(width: 100, height: 50)
        continueButton.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 1.8 - 150)
        continueButton.zPosition = 6
        continueButton.setScale(0)
        self.addChild(continueButton)
        continueButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func createQuitButton() {
        quitButton = SKSpriteNode(imageNamed: StaticValue.quitGameBtnImageField)
        quitButton.size = CGSize(width: 100, height: 50)
        quitButton.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2.3 - 150)
        quitButton.zPosition = 6
        quitButton.setScale(0)
        self.addChild(quitButton)
        quitButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
}
