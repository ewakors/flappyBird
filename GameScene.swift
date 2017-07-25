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
    static let pony: UInt32 = 0x1 << 1
    static let bottomFrame: UInt32 = 0x1 << 2
    static let barrier: UInt32 = 0x1 << 3
    static let score: UInt32 = 0x1 << 4
    static let transparentWall: UInt32 = 0x1 << 5
    static let background: UInt32 = 0x1 << 6
    static let topFrame: UInt32 = 0x1 << 7
    static let leftFrame: UInt32 = 0x1 << 8
    static let rightFrame: UInt32 = 0x1 << 9
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    let borderWallWidth = CGFloat(1.0)
    let grassHeight = CGFloat(40.0)
    
    static var score = Int()
    static var highScore = Int()
    static var gameLevel = Int()
    static var musicGame = SKAudioNode()
    static let scoreLabel = SKLabelNode()
    static let highScoreLabel = SKLabelNode()
    
    var bottomFrame = SKSpriteNode()
    var topFrame = SKSpriteNode()
    var leftFrame = SKSpriteNode()
    var rightFrame = SKSpriteNode()
    var pony = SKSpriteNode()
    var background = SKSpriteNode()
    var startButton = SKSpriteNode()
    var stopMusicButton = SKSpriteNode()
    var startMusicButton = SKSpriteNode()
    var wall = SKNode()
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    var died = Bool()
    var mute: Bool = false
    var duration: CFTimeInterval = CFTimeInterval(UserDefaults.standard.float(forKey: StaticValue.durationField))
    var distanceBetweenWalls: CGFloat = CGFloat(UserDefaults.standard.float(forKey: StaticValue.distanceBetweenWallsField))
    var widthWall: CGFloat = CGFloat(UserDefaults.standard.float(forKey: StaticValue.widthWallField))
    var heightWall: CGFloat = CGFloat(UserDefaults.standard.float(forKey: StaticValue.heightWallField))
    var heightPonyJump: CGFloat = CGFloat(UserDefaults.standard.float(forKey: StaticValue.heightPonyJumpField))
    //var heightPonyJump = CGFloat()
    var movePipes = SKAction()
    var gameTimer = Timer()
    var scoreNode = SKSpriteNode()
    var bottomBarrier  = SKSpriteNode()

    override func didMove(to view: SKView) {
       super.didMove(to: view)
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

                   // GameScene.musicGame.run((SKAction.stop()))
                   // playGameMusic(filename: StaticValue.backgroundMusicField, autoPlayLooped: true)
                    
                    pony.physicsBody?.affectedByGravity = true

                    createPony()
                    distanceBetweenWalls(duration: duration, distanceLength: distanceBetweenWalls)

                    for touch in touches {
                        let location = touch.location(in: self)
                        if stopMusicButton.contains(location) {
                            muteMusic()
                        }
                    }
                } else {
                    if died == true {
                       
                    } else {
                        //ponyJumpFeatures(heightPonyJump: 150.0)
                    
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
        super.update(currentTime)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB

        if (firstBody.categoryBitMask == PhysicsCategory.score && secondBody.categoryBitMask == PhysicsCategory.pony) || (firstBody.categoryBitMask == PhysicsCategory.pony && secondBody.categoryBitMask == PhysicsCategory.score) || (firstBody.categoryBitMask == PhysicsCategory.transparentWall && secondBody.categoryBitMask == PhysicsCategory.pony) || (firstBody.categoryBitMask == PhysicsCategory.pony && secondBody.categoryBitMask == PhysicsCategory.transparentWall) {
            
            GameScene.score += 1
            GameScene.scoreLabel.text = "\(GameScene.score)"
            playGameMusic(filename: StaticValue.scoreMusicField, autoPlayLooped: false)
            firstBody.node?.removeFromParent()
            
        } else if (firstBody.categoryBitMask == PhysicsCategory.pony && secondBody.categoryBitMask == PhysicsCategory.leftFrame || firstBody.categoryBitMask == PhysicsCategory.leftFrame && secondBody.categoryBitMask == PhysicsCategory.pony) || (firstBody.categoryBitMask == PhysicsCategory.pony) {
            
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
           
                self.createBarriers()
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

    func ponyJumpFeatures() {
        pony.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        pony.physicsBody?.applyImpulse(CGVector(dx: 0, dy: self.heightPonyJump))
    }
    
    func startGame(duration: CFTimeInterval, distanceBetweenWalls: CGFloat, widthWall: CGFloat, heightWall: CGFloat, heightPonyJump: CGFloat ) {
        
        self.duration = duration
        self.distanceBetweenWalls = distanceBetweenWalls
        self.widthWall = widthWall
        self.heightWall = heightWall
        self.heightPonyJump = heightPonyJump
        
        UserDefaults.standard.set(heightPonyJump, forKey: StaticValue.heightPonyJumpField)
        UserDefaults.standard.set(duration, forKey: StaticValue.durationField)
        UserDefaults.standard.set(distanceBetweenWalls, forKey: StaticValue.distanceBetweenWallsField)
        UserDefaults.standard.set(widthWall, forKey: StaticValue.widthWallField)
        UserDefaults.standard.set(heightWall, forKey: StaticValue.heightWallField)
    }
 
    func createBarriers() {
        
        self.ponyJumpFeatures()
        
        wall = SKNode()
        wall.zPosition = 2

        scoreNode = SKSpriteNode(imageNamed: StaticValue.coinImageField)
        createCoin(scoreNode: self.scoreNode)
        wall.addChild(self.scoreNode)

        bottomBarrier = SKSpriteNode(imageNamed: StaticValue.wallImageField)
        createBottomBarrier(bottomBarrier: self.bottomBarrier, bottomWidth: self.widthWall, bottomHeight: self.heightWall)
        wall.addChild(bottomBarrier)
        
        let transparentWall = SKSpriteNode(imageNamed: StaticValue.transparentWallImageField)
        createTransparentWall(transparentWall: transparentWall)
        wall.addChild(transparentWall)

        if GameScene.score < 3 {
            bottomBarrier.size.width = widthWall
            wall.position.y = wall.position.y
            scoreNode.position.y = scoreNode.position.y
        } else if GameScene.score >= 3 && GameScene.score < 6 {
            let height = CGFloat.staticWallHeight(wallHeight: 60)
            let width = CGFloat.staticWallWidth(wallWidth: widthWall + 10)
            widthWall =  width
            bottomBarrier.size.width = widthWall + 40
            wall.position.y = wall.position.y + height
            scoreNode.position.y = scoreNode.position.y + height
        } else if GameScene.score >= 6 && GameScene.score < 10 {
            let height = CGFloat.staticWallHeight(wallHeight: 80)
            let width = CGFloat.staticWallWidth(wallWidth: widthWall + 20)
            widthWall =  width
            wall.position.y = wall.position.y + height
            scoreNode.position.y = scoreNode.position.y + height / 2
        } else if GameScene.score >= 10 {
            let height = CGFloat.random(min: 0,max: 400)
            let width = CGFloat.staticWallWidth(wallWidth: widthWall + 30)
            bottomBarrier.size.width = width
            wall.position.y = wall.position.y + height
            scoreNode.position.y = scoreNode.position.y + height / 2
        }

        wall.run(moveAndRemove)
        
        addChild(wall)
    } 
    
    func levelGame() {
        if GameScene.gameLevel == 0 && (GameScene.score == 3 || GameScene.score == 4) {
            levelGameScene()
            GameScene.gameLevel += 1
        } else if GameScene.gameLevel == 1 && (GameScene.score == 6 || GameScene.score == 7) {
            GameScene.gameLevel += 1
            levelGameScene()
        } else if GameScene.gameLevel == 2 && (GameScene.score == 10 || GameScene.score == 11) {
            GameScene.gameLevel += 1
            levelGameScene()
        }
    }
    
    func createBottomBarrier(bottomBarrier: SKSpriteNode, bottomWidth: CGFloat, bottomHeight: CGFloat) {
        bottomBarrier.setScale(0.5)
        bottomBarrier.size.width = bottomWidth
        bottomBarrier.physicsBody = SKPhysicsBody(rectangleOf: bottomBarrier.size)
        bottomBarrier.physicsBody?.categoryBitMask = PhysicsCategory.barrier
        bottomBarrier.physicsBody?.isDynamic = false
        bottomBarrier.position = CGPoint(x: self.frame.width + 25, y: self.frame.height - self.frame.height * 1.35 + bottomHeight + grassHeight)
        bottomBarrier.zPosition = 1
    }
    
    func createTransparentWall(transparentWall: SKSpriteNode) {
        transparentWall.size = CGSize(width: 3, height: self.frame.height)
        transparentWall.position = CGPoint(x: self.frame.width + 25, y: (self.view?.bounds.size.height)! / 2)
        transparentWall.physicsBody = SKPhysicsBody(rectangleOf: transparentWall.size)
        transparentWall.physicsBody?.affectedByGravity = false
        transparentWall.physicsBody?.isDynamic = false
        transparentWall.physicsBody?.categoryBitMask = PhysicsCategory.transparentWall
    }
    
    func createCoin(scoreNode: SKSpriteNode) {
        scoreNode.size = CGSize(width: 50, height: 50)
        scoreNode.position = CGPoint(x: self.frame.width + 25 , y: self.frame.height / 4)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.score
    }
    
    func createStartButton() {
        startButton = SKSpriteNode(imageNamed: StaticValue.startBtnImageField)
        startButton.size = CGSize(width: frame.midX / 2, height: frame.midY / 4 )
        startButton.position = CGPoint(x: frame.midX, y: frame.midY)
        startButton.zPosition = 9
        addChild(startButton)
        startButton.run(SKAction.scale(to: 1.0, duration: 0.3))
        //playGameMusic(filename: StaticValue.startGameMusicField, autoPlayLooped: false)
    }
    
    func createStopMusicButton() {
        startMusicButton.removeFromParent()
        stopMusicButton = SKSpriteNode(imageNamed: StaticValue.muteImageField)
        stopMusicButton.size = CGSize(width: 25, height: 25)
        stopMusicButton.position = CGPoint(x: self.frame.width / 1.07, y: self.frame.height / 1.04)
        stopMusicButton.zPosition = 9
        addChild(stopMusicButton)
        stopMusicButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func createStartMusicButton() {
        stopMusicButton.removeFromParent()
        startMusicButton = SKSpriteNode(imageNamed: StaticValue.soundImageField)
        startMusicButton.size = CGSize(width: 25, height: 25)
        startMusicButton.position = CGPoint(x: self.frame.width / 1.07 , y: self.frame.height / 1.04)
        startMusicButton.zPosition = 9
        addChild(startMusicButton)
        startMusicButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }

    func restartScene() {
        GameScene.musicGame.run((SKAction.stop()))
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        saveHighScore(highScore: GameScene.score)
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let scene = GameOverScene(size: self.size)
        self.view?.presentScene(scene, transition: reveal)
        GameScene.score = 0
    }
    
    func levelGameScene() {
        GameScene.musicGame.run((SKAction.stop()))
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let scene = LevelGameScene(size: self.size)
        self.view?.presentScene(scene, transition: reveal)
        self.removeAllChildren()
        self.removeAllActions()
    }
    
    func createScene() {

        self.physicsWorld.contactDelegate = self
        
        background = SKSpriteNode(imageNamed: StaticValue.backgroundImageField)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = frame.size
        addChild(background)

        if mute == false {
            createStopMusicButton()
        }
        else {
            createStartMusicButton()
        }

        createScoreLabel()
        createFrameScene()
    }
    
    func createScoreLabel() {
        GameScene.highScoreLabel.position = CGPoint(x: frame.midX, y: frame.midY * 1.75)
        GameScene.highScoreLabel.fontName = StaticValue.fontNameField
        GameScene.highScoreLabel.fontSize = 40
        GameScene.highScoreLabel.zPosition = 2
        GameScene.highScoreLabel.fontColor = SKColor.black
        addChild(GameScene.highScoreLabel)
        
        GameScene.scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY * 1.5)
        GameScene.scoreLabel.text = "\(GameScene.score)"
        GameScene.scoreLabel.fontName = StaticValue.fontNameField
        GameScene.scoreLabel.fontSize = 40
        GameScene.scoreLabel.zPosition = 2
        GameScene.scoreLabel.fontColor = SKColor.black
        addChild(GameScene.scoreLabel)
    }
    
    func createFrameScene() {
        topFrame = SKSpriteNode(imageNamed: StaticValue.ceilingImageField)
        topFrame.size = CGSize(width: frame.width * 2, height: borderWallWidth)
        topFrame.position = CGPoint(x: 0, y: frame.maxY)
        topFrame.physicsBody = SKPhysicsBody(rectangleOf: topFrame.size)
        topFrame.physicsBody?.categoryBitMask = PhysicsCategory.topFrame
        topFrame.physicsBody?.isDynamic = false
        topFrame.zPosition = 1
        addChild(topFrame)
        
        rightFrame = SKSpriteNode(imageNamed: StaticValue.transparentWallImageField)
        rightFrame.size = CGSize(width: borderWallWidth, height: frame.height * 2)
        rightFrame.position = CGPoint(x: frame.maxX,y: 0)
        rightFrame.physicsBody = SKPhysicsBody(rectangleOf: rightFrame.size)
        rightFrame.physicsBody?.categoryBitMask = PhysicsCategory.rightFrame
        rightFrame.physicsBody?.isDynamic = false
        rightFrame.zPosition = 1
        addChild(rightFrame)
        
        leftFrame = SKSpriteNode(imageNamed: StaticValue.transparentWallImageField)
        leftFrame.size = CGSize(width: borderWallWidth, height: frame.height * 2)
        leftFrame.position = CGPoint(x: frame.minX ,y: 0)
        leftFrame.physicsBody = SKPhysicsBody(rectangleOf: leftFrame.size)
        leftFrame.physicsBody?.categoryBitMask = PhysicsCategory.leftFrame
        leftFrame.physicsBody?.isDynamic = false
        leftFrame.zPosition = 1
        addChild(leftFrame)
        
        bottomFrame = SKSpriteNode(imageNamed: StaticValue.groundImageField)
        bottomFrame.size = CGSize(width: frame.width * 2, height: grassHeight)
        bottomFrame.position = CGPoint(x: frame.width , y: frame.minY)
        bottomFrame.physicsBody = SKPhysicsBody(rectangleOf: bottomFrame.size)
        bottomFrame.physicsBody?.categoryBitMask = PhysicsCategory.bottomFrame
        bottomFrame.physicsBody?.isDynamic = false
        bottomFrame.zPosition = 3
        addChild(bottomFrame)
    }
    
    func createPony() {
        let ponyScale = CGFloat(0.75)
        pony = SKSpriteNode(imageNamed: StaticValue.ponyImageField )
        pony.size = CGSize(width: 100, height: 100)
        pony.xScale = ponyScale
        pony.yScale = ponyScale
        pony.position = CGPoint(x: frame.midX , y: frame.midY)
        pony.physicsBody = SKPhysicsBody(circleOfRadius: pony.size.height / 2)
        pony.physicsBody?.categoryBitMask = PhysicsCategory.pony
        pony.physicsBody?.collisionBitMask = PhysicsCategory.bottomFrame | PhysicsCategory.barrier | PhysicsCategory.topFrame | PhysicsCategory.leftFrame | PhysicsCategory.rightFrame
        pony.physicsBody?.contactTestBitMask = PhysicsCategory.bottomFrame | PhysicsCategory.barrier | PhysicsCategory.score | PhysicsCategory.topFrame | PhysicsCategory.leftFrame | PhysicsCategory.rightFrame | PhysicsCategory.transparentWall
        pony.physicsBody?.affectedByGravity = false
        pony.physicsBody?.isDynamic = true
        pony.zPosition = 2
        addChild(pony)
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
