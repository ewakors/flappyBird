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

enum GameScenery {
    case pony
    case astronaut
    
    func backgroundImageName() -> String {
        switch self {
        case .pony:
            return "Background_pony"
        case .astronaut:
            return "Background_astronaut"
        }
    }
    
    func playerImageName() -> String {
        switch self {
        case .pony:
            return StaticValue.ponyImageField
        case .astronaut:
            return "Player_astronaut"
        }
    }
    
    func bottomImageName() -> String {
        switch self {
        case .pony:
            return "Floor_pony"
        case .astronaut:
            return ""
        }
    }
    
    func blockImageName() -> String {
        switch self {
        case .pony:
            return "Block_pony"
        case .astronaut:
            return "Block_astronaut"
        }
    }
}

class GameScene: SKScene {

    let borderWallWidth = CGFloat(1.0)
    let grassHeight = CGFloat(40.0)
    
    static var score = Int()
    static var highScore = Int()
    static var gameLevel = Int()
    static var musicGame = SKAudioNode()
    static let scoreLabel = SKLabelNode()
    static let highScoreLabel = SKLabelNode()
    static let createBlocksAction = "createBlocksAction"
    
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
    
    var gameOver = SKSpriteNode()
    var restartButton = SKSpriteNode()
    
    var isStarted = false
    var needRestart = false
    
    var scenery: GameScenery = .pony
    
    var playerCollisionMask: UInt32 {
        return (PhysicsCategory.bottomFrame | PhysicsCategory.barrier | PhysicsCategory.topFrame | PhysicsCategory.leftFrame | PhysicsCategory.rightFrame)
    }
    
    var playerContactTestBitMask: UInt32 {
        return (PhysicsCategory.score | PhysicsCategory.transparentWall | PhysicsCategory.bottomFrame | PhysicsCategory.barrier | PhysicsCategory.topFrame | PhysicsCategory.leftFrame | PhysicsCategory.rightFrame)
    }
    
    override func didMove(to view: SKView) {
       super.didMove(to: view)
       
        physicsWorld.contactDelegate = self
        
        createScene()
        saveHighScore(highScore: GameScene.score)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if needRestart {
            for touch: AnyObject in touches {
                let location = touch.location(in: self)
                
                if restartButton.contains(location) {
                    restartScene()
                    print("restart")
                } else {
                    print("restart restart restart")
                    restartScene()
                }
            }
        }  else {
            for touch: AnyObject in touches {
                let location = touch.location(in: self)
                if startButton.contains(location) {
                    if isStarted == false {
                        startButton.removeFromParent()
                        startGame()
                    }
                } else {
                    ponyJumpFeatures()
                }
            }
        }

    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
    }
    
    func startGame() {
        
        isStarted = true
        
        let action = SKAction.run {
            self.createBarriers()
        }
        
        let timeBetweenBlocks = SKAction.wait(forDuration: TimeInterval(3.0))
        let actions = SKAction.sequence([action, timeBetweenBlocks])
        let actionsForever = SKAction.repeatForever(actions)
        
        run(actionsForever, withKey: GameScene.createBlocksAction)
        
        let distance = CGFloat(self.frame.width+wall.frame.width)
        let move = SKAction.moveBy(x: -distance, y: 0.0, duration: TimeInterval(0.008*distance))
        let remove = SKAction.removeFromParent()
        
        moveAndRemove = SKAction.sequence([move,remove])
        
        pony.physicsBody?.affectedByGravity = true
    }
    
    /*func didBegin(_ contact: SKPhysicsContact) {
        
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
    }*/
    
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
        pony.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
    }
    
    func startGame2(duration: CFTimeInterval, distanceBetweenWalls: CGFloat, widthWall: CGFloat, heightWall: CGFloat, heightPonyJump: CGFloat ) {
        
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
            widthWall = widthWall + CGFloat.staticWallWidth(wallWidth: 10)
            bottomBarrier.size.width = widthWall
            wall.position.y = wall.position.y + CGFloat.staticWallHeight(wallHeight: 20)
            scoreNode.position.y = scoreNode.position.y + CGFloat.staticWallHeight(wallHeight: 40)
        } else if GameScene.score >= 6 && GameScene.score < 10 {
            widthWall = widthWall + CGFloat.staticWallWidth(wallWidth: 20)
            bottomBarrier.size.width = widthWall
            print("\(widthWall)")
            wall.position.y = wall.position.y + CGFloat.staticWallHeight(wallHeight: 40)
            scoreNode.position.y = scoreNode.position.y + heightWall / 3
        } else if GameScene.score >= 10 {
            heightWall = heightWall + CGFloat.random(min: 0,max: 400)
            widthWall = widthWall + CGFloat.staticWallWidth(wallWidth: 30)
            bottomBarrier.size.width = widthWall
            wall.position.y = wall.position.y + heightWall
            scoreNode.position.y = scoreNode.position.y + heightWall / 3
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
        bottomBarrier.position = CGPoint(x: frame.maxX + 25 ,y: frame.midY - frame.midY * 1.65)
        bottomBarrier.zPosition = 2
    }
    
    func createTransparentWall(transparentWall: SKSpriteNode) {
        transparentWall.size = CGSize(width: 3, height: frame.height)
        transparentWall.position = CGPoint(x: frame.maxX + 25 , y: frame.midY)
        transparentWall.physicsBody = SKPhysicsBody(rectangleOf: transparentWall.size)
        transparentWall.physicsBody?.isDynamic = false
        transparentWall.physicsBody?.categoryBitMask = PhysicsCategory.transparentWall
    }
    
    func createCoin(scoreNode: SKSpriteNode) {
        scoreNode.size = CGSize(width: 50, height: 50)
        scoreNode.position = CGPoint(x: frame.maxX + 25,y: frame.midY * 1.4 - frame.midY)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.score
        scoreNode.zPosition = 2 
    }
    
    func createStartButton() {
        startButton = SKSpriteNode(imageNamed: StaticValue.startBtnImageField)
        startButton.size = CGSize(width: frame.midX / 2, height: frame.midY / 6 )
        startButton.position = CGPoint(x: frame.midX, y: frame.midY)
        startButton.zPosition = 4
        addChild(startButton)
        startButton.run(SKAction.scale(to: 1.0, duration: 0.3))
        //playGameMusic(filename: StaticValue.startGameMusicField, autoPlayLooped: false)
    }
    
    func createStopMusicButton() {
        startMusicButton.removeFromParent()
        stopMusicButton = SKSpriteNode(imageNamed: StaticValue.muteImageField)
        stopMusicButton.size = CGSize(width: 25, height: 25)
        stopMusicButton.position = CGPoint(x: self.frame.width / 1.07, y: self.frame.height / 1.04)
        addChild(stopMusicButton)
        stopMusicButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func createStartMusicButton() {
        stopMusicButton.removeFromParent()
        startMusicButton = SKSpriteNode(imageNamed: StaticValue.soundImageField)
        startMusicButton.size = CGSize(width: 25, height: 25)
        startMusicButton.position = CGPoint(x: self.frame.width / 1.07 , y: self.frame.height / 1.04)
        addChild(startMusicButton)
        startMusicButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }

    func restartScene() {
        GameScene.musicGame.run((SKAction.stop()))
        removeAllChildren()
        removeAllActions()
        isStarted = false
        needRestart = false
        
        //saveHighScore(highScore: GameScene.score)
       // let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        //let scene = GameOverScene(size: self.size)
        //self.view?.presentScene(scene, transition: reveal)
        GameScene.score = 0
        createScene()
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

        //self.physicsWorld.contactDelegate = self
        gameOver.removeAllChildren()
        
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

        createStartButton()
        createPony()
        createScoreLabel()
        createFrameScene()
    }
    
    func createScoreLabel() {
        GameScene.highScoreLabel.position = CGPoint(x: frame.midX, y: frame.midY * 1.75)
        GameScene.highScoreLabel.fontName = StaticValue.fontNameField
        GameScene.highScoreLabel.fontSize = CGFloat(StaticValue.scoreLabelFontSize)
        GameScene.highScoreLabel.zPosition = 3
        GameScene.highScoreLabel.fontColor = SKColor.black
        addChild(GameScene.highScoreLabel)
        
        GameScene.scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY * 1.5)
        GameScene.scoreLabel.text = "\(GameScene.score)"
        GameScene.scoreLabel.fontName = StaticValue.fontNameField
        GameScene.scoreLabel.fontSize = CGFloat(StaticValue.scoreLabelFontSize)
        GameScene.scoreLabel.zPosition = 3
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
        addChild(topFrame)
        
        rightFrame = SKSpriteNode(imageNamed: StaticValue.transparentWallImageField)
        rightFrame.size = CGSize(width: borderWallWidth, height: frame.height * 2)
        rightFrame.position = CGPoint(x: frame.maxX,y: 0)
        rightFrame.physicsBody = SKPhysicsBody(rectangleOf: rightFrame.size)
        rightFrame.physicsBody?.categoryBitMask = PhysicsCategory.rightFrame
        rightFrame.physicsBody?.isDynamic = false
        addChild(rightFrame)
        
        leftFrame = SKSpriteNode(imageNamed: StaticValue.transparentWallImageField)
        leftFrame.size = CGSize(width: borderWallWidth, height: frame.height * 2)
        leftFrame.position = CGPoint(x: frame.minX ,y: 0)
        leftFrame.physicsBody = SKPhysicsBody(rectangleOf: leftFrame.size)
        leftFrame.physicsBody?.categoryBitMask = PhysicsCategory.leftFrame
        leftFrame.physicsBody?.isDynamic = false
        addChild(leftFrame)
        
        bottomFrame = SKSpriteNode(imageNamed: StaticValue.groundImageField)
        bottomFrame.size = CGSize(width: frame.width * 2, height: grassHeight)
        bottomFrame.position = CGPoint(x: frame.width , y: frame.minY)
        bottomFrame.physicsBody = SKPhysicsBody(rectangleOf: bottomFrame.size)
        bottomFrame.physicsBody?.categoryBitMask = PhysicsCategory.bottomFrame
        bottomFrame.physicsBody?.isDynamic = false
        bottomFrame.zPosition = 4
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
        pony.physicsBody?.collisionBitMask = playerCollisionMask
        pony.physicsBody?.contactTestBitMask = playerContactTestBitMask
        pony.physicsBody?.affectedByGravity = false
        pony.physicsBody?.isDynamic = true
        pony.zPosition = 2
        addChild(pony)
    }
    
    func set(scenery: GameScenery) {
        self.scenery = scenery
    }
    
    func summaryGame() {
        
        removeAllActions()
        removeAllChildren()
        
        isStarted = false
        needRestart = true
        
        gameOver = SKSpriteNode(imageNamed: StaticValue.backgroundImageField)
        gameOver.size = self.frame.size
        gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOver.zPosition = 1
        
        restartButton = SKSpriteNode(imageNamed: StaticValue.restartBtnImageField)
        restartButton.size = CGSize(width: frame.midX / 2, height: frame.midY / 4 )
        restartButton.position = CGPoint(x: frame.midX, y: frame.midY * 0.75)
        restartButton.zPosition = 3
        
        gameOver.addChild(restartButton)
        
        addChild(gameOver)
    }

    func saveHighScore(highScore:Int) {
        if let currentHighScore:Int = UserDefaults.standard.value(forKey: StaticValue.highScoreField) as? Int{
            GameScene.highScoreLabel.text = "\(StaticValue.highScoreTextField)\(currentHighScore)"
            GameScene.highScore = currentHighScore
            if(highScore > currentHighScore){
                UserDefaults.standard.set(highScore, forKey: StaticValue.highScoreField)
                UserDefaults.standard.synchronize()
            }
        } else{
            GameScene.highScoreLabel.text = "\(StaticValue.highScoreTextField)\(highScore)"
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

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        
        if isGameOver(contact: contact) {
            summaryGame()
        } else if isScoreCoin(contact: contact) {
            GameScene.score += 1
            GameScene.scoreLabel.text = "\(GameScene.score)"
            contact.bodyA.node?.removeFromParent()
            //playGameMusic(filename: StaticValue.scoreMusicField, autoPlayLooped: false)
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
    }
}

extension GameScene {
    func isPlayer(body: SKPhysicsBody) -> Bool {
        return (body.categoryBitMask == PhysicsCategory.pony)
    }
    
    func isLeftWall(body: SKPhysicsBody) -> Bool {
        return (body.categoryBitMask == PhysicsCategory.leftFrame)
    }
    
    func isRightWall(body: SKPhysicsBody) -> Bool {
        return (body.categoryBitMask == PhysicsCategory.rightFrame)
    }
    
    func isBottomWall(body: SKPhysicsBody) -> Bool {
        return (body.categoryBitMask == PhysicsCategory.bottomFrame)
    }
    
    func isTopWall(body: SKPhysicsBody) -> Bool {
        return (body.categoryBitMask == PhysicsCategory.topFrame)
    }
    
    func isScore(body: SKPhysicsBody) -> Bool {
        return (body.categoryBitMask == PhysicsCategory.score)
    }
    
    func isTransparentWall(body: SKPhysicsBody) -> Bool {
        return (body.categoryBitMask == PhysicsCategory.transparentWall)
    }
    
    func isGameOver(contact: SKPhysicsContact) -> Bool {
        return ((isPlayer(body: contact.bodyA) || isPlayer(body: contact.bodyB)) && (isLeftWall(body: contact.bodyA) || isLeftWall(body: contact.bodyB)))
    }
    
    func isScoreCoin(contact: SKPhysicsContact) -> Bool {
        return ((isPlayer(body: contact.bodyA) || isPlayer(body: contact.bodyB)) && (isScore(body: contact.bodyA) || isScore(body: contact.bodyB)) || (isTransparentWall(body: contact.bodyA) || isTransparentWall(body: contact.bodyB)))
    }
}

extension SKNode {
    func setCenter() {
        self.position = CGPoint(x: frame.midX, y: frame.midY)
    }
}
