//
//  PairViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 9/13/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import AVFoundation
import CoreBluetooth

var gameInfoObjectID = ""
var inGameInfoObjectID = ""
var itemInfoObjectID = ""

class PairViewController: UIViewController, UITextFieldDelegate, CBPeripheralManagerDelegate {
    
    //lock in portrait orientation
    override func shouldAutorotate() -> Bool {
        return false }
    var offenseUserNames = [String]()
    var defenseUserNames = [String]()
    
    @IBOutlet var gameNameLabel: UILabel!
    @IBOutlet var beginButtonLabel: UIButton!
    @IBOutlet var switchTeamsButtonLabel: UIButton!
    
    //NEW CODE
    var matchRequest = PFObject(withoutDataWithClassName: "matchRequest", objectId: globalMatchRequestObjectID)
    
    //0 = game not being created, 1 = game being created, 2 = game ready to join, 3 = game started
    var beginButtonState: Int = 0
    
    @IBOutlet var offense1: UILabel!
    @IBOutlet var offense2: UILabel!
    @IBOutlet var offense3: UILabel!
    @IBOutlet var offense4: UILabel!
    @IBOutlet var offense5: UILabel!
    
    @IBOutlet var defense1: UILabel!
    @IBOutlet var defense2: UILabel!
    @IBOutlet var defense3: UILabel!
    @IBOutlet var defense4: UILabel!
    @IBOutlet var defense5: UILabel!
    
    @IBOutlet var beingCreatedHelpOutlet: UIButton!
    @IBOutlet var startGameHelpOutlet: UIButton!
    
    
    var offense1var = ""
    var offense2var = ""
    var offense3var = ""
    var offense4var = ""
    var offense5var = ""
    var defense1var = ""
    var defense2var = ""
    var defense3var = ""
    var defense4var = ""
    var defense5var = ""
    
    var gameCancelled = "n"
    
    //refresh timer
    var refreshTimer = NSTimer()
    var refreshTimerCount: Int = 0
    
    var postHeartbeat: String = "n"
    
    
    //player joined variables, 0 = no, 1 = yes, 2 = NA (player doesn't exist)
    var offense1joined: Int = 2
    var offense2joined: Int = 2
    var offense3joined: Int = 2
    var offense4joined: Int = 2
    var offense5joined: Int = 2
    var defense1joined: Int = 2
    var defense2joined: Int = 2
    var defense3joined: Int = 2
    var defense4joined: Int = 2
    var defense5joined: Int = 2
    
    var offensePlayersWaiting = 0
    var defensePlayersWaiting = 0
    var playersWaiting = 0
    
    //set up UI alerts
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController (title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //sounds
    var entersoundlow : AVAudioPlayer?
    var backsound : AVAudioPlayer?
    
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
    
    if let entersoundlow = self.setupAudioPlayerWithFile("entersoundlow", type:"mp3") {
        self.entersoundlow = entersoundlow
    }
    self.entersoundlow?.volume = 0.8
    if let backsound = self.setupAudioPlayerWithFile("backsound", type:"mp3") {
        self.backsound = backsound
    }
    self.backsound?.volume = 0.8

        self.beginButtonLabel.enabled = false
        
    //background colors
    if globalIsOffense == false {
        self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
    }
    
    if globalIsOffense == true {
        self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
    }

    //set game name UI label
        self.gameNameLabel.text = "game name: \(globalGameName)"
        
        
    //start refresh timer
        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("refreshTimerUpdate"), userInfo: nil, repeats: true)
        self.refreshTimer.tolerance = 0.3

    if Reachability.isConnectedToNetwork() == false {
        displayAlert("No internet connection", message: "You must have an active internet/data connection to play!")
    }
}
    
    
//refresh timer
    func refreshTimerUpdate() {
        if(refreshTimerCount > 0)
        {
            refreshTimerCount--
        }
        if(refreshTimerCount == 0)
        {
            
            
    //post heartbeat
            let heartbeatQuery = PFQuery(className:"matchRequest")
            heartbeatQuery.getObjectInBackgroundWithId(globalMatchRequestObjectID) {
                (matchRequest: PFObject?, error: NSError?) -> Void in
                if error == nil {
                    let rand: String = String(arc4random_uniform(999999))
                matchRequest!["heartbeat"] = rand
                matchRequest?.saveEventually()
                
                }
            }
            
    //check whether the game is being created, or has been created, and update UI accordingly
            let someSecondsAgo2 = NSDate(timeIntervalSinceNow:-20)
            let checkQuery = PFQuery(className: "gameInfo")
            checkQuery.whereKey("gameName", equalTo: globalGameName)
            checkQuery.whereKey("updatedAt", greaterThanOrEqualTo: someSecondsAgo2)
            checkQuery.orderByDescending("updatedAt")
            checkQuery.getFirstObjectInBackgroundWithBlock {
                (gameInfo: PFObject?, error: NSError?) -> Void in
                if error == nil && gameInfo != nil {
                    let isActive: Bool = gameInfo?.objectForKey("isActive") as! Bool
                    let cancelled: String = gameInfo?.objectForKey("cancelled") as! String
                    
                    //game is being created, grey out button
                    if isActive == false  && cancelled == "n" {
                        self.beginButtonState = 1
                        self.beginButtonLabel.enabled = false
                        self.beginButtonLabel.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                        self.beginButtonLabel.setTitle("game being created...", forState: UIControlState.Normal)
                        self.switchTeamsButtonLabel.enabled = false
                        self.switchTeamsButtonLabel.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                    }
                    
                    //game is ready to join, show "join game"
                    if isActive == true && cancelled == "n" {
                        self.beginButtonState = 2
                        self.beginButtonLabel.setTitle("join game", forState: UIControlState.Normal)
                        let purp = UIColor(
                            red:0.216,
                            green:0.251,
                            blue:0.812,
                            alpha:1.0)
                        self.beginButtonLabel.setTitleColor(purp, forState: UIControlState.Normal)
                        self.beginButtonLabel.enabled = true
                        self.switchTeamsButtonLabel.enabled = false
                        self.switchTeamsButtonLabel.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                    }
                    
                    //game is cancelled, show "create game"
                    if cancelled != "n" {
                        self.gameCancelled = cancelled
                        
                        self.beginButtonState = 0
                        let purp = UIColor(
                            red:0.216,
                            green:0.251,
                            blue:0.812,
                            alpha:1.0)
                        self.beginButtonLabel.setTitleColor(purp, forState: UIControlState.Normal)
                        self.beginButtonLabel.setTitle("start game", forState: UIControlState.Normal)
                        self.beginButtonLabel.enabled = true
                        self.switchTeamsButtonLabel.setTitleColor(purp, forState: UIControlState.Normal)
                        self.switchTeamsButtonLabel.enabled = true
                    }
                    
                }
                    
                    //game doesn't exist yet, show "create game"
                else {
                    self.beginButtonState = 0
                    let purp = UIColor(
                        red:0.216,
                        green:0.251,
                        blue:0.812,
                        alpha:1.0)
                    self.beginButtonLabel.setTitleColor(purp, forState: UIControlState.Normal)
                    self.beginButtonLabel.setTitle("start game", forState: UIControlState.Normal)
                    self.beginButtonLabel.enabled = true
                    self.switchTeamsButtonLabel.setTitleColor(purp, forState: UIControlState.Normal)
                    self.switchTeamsButtonLabel.enabled = true
                }
            }
    
    //refresh player UI labels
            self.refreshPlayerLabels()
            
        }
    }
    
    @IBAction func beginButton(sender: AnyObject) {
        
        self.playersWaiting = self.offensePlayersWaiting + self.defensePlayersWaiting
        
        if Reachability.isConnectedToNetwork() == false {
            displayAlert("No internet connection", message: "nFlux requires an active internet/data connection.  Make sure airplane mode on your phone is OFF, and that you have an active data plan.")
        }
//        else if bluetoothOn == false {
//            displayAlert("Bluetooth disabled", message: "nFlux requires bluetooth in order to determine when players get tagged by opponents. Make sure airplane mode on your phone is OFF, and that bluetooth is enabled and authorized.")
//        }
        
    //"Join" button
        else if self.beginButtonState == 2 {
                
                let query = PFQuery(className: "gameInfo")
                query.whereKey("gameName", equalTo: globalGameName)
                query.orderByDescending("updatedAt")
                query.getFirstObjectInBackgroundWithBlock {
                    (gameInfo: PFObject?, error: NSError?) -> Void in
                    if error == nil && gameInfo != nil {
                        let isActive: Bool = gameInfo?.objectForKey("isActive") as! Bool
                        if isActive == false {
                            self.displayAlert("Error", message: "Game does not exist or has not started")
                        }
                        
                        if isActive == true {
                            gameInfoObjectID = gameInfo!.objectId!
                            inGameInfoObjectID = gameInfo?["inGameInfoObjectID"] as! String
                            itemInfoObjectID = gameInfo?["itemInfoObjectID"] as! String
                            
                            self.refreshTimer.invalidate()
                            self.performSegueWithIdentifier("showWaitingViewControllerFromPair", sender: nil)
                        }
                        
                    }
                    else {
                        self.displayAlert("Error", message: "Game does not exist")
                    }
                }
                
            
            
        }
        
    //"Create Game" Button
        else if self.beginButtonState == 0 {
            
            if self.playersWaiting == 1 {
                
                
                
                let refreshAlert = UIAlertController(title: "Are you sure?", message: "Create a game with only one player?  Other players will not be able to join.  However, creating a game with only one player may be useful for understanding how the game works. ", preferredStyle: UIAlertControllerStyle.Alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                    
                    let gameInfo = PFObject(className: "gameInfo")
                    let acl = PFACL()
                    acl.setPublicReadAccess(true)
                    acl.setPublicWriteAccess(true)
                    gameInfo.ACL = acl
                    gameInfo["gameName"] = globalGameName
                    gameInfo["offense1"] = self.offense1var
                    gameInfo["offense2"] = self.offense2var
                    gameInfo["offense3"] = self.offense3var
                    gameInfo["offense4"] = self.offense4var
                    gameInfo["offense5"] = self.offense5var
                    gameInfo["defense1"] = self.defense1var
                    gameInfo["defense2"] = self.defense2var
                    gameInfo["defense3"] = self.defense3var
                    gameInfo["defense4"] = self.defense4var
                    gameInfo["defense5"] = self.defense5var
                    gameInfo["offense1joined"] = self.offense1joined
                    gameInfo["offense2joined"] = self.offense2joined
                    gameInfo["offense3joined"] = self.offense3joined
                    gameInfo["offense4joined"] = self.offense4joined
                    gameInfo["offense5joined"] = self.offense5joined
                    gameInfo["defense1joined"] = self.defense1joined
                    gameInfo["defense2joined"] = self.defense2joined
                    gameInfo["defense3joined"] = self.defense3joined
                    gameInfo["defense4joined"] = self.defense4joined
                    gameInfo["defense5joined"] = self.defense5joined
                    gameInfo["startTime"] = 99
                    gameInfo["heartbeat"] = "n"
                    gameInfo["isActive"] = false
                    gameInfo["hasStarted"] = false
                    gameInfo["cancelled"] = "n"
                    gameInfo.saveEventually() { (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            gameInfoObjectID = gameInfo.objectId!
                            
                            //SET UP IN GAME INFO PARSE OBJECT
                            let inGameInfo = PFObject(className: "inGameInfo")
                            let acl = PFACL()
                            acl.setPublicReadAccess(true)
                            acl.setPublicWriteAccess(true)
                            inGameInfo.ACL = acl
                            inGameInfo["gameInfoObjectID"] = gameInfoObjectID
                            inGameInfo["playerCapturingPoint"] = "n"
                            inGameInfo["playerCapturingPointPosition"] = "n"
                            inGameInfo["playerCapturingPointHeartbeat"] = "n"
                            inGameInfo["playerCapturedPoint"] = "n"
                            inGameInfo["playerCapturedPointPosition"] = "n"
                            inGameInfo["playerCapturedPointHeartbeat"] = "n"
                            inGameInfo["gameWinner"] = "n"
                            inGameInfo["playerTaggedBy"] = "n"
                            inGameInfo["playerTagged"] = "n"
                            inGameInfo["randomPlayerCapturingPoint"] = "n"
                            inGameInfo["randomPlayerWithPointTagged"] = "n"
                            inGameInfo["playerWithPointTaggedName"] = "n"
                            inGameInfo["timerSyncValue"] = -1
                            inGameInfo["secondsSyncInt"] = 20
                            inGameInfo["T"] = ["n","n",0,0,99999,false]
                            inGameInfo["T2"] = ["n","n",0,0,99999,false]
                            inGameInfo.saveEventually() { (success: Bool, error: NSError?) -> Void in
                                if (success) {
                                    inGameInfoObjectID = inGameInfo.objectId!
                                    
                                    
                                    //SET UP itemInfo PARSE OBJECT
                                    let itemInfo = PFObject(className: "itemInfo")
                                    let acl = PFACL()
                                    acl.setPublicReadAccess(true)
                                    acl.setPublicWriteAccess(true)
                                    itemInfo.ACL = acl
                                    
                                    itemInfo["OI1"] = [0,0,0]
                                    itemInfo["OI2"] = [0,0,0]
                                    itemInfo["OI3"] = [0,0,0]
                                    itemInfo["OI4"] = [0,0,0]
                                    itemInfo["OI5"] = [0,0,0]
                                    itemInfo["DI1"] = [0,0,0]
                                    itemInfo["DI2"] = [0,0,0]
                                    itemInfo["DI3"] = [0,0,0]
                                    itemInfo["DI4"] = [0,0,0]
                                    itemInfo["DI5"] = [0,0,0]
                                    
                                    itemInfo["OS"] = ["n",0,0,0,0]
                                    itemInfo["DS"] = ["n",0,0,0,0]
                                    itemInfo["OS2"] = ["n",0,0,0,0]
                                    itemInfo["DS2"] = ["n",0,0,0,0]
                                    itemInfo["OM"] = ["n",0,0,0,0,false]
                                    itemInfo["DM"] = ["n",0,0,0,0,false]
                                    itemInfo["OM2"] = ["n",0,0,0,0,false]
                                    itemInfo["DM2"] = ["n",0,0,0,0,false]
                                    itemInfo["OMU"] = [0,0]
                                    itemInfo["DMU"] = [0,0]
                                    itemInfo["OMU2"] = [0,0]
                                    itemInfo["DMU2"] = [0,0]
                                    
                                    itemInfo["offense1Inbox"] = [0,0,0]
                                    itemInfo["offense2Inbox"] = [0,0,0]
                                    itemInfo["offense3Inbox"] = [0,0,0]
                                    itemInfo["offense4Inbox"] = [0,0,0]
                                    itemInfo["offense5Inbox"] = [0,0,0]
                                    itemInfo["offenseInbox"] = [0,0,0]
                                    itemInfo["offenseInbox2"] = [0,0,0]
                                    itemInfo["offenseInbox3"] = [0,0,0]
                                    itemInfo["offenseInbox4"] = [0,0,0]
                                    itemInfo["defense1Inbox"] = [0,0,0]
                                    itemInfo["defense2Inbox"] = [0,0,0]
                                    itemInfo["defense3Inbox"] = [0,0,0]
                                    itemInfo["defense4Inbox"] = [0,0,0]
                                    itemInfo["defense5Inbox"] = [0,0,0]
                                    itemInfo["defenseInbox"] = [0,0,0]
                                    itemInfo["defenseInbox2"] = [0,0,0]
                                    itemInfo["defenseInbox3"] = [0,0,0]
                                    itemInfo["defenseInbox4"] = [0,0,0]
                                    
                                    
                                    itemInfo.saveEventually() { (success: Bool, error: NSError?) -> Void in
                                        if (success) {
                                            itemInfoObjectID = itemInfo.objectId!
                                            
                                            self.refreshTimer.invalidate()
                                            self.entersoundlow?.play()
                                            self.resetGlobalSetupVars()
                                            self.performSegueWithIdentifier("showGameOptionsViewController", sender: self)
                                        }
                                        else { self.displayAlert("Error", message: "Network connection issues. Please make sure you airplane mode is disabled and you have an active network connection, and restart the game.")
                                        }
                                    }
                                    
                                }
                                else { self.displayAlert("Error", message: "Network connection issues. Please make sure you airplane mode is disabled and you have an active network connection, and restart the game.")
                                }
                            }
                            
                        }
                        else { self.displayAlert("Error", message: "Network connection issues. Please make sure you airplane mode is disabled and you have an active network connection, and restart the game.")
                        }
                        
                    }
                    
                }))
                
                refreshAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
                    
                }))
                presentViewController(refreshAlert, animated: true, completion: nil)
                
                
                
                
            }
            
            else {
                
                
                
                
                let refreshAlert = UIAlertController(title: "Confirm", message: "Create a game with \(self.playersWaiting) players? Additional players will not be able to join after this point.", preferredStyle: UIAlertControllerStyle.Alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                    
                    let gameInfo = PFObject(className: "gameInfo")
                    let acl = PFACL()
                    acl.setPublicReadAccess(true)
                    acl.setPublicWriteAccess(true)
                    gameInfo.ACL = acl
                    gameInfo["gameName"] = globalGameName
                    gameInfo["offense1"] = self.offense1var
                    gameInfo["offense2"] = self.offense2var
                    gameInfo["offense3"] = self.offense3var
                    gameInfo["offense4"] = self.offense4var
                    gameInfo["offense5"] = self.offense5var
                    gameInfo["defense1"] = self.defense1var
                    gameInfo["defense2"] = self.defense2var
                    gameInfo["defense3"] = self.defense3var
                    gameInfo["defense4"] = self.defense4var
                    gameInfo["defense5"] = self.defense5var
                    gameInfo["offense1joined"] = self.offense1joined
                    gameInfo["offense2joined"] = self.offense2joined
                    gameInfo["offense3joined"] = self.offense3joined
                    gameInfo["offense4joined"] = self.offense4joined
                    gameInfo["offense5joined"] = self.offense5joined
                    gameInfo["defense1joined"] = self.defense1joined
                    gameInfo["defense2joined"] = self.defense2joined
                    gameInfo["defense3joined"] = self.defense3joined
                    gameInfo["defense4joined"] = self.defense4joined
                    gameInfo["defense5joined"] = self.defense5joined
                    gameInfo["startTime"] = 99
                    gameInfo["heartbeat"] = "n"
                    gameInfo["isActive"] = false
                    gameInfo["hasStarted"] = false
                    gameInfo["cancelled"] = "n"
                    gameInfo.saveEventually() { (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            gameInfoObjectID = gameInfo.objectId!
                            
                            //SET UP IN GAME INFO PARSE OBJECT
                            let inGameInfo = PFObject(className: "inGameInfo")
                            let acl = PFACL()
                            acl.setPublicReadAccess(true)
                            acl.setPublicWriteAccess(true)
                            inGameInfo.ACL = acl
                            inGameInfo["gameInfoObjectID"] = gameInfoObjectID
                            inGameInfo["playerCapturingPoint"] = "n"
                            inGameInfo["playerCapturingPointPosition"] = "n"
                            inGameInfo["playerCapturingPointHeartbeat"] = "n"
                            inGameInfo["playerCapturedPoint"] = "n"
                            inGameInfo["playerCapturedPointPosition"] = "n"
                            inGameInfo["playerCapturedPointHeartbeat"] = "n"
                            inGameInfo["gameWinner"] = "n"
                            inGameInfo["playerTaggedBy"] = "n"
                            inGameInfo["playerTagged"] = "n"
                            inGameInfo["randomPlayerCapturingPoint"] = "n"
                            inGameInfo["randomPlayerWithPointTagged"] = "n"
                            inGameInfo["playerWithPointTaggedName"] = "n"
                            inGameInfo["timerSyncValue"] = -1
                            inGameInfo["secondsSyncInt"] = 20
                            inGameInfo["T"] = ["n","n",0,0,99999,false]
                            inGameInfo["T2"] = ["n","n",0,0,99999,false]
                            inGameInfo.saveEventually() { (success: Bool, error: NSError?) -> Void in
                                if (success) {
                                    inGameInfoObjectID = inGameInfo.objectId!
                                    
                                    
                                    //SET UP itemInfo PARSE OBJECT
                                    let itemInfo = PFObject(className: "itemInfo")
                                    let acl = PFACL()
                                    acl.setPublicReadAccess(true)
                                    acl.setPublicWriteAccess(true)
                                    itemInfo.ACL = acl
                                    
                                    itemInfo["OI1"] = [0,0,0]
                                    itemInfo["OI2"] = [0,0,0]
                                    itemInfo["OI3"] = [0,0,0]
                                    itemInfo["OI4"] = [0,0,0]
                                    itemInfo["OI5"] = [0,0,0]
                                    itemInfo["DI1"] = [0,0,0]
                                    itemInfo["DI2"] = [0,0,0]
                                    itemInfo["DI3"] = [0,0,0]
                                    itemInfo["DI4"] = [0,0,0]
                                    itemInfo["DI5"] = [0,0,0]
                                    
                                    itemInfo["OS"] = ["n",0,0,0,0]
                                    itemInfo["DS"] = ["n",0,0,0,0]
                                    itemInfo["OS2"] = ["n",0,0,0,0]
                                    itemInfo["DS2"] = ["n",0,0,0,0]
                                    itemInfo["OM"] = ["n",0,0,0,0,false]
                                    itemInfo["DM"] = ["n",0,0,0,0,false]
                                    itemInfo["OM2"] = ["n",0,0,0,0,false]
                                    itemInfo["DM2"] = ["n",0,0,0,0,false]
                                    itemInfo["OMU"] = [0,0]
                                    itemInfo["DMU"] = [0,0]
                                    itemInfo["OMU2"] = [0,0]
                                    itemInfo["DMU2"] = [0,0]
                                    
                                    itemInfo["offense1Inbox"] = [0,0,0]
                                    itemInfo["offense2Inbox"] = [0,0,0]
                                    itemInfo["offense3Inbox"] = [0,0,0]
                                    itemInfo["offense4Inbox"] = [0,0,0]
                                    itemInfo["offense5Inbox"] = [0,0,0]
                                    itemInfo["offenseInbox"] = [0,0,0]
                                    itemInfo["offenseInbox2"] = [0,0,0]
                                    itemInfo["offenseInbox3"] = [0,0,0]
                                    itemInfo["offenseInbox4"] = [0,0,0]
                                    itemInfo["defense1Inbox"] = [0,0,0]
                                    itemInfo["defense2Inbox"] = [0,0,0]
                                    itemInfo["defense3Inbox"] = [0,0,0]
                                    itemInfo["defense4Inbox"] = [0,0,0]
                                    itemInfo["defense5Inbox"] = [0,0,0]
                                    itemInfo["defenseInbox"] = [0,0,0]
                                    itemInfo["defenseInbox2"] = [0,0,0]
                                    itemInfo["defenseInbox3"] = [0,0,0]
                                    itemInfo["defenseInbox4"] = [0,0,0]
                                    
                                    
                                    itemInfo.saveEventually() { (success: Bool, error: NSError?) -> Void in
                                        if (success) {
                                            itemInfoObjectID = itemInfo.objectId!
                                            
                                            self.refreshTimer.invalidate()
                                            self.entersoundlow?.play()
                                            self.resetGlobalSetupVars()
                                            self.performSegueWithIdentifier("showGameOptionsViewController", sender: self)
                                        }
                                        else { self.displayAlert("Error", message: "Network connection issues. Please make sure you airplane mode is disabled and you have an active network connection, and restart the game.")
                                        }
                                    }
                                    
                                }
                                else { self.displayAlert("Error", message: "Network connection issues. Please make sure you airplane mode is disabled and you have an active network connection, and restart the game.")
                                }
                            }
                            
                        }
                        else { self.displayAlert("Error", message: "Network connection issues. Please make sure you airplane mode is disabled and you have an active network connection, and restart the game.")
                        }
                        
                    }
                    
                }))
                
                refreshAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
                    
                }))
                presentViewController(refreshAlert, animated: true, completion: nil)
                
                
                
                
                
            }
            
        
        }

    }
    

    @IBAction func cancelButton(sender: AnyObject) {
        
        
        let refreshAlert = UIAlertController(title: "Exit waiting screen", message: "Are you sure?  You will not be able to participate in the current game", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            self.refreshTimer.invalidate()
            
            let deleteQuery = PFQuery(className:"matchRequest")
            deleteQuery.getObjectInBackgroundWithId(globalMatchRequestObjectID) {
                (matchRequest: PFObject?, error: NSError?) -> Void in
                if error == nil {
                    matchRequest?.deleteEventually()
                    
                }
            }
            self.backsound?.play()
            self.performSegueWithIdentifier("showViewControllerFromPairViewController", sender: nil)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func switchTeamsButton(sender: AnyObject) {
        if Reachability.isConnectedToNetwork() == false {
            displayAlert("No internet connection", message: "nFlux requires an active internet/data connection.  Make sure airplane mode on your phone is OFF, and that you have an active data plan.")
        }
        else {
        switchTeamsButtonLabel.enabled = false
        self.matchRequest.fetchInBackgroundWithBlock {
            (itemInfo: PFObject?, error: NSError?) -> Void in
            if error == nil {
                if globalIsOffense == true {
                    self.matchRequest["isOffense"] = false
                    self.matchRequest.saveEventually() { (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            self.switchTeamsButtonLabel.enabled = true
                            globalIsOffense = false
                            self.entersoundlow?.play()
                            self.refreshPlayerLabels()
                            
                            //background colors
                            if globalIsOffense == false {
                                self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
                            }
                            
                            if globalIsOffense == true {
                                self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
                            }
                        }
                        else {
                            self.switchTeamsButtonLabel.enabled = true
                        }
                    }
                }
                else if globalIsOffense == false {
                    self.matchRequest["isOffense"] = true
                    self.matchRequest.saveEventually() { (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            self.switchTeamsButtonLabel.enabled = true
                            self.entersoundlow?.play()
                            globalIsOffense = true
                            self.refreshPlayerLabels()
                            
//                            self.matchRequest.fetchInBackground()
//                            print("match request fetched again: \(self.matchRequest)")
                            
                            //background colors
                            if globalIsOffense == false {
                                self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
                            }
                            
                            if globalIsOffense == true {
                                self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
                            }
                        }
                        else {
                            self.switchTeamsButtonLabel.enabled = true
                        }
                    }
                }
            }
            else {
                self.switchTeamsButtonLabel.enabled = true
            }
        }
        }
//        let switchQuery = PFQuery(className:"matchRequest")
//        switchQuery.getObjectInBackgroundWithId(globalMatchRequestObjectID) {
//            (matchRequest: PFObject?, error: NSError?) -> Void in
//            if error == nil {
//                
//                if globalIsOffense == true {
//                matchRequest!["isOffense"] = false
//                matchRequest?.saveEventually() { (success: Bool, error: NSError?) -> Void in
//                    if (success) {
//                        globalIsOffense = false
//                        self.entersoundlow?.play()
//                        self.refreshPlayerLabels()
//                        
//                        //background colors
//                        if globalIsOffense == false {
//                            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
//                        }
//                        
//                        if globalIsOffense == true {
//                            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
//                        }
//                    }
//                }
//            }
//                else if globalIsOffense == false {
//                    matchRequest!["isOffense"] = true
//                    matchRequest?.saveEventually() { (success: Bool, error: NSError?) -> Void in
//                        if (success) {
//                            self.entersoundlow?.play()
//                            globalIsOffense = true
//                            self.refreshPlayerLabels()
//                            
//                            //background colors
//                            if globalIsOffense == false {
//                                self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
//                            }
//                            
//                            if globalIsOffense == true {
//                                self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
//                            }
//                        }
//                    }
//                }
//                
//            }
//        }
        
    }
    
    func refreshPlayerLabels() {
        
            self.offenseUserNames.removeAll()
            self.defenseUserNames.removeAll()
            
            let someSecondsAgo = NSDate(timeIntervalSinceNow:-7)
            
            let query = PFQuery(className: "matchRequest")
            query.whereKey("gameName", equalTo: globalGameName)
            query.whereKey("isOffense", equalTo: true)
            query.whereKey("updatedAt", greaterThanOrEqualTo: someSecondsAgo)
            query.orderByDescending("createdAt")
            query.limit = 5
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    self.offense1var = ""
                    self.offense2var = ""
                    self.offense3var = ""
                    self.offense4var = ""
                    self.offense5var = ""
                    self.offense1joined = 2
                    self.offense2joined = 2
                    self.offense3joined = 2
                    self.offense4joined = 2
                    self.offense5joined = 2
                    self.offensePlayersWaiting = 0
                    
                    if let objects = objects {
                        
                        for object in objects {
                            if let username = object["userName"] as? String {
                                self.offenseUserNames.append(username)
                                self.offensePlayersWaiting++
                            }
                        }
                        
                        
                        //clear labels for players who left
                        do {
                            if self.offense1var == "" && self.offense1.text != "..." {
                                self.offense1.text = "..."
                            }
                            if self.offense2var == "" && self.offense2.text != "..." {
                                self.offense2.text = "..."
                            }
                            if self.offense3var == "" && self.offense3.text != "..." {
                                self.offense3.text = "..."
                            }
                            if self.offense4var == "" && self.offense4.text != "..." {
                                self.offense4.text = "..."
                            }
                            if self.offense5var == "" && self.offense5.text != "..." {
                                self.offense5.text = "..."
                            }
                            
                        }
                        
                        //populate offense player vars
                        for offenseUserName in self.offenseUserNames
                        {
                            
                            if self.offense1var == ""  {
                                self.offense1var = offenseUserName
                                self.offense1joined = 0
                            }
                            else if self.offense2var == "" && self.offense1var != offenseUserName  {
                                self.offense2var = offenseUserName
                                self.offense2joined = 0
                            }
                            else if self.offense3var == "" && self.offense1var != offenseUserName && self.offense2var != offenseUserName {
                                self.offense3var = offenseUserName
                                self.offense3joined = 0
                            }
                            else if self.offense4var == "" && self.offense1var != offenseUserName && self.offense2var != offenseUserName && self.offense3var != offenseUserName {
                                self.offense4var = offenseUserName
                                self.offense4joined = 0
                            }
                            else if self.offense5var == "" && self.offense1var != offenseUserName && self.offense2var != offenseUserName && self.offense3var != offenseUserName && self.offense4var != offenseUserName   {
                                self.offense5var = offenseUserName
                                self.offense5joined = 0
                            }
                        }
                        
                        
                        //make changes to UI if necessary
                        do {
                            if self.offense1.text != self.offense1var && self.offense1var != "" {
                                self.offense1.text = self.offense1var
                            }
                            if self.offense2.text != self.offense2var && self.offense2var != ""  {
                                self.offense2.text = self.offense2var
                            }
                            if self.offense3.text != self.offense3var && self.offense3var != ""  {
                                self.offense3.text = self.offense3var
                            }
                            if self.offense4.text != self.offense4var && self.offense4var != ""  {
                                self.offense4.text = self.offense4var
                            }
                            if self.offense5.text != self.offense5var && self.offense5var != ""  {
                                self.offense5.text = self.offense5var
                            }
                        }
                        
                        
                    }
                    
                }
                else {
                    self.refreshTimerCount = 3
                }
                
                let someSecondsAgo2 = NSDate(timeIntervalSinceNow:-7)
                let query2 = PFQuery(className: "matchRequest")
                query2.whereKey("gameName", equalTo: globalGameName)
                query2.whereKey("isOffense", equalTo: false)
                query2.whereKey("updatedAt", greaterThanOrEqualTo: someSecondsAgo2)
                query2.orderByDescending("createdAt")
                query2.limit = 5
                query2.findObjectsInBackgroundWithBlock {
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    if error == nil {
                        self.defense1var = ""
                        self.defense2var = ""
                        self.defense3var = ""
                        self.defense4var = ""
                        self.defense5var = ""
                        self.defense1joined = 2
                        self.defense2joined = 2
                        self.defense3joined = 2
                        self.defense4joined = 2
                        self.defense5joined = 2
                        self.defensePlayersWaiting = 0
                        if let objects = objects  {
                            
                            for object in objects {
                                
                                if let username = object["userName"] as? String {
                                    self.defenseUserNames.append(username)
                                    self.defensePlayersWaiting++
                                }
                            }
                            
                            
                            //clear labels for players who left
                            do {
                                if self.defense1var == "" && self.defense1.text != "..." {
                                    self.defense1.text = "..."
                                }
                                if self.defense2var == "" && self.defense2.text != "..." {
                                    self.defense2.text = "..."
                                }
                                if self.defense3var == "" && self.defense3.text != "..." {
                                    self.defense3.text = "..."
                                }
                                if self.defense4var == "" && self.defense4.text != "..." {
                                    self.defense4.text = "..."
                                }
                                if self.defense5var == "" && self.defense5.text != "..." {
                                    self.defense5.text = "..."
                                }
                                
                            }
                            
                            
                            //populate defense player vars
                            for defenseUserName in self.defenseUserNames
                            {
                                print("defense user names:")
                                print(defenseUserName)
                                
                                if self.defense1var == "" {
                                    self.defense1var = defenseUserName
                                    self.defense1joined = 0
                                }
                                else if self.defense2var == ""  && self.defense1var != defenseUserName {
                                    self.defense2var = defenseUserName
                                    self.defense2joined = 0
                                }
                                else if self.defense3var == "" && self.defense1var != defenseUserName && self.defense2var != defenseUserName {
                                    self.defense3var = defenseUserName
                                    self.defense3joined = 0
                                }
                                else if self.defense4var == "" && self.defense1var != defenseUserName && self.defense2var != defenseUserName && self.defense3var != defenseUserName {
                                    self.defense4var = defenseUserName
                                    self.defense4joined = 0
                                }
                                else if self.defense5var == "" && self.defense1var != defenseUserName && self.defense2var != defenseUserName && self.defense3var != defenseUserName && self.defense4var != defenseUserName {
                                    self.defense5var = defenseUserName
                                    self.defense5joined = 0
                                }
                            }
                            
                            
                            //make changes to UI if necessary
                            do {
                                if self.defense1.text != self.defense1var && self.defense1var != ""  {
                                    self.defense1.text = self.defense1var
                                }
                                if self.defense2.text != self.defense2var && self.defense2var != "" {
                                    self.defense2.text = self.defense2var
                                }
                                if self.defense3.text != self.defense3var && self.defense3var != "" {
                                    self.defense3.text = self.defense3var
                                }
                                if self.defense4.text != self.defense4var && self.defense4var != "" {
                                    self.defense4.text = self.defense4var
                                }
                                if self.defense5.text != self.defense5var && self.defense5var != "" {
                                    self.defense5.text = self.defense5var
                                }
                                
                            }
                            
                            
                        }
                        self.refreshTimerCount = 3
                    }
                    else {
                        self.refreshTimerCount = 3
                    }
                }
            }
        
    }
    
    
    @IBAction func offenseHelpButton(sender: AnyObject) {
        self.displayAlert("Offense team", message: "The offense team tries to sneak past defensive players to capture the flag and return with it to their base before time runs out.  If tagged by a defender, offense players must return to their base before continuing.")
    }
    
    @IBAction func defenseHelpButton(sender: AnyObject) {
        self.displayAlert("Defense team", message: "The defense team tags offense players (forcing them to return to their base) to prevent them from capturing the flag.  Defense wins when time runs out and the flag has not been captured.")
    }
    
    @IBAction func startGameHelpButton(sender: AnyObject) {
        if self.beginButtonState == 0 {
        self.displayAlert("Start game", message: "When all players have joined, one player presses the create game button and sets up the game.  When the game is set up, all other players will be given the option to join.")
        }
        else if self.beginButtonState == 1 {self.displayAlert("Game being created", message: "Please wait, the game is being set up.  You will be given the option to join the game when it's ready.")
        }
        else if self.beginButtonState == 2 {
            self.displayAlert("Join game", message: "When you are ready to start the game, press this button.  The game begins when all players have joined.")
        }
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state == CBPeripheralManagerState.PoweredOn {
            print("Broadcasting...")
            bluetoothOn = true
        } else if peripheral.state == CBPeripheralManagerState.PoweredOff || peripheral.state == CBPeripheralManagerState.Unsupported || peripheral.state == CBPeripheralManagerState.Unauthorized {
            print("Stopped")
            bluetoothOn = false
        }
    }

    func resetGlobalSetupVars() {
        tagPickerSelect = "normal"
        timePickerSelect = "15:00"
        captureTime = 10
        itemsOn = true
        
        itemPricesOffense = [2,7,5,10,7,12,5,8,7,15,7,15]
        itemPricesDefense = [2,7,5,10,7,12,5,8,8,10,12,20]
        itemsDisabledOffense = [false,false,false,false,false,false,false,false,false,false,false,false]
        itemsDisabledDefense = [false,false,false,false,false,false,false,false,false,false,false,false]
        globalOffenseSelect = "normal"
        globalDefenseSelect = "normal"
        
        offenseAbundance = 3
        defenseAbundance = 3
        
        itemModeOn = true
        
        offenseStartingFunds = 5
        defenseStartingFunds = 5
        
    }
    
}
