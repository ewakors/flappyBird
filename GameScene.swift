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
    static let moveRemoveBlocksAction = "moveRemoveBlocksAction"
    static let MAX_SCREEN_PERCENT_FOR_MAX_HEIGHT = 80
    
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
    
    
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    var died = Bool()
    var mute: Bool = false
    var duration = CFTimeInterval()
    //var duration: CFTimeInterval = CFTimeInterval(UserDefaults.standard.float(forKey: StaticValue.durationField))
    //var distanceBetweenWalls: CGFloat = CGFloat(UserDefaults.standard.float(forKey: StaticValue.distanceBetweenWallsField))
    var distanceBetweenWalls = CGFloat()
    //var widthWall: CGFloat = CGFloat(UserDefaults.standard.float(forKey: StaticValue.widthWallField))
    var widthWall = CGFloat()
    var heightWall: CGFloat = CGFloat(UserDefaults.standard.float(forKey: StaticValue.heightWallField))
    var heightPonyJump = CGFloat()
    //var heightPonyJump: CGFloat = CGFloat(UserDefaults.standard.float(forKey: StaticValue.heightPonyJumpField))
    //var heightPonyJump = CGFloat()
    var movePipes = SKAction()
    var gameTimer = Timer()
    var bottomBarrier  = SKSpriteNode()
    
    
    var gameOver = SKSpriteNode()
    var restartButton = SKSpriteNode()
    
    var moveRemove = SKAction()
    var isStarted = false
    var needRestart = false
    
    var scenery: GameScenery = .pony
    
    var playerCollisionMask: UInt32 {
        return (PhysicsCategory.bottomWall | PhysicsCategory.block | PhysicsCategory.blockTop | PhysicsCategory.topWall | PhysicsCategory.leftWall | PhysicsCategory.rightWall)
    }
    
    var playerContactTestBitMask: UInt32 {
        return (PhysicsCategory.score | PhysicsCategory.transparentWall | PhysicsCategory.bottomWall | PhysicsCategory.block | PhysicsCategory.blockTop | PhysicsCategory.topWall | PhysicsCategory.leftWall | PhysicsCategory.rightWall)
    }
    
    override func didMove(to view: SKView) {
       super.didMove(to: view)
        
        //duration = (gameVC?.duration)!
       
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
                    startGame()
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
                    playerJump(percent: 25)
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
            self.createBlocks()
        }
        
        let distance = CGFloat(self.frame.width+blocks.frame.width)
        let interval = 0.008*distance
        
        let timeBetweenBlocks = SKAction.wait(forDuration: TimeInterval(interval))
        let actions = SKAction.sequence([action, timeBetweenBlocks])
        let actionsForever = SKAction.repeatForever(actions)
        
        run(actionsForever, withKey: GameScene.createBlocksAction)
        
        let move = SKAction.moveBy(x: -distance, y: 0.0, duration: TimeInterval(interval))
        let remove = SKAction.removeFromParent()
        
        moveRemove = SKAction.sequence([move,remove])
        
        player.physicsBody?.affectedByGravity = true
    }
    
//    func distanceBetweenWalls(duration: CFTimeInterval, distanceLength: CGFloat) {
//        
//        let spawn = SKAction.run({
//            () in
//                self.createBarriers()
//        })
//        
//        let delay = SKAction.wait(forDuration: duration)
//        let spawnDelay = SKAction.sequence([spawn,delay])
//        let spawnDelayForever = SKAction.repeatForever(spawnDelay)
//        self.run(spawnDelayForever)
//
//        let distance = CGFloat(self.frame.width + wall.frame.width)
//        movePipes = SKAction.moveBy(x: -distance - distanceLength, y: 0, duration: TimeInterval(0.008 * distance))
//        let removePipes = SKAction.removeFromParent()
//        moveAndRemove = SKAction.sequence([movePipes,removePipes])
//    }

   
    
    func startGame2(duration: CFTimeInterval, distanceBetweenWalls: CGFloat, widthWall: CGFloat, heightWall: CGFloat, heightPonyJump: CGFloat ) {
        
        self.duration = duration
        self.distanceBetweenWalls = distanceBetweenWalls
        self.widthWall = widthWall
        self.heightWall = heightWall
        self.heightPonyJump = heightPonyJump
        
       // startValue?.setWidthWall(widthWall: Float(widthWall))
        
        //UserDefaults.standard.set(heightPonyJump, forKey: StaticValue.heightPonyJumpField)
        //UserDefaults.standard.set(duration, forKey: StaticValue.durationField)
        //UserDefaults.standard.set(distanceBetweenWalls, forKey: StaticValue.distanceBetweenWallsField)
      //  UserDefaults.standard.set(widthWall, forKey: StaticValue.widthWallField)
        UserDefaults.standard.set(heightWall, forKey: StaticValue.heightWallField)
    }
    
    
    func playerJump(percent: Int) {
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: gamePercentToPixel(percent: percent)))
    }
    func toPixelHeight(percent: Int) -> CGFloat {
        return (frame.height * CGFloat(percent))/100.0
    }
    
    func gamePercentToPixel(percent: Int) -> CGFloat {
        let max = toPixelHeight(percent: GameScene.MAX_SCREEN_PERCENT_FOR_MAX_HEIGHT)
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
        
        
        let blockTop = SKSpriteNode(color: UIColor.black, size: CGSize(width: block.size.width * 0.75, height: gamePercentToPixel(percent: 1)))
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
        
        if GameScene.score >= 3 && GameScene.score < 7 {
            block.size.height = gamePercentToPixel(percent: 30)
            scoreBlockTopPosition(scoreNode: scoreNode, blockTop: blockTop, block: block)
        } else if GameScene.score >= 7 && GameScene.score < 13 {
            block.size = CGSize(width: 80, height: gamePercentToPixel(percent: 60))
            scoreBlockTopPosition(scoreNode: scoreNode, blockTop: blockTop, block: block)
         } else if GameScene.score >= 13 {
            block.size = CGSize(width: 80, height: CGFloat.random(min: 0, max: gamePercentToPixel(percent: 100)))
            scoreBlockTopPosition(scoreNode: scoreNode, blockTop: blockTop, block: block)
         }
    }
    
    func scoreBlockTopPosition(scoreNode: SKSpriteNode, blockTop: SKSpriteNode, block: SKSpriteNode) {
        scoreNode.position.y = block.frame.maxY + frame.height * 0.1
        blockTop.position = CGPoint(x: frame.maxX,y: block.frame.maxY)
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
        saveHighScore(highScore: GameScene.score)
        removeAllChildren()
        removeAllActions()
        isStarted = false
        needRestart = false
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
        topWall = SKSpriteNode(imageNamed: StaticValue.ceilingImageField)
        topWall.size = CGSize(width: frame.width * 2, height: borderWallWidth)
        topWall.position = CGPoint(x: 0, y: frame.maxY)
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.topWall
        topWall.physicsBody?.isDynamic = false
        addChild(topWall)
        
        rightWall = SKSpriteNode(imageNamed: StaticValue.transparentWallImageField)
        rightWall.size = CGSize(width: borderWallWidth, height: frame.height * 2)
        rightWall.position = CGPoint(x: frame.maxX,y: 0)
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.size)
        rightWall.physicsBody?.categoryBitMask = PhysicsCategory.rightWall
        rightWall.physicsBody?.isDynamic = false
        addChild(rightWall)
        
        leftWall = SKSpriteNode(imageNamed: StaticValue.transparentWallImageField)
        leftWall.size = CGSize(width: borderWallWidth, height: frame.height * 2)
        leftWall.position = CGPoint(x: frame.minX ,y: 0)
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.size)
        leftWall.physicsBody?.categoryBitMask = PhysicsCategory.leftWall
        leftWall.physicsBody?.isDynamic = false
        addChild(leftWall)
        
        bottomWall = SKSpriteNode(imageNamed: StaticValue.groundImageField)
        bottomWall.size = CGSize(width: frame.width * 2, height: grassHeight)
        bottomWall.position = CGPoint(x: frame.width , y: frame.minY)
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
        bottomWall.physicsBody?.categoryBitMask = PhysicsCategory.bottomWall
        bottomWall.physicsBody?.isDynamic = false
        bottomWall.zPosition = 4
        addChild(bottomWall)
    }
    
    func createPony() {
        let ponyScale = CGFloat(0.75)
        player = SKSpriteNode(imageNamed: StaticValue.ponyImageField )
        player.size = CGSize(width: 100, height: 100)
        player.xScale = ponyScale
        player.yScale = ponyScale
        player.position = CGPoint(x: frame.midX , y: frame.midY)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height / 2)
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.collisionBitMask = playerCollisionMask
        player.physicsBody?.contactTestBitMask = playerContactTestBitMask
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        player.zPosition = 2
        addChild(player)
    }
    
    func set(scenery: GameScenery) {
        self.scenery = scenery
    }
    
    func summaryGame() {
        
        removeAllActions()
        removeAllChildren()
        
        isStarted = false
        needRestart = true
        
        createScoreLabel()
        
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
