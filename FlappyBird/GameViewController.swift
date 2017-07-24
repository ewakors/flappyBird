//
//  ViewController.swift
//  FlappyBird
//
//  Created by Ewa Korszaczuk on 10.07.2017.
//  Copyright © 2017 Ewa Korszaczuk. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    let duration = 3.0
    let distanceBetweenWalls = 100.0
    let widthWall = 40.0
    let heightWall = 20.0
    var gameTimer = Timer()
    var timeInterval = 0.5

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GameScene(fileNamed:"GameScene") {

            gameTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block:
                {(gameTimer) in
                    if scene.gameStarted == true {
                        let heightPonyJump = CGFloat.random(min: 0,max: 100)
                        scene.ponyJumpFeatures(heightPonyJump: heightPonyJump)
                        scene.startGameTimer(gameTimer: gameTimer)
                    }
            })
   
            scene.startGame(duration: duration, distanceBetweenWalls: CGFloat(distanceBetweenWalls), widthWall: CGFloat(widthWall), heightWall: CGFloat(heightWall))
            
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .aspectFill
            scene.size = self.view.bounds.size
            
            skView.presentScene(scene)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }

}

