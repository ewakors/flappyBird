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

    static var score = Int()
    static var highScore = Int()
    static var musicGame = SKAudioNode()
    static let scoreLabel = SKLabelNode()
    static let highScoreLabel = SKLabelNode()
    
    
    var Ground = SKSpriteNode()
    var Ceiling = SKSpriteNode()
    var Pony = SKSpriteNode()
    var startButton = SKSpriteNode()
    var stopMusicButton = SKSpriteNode()
    var startMusicButton = SKSpriteNode()
    var wall = SKNode()
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    var died = Bool()
    var mute: Bool = false
    var duration = CFTimeInterval()
    var distanceBetweenWalls = CGFloat()
    var widthWall = CGFloat()
    var heightWall = CGFloat()
    let startLabel = SKLabelNode()
    var movePipes = SKAction()

    override func didMove(to view: SKView) {
        createStartButton()
        createScene()
        saveHighScore(highScore: GameScene.score)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            if startButton.contains(location) {
                if gameStarted == false {
                    startButton.removeFromParent()
                    startButton.size = CGSize(width: self.frame.width, height: self.frame.height)

                    gameStarted = true
                    GameScene.musicGame.run((SKAction.stop()))
                    playGameMusic(filename: StaticValue.backgroundMusicField, autoPlayLooped: true)
                    
                    Pony.physicsBody?.affectedByGravity = true

                    distanceBetweenWalls(duration: duration, distanceLength: distanceBetweenWalls)
                    ponyJumpFeatures(height: 150)
                    
                    for touch in touches {
                        let location = touch.location(in: self)
                        if stopMusicButton.contains(location) {
                            muteMusic()
                        }
                    }
                } else {
                    if died == true {
                        
                    } else {
                        ponyJumpFeatures(height: 150)
                    }
                }
                
                for touch in touches {
                    let location = touch.location(in: self)
                    if stopMusicButton.contains(location) {
                        muteMusic()
                    }
                }
            } else if stopMusicButton.contains(location) {
                muteMusic()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameStarted == true {
            if died == false {
                enumerateChildNodes(withName: StaticValue.backgroundName, using: ({
                    (node, error) in
                    
                    let background = node as! SKSpriteNode
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
            
            GameScene.score += 1
            GameScene.scoreLabel.text = "\(GameScene.score)"
            playGameMusic(filename: StaticValue.scoreMusicField, autoPlayLooped: false)
            firstBody.node?.removeFromParent()
            
        } else if (firstBody.categoryBitMask == PhysicsCategory.Pony && secondBody.categoryBitMask == PhysicsCategory.Wall || firstBody.categoryBitMask == PhysicsCategory.Wall && secondBody.categoryBitMask == PhysicsCategory.Pony) || (firstBody.categoryBitMask == PhysicsCategory.Pony) {
            
            enumerateChildNodes(withName: StaticValue.wallName, using: ({
                (node, error) in
                
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            
            if died == false {
                died = true
                GameScene.musicGame.run((SKAction.stop()))
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameOverScene(size: self.size)
                self.view?.presentScene(scene, transition: reveal)
                restartScene()
            }
        } else if (firstBody.categoryBitMask == PhysicsCategory.Ground && secondBody.categoryBitMask == PhysicsCategory.Pony) || (firstBody.categoryBitMask == PhysicsCategory.Pony && secondBody.categoryBitMask == PhysicsCategory.Ground) {
            distanceBetweenWalls(duration: 0.0,distanceLength: 0.0)
        }
    }
    
    func startGame(duration: CFTimeInterval, distanceBetweenWalls: CGFloat, widthWall: CGFloat, heightWall: CGFloat) {
        self.duration = duration
        self.distanceBetweenWalls = distanceBetweenWalls
        self.widthWall = widthWall
        self.heightWall = heightWall
    }
    
    func createWalls() {
        
        let scoreNode = SKSpriteNode(imageNamed: StaticValue.coinImageField)
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
        wall.name = StaticValue.wallName

        let bottomWall = SKSpriteNode(imageNamed: StaticValue.wallImageField)
        createBottomWall(bottomWall: bottomWall, bottomWidth: widthWall)
        
        wall.addChild(bottomWall)
        wall.zPosition = 1
        
//        if GameScene.score < 3 {
//            let height = CGFloat.staticWallHeight(wallHeight: 20)
//            let width = CGFloat.staticWallWidth(wallWidth: widthWall)
//            wall.position.y = wall.position.y + height
//            bottomWall.size.width = width
//            scoreNode.position.y = scoreNode.position.y + height
//        } else if GameScene.score >= 3 && GameScene.score < 6 {
//            let height = CGFloat.staticWallHeight(wallHeight: 40)
//            let width = CGFloat.staticWallWidth(wallWidth: 70)
//            bottomWall.size.width = width
//            wall.position.y = wall.position.y + height
//            bottomWall.size.width = 200
//            scoreNode.position.y = scoreNode.position.y + height
//        } else {
//            let height = CGFloat.random(min: 0,max: 200)
//            let width = CGFloat.staticWallWidth(wallWidth: 70)
//            bottomWall.size.width = width
//            wall.position.y = wall.position.y + height
//            scoreNode.position.y = scoreNode.position.y + height / 2
//        }

        wall.addChild(scoreNode)
        wall.run(moveAndRemove)
        
        self.addChild(wall)
    }
 
    func createBottomWall(bottomWall: SKSpriteNode, bottomWidth: CGFloat) {
        bottomWall.setScale(0.5)
        bottomWall.size.width = bottomWidth
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
        bottomWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        bottomWall.physicsBody?.collisionBitMask = PhysicsCategory.Pony
        bottomWall.physicsBody?.contactTestBitMask = PhysicsCategory.Pony
        bottomWall.physicsBody?.affectedByGravity = false
        bottomWall.physicsBody?.isDynamic = false
        bottomWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 450)
    }
    
    func createStartButton() {
        startButton = SKSpriteNode(imageNamed: StaticValue.startBtnImageField )
        startButton.size = CGSize(width: 100, height: 50)
        startButton.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        startButton.zPosition = 4
        startButton.setScale(0)
        self.addChild(startButton)
        startButton.run(SKAction.scale(to: 1.0, duration: 0.3))
        playGameMusic(filename: StaticValue.startGameMusicField, autoPlayLooped: false)
    }
    
    func createStopMusicButton() {
        startMusicButton.removeFromParent()
        stopMusicButton = SKSpriteNode(imageNamed: StaticValue.muteImageField)
        stopMusicButton.size = CGSize(width: 30, height: 30)
        stopMusicButton.position = CGPoint(x: self.frame.width / 4 + 220 , y: self.frame.height / 4 + 400)
        stopMusicButton.zPosition = 9
        stopMusicButton.setScale(0)
        self.addChild(stopMusicButton)
        stopMusicButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func createStartMusicButton() {
        stopMusicButton.removeFromParent()
        startMusicButton = SKSpriteNode(imageNamed: StaticValue.soundImageField)
        startMusicButton.size = CGSize(width: 30, height: 30)
        startMusicButton.position = CGPoint(x: self.frame.width / 4 + 220 , y: self.frame.height / 4 + 400)
        startMusicButton.zPosition = 9
        startMusicButton.setScale(0)
        self.addChild(startMusicButton)
        startMusicButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }

    func restartScene() {
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        saveHighScore(highScore: GameScene.score)
        GameScene.score = 0
        createStartButton()
        createScene()
    }
    
    func restartScene(duration: CFTimeInterval, distanceBetweenWalls: CGFloat, widthWall: CGFloat, heightWall: CGFloat) {
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        saveHighScore(highScore: GameScene.score)
        GameScene.score = 0
        createStartButton()
        createScene()
        self.duration = duration
        self.distanceBetweenWalls = distanceBetweenWalls
        self.widthWall = widthWall
        self.heightWall = heightWall
    }
    
    func createScene() {

        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: StaticValue.backgroundImageField)
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i) * self.frame.width, y: 0)
            background.name = StaticValue.backgroundName
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }

        if mute == false {
            createStopMusicButton()
        }
        else {
            createStartMusicButton()
        }

        createGameScene()
        createCeilingScene()
        createGroundScene()
        createPony()
    }
    
    func createGameScene() {
        GameScene.scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2.5 + self.frame.height / 2.5)
        GameScene.scoreLabel.text = "\(GameScene.score)"
        GameScene.scoreLabel.fontName = StaticValue.fontNameField
        GameScene.scoreLabel.fontSize = 40
        GameScene.scoreLabel.zPosition = 5
        self.addChild(GameScene.scoreLabel)
        
        GameScene.highScoreLabel.position = CGPoint(x: self.frame.width / 3, y: self.frame.height / 2 + self.frame.height / 2.5)
        GameScene.highScoreLabel.fontName = StaticValue.fontNameField
        GameScene.highScoreLabel.fontSize = 40
        GameScene.highScoreLabel.zPosition = 8
        self.addChild(GameScene.highScoreLabel)
    }
    
    func createCeilingScene() {
        Ceiling = SKSpriteNode(imageNamed: StaticValue.ceilingImageField)
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
    }
    
    func createGroundScene() {
        Ground = SKSpriteNode(imageNamed: StaticValue.groundImageField)
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
    }
    
    func createPony() {
        Pony = SKSpriteNode(imageNamed: StaticValue.ponyImageField )
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

    func distanceBetweenWalls(duration: CFTimeInterval, distanceLength: CGFloat) {
        
        let spawn = SKAction.run({
            () in
            self.createWalls()
        })
        
        let delay = SKAction.wait(forDuration: duration)
        let spawnDelay = SKAction.sequence([spawn,delay])
        let spawnDelayForever = SKAction.repeatForever(spawnDelay)
        self.run(spawnDelayForever)
        
        let distance = CGFloat(self.frame.width + wall.frame.width)
        movePipes = SKAction.moveBy(x: -distance - distanceLength, y: 0, duration: TimeInterval(0.008 * distance))
        let removePipes = SKAction.removeFromParent()
        moveAndRemove = SKAction.sequence([movePipes,removePipes])
    }
    
    func ponyJumpFeatures(height: CGFloat) {
        Pony.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        Pony.physicsBody?.applyImpulse(CGVector(dx: 0, dy: height))
    }
    
    func saveHighScore(highScore:Int){
        if let currentHighScore:Int = UserDefaults.standard.value(forKey: StaticValue.highScoreField) as? Int{
            GameScene.highScoreLabel.text = "\(StaticValue.highScoreTextField) \(currentHighScore)"
            GameScene.highScore = currentHighScore
            if(highScore > currentHighScore){
                UserDefaults.standard.set(highScore, forKey: StaticValue.highScoreField)
                UserDefaults.standard.synchronize()
            }
        } else{
            GameScene.highScoreLabel.text = "\(StaticValue.highScoreTextField) \(highScore)"
            UserDefaults.standard.set(highScore, forKey: StaticValue.highScoreField)
            UserDefaults.standard.synchronize()
        }
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
    
    func muteMusic() {
        if mute {
            createStopMusicButton()
            mute = false
            GameScene.musicGame.run(SKAction.changeVolume(to: 1, duration: 0.3))
        } else {
            createStartMusicButton()
            mute = true
            GameScene.musicGame.run(SKAction.changeVolume(to: 0, duration: 0.3))
        }
    }
}
