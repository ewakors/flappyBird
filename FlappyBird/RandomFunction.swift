//
//  RandomFunction.swift
//  FlappyBird
//
//  Created by Ewa Korszaczuk on 10.07.2017.
//  Copyright © 2017 Ewa Korszaczuk. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGFloat {
    
    public static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    public static func random(min : CGFloat, max : CGFloat) -> CGFloat {
    
        return CGFloat.random() * (max - min) + min
    }
    
    public static func staticHeight(wallHeight: CGFloat) -> CGFloat {
        return wallHeight
    }
    
    public static func staticDictance(distanceBetweenWalls: CGFloat) -> CGFloat {
        return distanceBetweenWalls
    }
}
