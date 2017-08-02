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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            if let scene = GameScene(fileNamed: GameScene.id) {
                
                let scenery = ScenerySettings(type: .pony, screenPercentProportionForMaxBlockHeight: 80)
                let player = PlayerSettings(jumpHeightPercent: 30)
                
                let randomHeight = BlockRandom(minPercent: 10, maxPercent: 50)
                let blocks = BlocksSettings(timeBetweenBlocks: 3.0, heightPercent: 10, widthTime: 2, randomHeight: nil)
                
                scene.settingsFor(scenery: scenery, player: player, blocks: blocks)
                
                scene.scaleMode = .resizeFill
                scene.size = self.view.bounds.size
                
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

}

