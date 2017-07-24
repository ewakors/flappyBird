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
    static let TransparentWall: UInt32 = 0x1 << 5
    static let Background: UInt32 = 0x1 << 6
    static let Ceiling: UInt32 = 0x1 << 7
    static let LeftFrame: UInt32 = 0x1 << 8
    static let RightFrame: UInt32 = 0x1 << 9
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    static var score = Int()
    static var highScore = Int()
    static var gameLevel = Int()
    static var musicGame = SKAudioNode()
    static let scoreLabel = SKLabelNode()
    static let highScoreLabel = SKLabelNode()
    
    var Ground = SKSpriteNode()
    var Ceiling = SKSpriteNode()
    var LeftFrame = SKSpriteNode()
    var RightFrame = SKSpriteNode()
    var Pony = SKSpriteNode()
    var background = SKSpriteNode()
    var startButton = SKSpriteNode()
    var stopMusicButton = SKSpriteNode()
    var startMusicButton = SKSpriteNode()
    var wall = SKNode()
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    var died = Bool()
    var mute: Bool = false
    var gamePaused = Bool ()
    var duration: CFTimeInterval = CFTimeInterval(UserDefaults.standard.float(forKey: StaticValue.durationField))
    var distanceBetweenWalls: CGFloat = CGFloat(UserDefaults.standard.float(forKey: StaticValue.distanceBetweenWallsField))
    var widthWall: CGFloat = CGFloat(UserDefaults.standard.float(forKey: StaticValue.widthWallField))
    var heightWall: CGFloat = CGFloat(UserDefaults.standard.float(forKey: StaticValue.heightWallField))
    var heightPonyJump: CGFloat = CGFloat(UserDefaults.standard.float(forKey: StaticValue.heightPonyJumpField))
    let startLabel = SKLabelNode()
    var movePipes = SKAction()
    //var gameTimer = Timer()
    var gameTimer: Timer? = UserDefaults.standard.value(forKey: StaticValue.gameTimerField) as? Timer
    var scoreNode = SKSpriteNode()
    var bottomWall = SKSpriteNode()
    var actionCreateBottomWall = SKAction()

    override func didMove(to view: SKView) {
       
        createStartButton()
        createScene()
        saveHighScore(highScore: GameScene.score)
        
        /*gameTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block:
            {(gameTimer) in
            if self.gameStarted == true {
                let heightPonyJump = CGFloat.random(min: 0,max: 100)
                
                self.ponyJumpFeatures(heightPonyJump: heightPonyJump)
                self.startGameTimer(gameTimer: gameTimer)
            }
        })*/
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            if startButton.contains(location) {
                if gameStarted == false {
                    
                    startButton.removeFromParent()
                    startButton.size = CGSize(width: self.frame.width, height: self.frame.height)
                    gameStarted = true
                    gamePaused = false
                    
                    GameScene.musicGame.run((SKAction.stop()))
                   // playGameMusic(filename: StaticValue.backgroundMusicField, autoPlayLooped: true)
                    
                    Pony.physicsBody?.affectedByGravity = true

                    distanceBetweenWalls(duration: duration, distanceLength: distanceBetweenWalls)
                    ponyJumpFeatures(heightPonyJump: 150)
                    
                    for touch in touches {
                        let location = touch.location(in: self)
                        if stopMusicButton.contains(location) {
                            muteMusic()
                        }
                    }
                } else {
                    if died == true {
                        
                    } else {
                        ponyJumpFeatures(heightPonyJump: 150)
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
                    
                    self.background = node as! SKSpriteNode
                    self.background.position = CGPoint(x: self.background.position.x - 2, y: self.background.position.y)
                    
                    if self.background.position.x <= -self.background.size.width {
                        self.background.position = CGPoint(x: self.background.position.x + self.background.size.width * 2,y: self.background.position.y)
                    }
                }))
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if (firstBody.categoryBitMask == PhysicsCategory.Score && secondBody.categoryBitMask == PhysicsCategory.Pony) || (firstBody.categoryBitMask == PhysicsCategory.Pony && secondBody.categoryBitMask == PhysicsCategory.Score) || (firstBody.categoryBitMask == PhysicsCategory.TransparentWall && secondBody.categoryBitMask == PhysicsCategory.Pony) || (firstBody.categoryBitMask == PhysicsCategory.Pony && secondBody.categoryBitMask == PhysicsCategory.TransparentWall) {
            
            GameScene.score += 1
            GameScene.scoreLabel.text = "\(GameScene.score)"
            playGameMusic(filename: StaticValue.scoreMusicField, autoPlayLooped: false)
            firstBody.node?.removeFromParent()
            
        }
        else if (firstBody.categoryBitMask == PhysicsCategory.Pony && secondBody.categoryBitMask == PhysicsCategory.LeftFrame || firstBody.categoryBitMask == PhysicsCategory.LeftFrame && secondBody.categoryBitMask == PhysicsCategory.Pony) || (firstBody.categoryBitMask == PhysicsCategory.Pony) {
            
            enumerateChildNodes(withName: StaticValue.leftFrame, using: ({
                (node, error) in
    
                node.speed = 0
                self.removeAllActions()
            }))
            
            if died == false {
                died = true
                
                restartScene()                
            }
        }
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

    func ponyJumpFeatures(heightPonyJump: CGFloat) {
        self.heightPonyJump = heightPonyJump
        UserDefaults.standard.set(heightPonyJump, forKey: StaticValue.heightPonyJumpField)
        UserDefaults.standard.synchronize()
        Pony.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        Pony.physicsBody?.applyImpulse(CGVector(dx: 0, dy: heightPonyJump))
    }
    
    func startGame(duration: CFTimeInterval, distanceBetweenWalls: CGFloat, widthWall: CGFloat, heightWall: CGFloat ) {
        self.duration = duration
        self.distanceBetweenWalls = distanceBetweenWalls
        self.widthWall = widthWall
        self.heightWall = heightWall
        
        UserDefaults.standard.set(duration, forKey: StaticValue.durationField)
        UserDefaults.standard.synchronize()
        UserDefaults.standard.set(distanceBetweenWalls, forKey: StaticValue.distanceBetweenWallsField)
        UserDefaults.standard.synchronize()
        UserDefaults.standard.set(widthWall, forKey: StaticValue.widthWallField)
        UserDefaults.standard.synchronize()
        UserDefaults.standard.set(heightWall, forKey: StaticValue.heightWallField)
        UserDefaults.standard.synchronize()
    }

    func startGameTimer(gameTimer: Timer) {
        self.gameTimer = gameTimer
        //UserDefaults.standard.set(gameTimer, forKey: "gameTimer")
        //UserDefaults.standard.synchronize()
    }
 
    func createWalls() {
        
        wall = SKNode()
        wall.name = StaticValue.wallName
        wall.zPosition = 1

        scoreNode = SKSpriteNode(imageNamed: StaticValue.coinImageField)
        let actionCreateCoin = SKAction.run {
            self.createCoin(scoreNode: self.scoreNode)
        }
        wall.addChild(self.scoreNode)
        scoreNode.run(actionCreateCoin, withKey: StaticValue.actionCreateCoinField)

        
        bottomWall = SKSpriteNode(imageNamed: StaticValue.wallImageField)
        actionCreateBottomWall = SKAction.run {
            self.createBottomWall(bottomWall: self.bottomWall, bottomWidth: self.widthWall, bottomHeight: self.heightWall)
        }
    
        wall.addChild(bottomWall)
        bottomWall.run(actionCreateBottomWall, withKey: StaticValue.actionCreateBottomWallField)
        
        let transparentWall = SKSpriteNode(imageNamed: StaticValue.transparentWallImageField)
        createTransparentWall(transparentWall: transparentWall)
        wall.addChild(transparentWall)
        
        if GameScene.score < 3 {
            bottomWall.size.width = widthWall
            wall.position.y = wall.position.y
            scoreNode.position.y = scoreNode.position.y
        } else if GameScene.score >= 3 && GameScene.score < 6 {
            let height = CGFloat.staticWallHeight(wallHeight: 40)
            let width = CGFloat.staticWallWidth(wallWidth: widthWall + 10)
            bottomWall.size.width = width
            wall.position.y = wall.position.y + height
            scoreNode.position.y = scoreNode.position.y + height
        } else if GameScene.score >= 6 && GameScene.score < 10 {
            let height = CGFloat.staticWallHeight(wallHeight: 60)
            let width = CGFloat.staticWallWidth(wallWidth: widthWall)
            bottomWall.size.width = width + 20 
            wall.position.y = wall.position.y + height
            scoreNode.position.y = scoreNode.position.y + height / 2
        } else if GameScene.score >= 10 && GameScene.score < 14 {
             let height = CGFloat.random(min: 0,max: 400)
            let width = CGFloat.staticWallWidth(wallWidth: widthWall + 20)
            bottomWall.size.width = width
            wall.position.y = wall.position.y + height
            scoreNode.position.y = scoreNode.position.y + height / 2
        }

        if GameScene.gameLevel == 0 && (GameScene.score == 3 || GameScene.score == 4) {
            levelGameScene()
            GameScene.gameLevel += 1
        } else if GameScene.gameLevel == 1 && (GameScene.score == 6 || GameScene.score == 7) {
            GameScene.gameLevel += 1
            print("\(GameScene.gameLevel)")
            levelGameScene()
        } else if GameScene.gameLevel == 2 && (GameScene.score == 10 || GameScene.score == 11) {
            GameScene.gameLevel += 1
            print("\(GameScene.gameLevel)")
            levelGameScene()
        }
        
        wall.run(moveAndRemove)
        
        self.addChild(wall)
    } 
    
    func createBottomWall(bottomWall: SKSpriteNode, bottomWidth: CGFloat, bottomHeight: CGFloat) {
        bottomWall.setScale(0.5)
        bottomWall.size.width = bottomWidth
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
        bottomWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        bottomWall.physicsBody?.collisionBitMask = PhysicsCategory.Pony
        bottomWall.physicsBody?.contactTestBitMask = PhysicsCategory.Pony
        bottomWall.physicsBody?.affectedByGravity = false
        bottomWall.physicsBody?.isDynamic = false
        bottomWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height - self.frame.height * 1.35 + bottomHeight)
    }
    
    func createTransparentWall(transparentWall: SKSpriteNode) {
        transparentWall.size = CGSize(width: 3, height: self.frame.height)
        transparentWall.position = CGPoint(x: self.frame.width + 25, y: (self.view?.bounds.size.height)! / 2)
        transparentWall.physicsBody = SKPhysicsBody(rectangleOf: transparentWall.size)
        transparentWall.physicsBody?.affectedByGravity = false
        transparentWall.physicsBody?.isDynamic = false
        transparentWall.physicsBody?.categoryBitMask = PhysicsCategory.TransparentWall
        transparentWall.physicsBody?.collisionBitMask = 0
        transparentWall.physicsBody?.contactTestBitMask = PhysicsCategory.Pony
    }
    
    func createCoin(scoreNode: SKSpriteNode) {
        scoreNode.size = CGSize(width: 50, height: 50)
        scoreNode.position = CGPoint(x: self.frame.width + 25 , y: self.frame.height / 4)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.Pony
    }
    
    func createStartButton() {
        startButton = SKSpriteNode(imageNamed: StaticValue.startBtnImageField)
        startButton.size = CGSize(width: 100, height: 50)
        startButton.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        startButton.zPosition = 4
        self.addChild(startButton)
        startButton.run(SKAction.scale(to: 1.0, duration: 0.3))
        //playGameMusic(filename: StaticValue.startGameMusicField, autoPlayLooped: false)
    }
    
    func createStopMusicButton() {
        startMusicButton.removeFromParent()
        stopMusicButton = SKSpriteNode(imageNamed: StaticValue.muteImageField)
        stopMusicButton.size = CGSize(width: 25, height: 25)
        stopMusicButton.position = CGPoint(x: self.frame.width / 1.07, y: self.frame.height / 1.04)
        stopMusicButton.zPosition = 9
        self.addChild(stopMusicButton)
        stopMusicButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func createStartMusicButton() {
        stopMusicButton.removeFromParent()
        startMusicButton = SKSpriteNode(imageNamed: StaticValue.soundImageField)
        startMusicButton.size = CGSize(width: 25, height: 25)
        startMusicButton.position = CGPoint(x: self.frame.width / 1.07 , y: self.frame.height / 1.04)
        startMusicButton.zPosition = 9
        self.addChild(startMusicButton)
        startMusicButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }

    func restartScene() {
        GameScene.musicGame.run((SKAction.stop()))
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let scene = GameOverScene(size: self.size)
        self.view?.presentScene(scene, transition: reveal)
        
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        saveHighScore(highScore: GameScene.score)
        GameScene.score = 0
    }
    
    func levelGameScene() {
        GameScene.musicGame.run((SKAction.stop()))
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let scene = LevelGameScene(size: self.size)
        self.view?.presentScene(scene, transition: reveal)
        self.removeAllChildren()
        self.removeAllActions()
        gamePaused = false
    }
    
    func createScene() {

        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2 {
            background = SKSpriteNode(imageNamed: StaticValue.backgroundImageField)
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
        createPony()
        createFrameScene()
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
        GameScene.highScoreLabel.zPosition = 2
        self.addChild(GameScene.highScoreLabel)
    }
    
    func createFrameScene() {
        Ceiling = SKSpriteNode(imageNamed: StaticValue.ceilingImageField)
        Ceiling.setScale(0.5)
        Ceiling.size = CGSize(width: self.frame.width, height: 5)
        Ceiling.position = CGPoint(x: self.frame.width / 2, y: self.frame.height )
        Ceiling.physicsBody = SKPhysicsBody(rectangleOf: Ceiling.size)
        Ceiling.physicsBody?.categoryBitMask = PhysicsCategory.Ceiling
        Ceiling.physicsBody?.collisionBitMask = PhysicsCategory.Pony
        Ceiling.physicsBody?.contactTestBitMask = PhysicsCategory.Pony
        Ceiling.physicsBody?.affectedByGravity = false
        Ceiling.physicsBody?.isDynamic = false
        Ceiling.zPosition = 7
        self.addChild(Ceiling)
        
        RightFrame = SKSpriteNode(imageNamed: StaticValue.transparentWallImageField)
        RightFrame.setScale(0.5)
        RightFrame.size = CGSize(width: 5, height: self.frame.height)
        RightFrame.position = CGPoint(x: self.frame.width ,y: self.frame.height / 2)
        RightFrame.physicsBody = SKPhysicsBody(rectangleOf: RightFrame.size)
        RightFrame.physicsBody?.categoryBitMask = PhysicsCategory.RightFrame
        RightFrame.physicsBody?.collisionBitMask = PhysicsCategory.Pony
        RightFrame.physicsBody?.contactTestBitMask = PhysicsCategory.Pony
        RightFrame.physicsBody?.affectedByGravity = false
        RightFrame.physicsBody?.isDynamic = false
        RightFrame.zPosition = 2
        self.addChild(RightFrame)
        
        LeftFrame = SKSpriteNode(imageNamed: StaticValue.wallImageField)
        LeftFrame.setScale(0.5)
        LeftFrame.size = CGSize(width: 25, height: self.frame.height)
        LeftFrame.position = CGPoint(x: self.frame.width - self.frame.width - 25 ,y: self.frame.height / 2)
        LeftFrame.physicsBody = SKPhysicsBody(rectangleOf: LeftFrame.size)
        LeftFrame.physicsBody?.categoryBitMask = PhysicsCategory.LeftFrame
        LeftFrame.physicsBody?.collisionBitMask = PhysicsCategory.Pony
        LeftFrame.physicsBody?.contactTestBitMask = PhysicsCategory.Pony
        LeftFrame.physicsBody?.affectedByGravity = false
        LeftFrame.physicsBody?.isDynamic = false
        LeftFrame.zPosition = 2
        LeftFrame.name = StaticValue.leftFrame
        self.addChild(LeftFrame)
        
        Ground = SKSpriteNode(imageNamed: StaticValue.groundImageField)
        Ground.setScale(0.5)
        Ground.position = CGPoint(x: self.frame.width / 2, y: self.frame.height - self.frame.height)
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
        Pony.position = CGPoint(x: self.frame.width / 2 , y: self.frame.height / 2)
        Pony.physicsBody = SKPhysicsBody(circleOfRadius: Pony.size.height / 2)
        Pony.physicsBody?.categoryBitMask = PhysicsCategory.Pony
        Pony.physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.Ceiling | PhysicsCategory.LeftFrame | PhysicsCategory.RightFrame
        Pony.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.Score | PhysicsCategory.Ceiling | PhysicsCategory.LeftFrame | PhysicsCategory.RightFrame
        Pony.physicsBody?.affectedByGravity = false
        Pony.physicsBody?.isDynamic = true
        Pony.zPosition = 2
        self.addChild(Pony)
    }

    func saveHighScore(highScore:Int) {
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
