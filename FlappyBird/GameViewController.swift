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
    let widthWall = 50.0
    let heightWall = 100.0
    var gameTimer = Timer()
    var timeInterval = 0.5


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GameScene(fileNamed:"GameScene") {

            gameTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block:
                {(gameTimer) in
                    if scene.gameStarted == true {
                    let height = CGFloat.random(min: 0,max: 150)
                    scene.ponyJumpFeatures(height: height)
                    print("\(height)")
                    } else {
                        
                    }
            })
   
            scene.startGame(duration: duration, distanceBetweenWalls: CGFloat(distanceBetweenWalls), widthWall: scene.frame.width / 20, heightWall: CGFloat(heightWall))
            scene.startGameTimer(gameTimer: gameTimer)
            
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .aspectFill
            scene.userData = NSMutableDictionary()
           // scene.userData?.setObject(gameTimer , forKey: "gameTimer" as NSCopying)
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

