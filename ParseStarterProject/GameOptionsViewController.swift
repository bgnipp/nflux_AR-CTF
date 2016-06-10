//
//  GameOptionsViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 10/5/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

var tagPickerSelect = "normal"
var timePickerSelect = "15:00"
var captureTime = 10
var itemsOn = true

class GameOptionsViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet var tagPicker: UIPickerView!
    let tagPickerData = ["very high","high","normal","low","very low"]
    var tagThreshold = -73
    
    @IBOutlet var timePicker: UIPickerView!
    let timePickerData = ["60:00","59:00","58:00","57:00","56:00","55:00","54:00","53:00","52:00","51:00","50:00","49:00","48:00","47:00","46:00","45:00","44:00","43:00","42:00","41:00","40:00","39:00","38:00","37:00","36:00","35:00","34:00","33:00","32:00","31:00","30:00","29:00","28:00","27:00","26:00","25:00","24:00","23:00","22:00","21:00","20:00","19:00","18:00","17:00","16:00","15:00","14:00","13:00","12:00","11:00","10:00","9:00","8:00","7:00","6:00","5:00","4:00","3:00"]
    
    
    @IBOutlet var tagButtonOutlet: UIButton!
    @IBOutlet var gameLengthButtonOutlet: UIButton!
    @IBOutlet var captureTimeTextField: UITextField!

    //sounds
    var entersoundlow : AVAudioPlayer?
    var backsound : AVAudioPlayer?
    
    //lock in portrait orientation
    override func shouldAutorotate() -> Bool {
        return false }
    
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController (title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBOutlet var testFeaturesSwitch: UISwitch!
    @IBOutlet var powerupsSwitch: UISwitch!
    
    
    //refresh timer
    var gameOptionsSystemTimer = NSTimer()
    var gameOptionsSystemTimerCount: Int = 3
    
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
        
        //pickers
        self.tagPicker.hidden = true
        self.tagPicker.dataSource = self
        self.tagPicker.delegate = self
        self.timePicker.hidden = true
        self.timePicker.dataSource = self
        self.timePicker.delegate = self
        
        
        //sounds
        if let entersoundlow = self.setupAudioPlayerWithFile("entersoundlow", type:"mp3") {
            self.entersoundlow = entersoundlow
        }
        self.entersoundlow?.volume = 0.8
        if let backsound = self.setupAudioPlayerWithFile("backsound", type:"mp3") {
            self.backsound = backsound
        }
        self.backsound?.volume = 0.8
        
        
        if tagPickerSelect == "normal" {
            self.tagButtonOutlet.setTitle("normal", forState: UIControlState.Normal)
            tagPicker.selectRow(2, inComponent: 0, animated: false)
            print("a")
        }
        else if tagPickerSelect == "very high" {
            self.tagButtonOutlet.setTitle("very high", forState: UIControlState.Normal)
            tagPicker.selectRow(0, inComponent: 0, animated: false)
            
        }
        else if tagPickerSelect == "high" {
            self.tagButtonOutlet.setTitle("high", forState: UIControlState.Normal)
            tagPicker.selectRow(1, inComponent: 0, animated: false)
            print("c")
        }
        else if tagPickerSelect == "low" {
            self.tagButtonOutlet.setTitle("low", forState: UIControlState.Normal)
            tagPicker.selectRow(3, inComponent: 0, animated: false)
            print("d")
        }
        else if tagPickerSelect == "very low" {
            self.tagButtonOutlet.setTitle("very low", forState: UIControlState.Normal)
            tagPicker.selectRow(4, inComponent: 0, animated: false)
            print("e")
        }
        
        
        self.captureTimeTextField.text = String(captureTime)
        
        if itemsOn == false {
            self.powerupsSwitch.on = false
        }
        
        //default
        if timePickerSelect == "15:00" {
            self.gameLengthButtonOutlet.setTitle("15:00", forState: UIControlState.Normal)
            timePicker.selectRow(45, inComponent: 0, animated: false)
            print("f")
        }
        else if timePickerSelect == "60:00" {
            self.gameLengthButtonOutlet.setTitle("60:00", forState: UIControlState.Normal)
            timePicker.selectRow(0, inComponent: 0, animated: false)
            print("g")
        }
        else if timePickerSelect == "59:00" {
            self.gameLengthButtonOutlet.setTitle("59:00", forState: UIControlState.Normal)
            timePicker.selectRow(1, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "58:00" {
            self.gameLengthButtonOutlet.setTitle("58:00", forState: UIControlState.Normal)
            timePicker.selectRow(2, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "57:00" {
            self.gameLengthButtonOutlet.setTitle("57:00", forState: UIControlState.Normal)
            timePicker.selectRow(3, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "56:00" {
            self.gameLengthButtonOutlet.setTitle("56:00", forState: UIControlState.Normal)
            timePicker.selectRow(4, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "55:00" {
            self.gameLengthButtonOutlet.setTitle("55:00", forState: UIControlState.Normal)
            timePicker.selectRow(5, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "54:00" {
            self.gameLengthButtonOutlet.setTitle("54:00", forState: UIControlState.Normal)
            timePicker.selectRow(6, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "53:00" {
            self.gameLengthButtonOutlet.setTitle("53:00", forState: UIControlState.Normal)
            timePicker.selectRow(7, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "52:00" {
            self.gameLengthButtonOutlet.setTitle("52:00", forState: UIControlState.Normal)
            timePicker.selectRow(8, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "51:00" {
            self.gameLengthButtonOutlet.setTitle("51:00", forState: UIControlState.Normal)
            timePicker.selectRow(9, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "50:00" {
            self.gameLengthButtonOutlet.setTitle("50:00", forState: UIControlState.Normal)
            timePicker.selectRow(10, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "49:00" {
            self.gameLengthButtonOutlet.setTitle("49:00", forState: UIControlState.Normal)
            timePicker.selectRow(11, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "48:00" {
            self.gameLengthButtonOutlet.setTitle("48:00", forState: UIControlState.Normal)
            timePicker.selectRow(12, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "47:00" {
            self.gameLengthButtonOutlet.setTitle("47:00", forState: UIControlState.Normal)
            timePicker.selectRow(13, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "46:00" {
            self.gameLengthButtonOutlet.setTitle("46:00", forState: UIControlState.Normal)
            timePicker.selectRow(14, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "45:00" {
            self.gameLengthButtonOutlet.setTitle("45:00", forState: UIControlState.Normal)
            timePicker.selectRow(15, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "44:00" {
            self.gameLengthButtonOutlet.setTitle("44:00", forState: UIControlState.Normal)
            timePicker.selectRow(16, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "43:00" {
            self.gameLengthButtonOutlet.setTitle("43:00", forState: UIControlState.Normal)
            timePicker.selectRow(17, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "42:00" {
            self.gameLengthButtonOutlet.setTitle("42:00", forState: UIControlState.Normal)
            timePicker.selectRow(18, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "41:00" {
            self.gameLengthButtonOutlet.setTitle("41:00", forState: UIControlState.Normal)
            timePicker.selectRow(19, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "40:00" {
            self.gameLengthButtonOutlet.setTitle("40:00", forState: UIControlState.Normal)
            timePicker.selectRow(20, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "39:00" {
            self.gameLengthButtonOutlet.setTitle("39:00", forState: UIControlState.Normal)
            timePicker.selectRow(21, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "38:00" {
            self.gameLengthButtonOutlet.setTitle("38:00", forState: UIControlState.Normal)
            timePicker.selectRow(22, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "37:00" {
            self.gameLengthButtonOutlet.setTitle("37:00", forState: UIControlState.Normal)
            timePicker.selectRow(23, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "36:00" {
            self.gameLengthButtonOutlet.setTitle("36:00", forState: UIControlState.Normal)
            timePicker.selectRow(24, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "35:00" {
            self.gameLengthButtonOutlet.setTitle("35:00", forState: UIControlState.Normal)
            timePicker.selectRow(25, inComponent: 0, animated: false)
        }
        if timePickerSelect == "34:00" {
            self.gameLengthButtonOutlet.setTitle("34:00", forState: UIControlState.Normal)
            timePicker.selectRow(26, inComponent: 0, animated: false)
        }
        if timePickerSelect == "33:00" {
            self.gameLengthButtonOutlet.setTitle("33:00", forState: UIControlState.Normal)
            timePicker.selectRow(27, inComponent: 0, animated: false)
        }
        if timePickerSelect == "32:00" {
            self.gameLengthButtonOutlet.setTitle("32:00", forState: UIControlState.Normal)
            timePicker.selectRow(28, inComponent: 0, animated: false)
        }
        if timePickerSelect == "31:00" {
            self.gameLengthButtonOutlet.setTitle("31:00", forState: UIControlState.Normal)
            timePicker.selectRow(29, inComponent: 0, animated: false)
        }
        if timePickerSelect == "30:00" {
            self.gameLengthButtonOutlet.setTitle("30:00", forState: UIControlState.Normal)
            timePicker.selectRow(30, inComponent: 0, animated: false)
        }
        if timePickerSelect == "29:00" {
            self.gameLengthButtonOutlet.setTitle("29:00", forState: UIControlState.Normal)
            timePicker.selectRow(31, inComponent: 0, animated: false)
        }
        if timePickerSelect == "28:00" {
            self.gameLengthButtonOutlet.setTitle("28:00", forState: UIControlState.Normal)
            timePicker.selectRow(32, inComponent: 0, animated: false)
        }
        if timePickerSelect == "27:00" {
            self.gameLengthButtonOutlet.setTitle("27:00", forState: UIControlState.Normal)
            timePicker.selectRow(33, inComponent: 0, animated: false)
        }
        if timePickerSelect == "26:00" {
            self.gameLengthButtonOutlet.setTitle("26:00", forState: UIControlState.Normal)
            timePicker.selectRow(34, inComponent: 0, animated: false)
        }
        if timePickerSelect == "25:00" {
            self.gameLengthButtonOutlet.setTitle("25:00", forState: UIControlState.Normal)
            timePicker.selectRow(35, inComponent: 0, animated: false)
        }
        if timePickerSelect == "24:00" {
            self.gameLengthButtonOutlet.setTitle("24:00", forState: UIControlState.Normal)
            timePicker.selectRow(36, inComponent: 0, animated: false)
        }
        if timePickerSelect == "23:00" {
            self.gameLengthButtonOutlet.setTitle("23:00", forState: UIControlState.Normal)
            timePicker.selectRow(37, inComponent: 0, animated: false)
        }
        if timePickerSelect == "22:00" {
            self.gameLengthButtonOutlet.setTitle("22:00", forState: UIControlState.Normal)
            timePicker.selectRow(38, inComponent: 0, animated: false)
        }
        if timePickerSelect == "21:00" {
            self.gameLengthButtonOutlet.setTitle("21:00", forState: UIControlState.Normal)
            timePicker.selectRow(39, inComponent: 0, animated: false)
        }
        if timePickerSelect == "20:00" {
            self.gameLengthButtonOutlet.setTitle("20:00", forState: UIControlState.Normal)
            timePicker.selectRow(40, inComponent: 0, animated: false)
        }
        if timePickerSelect == "19:00" {
            self.gameLengthButtonOutlet.setTitle("19:00", forState: UIControlState.Normal)
            timePicker.selectRow(41, inComponent: 0, animated: false)
        }
        if timePickerSelect == "18:00" {
            self.gameLengthButtonOutlet.setTitle("18:00", forState: UIControlState.Normal)
            timePicker.selectRow(42, inComponent: 0, animated: false)
        }
        if timePickerSelect == "17:00" {
            self.gameLengthButtonOutlet.setTitle("17:00", forState: UIControlState.Normal)
            timePicker.selectRow(43, inComponent: 0, animated: false)
        }
        if timePickerSelect == "16:00" {
            self.gameLengthButtonOutlet.setTitle("16:00", forState: UIControlState.Normal)
            timePicker.selectRow(44, inComponent: 0, animated: false)
        }
        if timePickerSelect == "14:00" {
            self.gameLengthButtonOutlet.setTitle("14:00", forState: UIControlState.Normal)
            timePicker.selectRow(46, inComponent: 0, animated: false)
        }
        if timePickerSelect == "13:00" {
            self.gameLengthButtonOutlet.setTitle("13:00", forState: UIControlState.Normal)
            timePicker.selectRow(47, inComponent: 0, animated: false)
        }
        if timePickerSelect == "12:00" {
            self.gameLengthButtonOutlet.setTitle("12:00", forState: UIControlState.Normal)
            timePicker.selectRow(48, inComponent: 0, animated: false)
        }
        if timePickerSelect == "11:00" {
            self.gameLengthButtonOutlet.setTitle("11:00", forState: UIControlState.Normal)
            timePicker.selectRow(49, inComponent: 0, animated: false)
        }
        if timePickerSelect == "10:00" {
            self.gameLengthButtonOutlet.setTitle("10:00", forState: UIControlState.Normal)
            timePicker.selectRow(50, inComponent: 0, animated: false)
        }
        if timePickerSelect == "9:00" {
            self.gameLengthButtonOutlet.setTitle("9:00", forState: UIControlState.Normal)
            timePicker.selectRow(51, inComponent: 0, animated: false)
        }
        if timePickerSelect == "8:00" {
            self.gameLengthButtonOutlet.setTitle("8:00", forState: UIControlState.Normal)
            timePicker.selectRow(52, inComponent: 0, animated: false)
        }
        if timePickerSelect == "7:00" {
            self.gameLengthButtonOutlet.setTitle("7:00", forState: UIControlState.Normal)
            timePicker.selectRow(53, inComponent: 0, animated: false)
        }
        if timePickerSelect == "6:00" {
            self.gameLengthButtonOutlet.setTitle("6:00", forState: UIControlState.Normal)
            timePicker.selectRow(54, inComponent: 0, animated: false)
        }
        if timePickerSelect == "5:00" {
            self.gameLengthButtonOutlet.setTitle("5:00", forState: UIControlState.Normal)
            timePicker.selectRow(55, inComponent: 0, animated: false)
        }
        if timePickerSelect == "4:00" {
            self.gameLengthButtonOutlet.setTitle("4:00", forState: UIControlState.Normal)
            timePicker.selectRow(56, inComponent: 0, animated: false)
        }
        if timePickerSelect == "3:00" {
            self.gameLengthButtonOutlet.setTitle("3:00", forState: UIControlState.Normal)
            timePicker.selectRow(57, inComponent: 0, animated: false)
        }
        


        //hide keyboard when tap on background
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        //numpad keyboard 
//        self.gameLengthTextField.keyboardType = UIKeyboardType.NumberPad
        self.captureTimeTextField.keyboardType = UIKeyboardType.NumberPad
    
        //switch off color
        self.testFeaturesSwitch.tintColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.testFeaturesSwitch.backgroundColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.testFeaturesSwitch.layer.cornerRadius = 16.0
        self.powerupsSwitch.tintColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.powerupsSwitch.backgroundColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.powerupsSwitch.layer.cornerRadius = 16.0
        
        //background colors
        if globalIsOffense == false {
            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
        }
        
        if globalIsOffense == true {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
        }
    
        //start refresh timer
        self.gameOptionsSystemTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("gameOptionsSystemTimerUpdate"), userInfo: nil, repeats: true)
        self.gameOptionsSystemTimer.tolerance = 0.3
        
        //hide keyboard
//        self.gameLengthTextField.delegate = self
        self.captureTimeTextField.delegate = self
//
        self.captureTimeTextField.text = String(captureTime)
//        self.gameLengthTextField.text = "1000"
    }

    @IBAction func enterButton(sender: AnyObject) {
    
        //alert if tag threshold and game length null
        if captureTimeTextField.text == "" {
        displayAlert("Error", message: "Missing fields")
        }
    
        else {
        
            var query = PFQuery(className:"gameInfo")
            query.getObjectInBackgroundWithId(gameInfoObjectID) {
                (gameInfo: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    self.displayAlert("Error", message: "Trying to connect to network..")
                    
                    query.getObjectInBackgroundWithId(gameInfoObjectID) {
                        (gameInfo: PFObject?, error: NSError?) -> Void in
                        if error != nil {
                            self.displayAlert("Error", message: "Network connection issues. Please make sure you airplane mode is disabled and you have an active network connection, and restart the game.")
                            
                        }
                        else if let gameInfo = gameInfo {
                            
                            if tagPickerSelect == "very low" {
//                                self.tagThreshold = -67
                                self.tagThreshold = -40
                            }
                            if tagPickerSelect == "low" {
                                self.tagThreshold = -70
                            }
                            if tagPickerSelect == "normal" {
                                self.tagThreshold = -73
                            }
                            if tagPickerSelect == "high" {
                                self.tagThreshold = -75
                            }
                            if tagPickerSelect == "very high" {
                                self.tagThreshold = -77
                            }
                            
                            var gameLength = 900
                            
                            if timePickerSelect == "60:00" { gameLength = 2160 }
                            if timePickerSelect == "59:00" { gameLength = 3540 }
                            if timePickerSelect == "58:00" { gameLength = 3480 }
                            if timePickerSelect == "57:00" { gameLength = 3420 }
                            if timePickerSelect == "56:00" { gameLength = 3360 }
                            if timePickerSelect == "55:00" { gameLength = 3300 }
                            if timePickerSelect == "54:00" { gameLength = 3240 }
                            if timePickerSelect == "53:00" { gameLength = 3180 }
                            if timePickerSelect == "52:00" { gameLength = 3120 }
                            if timePickerSelect == "51:00" { gameLength = 3060 }
                            if timePickerSelect == "50:00" { gameLength = 3000 }
                            if timePickerSelect == "49:00" { gameLength = 2940 }
                            if timePickerSelect == "48:00" { gameLength = 2880 }
                            if timePickerSelect == "47:00" { gameLength = 2820 }
                            if timePickerSelect == "46:00" { gameLength = 2760 }
                            if timePickerSelect == "45:00" { gameLength = 2700 }
                            if timePickerSelect == "44:00" { gameLength = 2640 }
                            if timePickerSelect == "43:00" { gameLength = 2580 }
                            if timePickerSelect == "42:00" { gameLength = 2520 }
                            if timePickerSelect == "41:00" { gameLength = 2460 }
                            if timePickerSelect == "40:00" { gameLength = 2400 }
                            if timePickerSelect == "39:00" { gameLength = 2340 }
                            if timePickerSelect == "38:00" { gameLength = 2280 }
                            if timePickerSelect == "37:00" { gameLength = 2220 }
                            if timePickerSelect == "36:00" { gameLength = 2160 }
                            if timePickerSelect == "35:00" { gameLength = 2100 }
                            if timePickerSelect == "34:00" { gameLength = 2040 }
                            if timePickerSelect == "33:00" { gameLength = 1980 }
                            if timePickerSelect == "32:00" { gameLength = 1920 }
                            if timePickerSelect == "31:00" { gameLength = 1860 }
                            if timePickerSelect == "30:00" { gameLength = 1800 }
                            if timePickerSelect == "29:00" { gameLength = 1740 }
                            if timePickerSelect == "28:00" { gameLength = 1680 }
                            if timePickerSelect == "27:00" { gameLength = 1620 }
                            if timePickerSelect == "26:00" { gameLength = 1560 }
                            if timePickerSelect == "25:00" { gameLength = 1500 }
                            if timePickerSelect == "24:00" { gameLength = 1440 }
                            if timePickerSelect == "23:00" { gameLength = 1380 }
                            if timePickerSelect == "22:00" { gameLength = 1320 }
                            if timePickerSelect == "21:00" { gameLength = 1260 }
                            if timePickerSelect == "20:00" { gameLength = 1200 }
                            if timePickerSelect == "19:00" { gameLength = 1140 }
                            if timePickerSelect == "18:00" { gameLength = 1080 }
                            if timePickerSelect == "17:00" { gameLength = 1020 }
                            if timePickerSelect == "16:00" { gameLength = 960 }
                            if timePickerSelect == "15:00" { gameLength = 900 }
                            if timePickerSelect == "14:00" { gameLength = 840 }
                            if timePickerSelect == "13:00" { gameLength = 780 }
                            if timePickerSelect == "12:00" { gameLength = 720 }
                            if timePickerSelect == "11:00" { gameLength = 660 }
                            if timePickerSelect == "10:00" { gameLength = 600 }
                            if timePickerSelect == "9:00" { gameLength = 540 }
                            if timePickerSelect == "8:00" { gameLength = 480 }
                            if timePickerSelect == "7:00" { gameLength = 420 }
                            if timePickerSelect == "6:00" { gameLength = 360 }
                            if timePickerSelect == "5:00" { gameLength = 300 }
                            if timePickerSelect == "4:00" { gameLength = 240 }
                            if timePickerSelect == "3:00" { gameLength = 180 }
                            

                            gameInfo["tagThreshold"] = self.tagThreshold
                            gameInfo["gameLength"] = Int(gameLength)
                            gameInfo["captureTime"] = Int(self.captureTimeTextField.text!)
                            captureTime = Int(self.captureTimeTextField.text!)!
                            let testFeaturesOn = self.testFeaturesSwitch.on
                            gameInfo["testFeaturesOn"] = testFeaturesOn
                            itemsOn = self.powerupsSwitch.on
                            gameInfo["powerupsOn"] = itemsOn
                            gameInfo.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                                if error == nil {
                                    self.entersoundlow?.play()
                                    
                                    if itemsOn == false {
                                    self.gameOptionsSystemTimer.invalidate()
                                    self.performSegueWithIdentifier("showPointLocationViewController", sender: nil)
                                    }
                                    if itemsOn == true {
                                    self.gameOptionsSystemTimer.invalidate()
                                        self.performSegueWithIdentifier("showItemOptionsViewControllerFromGameOptionsViewController", sender: nil)
                                    }
                                    
                                }
                                else if error != nil {
                                    gameInfo.saveEventually { (success: Bool, error: NSError?) -> Void in
                                        if error == nil {
                                            self.entersoundlow?.play()
                                            
                                            if itemsOn == false {
                                                self.gameOptionsSystemTimer.invalidate()
                                                self.performSegueWithIdentifier("showPointLocationViewController", sender: nil)
                                            }
                                            if itemsOn == true {
                                                self.gameOptionsSystemTimer.invalidate()
                                            self.performSegueWithIdentifier("showItemOptionsViewControllerFromGameOptionsViewController", sender: nil)
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                    }

                    
                } else if let gameInfo = gameInfo {
                    
                    if tagPickerSelect == "very low" {
//                        self.tagThreshold = -67
                        self.tagThreshold = -40
                    }
                    if tagPickerSelect == "low" {
                        self.tagThreshold = -70
                    }
                    if tagPickerSelect == "normal" {
                        self.tagThreshold = -73
                    }
                    if tagPickerSelect == "high" {
                        self.tagThreshold = -75
                    }
                    if tagPickerSelect == "very high" {
                        self.tagThreshold = -77
                    }
                    
                    var gameLength = 900
                    
                    if timePickerSelect == "60:00" { gameLength = 2160 }
                    if timePickerSelect == "59:00" { gameLength = 3540 }
                    if timePickerSelect == "58:00" { gameLength = 3480 }
                    if timePickerSelect == "57:00" { gameLength = 3420 }
                    if timePickerSelect == "56:00" { gameLength = 3360 }
                    if timePickerSelect == "55:00" { gameLength = 3300 }
                    if timePickerSelect == "54:00" { gameLength = 3240 }
                    if timePickerSelect == "53:00" { gameLength = 3180 }
                    if timePickerSelect == "52:00" { gameLength = 3120 }
                    if timePickerSelect == "51:00" { gameLength = 3060 }
                    if timePickerSelect == "50:00" { gameLength = 3000 }
                    if timePickerSelect == "49:00" { gameLength = 2940 }
                    if timePickerSelect == "48:00" { gameLength = 2880 }
                    if timePickerSelect == "47:00" { gameLength = 2820 }
                    if timePickerSelect == "46:00" { gameLength = 2760 }
                    if timePickerSelect == "45:00" { gameLength = 2700 }
                    if timePickerSelect == "44:00" { gameLength = 2640 }
                    if timePickerSelect == "43:00" { gameLength = 2580 }
                    if timePickerSelect == "42:00" { gameLength = 2520 }
                    if timePickerSelect == "41:00" { gameLength = 2460 }
                    if timePickerSelect == "40:00" { gameLength = 2400 }
                    if timePickerSelect == "39:00" { gameLength = 2340 }
                    if timePickerSelect == "38:00" { gameLength = 2280 }
                    if timePickerSelect == "37:00" { gameLength = 2220 }
                    if timePickerSelect == "36:00" { gameLength = 2160 }
                    if timePickerSelect == "35:00" { gameLength = 2100 }
                    if timePickerSelect == "34:00" { gameLength = 2040 }
                    if timePickerSelect == "33:00" { gameLength = 1980 }
                    if timePickerSelect == "32:00" { gameLength = 1920 }
                    if timePickerSelect == "31:00" { gameLength = 1860 }
                    if timePickerSelect == "30:00" { gameLength = 1800 }
                    if timePickerSelect == "29:00" { gameLength = 1740 }
                    if timePickerSelect == "28:00" { gameLength = 1680 }
                    if timePickerSelect == "27:00" { gameLength = 1620 }
                    if timePickerSelect == "26:00" { gameLength = 1560 }
                    if timePickerSelect == "25:00" { gameLength = 1500 }
                    if timePickerSelect == "24:00" { gameLength = 1440 }
                    if timePickerSelect == "23:00" { gameLength = 1380 }
                    if timePickerSelect == "22:00" { gameLength = 1320 }
                    if timePickerSelect == "21:00" { gameLength = 1260 }
                    if timePickerSelect == "20:00" { gameLength = 1200 }
                    if timePickerSelect == "19:00" { gameLength = 1140 }
                    if timePickerSelect == "18:00" { gameLength = 1080 }
                    if timePickerSelect == "17:00" { gameLength = 1020 }
                    if timePickerSelect == "16:00" { gameLength = 960 }
                    if timePickerSelect == "15:00" { gameLength = 900 }
                    if timePickerSelect == "14:00" { gameLength = 840 }
                    if timePickerSelect == "13:00" { gameLength = 780 }
                    if timePickerSelect == "12:00" { gameLength = 720 }
                    if timePickerSelect == "11:00" { gameLength = 660 }
                    if timePickerSelect == "10:00" { gameLength = 600 }
                    if timePickerSelect == "9:00" { gameLength = 540 }
                    if timePickerSelect == "8:00" { gameLength = 480 }
                    if timePickerSelect == "7:00" { gameLength = 420 }
                    if timePickerSelect == "6:00" { gameLength = 360 }
                    if timePickerSelect == "5:00" { gameLength = 300 }
                    if timePickerSelect == "4:00" { gameLength = 240 }
                    if timePickerSelect == "3:00" { gameLength = 180 }
                    
                    gameInfo["tagThreshold"] = self.tagThreshold
                    gameInfo["gameLength"] = Int(gameLength)
                    gameInfo["captureTime"] = Int(self.captureTimeTextField.text!)
                    captureTime = Int(self.captureTimeTextField.text!)!
                    let testFeaturesOn = self.testFeaturesSwitch.on
                    gameInfo["testFeaturesOn"] = testFeaturesOn
                    itemsOn = self.powerupsSwitch.on
                    gameInfo["powerupsOn"] = itemsOn
                    gameInfo.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                        if error == nil {
                    
                        self.entersoundlow?.play()
                            
                            if itemsOn == false {
                                self.gameOptionsSystemTimer.invalidate()
                                self.performSegueWithIdentifier("showPointLocationViewController", sender: nil)
                            }
                            if itemsOn == true {
                                self.gameOptionsSystemTimer.invalidate()
                                self.performSegueWithIdentifier("showItemOptionsViewControllerFromGameOptionsViewController", sender: nil)
                            }
                            
                        }
                        else if error != nil {
                            gameInfo.saveEventually { (success: Bool, error: NSError?) -> Void in
                                if error == nil {
                                    self.entersoundlow?.play()
                             
                                    if itemsOn == false {
                                        self.gameOptionsSystemTimer.invalidate()
                                        self.performSegueWithIdentifier("showPointLocationViewController", sender: nil)
                                    }
                                    if itemsOn == true  {
                                        self.gameOptionsSystemTimer.invalidate()
                                        self.performSegueWithIdentifier("showItemOptionsViewControllerFromGameOptionsViewController", sender: nil)
                                    }
                                }
                            }
                        }
                    }
                
                }
            }

        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // Dismiss the keyboard when the user taps the "Return" key or its equivalent
    // while editing a text field.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    //maximum text field length
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
//        replacementString string: String) -> Bool
//    {
//        let maxLength = 2
//        let currentString: NSString = self.gameLengthTextField.text!
//        let newString: NSString =
//        currentString.stringByReplacingCharactersInRange(range, withString: string)
//        return newString.length <= maxLength
//    }
    
    
    @IBAction func cancelButton(sender: AnyObject) {
        
        let query = PFQuery(className:"gameInfo")
        query.getObjectInBackgroundWithId(gameInfoObjectID) {
            (gameInfo: PFObject?, error: NSError?) -> Void in
            if error != nil {
                self.displayAlert("Error", message: "Network error, try again.")
                    }
                    else if let gameInfo = gameInfo {
                        gameInfo["cancelled"] = globalUserName
                        gameInfo.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                            if error == nil {
                                
                                self.gameOptionsSystemTimer.invalidate()
                                self.backsound?.play()
                            self.performSegueWithIdentifier("showPairViewControllerFromGameOptionsViewController", sender: nil)
                            }
                            else if error != nil {
                            self.displayAlert("Error", message: "Network error, try again.")
                            }
                }
            }
        }
    }
    
    //system timer
    func gameOptionsSystemTimerUpdate() {
        if(gameOptionsSystemTimerCount > 0)
        {
            gameOptionsSystemTimerCount--
        }
        if(gameOptionsSystemTimerCount == 0)
        {
            gameOptionsSystemTimerCount = 3
            
            //post heartbeat to matchRequest object
            let heartbeatQuery = PFQuery(className:"matchRequest")
            heartbeatQuery.getObjectInBackgroundWithId(globalMatchRequestObjectID) {
                (matchRequest: PFObject?, error: NSError?) -> Void in
                if error == nil {
                    let rand: String = String(arc4random_uniform(999999))
                    matchRequest!["heartbeat"] = rand
                    matchRequest?.saveEventually()
                }
            }
            
            
            //post heartbeat to gameInfo object
            let heartbeatQuery2 = PFQuery(className:"gameInfo")
            heartbeatQuery2.getObjectInBackgroundWithId(gameInfoObjectID) {
                (gameInfo: PFObject?, error: NSError?) -> Void in
                if error == nil {
                    let rand: String = String(arc4random_uniform(999999))
                    gameInfo!["heartbeat"] = rand
                    gameInfo?.saveEventually()
                }
            }
            
        }
    }
    
    //hide keyboard when background is tapped
    func dismissKeyboard() {
        view.endEditing(true)
        self.tagPicker.hidden = true
        self.timePicker.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
    }
    
    @IBAction func tagHelpButton(sender: AnyObject) {
        displayAlert("Tag sensitivity", message: "Sets how close an offense player must be to an oppoent to tag them")
    }
    
    @IBAction func gameLengthHelpButton(sender: AnyObject) {
        displayAlert("Game length", message: "The length of the game (in seconds).  If offense doesn't capture the flag before time runs out, defense wins")
    }
    
    @IBAction func captureTimeHelpButton(sender: AnyObject) {
        displayAlert("Capture time", message: "The number of seconds an offense player must stay within the flag region in order to capture the flag")
    }
    
    
    @IBAction func itemsHelpButton(sender: AnyObject) {
        displayAlert("items", message: "Examples of items include scans (reveals opponents' locations, bombs (tags opponents in a certain area of the map), mines, etc")
    }
    
    
    //picker
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return tagPickerData.count
        }
        else {
            return timePickerData.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return tagPickerData[row]
        }
        else {
            return timePickerData[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            tagButtonOutlet.setTitle(tagPickerData[row], forState: UIControlState.Normal)
            tagPickerSelect = tagPickerData[row]
    
            }
                else {
            gameLengthButtonOutlet.setTitle(timePickerData[row], forState: UIControlState.Normal)
            timePickerSelect = timePickerData[row]
            }
    }

    @IBAction func tagButton(sender: AnyObject) {
        if self.tagPicker.hidden == false {
            self.tagPicker.hidden = true
        }
        else {
            self.tagPicker.hidden = false
        }
    }

    @IBAction func gameLengthButton(sender: AnyObject) {
        if self.timePicker.hidden == false {
            self.timePicker.hidden = true
        }
        else {
            self.timePicker.hidden = false
        }
    }

    
}
