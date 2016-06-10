//
//  WaitingViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 10/7/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import AudioToolbox
import AVFoundation

class WaitingViewController: UIViewController {

    //sounds
    var logicSFX5 : AVAudioPlayer?
    var backsound : AVAudioPlayer?
    var entersound : AVAudioPlayer?
    
    //lock in portrait orientation
    override func shouldAutorotate() -> Bool {
        return false }
    
    //UI label outlets
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var timerLabel: UILabel!
    
    //sound effect variables
    var soundURL: NSURL?
    var soundID:SystemSoundID = 0
    
    //beginning game
    var localPlayerPosition = ""
    var allPlayersJoined = false
    
    //objects 
    var matchRequest = PFObject(withoutDataWithClassName: "matchRequest", objectId: globalMatchRequestObjectID)
    var gameInfo = PFObject(withoutDataWithClassName: "gameInfo", objectId: gameInfoObjectID)
    
    //timers
    var playerJoinTimer = NSTimer()
    var playerJoinTimerCount: Int = 1
    var countdownTimer = NSTimer()
    var countdownTimerCount: Int = 3
    var synchronizeTimer = NSTimer()
    var synchronizeTimerCount: Int = 20
    
    var startTime = 99
    
    //player join timer (used to run code every 5 seconds)
    func playerJoinTimerUpdate() {
        if(playerJoinTimerCount > 0)
        {
            playerJoinTimerCount--

        }
        if(playerJoinTimerCount == 0)
        {
            playerJoinTimerCount = 1
    
    
        //post heartbeat to match request object
                    let rand: String = String(arc4random_uniform(999999))
                    self.matchRequest["heartbeat"] = rand
                    self.matchRequest.saveEventually()

            //post heartbeat to gameInfo object
                    let rand2: String = String(arc4random_uniform(999999))
                    self.gameInfo["heartbeat"] = rand2
                    self.gameInfo.saveEventually()
            
        //check whether all players have joined

           gameInfo.fetchInBackgroundWithBlock {
                (gameInfo: PFObject?, error: NSError?) -> Void in
                if error == nil && gameInfo != nil {
                    
                    let cancelled = gameInfo!.objectForKey("cancelled") as! String
                    if cancelled != "n" {
                        self.cancel(cancelled)
                    }
                    
                    let offense1joined = gameInfo!.objectForKey("offense1joined") as! Int
                    let offense2joined = gameInfo!.objectForKey("offense2joined") as! Int
                    let offense3joined = gameInfo!.objectForKey("offense3joined") as! Int
                    let offense4joined = gameInfo!.objectForKey("offense4joined") as! Int
                    let offense5joined = gameInfo!.objectForKey("offense5joined") as! Int
                    let defense1joined = gameInfo!.objectForKey("defense1joined") as! Int
                    let defense2joined = gameInfo!.objectForKey("defense2joined") as! Int
                    let defense3joined = gameInfo!.objectForKey("defense3joined") as! Int
                    let defense4joined = gameInfo!.objectForKey("defense4joined") as! Int
                    let defense5joined = gameInfo!.objectForKey("defense5joined") as! Int
                    let startTime = gameInfo!.objectForKey("startTime") as! Int
                    
                     if offense1joined != 0 &&
                        offense2joined != 0 &&
                        offense3joined != 0 &&
                        offense4joined != 0 &&
                        offense5joined != 0 &&
                        defense1joined != 0 &&
                        defense2joined != 0 &&
                        defense3joined != 0 &&
                        defense4joined != 0 &&
                        defense5joined != 0 &&
                        startTime == 99 {
                            var startTimeCalc = 99
                            
                            let date = NSDate()
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "ss"
                            let dateString = dateFormatter.stringFromDate(date)
                            let intDate = Int(dateString)
                            
                            startTimeCalc = intDate! + 10
                            
                            if startTimeCalc >= 60 {
                                startTimeCalc = startTimeCalc - 60
                            }
                            
                            gameInfo!["startTime"] = startTimeCalc
                            
                            gameInfo!.saveEventually()
                            
                    }
                    else if offense1joined != 0 &&
                    offense2joined != 0 &&
                    offense3joined != 0 &&
                    offense4joined != 0 &&
                    offense5joined != 0 &&
                    defense1joined != 0 &&
                    defense2joined != 0 &&
                    defense3joined != 0 &&
                    defense4joined != 0 &&
                    defense5joined != 0 &&
                    startTime != 99 {
                        self.startTime = startTime
                        //start synchronize timer
                        self.synchronizeTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("synchronizeTimerUpdate"), userInfo: nil, repeats: true)
                        self.synchronizeTimer.tolerance = 0.1
                        //stop player join timer
                        self.playerJoinTimer.invalidate()
                    }
                    
                    
                    
                    
                } else {
                    print("check join error")
                    print(error)
                }
            }
    
        }
    
    }

    
    //synchronize timer
    func synchronizeTimerUpdate() {
        if(synchronizeTimerCount > 0)
        {
            synchronizeTimerCount--
            
            gameInfo.fetchInBackgroundWithBlock {
                (gameInfo: PFObject?, error: NSError?) -> Void in
                if error == nil {
                    self.startTime = gameInfo!.objectForKey("startTime") as! Int
                }
            }
            
            
        //start game when the clock time seconds is divisble by 8, to synchronize players
                let date = NSDate()
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "ss"
                let dateString = dateFormatter.stringFromDate(date)
            let intDate: Int = Int(dateString)!
            
            if self.startTime == intDate ||
                self.startTime == (intDate + 1) ||
                self.startTime == (intDate + 2) ||
                self.startTime == (intDate + 3) ||
                self.startTime == (intDate + 4) ||
                self.startTime == (intDate + 5) ||
                self.startTime == (intDate + 6) ||
                self.startTime == (intDate + 7) ||
                self.startTime == (intDate + 8) ||
                self.startTime == (intDate + 9) ||
                self.startTime == (intDate + 10) ||
                self.startTime == (intDate + 11) ||
                self.startTime == (intDate + 12) ||
                self.startTime == (intDate - 59) ||
                self.startTime == (intDate - 58) ||
                self.startTime == (intDate - 57) ||
                self.startTime == (intDate - 56) ||
                self.startTime == (intDate - 55) ||
                self.startTime == (intDate - 54) ||
                self.startTime == (intDate - 53) ||
                self.startTime == (intDate - 52) ||
                self.startTime == (intDate - 51) ||
                self.startTime == (intDate - 50) ||
                self.startTime == (intDate - 49) ||
                self.startTime == (intDate - 48)
                            {
                
                //update/reveal labels
                self.headerLabel.text = "game starting in..."
                self.cancelButtonOutlet.hidden = true
                self.timerLabel.hidden = false
                
                //start countdown timer
                self.countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("countdownTimerUpdate"), userInfo: nil, repeats: true)
                self.countdownTimer.tolerance = 0.1
                
                self.synchronizeTimer.invalidate()
            }
            
            
        }
        if(synchronizeTimerCount == 0)
        {
            //update/reveal labels
            self.headerLabel.text = "error, restart game"
            self.cancelButtonOutlet.hidden = false
            self.timerLabel.hidden = true
            
            self.synchronizeTimer.invalidate()
        }
        
    }
    

    //countdown timer
    func countdownTimerUpdate() {
        if(countdownTimerCount == 0)
        {
            self.countdownTimer.invalidate()
            self.performSegueWithIdentifier("showGameViewController", sender: nil)
            self.countdownTimerCount = -1
        }
        if(countdownTimerCount > 0)
        {
            timerLabel.text = String(countdownTimerCount--)
            
        }
    }
    
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
        if let logicSFX5 = self.setupAudioPlayerWithFile("logicSFX5", type:"mp3") {
            self.logicSFX5 = logicSFX5
        }
        self.logicSFX5?.volume = 0.7
        if let backsound = self.setupAudioPlayerWithFile("backsound", type:"mp3") {
            self.backsound = backsound
        }
        self.backsound?.volume = 0.8
        if let entersound = self.setupAudioPlayerWithFile("entersound", type:"mp3") {
            self.entersound = entersound
        }
        self.entersound?.volume = 0.6
        
        //background colors
        if globalIsOffense == false {
            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
        }
        
        if globalIsOffense == true {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
        }
        
        
        print(globalUserName)
        print(localPlayerPosition)
        
        self.logicSFX5?.play()
        
        //backckground
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "blue2.jpg")!)
        
        print("game info object ID, prior to query")
        print(gameInfoObjectID)
    
        
        //query game data upon load
        
        gameInfo.fetchInBackgroundWithBlock {
            (gameInfo: PFObject?, error: NSError?) -> Void in
            if error != nil {
            } else if let gameInfo = gameInfo {
                
        //determine the local player's position
                if globalUserName == gameInfo.objectForKey("offense1") as! String {
                    self.localPlayerPosition = "offense1"
                }
                else if globalUserName == gameInfo.objectForKey("offense2") as! String {
                    self.localPlayerPosition = "offense2"
                }
                else if globalUserName == gameInfo.objectForKey("offense3") as! String {
                    self.localPlayerPosition = "offense3"
                }
                else if globalUserName == gameInfo.objectForKey("offense4") as! String {
                    self.localPlayerPosition = "offense4"
                }
                else if globalUserName == gameInfo.objectForKey("offense5") as! String {
                    self.localPlayerPosition = "offense5"
                }
                else if globalUserName == gameInfo.objectForKey("defense1") as! String {
                    self.localPlayerPosition = "defense1"
                }
                else if globalUserName == gameInfo.objectForKey("defense2") as! String {
                    self.localPlayerPosition = "defense2"
                }
                else if globalUserName == gameInfo.objectForKey("defense3") as! String {
                    self.localPlayerPosition = "defense3"
                }
                else if globalUserName == gameInfo.objectForKey("defense4") as! String {
                    self.localPlayerPosition = "defense4"
                }
                else if globalUserName == gameInfo.objectForKey("defense5") as! String {
                    self.localPlayerPosition = "defense5"
                }
                
        //tell DB that the local player has joined
                print("joined var")
                print("\(self.localPlayerPosition)joined")
                gameInfo["\(self.localPlayerPosition)joined"] = Int(1)
                gameInfo.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    if error != nil {
                        print("error initial view load save fail")
                        print(error)
                    }
                    
                    else {
                        print("test output:")
                        print("local player position")
                        print(self.localPlayerPosition)
                        
                        //player join timer
                        self.playerJoinTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("playerJoinTimerUpdate"), userInfo: nil, repeats: true)
                        self.playerJoinTimer.tolerance = 0.3

                    }
                }

            }
        }
        
    }

    @IBOutlet var cancelButtonOutlet: UIButton!
    @IBAction func cancelButton(sender: AnyObject) {
        self.backsound?.play()
        let refreshAlert = UIAlertController(title: "Exit", message: "Are you sure?  This will cancel the game for all players", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            
            self.gameInfo.fetchInBackgroundWithBlock {
                (gameInfo: PFObject?, error: NSError?) -> Void in
                if error == nil {
                    self.gameInfo["cancelled"] = globalUserName
                    self.gameInfo.saveEventually()
                }
            }
            
            self.entersound?.play()
            self.synchronizeTimer.invalidate()
            self.playerJoinTimer.invalidate()
            self.countdownTimer.invalidate()
            self.performSegueWithIdentifier("showPairViewControllerFromWaitingViewController", sender: nil)
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
        
        
    }
    
    func cancel(canceller: String) {
        
        self.backsound?.play()
        let refreshAlert = UIAlertController(title: "Game cancelled", message: "\(canceller) exited", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            
            self.entersound?.play()
            self.synchronizeTimer.invalidate()
            self.playerJoinTimer.invalidate()
            self.countdownTimer.invalidate()
            self.performSegueWithIdentifier("showPairViewControllerFromWaitingViewController", sender: nil)
            
        }))
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
