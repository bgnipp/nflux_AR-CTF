//
//  GameResultsViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 10/5/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import AudioToolbox
import Parse
import AVFoundation

class GameResultsViewController: UIViewController {
    
    //sounds
    var logicLoseGame : AVAudioPlayer?
    var logicWinGame : AVAudioPlayer?

    //lock in portrait orientation
    override func shouldAutorotate() -> Bool {
        return false }
    
    @IBOutlet var winnerLabel: UILabel!
    @IBOutlet var winningPlayerLabel: UILabel!
    @IBOutlet var tagCountLabel: UILabel!
    
    var gameWinner =  ""
    
    //sounds
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?  {
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        var audioPlayer:AVAudioPlayer?
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        return audioPlayer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sounds
        if let logicLoseGame = self.setupAudioPlayerWithFile("logicLoseGame", type:"mp3") {
            self.logicLoseGame = logicLoseGame
        }
        self.logicLoseGame?.volume = 0.7
        if let logicWinGame = self.setupAudioPlayerWithFile("logicWinGame", type:"mp3") {
            self.logicWinGame = logicWinGame
        }
        self.logicWinGame?.volume = 0.7
        
        //background colors
        if globalIsOffense == false {
            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
        }
        
        if globalIsOffense == true {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
        }
        
        if globalDefenseWonGame == true {
            self.winnerLabel.text = "defense wins!!!"
            self.tagCountLabel.hidden = true
            
            if globalIsOffense == true {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.logicLoseGame?.play()
                self.winningPlayerLabel.hidden = true
                
            }
            if globalIsOffense == false {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.logicWinGame?.play()
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                if playerTagCount == 0 {
                    self.winningPlayerLabel.text = "You got 0 tags"
                }
                else if playerTagCount == 1 {
                    self.winningPlayerLabel.text = "You got 1 tag"
                }
                else {
                self.winningPlayerLabel.text = "You got \(String(playerTagCount)) tags"
                }
            }
      
        }
       
            
        else {
           self.winnerLabel.text = "offense wins!!!"
            //indicate which player won the game 
            var query = PFQuery(className:"inGameInfo")
            query.getObjectInBackgroundWithId(inGameInfoObjectID) {
                (inGameInfo: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    print("parse error")  }
                else if let inGameInfo = inGameInfo {
                    self.gameWinner = inGameInfo.objectForKey("gameWinner") as! String
                    self.winningPlayerLabel.text = "\(self.gameWinner) won it!!"
                }
            }
            
            if globalIsOffense == true {
                self.logicWinGame?.play()
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                
            }
            if globalIsOffense == false {
                self.logicLoseGame?.play()
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            
            
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
