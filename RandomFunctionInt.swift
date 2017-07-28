//
//  RandomFunctionInt.swift
//  FlappyBird
//
//  Created by Ewa Korszaczuk on 28.07.2017.
//  Copyright © 2017 Ewa Korszaczuk. All rights reserved.
//

import Foundation

extension Int {
    static func randomNumber(range: ClosedRange<Int> = 1...6) -> Int {
        let min = range.lowerBound
        let max = range.upperBound
        return Int(arc4random_uniform(UInt32(1 + max - min))) + min
    }
}
