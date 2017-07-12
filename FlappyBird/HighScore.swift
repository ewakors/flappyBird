//
//  HighScore.swift
//  FlappyBird
//
//  Created by Ewa Korszaczuk on 12.07.2017.
//  Copyright © 2017 Ewa Korszaczuk. All rights reserved.
//

import Foundation

class HighScore: NSObject, NSCoding {
    
    static let scoreField = "score"
    static let dateOfScoreField = "dateOfScore"
    
    var score : Int = 0
    let dateOfScore : NSDate
    
    init(score: Int, dateOfScore: NSDate) {
        self.score = score
        self.dateOfScore = dateOfScore
    }
    
    required init(coder: NSCoder) {
        self.score = coder.decodeObject(forKey: HighScore.scoreField)! as! Int
        self.dateOfScore = coder.decodeObject(forKey: HighScore.dateOfScoreField)! as! NSDate
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.score, forKey: HighScore.scoreField)
        aCoder.encode(self.dateOfScore, forKey: HighScore.dateOfScoreField)
    }
    
}
