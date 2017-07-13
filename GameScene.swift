//
//  GameScene.swift
//  FlappyBird
//
//  Created by Ewa Korszaczuk on 10.07.2017.
//  Copyright © 2017 Ewa Korszaczuk. All rights reserved.
//

import SpriteKit
import AVFoundation

struct PhysicsCategory {
    static let Pony: UInt32 = 0x1 << 1
    static let Ground: UInt32 = 0x1 << 2
    static let Wall: UInt32 = 0x1 << 3
    static let Score: UInt32 = 0x1 << 4
    static let Ceiling: UInt32 = 0x1 << 7
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    static let wallName = "wallPair"
    static let backgroundName = "background"
    static let highScoreField = "highScoreLabel"
    static let backgroundMusicField = "backgroundMusic"
    static let gameOverMusicField = "gameOverMusic"
    static let coinImageField = "coinHeart"
    static let wallImageField = "Wall"
    static let restartBtnImageField = "RestartBtn"
    static let startBtnImageField = "startButton"
    static let backgroundImageField = "Background2"
    static let fontNameField = "FlappyBirdy"
    static let groundImageField = "Ground"
    static let ponyImageField = "Kucyk"
    
    var Ground = SKSpriteNode()
    var Ceiling = SKSpriteNode()
    var Pony = SKSpriteNode()
    var wall = SKNode()
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    var score = Int()
    var died = Bool()
    var restartButton = SKSpriteNode()
    var startButton = SKSpriteNode()
    var musicGame = SKAudioNode()
    let scoreLabel = SKLabelNode()
    let highScoreLabel = SKLabelNode()
    let startLabel = SKLabelNode()
    

    override func didMove(to view: SKView) {
        createStartButton()
        createScene()
        saveHighScore(highScore: score)

        //let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(GameScene.longPressed(longPress:)))
        //self.view?.addGestureRecognizer(longGesture)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            if startButton.contains(location) {
                if gameStarted == false {
                    startButton.removeFromParent()
                    startButton.size = CGSize(width: self.frame.width, height: self.frame.height)

                    gameStarted = true
                    
                    playGameMusic(filename: GameScene.backgroundMusicField)
                    musicGame.run((SKAction.play()))
                    
                    Pony.physicsBody?.affectedByGravity = true
                    
                    let spawn = SKAction.run({
                        () in
                        self.createWalls()
                    })
                    
                    let delay = SKAction.wait(forDuration: 2.0)
                    let spawnDelay = SKAction.sequence([spawn,delay])
                    let spawnDelayForever = SKAction.repeatForever(spawnDelay)
                    self.run(spawnDelayForever)
                    
                    distanceBetweenWalls(distanceLength: 100.0)
                    ponyJumpFeatures(height: 150)
                    
                } else {
                    if died == true {
                        
                    } else {
                        ponyJumpFeatures(height: 150)
                    }
                }
                
                for touch in touches {
                    let location = touch.location(in: self)
                    
                    if died == true {
                        if restartButton.contains(location) {
                            restartScene()
                        }
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameStarted == true {
            if died == false {
                enumerateChildNodes(withName: GameScene.backgroundName, using: ({
                    (node, error) in
                    
                    let background = node as! SKSpriteNode
                    // 20 - speeder background
                    background.position = CGPoint(x: background.position.x - 2, y: background.position.y)
                    
                    if background.position.x <= -background.size.width {
                        background.position = CGPoint(x: background.position.x + background.size.width * 2,y: background.position.y)
                    }
                }))
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if (firstBody.categoryBitMask == PhysicsCategory.Score && secondBody.categoryBitMask == PhysicsCategory.Pony) || (firstBody.categoryBitMask == PhysicsCategory.Pony && secondBody.categoryBitMask == PhysicsCategory.Score) {
            
            score += 1
            scoreLabel.text = "\(score)"
            firstBody.node?.removeFromParent()
            
        } else if (firstBody.categoryBitMask == PhysicsCategory.Pony && secondBody.categoryBitMask == PhysicsCategory.Wall || firstBody.categoryBitMask == PhysicsCategory.Wall && secondBody.categoryBitMask == PhysicsCategory.Pony) || (firstBody.categoryBitMask == PhysicsCategory.Pony && secondBody.categoryBitMask == PhysicsCategory.Ground || firstBody.categoryBitMask == PhysicsCategory.Ground && secondBody.categoryBitMask == PhysicsCategory.Pony) {
            
            enumerateChildNodes(withName: GameScene.wallName, using: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            
            if died == false {
                died = true
                musicGame.run((SKAction.stop()))
                playGameMusic(filename: GameScene.gameOverMusicField)
                createRestartButton()
            }
        }
    }
    
    func createWalls() {
        
        let scoreNode = SKSpriteNode(imageNamed: GameScene.coinImageField)
        scoreNode.size = CGSize(width: 50, height: 50)
        scoreNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 170)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.Pony
        scoreNode.color = SKColor.blue
        
        wall = SKNode()
        wall.name = GameScene.wallName

        let bottomWall = SKSpriteNode(imageNamed: GameScene.wallImageField)

        bottomWall.setScale(0.5)
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
        bottomWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        bottomWall.physicsBody?.collisionBitMask = PhysicsCategory.Pony
        bottomWall.physicsBody?.contactTestBitMask = PhysicsCategory.Pony
        bottomWall.physicsBody?.affectedByGravity = false
        bottomWall.physicsBody?.isDynamic = false
        bottomWall.position = CGPoint(x: self.frame.width + 25 , y: self.frame.height / 2 - 450)
        
        wall.addChild(bottomWall)
        wall.zPosition = 1
        
        if score < 3 {
            let height = CGFloat.staticHeight(wallHeight: 20)
            wall.position.y = wall.position.y + height
            scoreNode.position.y = scoreNode.position.y + height
        } else if score >= 3 && score < 6 {
            let height = CGFloat.staticHeight(wallHeight: 40)
            wall.position.y = wall.position.y + height
            scoreNode.position.y = scoreNode.position.y + height
        } else {
            let height = CGFloat.random(min: 0,max: 200)
            wall.position.y = wall.position.y + height
            scoreNode.position.y = scoreNode.position.y + height / 2
        }

        wall.addChild(scoreNode)
        wall.run(moveAndRemove)
        
        self.addChild(wall)
    }
    
    func createRestartButton() {
        restartButton = SKSpriteNode(imageNamed: GameScene.restartBtnImageField)
        restartButton.size = CGSize(width: 200, height: 100)
        restartButton.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartButton.zPosition = 6
        restartButton.setScale(0)
        self.addChild(restartButton)
        restartButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func createStartButton() {
        startButton = SKSpriteNode(imageNamed: GameScene.startBtnImageField )
        startButton.size = CGSize(width: 200, height: 100)
        startButton.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        startButton.zPosition = 6
        startButton.setScale(0)
        self.addChild(startButton)
        startButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func restartScene() {
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        saveHighScore(highScore: score)
        score = 0
        createStartButton()
        createScene()
        playGameMusic(filename: GameScene.backgroundMusicField)
        musicGame.run((SKAction.stop()))
    }
    
    func createScene() {

        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: GameScene.backgroundImageField)
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i) * self.frame.width, y: 0)
            background.name = GameScene.backgroundName
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }
        
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2.5 + self.frame.height / 2.5)
        scoreLabel.text = "\(score)"
        scoreLabel.fontName = GameScene.fontNameField
        scoreLabel.fontSize = 40
        scoreLabel.zPosition = 5
        self.addChild(scoreLabel)
        
        highScoreLabel.position = CGPoint(x: self.frame.width / 3, y: self.frame.height / 2 + self.frame.height / 2.5)
        highScoreLabel.fontName = GameScene.fontNameField
        highScoreLabel.fontSize = 40
        highScoreLabel.zPosition = 8
        self.addChild(highScoreLabel)
        
//        startLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
//        startLabel.text = "Start game"
//        startLabel.fontName = "FlappyBirdy"
//        startLabel.fontSize = 60
//        startLabel.zPosition = 5
//        self.addChild(startLabel)
        
//        createStartButton()
        
        Ceiling = SKSpriteNode(imageNamed: GameScene.groundImageField)
        Ceiling.setScale(0.5)
        Ceiling.position = CGPoint(x: self.frame.width / 2, y: 0 + Ceiling.frame.height / 2 + 650)
        Ceiling.physicsBody = SKPhysicsBody(rectangleOf: Ceiling.size)
        Ceiling.physicsBody?.categoryBitMask = PhysicsCategory.Ceiling
        Ceiling.physicsBody?.collisionBitMask = PhysicsCategory.Pony
        Ceiling.physicsBody?.contactTestBitMask = PhysicsCategory.Pony
        Ceiling.physicsBody?.affectedByGravity = false
        Ceiling.physicsBody?.isDynamic = false
        Ceiling.zRotation = CGFloat(M_PI)
        Ceiling.zPosition = 7
        self.addChild(Ceiling)
        
        Ground = SKSpriteNode(imageNamed: GameScene.groundImageField)
        Ground.setScale(0.5)
        Ground.position = CGPoint(x: self.frame.width / 2, y: 0 + Ground.frame.height / 2)
        Ground.physicsBody = SKPhysicsBody(rectangleOf: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCategory.Pony
        Ground.physicsBody?.contactTestBitMask = PhysicsCategory.Pony
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.isDynamic = false
        Ground.zPosition = 3
        self.addChild(Ground)
        
        Pony = SKSpriteNode(imageNamed: GameScene.ponyImageField )
        Pony.size = CGSize(width: 70, height: 80)
        Pony.position = CGPoint(x: self.frame.width / 2 - Pony.frame.width, y: self.frame.height / 2)
        Pony.physicsBody = SKPhysicsBody(circleOfRadius: Pony.frame.height / 2)
        Pony.physicsBody?.categoryBitMask = PhysicsCategory.Pony
        Pony.physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.Ceiling
        Pony.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.Score | PhysicsCategory.Ceiling
        Pony.physicsBody?.affectedByGravity = false
        Pony.physicsBody?.isDynamic = true
        Pony.zPosition = 2
        self.addChild(Pony)
    }
    
    func longPressed(longPress: UILongPressGestureRecognizer) {
        
        if gameStarted == true {

            Pony.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.run({
                () in
            })
            
            let delay = SKAction.wait(forDuration: 2.0)
            let spawnDelay = SKAction.sequence([spawn,delay])
            let spawnDelayForever = SKAction.repeatForever(spawnDelay)
            self.run(spawnDelayForever)
            
            distanceBetweenWalls(distanceLength: 100.0)
            ponyJumpFeatures(height: 90)
        } else {
            if died == true {
                
            } else {
                ponyJumpFeatures(height: 90)
            }
        }
    }
    
    func distanceBetweenWalls(distanceLength: CGFloat) {
        
        let distance = CGFloat(self.frame.width + wall.frame.width)
        // 0.004 - faster
        //let movePipes = SKAction.moveBy(x: -distance - 50, y: 100, duration: TimeInterval(0.008 * distance)) - move pipes
        let movePipes = SKAction.moveBy(x: -distance - distanceLength, y: 0, duration: TimeInterval(0.008 * distance))
        let removePipes = SKAction.removeFromParent()
        moveAndRemove = SKAction.sequence([movePipes,removePipes])
    }
    
    func ponyJumpFeatures(height: CGFloat) {
        Pony.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        Pony.physicsBody?.applyImpulse(CGVector(dx: 1, dy: 150))
    }
    
    func saveHighScore(highScore:Int){
        if let currentHighScore:Int = UserDefaults.standard.value(forKey: GameScene.highScoreField) as? Int{
            highScoreLabel.text = "High score: \(currentHighScore)"
            if(highScore > currentHighScore){
                UserDefaults.standard.set(highScore, forKey: GameScene.highScoreField)
                UserDefaults.standard.synchronize()
                print("h: \(currentHighScore)")
            }
        } else{
            highScoreLabel.text = "High score: \(highScore)"
            UserDefaults.standard.set(highScore, forKey: GameScene.highScoreField)
            UserDefaults.standard.synchronize()
        }
    }
    
    func playGameMusic(filename: String) {
        if let musicURL = Bundle.main.url(forResource: filename, withExtension: "mp3") {
            musicGame = SKAudioNode(url: musicURL)
            print("\(musicURL)")
            addChild(musicGame)
            
        } else {
            print("could not find file \(filename)")
            return
        }
    }
}
