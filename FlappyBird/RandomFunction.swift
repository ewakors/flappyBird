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
    
    public static func staticWallWidth(wallWidth: CGFloat) -> CGFloat {
        return wallWidth
    }
    
    public static func staticWallHeight(wallHeight: CGFloat) -> CGFloat {
        return wallHeight
    }
  
    public static func staticDictance(distanceBetweenWalls: CGFloat) -> CGFloat {
        return distanceBetweenWalls
    }
}
