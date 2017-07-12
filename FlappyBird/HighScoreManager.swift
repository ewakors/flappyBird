//
//  HighScoreManager.swift
//  FlappyBird
//
//  Created by Ewa Korszaczuk on 12.07.2017.
//  Copyright © 2017 Ewa Korszaczuk. All rights reserved.
//

import Foundation

class HighScoreManager {
    
    var scores: Array<HighScore> = []
    
    init() {
        // load existing high scores or set up an empty array
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        let path = documentsDirectory.appendingPathComponent("HighScores.plist")
        let fileManager = FileManager.default
        
        // check if file exists
        if !fileManager.fileExists(atPath: path) {
            // create an empty file if it doesn't exist
            if let bundle = Bundle.main.path(forResource: "DefaultFile", ofType: "plist") {
                
                do {
                    try fileManager.copyItem(atPath: bundle, toPath: path)
                } catch {
                    print(error)
                }
            }
        }
        
        if let rawData = NSData(contentsOfFile: path) {
            // do we get serialized data back from the attempted path?
            // if so, unarchive it into an AnyObject, and then convert to an array of HighScores, if possible            
            let scoreArray: AnyObject? = NSKeyedUnarchiver.unarchiveObject(with: rawData as Data) as AnyObject?
            self.scores = scoreArray as? [HighScore] ?? [];
        }
    }
    
    func saveHighScore() {
        let saveData = NSKeyedArchiver.archivedData(withRootObject: self.scores)
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths.object(at: 0) as! NSString
        let path = documentsDirectory.appendingPathComponent("HighScores.plist")
        
        do {
            try saveData.write(to: URL(fileURLWithPath: path), options: .atomic)
        } catch let error {
            print(error)
        }
    }
    
    func addNewScore(newScore:Int) {
        let newHighScore = HighScore(score: newScore, dateOfScore: NSDate())
        self.scores.append(newHighScore)
        self.saveHighScore()
    }
}
