//
//  ViewController.swift
//  FlappyBird
//
//  Created by Ewa Korszaczuk on 10.07.2017.
//  Copyright © 2017 Ewa Korszaczuk. All rights reserved.
//

import UIKit
import SpriteKit

protocol startValue {
    var duration: TimeInterval { get set }
    var distanceBetweenWalls: Float { get set }
    var widthWall: Float { get set }
    var heightWall: Float { get set }
    var gameTimer: Timer { get set }
    var timeInterval: Float { get set }
    var heightPonyJump: Float { get set }
}

class GameViewController: UIViewController {


    var duration = CFTimeInterval()
    var distanceBetweenWalls = CGFloat()
    var widthWall = CGFloat()
    var heightWall = CGFloat()
    var gameTimer = Timer()
    var timeInterval = 0.5
    var heightPonyJump = CGFloat()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GameScene(fileNamed:"GameScene") {
 
            gameTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block:
                {(gameTimer) in
                    self.duration = 3.0
                    self.distanceBetweenWalls = 100.0
                    self.widthWall = 40.0
                    self.heightWall = 20.0
                    self.timeInterval = 0.5
                    self.heightPonyJump = CGFloat.random(min: -150 ,max: 50)
                    
                    if scene.gameStarted == true {
                        scene.startGame2(duration: CFTimeInterval(self.duration), distanceBetweenWalls: CGFloat(self.distanceBetweenWalls), widthWall: CGFloat(self.widthWall), heightWall: CGFloat(self.heightWall), heightPonyJump: self.heightPonyJump)
                    }

            })


            
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .resizeFill
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

