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
    static let none = 0
    static let all = UInt32.max
    
    static let player: UInt32           = (1)
    static let topWall: UInt32          = (1<<1)
    static let bottomWall: UInt32       = (1<<2)
    static let leftWall: UInt32         = (1<<3)
    static let rightWall: UInt32        = (1<<4)
    static let block: UInt32            = (1<<5)
    static let score: UInt32            = (1<<6)
    static let transparentWall: UInt32  = (1<<7)
    static let blockTop: UInt32       = (1<<8)
}

enum GameScenery {
    case pony
    case astronaut
    
    func backgroundImageName() -> String {
        switch self {
        case .pony:
            return "Background2"
        case .astronaut:
            return "Background_astronaut"
        }
    }
    
    func playerImageName() -> String {
        switch self {
        case .pony:
            return "Kucyk"
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
            return "Wall"
        case .astronaut:
            return "Block_astronaut"
        }
    }
}

struct ScenerySettings {
    var type: GameScenery!
    var screenPercentProportionForMaxBlockHeight: Int!
    
    init(type: GameScenery, screenPercentProportionForMaxBlockHeight: Int) {
        self.type = type
        self.screenPercentProportionForMaxBlockHeight = screenPercentProportionForMaxBlockHeight
    }
}

struct PlayerSettings {
    var jumpHeightPercent: Int!
    
    init(jumpHeightPercent: Int) {
        self.jumpHeightPercent = jumpHeightPercent
    }
}

struct BlockRandom {
    var minPercent: Int!
    var maxPercent: Int!
    
    init(minPercent: Int, maxPercent: Int) {
        self.minPercent = minPercent
        self.maxPercent = maxPercent
    }
}

struct BlocksSettings {
    
    var timeBetweenBlocks: Double!
    var heightPercent: Int!
    
    var randomHeight: BlockRandom?
    
    var isRandomHeightEnabled: Bool {
        return (randomHeight != nil)
    }
    
    var widthTime: Double!
    
    init(timeBetweenBlocks: Double, heightPercent: Int, widthTime: Double, randomHeight: BlockRandom?) {
        self.timeBetweenBlocks = timeBetweenBlocks
        self.heightPercent = heightPercent
        self.randomHeight = randomHeight
        self.widthTime = widthTime
    }
}

class GameScene: SKScene {

    static var highScore = Int()
    static var gameLevel = Int()
    static var musicGame = SKAudioNode()
    static let createBlocksAction = "createBlocksAction"
    static let moveRemoveBlocksAction = "moveRemoveBlocksAction"
    static let id = "GameScene"
    
    let borderWallWidth = CGFloat(1.0)
    let grassHeight = CGFloat(10.0)
    
    var score = Int()
    let scoreLabel = SKLabelNode()
    let highScoreLabel = SKLabelNode()
    
    var topWall = SKSpriteNode()
    var bottomWall = SKSpriteNode()
    var leftWall = SKSpriteNode()
    var rightWall = SKSpriteNode()
    var blocks = SKNode()
    var scoreBlockTop = SKNode()
    
    var player = SKSpriteNode()
    var background = SKSpriteNode()
    
    var startButton = SKSpriteNode()
    var stopMusicButton = SKSpriteNode()
    var startMusicButton = SKSpriteNode()
    
    
    var mute: Bool = false
    
    var gameOver = SKSpriteNode()
    var restartButton = SKSpriteNode()
    
    var moveRemove = SKAction()
    var isStarted = false
    var needRestart = false
    
    var scenerySettings = ScenerySettings(type: .pony, screenPercentProportionForMaxBlockHeight: 80)
    var playerSettings = PlayerSettings(jumpHeightPercent: 25)
    var blocksSettings = BlocksSettings(timeBetweenBlocks: 3.0, heightPercent: 30, widthTime: 0.2, randomHeight: nil)
    
    var playerCollisionMask: UInt32 {
        return (PhysicsCategory.bottomWall | PhysicsCategory.block | PhysicsCategory.blockTop | PhysicsCategory.topWall | PhysicsCategory.leftWall | PhysicsCategory.rightWall)
    }
    
    var playerContactTestBitMask: UInt32 {
        return (PhysicsCategory.score | PhysicsCategory.transparentWall | PhysicsCategory.bottomWall | PhysicsCategory.block | PhysicsCategory.blockTop | PhysicsCategory.topWall | PhysicsCategory.leftWall | PhysicsCategory.rightWall)
    }
    
    override func didMove(to view: SKView) {
       super.didMove(to: view)

        physicsWorld.contactDelegate = self
        
        createScene()
        saveHighScore(highScore: score)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if needRestart {
            for touch in touches {
                let location = touch.location(in: self)
                
                if restartButton.contains(location) {
                    restartScene()
                    print("restart button")
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
                    playerJump(percent: playerSettings.jumpHeightPercent)
                }
            }
        }
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
    }
    
    func startGame() {
        
        isStarted = true
        
        let createBlocksAction = SKAction.run {
            self.createBlocks()
        }
        
        let actionsForever = SKAction.repeatForever(SKAction.sequence([createBlocksAction, SKAction.wait(forDuration: TimeInterval(blocksSettings.timeBetweenBlocks))]))
        run(actionsForever, withKey: GameScene.createBlocksAction)
        
        let distance = CGFloat(self.frame.width+blocks.frame.width)
        let interval = 0.008*distance
        
        let move = SKAction.moveBy(x: -distance, y: 0.0, duration: TimeInterval(interval))
        let remove = SKAction.removeFromParent()
        
        moveRemove = SKAction.sequence([move,remove])
        
        player.physicsBody?.affectedByGravity = true
    }
    
    func settingsFor(scenery: ScenerySettings, player: PlayerSettings, blocks: BlocksSettings) {
        self.scenerySettings = scenery
        self.playerSettings = player
        self.blocksSettings = blocks
    }
    
    func playerJump(percent: Int) {
        let yValue = gamePercentToPixel(percent: percent)
        player.physicsBody?.velocity = CGVector(dx: 0, dy: yValue)
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: yValue))
    }
    
    func toPixelHeight(percent: Int) -> CGFloat {
        return (frame.height * CGFloat(percent))/100.0
    }
    
    func gamePercentToPixel(percent: Int) -> CGFloat {
        let max = toPixelHeight(percent: scenerySettings.screenPercentProportionForMaxBlockHeight)
        return (max * CGFloat(percent))/100.0
    }
    
    func createBlocks() {
        blocks = SKNode()

        let block = SKSpriteNode(imageNamed: StaticValue.wallImageField)
        block.size = CGSize(width: 80, height: gamePercentToPixel(percent: 10))
        block.position = CGPoint(x: frame.maxX, y: frame.minY + block.size.height/2)

        block.physicsBody = SKPhysicsBody(rectangleOf: block.size)
        block.physicsBody?.categoryBitMask = PhysicsCategory.block
        
        block.physicsBody?.collisionBitMask = PhysicsCategory.player
        block.physicsBody?.contactTestBitMask = PhysicsCategory.player
        
        block.physicsBody?.isDynamic = false
        block.physicsBody?.affectedByGravity = false
        block.zPosition = 1
        
        
        let blockTop = SKSpriteNode(color: UIColor.black, size: CGSize(width: block.size.width * 0.4, height: gamePercentToPixel(percent: 1)))
        blockTop.position = CGPoint(x: frame.maxX,y: block.frame.maxY)
        
        blockTop.physicsBody = SKPhysicsBody(rectangleOf: blockTop.size)
        blockTop.physicsBody?.categoryBitMask = PhysicsCategory.blockTop
        
        blockTop.physicsBody?.collisionBitMask = PhysicsCategory.player
        blockTop.physicsBody?.contactTestBitMask = PhysicsCategory.player
        
        blockTop.physicsBody?.isDynamic = false
        
        blockTop.zPosition = 2
        
        let transparentBlock = SKSpriteNode(imageNamed: StaticValue.transparentWallImageField)
        transparentBlock.size = CGSize(width: block.size.width / 6, height: gamePercentToPixel(percent: 100))
        transparentBlock.position = CGPoint(x: frame.maxX, y: frame.midY)
        
        transparentBlock.physicsBody = SKPhysicsBody(rectangleOf: transparentBlock.size)
        transparentBlock.physicsBody?.categoryBitMask = PhysicsCategory.transparentWall

        transparentBlock.physicsBody?.isDynamic = false
        
        let scoreNode = SKSpriteNode(imageNamed: StaticValue.coinImageField)
        scoreNode.size = CGSize(width: gamePercentToPixel(percent: 10), height: gamePercentToPixel(percent: 10))
        scoreNode.position = CGPoint(x: frame.maxX, y: block.frame.maxY + gamePercentToPixel(percent: 10))
        
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.score

        scoreNode.physicsBody?.isDynamic = false
        scoreNode.zPosition = 2
        
        blocks.addChild(block)
        blocks.addChild(blockTop)
        blocks.addChild(transparentBlock)
        blocks.addChild(scoreNode)
        blocks.run(moveRemove, withKey: GameScene.moveRemoveBlocksAction)
        
        addChild(blocks)
        
        if score >= 3 && score < 7 {
            block.size.height = gamePercentToPixel(percent: 30)
            scoreBlockTopPosition(scoreNode: scoreNode, blockTop: blockTop, block: block)
        } else if score >= 7 && score < 13 {
            block.size = CGSize(width: 80, height: gamePercentToPixel(percent: 60))
            scoreBlockTopPosition(scoreNode: scoreNode, blockTop: blockTop, block: block)
         } else if score >= 13 {
            block.size = CGSize(width: 80, height: CGFloat.random(min: 0, max: gamePercentToPixel(percent: 100)))
            scoreBlockTopPosition(scoreNode: scoreNode, blockTop: blockTop, block: block)
         }
    }
    
    func scoreBlockTopPosition(scoreNode: SKSpriteNode, blockTop: SKSpriteNode, block: SKSpriteNode) {
        scoreNode.position.y = block.frame.maxY + frame.height * 0.1
        blockTop.position = CGPoint(x: frame.maxX,y: block.frame.maxY)
    }
    
    func levelGame() {
       /* if GameScene.gameLevel == 0 && (GameScene.score == 3 || GameScene.score == 4) {
            levelGameScene()
            GameScene.gameLevel += 1
        } else if GameScene.gameLevel == 1 && (GameScene.score == 6 || GameScene.score == 7) {
            GameScene.gameLevel += 1
            levelGameScene()
        } else if GameScene.gameLevel == 2 && (GameScene.score == 10 || GameScene.score == 11) {
            GameScene.gameLevel += 1
            levelGameScene()
        }*/
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
        saveHighScore(highScore: score)
        removeAllChildren()
        removeAllActions()
        isStarted = false
        needRestart = false
        score = 0
        createScene()
    }
    
    func levelGameScene() {
        GameScene.musicGame.run((SKAction.stop()))
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let scene = LevelGameScene(size: self.size)
        self.view?.presentScene(scene, transition: reveal)
        removeAllChildren()
        removeAllActions()
    }
    
    func createScene() {

        gameOver.removeAllChildren()
        restartButton.removeAllChildren()
        
        background = SKSpriteNode(imageNamed: scenerySettings.type.backgroundImageName())
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = frame.size
        addChild(background)

        player = SKSpriteNode(imageNamed: scenerySettings.type.playerImageName())
        player.size = CGSize(width: frame.midX / 3, height: frame.midY / 3 )
        player.position = CGPoint(x: frame.midX , y: frame.midY)

        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height / 2)
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.collisionBitMask = playerCollisionMask
        player.physicsBody?.contactTestBitMask = playerContactTestBitMask
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        player.physicsBody?.allowsRotation = false
        player.zPosition = 3
        addChild(player)
        
        let wall = SKNode()
        
        topWall = SKSpriteNode(imageNamed: StaticValue.ceilingImageField)
        topWall.size = CGSize(width: frame.width * 2, height: borderWallWidth)
        topWall.position = CGPoint(x: frame.midX, y: frame.maxY)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.topWall
        topWall.physicsBody?.isDynamic = false
        wall.addChild(topWall)
        
        rightWall.size = CGSize(width: borderWallWidth, height: frame.height * 2)
        rightWall.position = CGPoint(x: frame.maxX,y: frame.midY)
        
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.size)
        rightWall.physicsBody?.categoryBitMask = PhysicsCategory.rightWall
        rightWall.physicsBody?.isDynamic = false
        wall.addChild(rightWall)
        
        leftWall.size = CGSize(width: borderWallWidth, height: frame.height * 2)
        leftWall.position = CGPoint(x: frame.minX ,y: frame.midY)
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.size)
        leftWall.physicsBody?.categoryBitMask = PhysicsCategory.leftWall
        leftWall.physicsBody?.isDynamic = false
        wall.addChild(leftWall)
        
        if scenerySettings.type.bottomImageName() != "" {
            bottomWall = SKSpriteNode(imageNamed: scenerySettings.type.bottomImageName())
        } else {
            bottomWall = SKSpriteNode()
        }
        bottomWall.size = CGSize(width: frame.width * 2, height: grassHeight)
        bottomWall.position = CGPoint(x: frame.midX , y: frame.minY)
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
        bottomWall.physicsBody?.categoryBitMask = PhysicsCategory.bottomWall
        bottomWall.physicsBody?.isDynamic = false
        bottomWall.zPosition = 4
        wall.addChild(bottomWall)
        
        addChild(wall)
        
        if mute == false {
            createStopMusicButton()
        }
        else {
            createStartMusicButton()
        }

        startButton = SKSpriteNode(imageNamed: StaticValue.startBtnImageField)
        startButton.size = CGSize(width: frame.midX / 2, height: frame.midY / 6 )
        startButton.position = CGPoint(x: frame.midX, y: frame.midY)
        startButton.zPosition = 4
        addChild(startButton)
        startButton.run(SKAction.scale(to: 1.0, duration: 0.3))
        //playGameMusic(filename: StaticValue.startGameMusicField, autoPlayLooped: false)

        createScoreLabel()
    }
    
    func createScoreLabel() {
        highScoreLabel.position = CGPoint(x: frame.midX, y: frame.midY * 1.75)
        highScoreLabel.fontName = StaticValue.fontNameField
        highScoreLabel.fontSize = CGFloat(StaticValue.scoreLabelFontSize)
        highScoreLabel.zPosition = 3
        highScoreLabel.fontColor = SKColor.black
        addChild(highScoreLabel)
        
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY * 1.5)
        scoreLabel.text = "\(score)"
        scoreLabel.fontName = StaticValue.fontNameField
        scoreLabel.fontSize = CGFloat(StaticValue.scoreLabelFontSize)
        scoreLabel.zPosition = 3
        scoreLabel.fontColor = SKColor.black
        addChild(scoreLabel)
    }
    
    func summaryGame() {
        removeAllActions()
        removeAllChildren()
        
        isStarted = false
        needRestart = true
        
        let gameOverLabel = SKLabelNode()
        gameOverLabel.fontName = StaticValue.fontNameField
        gameOverLabel.text = StaticValue.gameOverMessageField
        gameOverLabel.fontColor = SKColor.black
        gameOverLabel.fontSize = CGFloat(StaticValue.levelLabelFontSize)
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY * 1.5)
        gameOverLabel.zPosition = 4
        addChild(gameOverLabel)
        
        createScoreLabel()
        
        gameOver = SKSpriteNode(imageNamed: scenerySettings.type.backgroundImageName())
        gameOver.size = self.frame.size
        gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOver.zPosition = 1
        
        restartButton = SKSpriteNode(imageNamed: StaticValue.restartBtnImageField)
        restartButton.size = CGSize(width: frame.midX / 2 ,height: frame.midY / 6)
        restartButton.position = CGPoint(x: frame.midX ,y: frame.midY)
        restartButton.zPosition = 4

        addChild(gameOver)
        addChild(restartButton)
    }

    func saveHighScore(highScore:Int) {
        if let currentHighScore:Int = UserDefaults.standard.value(forKey: StaticValue.highScoreField) as? Int{
            highScoreLabel.text = "\(StaticValue.highScoreTextField)\(currentHighScore)"
            GameScene.highScore = currentHighScore
            if(highScore > currentHighScore){
                UserDefaults.standard.set(highScore, forKey: StaticValue.highScoreField)
                UserDefaults.standard.synchronize()
            }
        } else{
            highScoreLabel.text = "\(StaticValue.highScoreTextField)\(highScore)"
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
            score += 1
            scoreLabel.text = "\(score)"
            contact.bodyA.node?.removeFromParent()
            //playGameMusic(filename: StaticValue.scoreMusicField, autoPlayLooped: false)
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
    }
}

extension GameScene {
    func isPlayer(body: SKPhysicsBody) -> Bool {
        return (body.categoryBitMask == PhysicsCategory.player)
    }
    
    func isLeftWall(body: SKPhysicsBody) -> Bool {
        return (body.categoryBitMask == PhysicsCategory.leftWall)
    }
    
    func isRightWall(body: SKPhysicsBody) -> Bool {
        return (body.categoryBitMask == PhysicsCategory.rightWall)
    }
    
    func isBottomWall(body: SKPhysicsBody) -> Bool {
        return (body.categoryBitMask == PhysicsCategory.bottomWall)
    }
    
    func isTopWall(body: SKPhysicsBody) -> Bool {
        return (body.categoryBitMask == PhysicsCategory.topWall)
    }
    
    func isBlock(body: SKPhysicsBody) -> Bool {
        return (body.categoryBitMask == PhysicsCategory.blockTop)
    }
    
    func isScore(body: SKPhysicsBody) -> Bool {
        return (body.categoryBitMask == PhysicsCategory.score)
    }
    
    func isTransparentWall(body: SKPhysicsBody) -> Bool {
        return (body.categoryBitMask == PhysicsCategory.transparentWall)
    }
    
    func isGameOver(contact: SKPhysicsContact) -> Bool {
        return ((isPlayer(body: contact.bodyA) || isPlayer(body: contact.bodyB)) && (isLeftWall(body: contact.bodyA) || isLeftWall(body: contact.bodyB)) || (isBlock(body: contact.bodyA) || isBlock(body: contact.bodyB)))
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
