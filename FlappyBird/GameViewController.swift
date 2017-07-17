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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GameScene(fileNamed:"GameScene") {
            
            scene.startGame(duration: 1.0, distanceBetweenWalls: CGFloat(distanceBetweenWalls), widthWall: CGFloat(widthWall), heightWall: CGFloat(heightWall))
           
            
            //scene.startGame(duration: 3.0, distanceBetweenWalls: 100.0, widthWall: 50.0, heightWall: 50.0)
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            scene.size = self.view.bounds.size
            
            skView.presentScene(scene)
            
            scene.restartScene(duration: 2.0, distanceBetweenWalls: CGFloat(distanceBetweenWalls), widthWall: CGFloat(widthWall), heightWall: CGFloat(heightWall))
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

