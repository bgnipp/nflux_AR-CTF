//
//  ItemOptionsViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 11/19/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

var itemPricesOffense = [2,7,5,10,7,12,5,8,7,15,7,15]
var itemPricesDefense = [2,7,5,10,7,12,5,8,8,10,12,20]
var itemsDisabledOffense = [false,false,false,false,false,false,false,false,false,false,false,false]
var itemsDisabledDefense = [false,false,false,false,false,false,false,false,false,false,false,false]
var globalOffenseSelect = "normal"
var globalDefenseSelect = "normal"

var offenseAbundance = 3
var defenseAbundance = 3

var itemModeOn = true

var offenseStartingFunds: Int = 5
var defenseStartingFunds: Int = 5

class ItemOptionsViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var offenseStartingFundsTextField: UITextField!
    @IBOutlet var defenseStartingFundsTextField: UITextField!
    @IBOutlet var itemModeSwitch: UISwitch!
    @IBOutlet var offenseButtonLabel: UIButton!
    @IBOutlet var defenseButtonLabel: UIButton!
    
    
    @IBOutlet var offensePicker: UIPickerView!
    let offenseData = ["very high","high","normal","low","very low"]
    
    @IBOutlet var defensePicker: UIPickerView!
    let defenseData = ["very high","high","normal","low","very low"]
    
    
    //refresh timer
    var itemOptionsSystemTimer = NSTimer()
    var itemOptionsSystemTimerCount: Int = 3
    

    //set up UI alerts
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController (title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //lock in portrait orientation
    override func shouldAutorotate() -> Bool {
        return false }
    
    //hide keyboard when background is tapped
    func dismissKeyboard() {
        view.endEditing(true)
        self.offensePicker.hidden = true
        self.defensePicker.hidden = true
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
    
    //sounds
    var entersoundlow : AVAudioPlayer?
    var backsound: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //pickers
        self.offensePicker.hidden = true
        self.offensePicker.dataSource = self
        self.offensePicker.delegate = self
        self.defensePicker.hidden = true
        self.defensePicker.dataSource = self
        self.defensePicker.delegate = self
        
        //hide keyboard when tap on background
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        //numpad keyboard
        self.offenseStartingFundsTextField.keyboardType = UIKeyboardType.NumberPad
        self.defenseStartingFundsTextField.keyboardType = UIKeyboardType.NumberPad
        
        //sounds
        if let entersoundlow = self.setupAudioPlayerWithFile("entersoundlow", type:"mp3") {
            self.entersoundlow = entersoundlow
        }
        self.entersoundlow?.volume = 0.8
        if let backsound = self.setupAudioPlayerWithFile("backsound", type:"mp3") {
            self.backsound = backsound
        }
        self.backsound?.volume = 0.8
        
        //background colors
        if globalIsOffense == false {
            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
        }
        
        if globalIsOffense == true {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
        }
        
        if offenseAbundance == 3 {
            self.offenseButtonLabel.setTitle("normal", forState: UIControlState.Normal)
            offensePicker.selectRow(2, inComponent: 0, animated: false)
        }
        else if offenseAbundance == 2 {
            self.offenseButtonLabel.setTitle("low", forState: UIControlState.Normal)
            offensePicker.selectRow(3, inComponent: 0, animated: false)
        }
        else if offenseAbundance == 1 {
            self.offenseButtonLabel.setTitle("very low", forState: UIControlState.Normal)
            offensePicker.selectRow(4, inComponent: 0, animated: false)
        }
        else if offenseAbundance == 4 {
            self.offenseButtonLabel.setTitle("high", forState: UIControlState.Normal)
            offensePicker.selectRow(1, inComponent: 0, animated: false)
        }
        else if offenseAbundance == 5 {
            self.offenseButtonLabel.setTitle("very high", forState: UIControlState.Normal)
            offensePicker.selectRow(0, inComponent: 0, animated: false)
        }
        
        if defenseAbundance == 3 {
            self.defenseButtonLabel.setTitle("normal", forState: UIControlState.Normal)
            defensePicker.selectRow(2, inComponent: 0, animated: false)
        }
        else if defenseAbundance == 2 {
            self.defenseButtonLabel.setTitle("low", forState: UIControlState.Normal)
            defensePicker.selectRow(3, inComponent: 0, animated: false)
        }
        else if defenseAbundance == 1 {
            self.defenseButtonLabel.setTitle("very low", forState: UIControlState.Normal)
            defensePicker.selectRow(4, inComponent: 0, animated: false)
        }
        else if defenseAbundance == 4 {
            self.defenseButtonLabel.setTitle("high", forState: UIControlState.Normal)
            defensePicker.selectRow(1, inComponent: 0, animated: false)
        }
        else if defenseAbundance == 5 {
            self.defenseButtonLabel.setTitle("very high", forState: UIControlState.Normal)
            defensePicker.selectRow(0, inComponent: 0, animated: false)
        }
        
        self.offenseStartingFundsTextField.text = String(offenseStartingFunds)
        self.defenseStartingFundsTextField.text = String(defenseStartingFunds)
        
        self.itemModeSwitch.on = itemModeOn
        
        
        //switch off color
        self.itemModeSwitch.tintColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.itemModeSwitch.backgroundColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.itemModeSwitch.layer.cornerRadius = 16.0
        
        //start refresh timer
        self.itemOptionsSystemTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("itemOptionsSystemTimerUpdate"), userInfo: nil, repeats: true)
        self.itemOptionsSystemTimer.tolerance = 0.3
        
        //hide keyboard
        self.offenseStartingFundsTextField.delegate = self
        self.defenseStartingFundsTextField.delegate = self
        
        self.offenseStartingFundsTextField.text = String(offenseStartingFunds)
        self.defenseStartingFundsTextField.text = String(defenseStartingFunds)
        
    }
    

    // Dismiss the keyboard when the user taps the "Return" key or its equivalent
    // while editing a text field.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func enterButton(sender: AnyObject) {
        
        

            //alert if fields are null
            if offenseStartingFundsTextField.text == "" || defenseStartingFundsTextField.text == "" {
                displayAlert("Error", message: "Missing fields")
            }
                
            else {
                
                var query = PFQuery(className:"gameInfo")
                query.getObjectInBackgroundWithId(gameInfoObjectID) {
                    (gameInfo: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        self.displayAlert("Error", message: "Network error, retrying..")
                        
                        query.getObjectInBackgroundWithId(gameInfoObjectID) {
                            (gameInfo: PFObject?, error: NSError?) -> Void in
                            if error != nil {
                                self.displayAlert("Error", message: "Network connection issues. Please make sure you airplane mode is disabled and you have an active network connection, and restart the game.")
                                
                            }
                            else if let gameInfo = gameInfo {
                                
                                if globalOffenseSelect == "very low" {
                                    offenseAbundance = 1
                                }
                                if globalOffenseSelect == "low" {
                                    offenseAbundance = 2
                                }
                                if globalOffenseSelect == "normal" {
                                    offenseAbundance = 3
                                }
                                if globalOffenseSelect == "high" {
                                    offenseAbundance = 4
                                }
                                if globalOffenseSelect == "very high" {
                                    offenseAbundance = 5
                                }
                                if globalDefenseSelect == "very low" {
                                    defenseAbundance = 1
                                }
                                if globalDefenseSelect == "low" {
                                    defenseAbundance = 2
                                }
                                if globalDefenseSelect == "normal" {
                                    defenseAbundance = 3
                                }
                                if globalDefenseSelect == "high" {
                                    defenseAbundance = 4
                                }
                                if globalDefenseSelect == "very high" {
                                    defenseAbundance = 5
                                }
                                
                                
                                gameInfo["offenseStartingFunds"] = Int(self.offenseStartingFundsTextField.text!)
                                offenseStartingFunds = Int(self.offenseStartingFundsTextField.text!)!
                                gameInfo["defenseStartingFunds"] = Int(self.defenseStartingFundsTextField.text!)
                                defenseStartingFunds = Int(self.defenseStartingFundsTextField.text!)!
                                gameInfo["itemAbundanceOffense"] = offenseAbundance
                                gameInfo["itemAbundanceDefense"] = defenseAbundance
                                gameInfo["itemPricesOffense"] = itemPricesOffense
                                gameInfo["itemPricesDefense"] = itemPricesDefense
                                gameInfo["itemsDisabledOffense"] = itemsDisabledOffense
                                gameInfo["itemsDisabledDefense"] = itemsDisabledDefense
                                itemModeOn = self.itemModeSwitch.on
                                gameInfo["itemModeOn"] = itemModeOn
                                gameInfo.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                                    if error == nil {
                                        self.entersoundlow?.play()
                                        
                                        self.itemOptionsSystemTimer.invalidate()
                                        self.performSegueWithIdentifier("showPointLocationViewControllerFromItemOptionsViewController", sender: nil)
                                    }
                                    else if error != nil {
                                        gameInfo.saveEventually { (success: Bool, error: NSError?) -> Void in
                                            if error == nil {
                                                self.entersoundlow?.play()
                                                self.itemOptionsSystemTimer.invalidate()
                                                self.performSegueWithIdentifier("showPointLocationViewControllerFromItemOptionsViewController", sender: nil)
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
                        
                        
                    } else if let gameInfo = gameInfo {
                        
                        if globalOffenseSelect == "very low" {
                            offenseAbundance = 1
                        }
                        if globalOffenseSelect == "low" {
                            offenseAbundance = 2
                        }
                        if globalOffenseSelect == "normal" {
                            offenseAbundance = 3
                        }
                        if globalOffenseSelect == "high" {
                            offenseAbundance = 4
                        }
                        if globalOffenseSelect == "very high" {
                            offenseAbundance = 5
                        }
                        if globalDefenseSelect == "very low" {
                            defenseAbundance = 1
                        }
                        if globalDefenseSelect == "low" {
                            defenseAbundance = 2
                        }
                        if globalDefenseSelect == "normal" {
                            defenseAbundance = 3
                        }
                        if globalDefenseSelect == "high" {
                            defenseAbundance = 4
                        }
                        if globalDefenseSelect == "very high" {
                            defenseAbundance = 5
                        }
                        
                        gameInfo["offenseStartingFunds"] = Int(self.offenseStartingFundsTextField.text!)
                        offenseStartingFunds = Int(self.offenseStartingFundsTextField.text!)!
                        gameInfo["defenseStartingFunds"] = Int(self.defenseStartingFundsTextField.text!)
                        defenseStartingFunds = Int(self.defenseStartingFundsTextField.text!)!
                        gameInfo["itemAbundanceOffense"] = offenseAbundance
                        gameInfo["itemAbundanceDefense"] = defenseAbundance
                        gameInfo["itemPricesOffense"] = itemPricesOffense
                        gameInfo["itemPricesDefense"] = itemPricesDefense
                        gameInfo["itemsDisabledOffense"] = itemsDisabledOffense
                        gameInfo["itemsDisabledDefense"] = itemsDisabledDefense
                        itemModeOn = self.itemModeSwitch.on
                        gameInfo["itemModeOn"] = itemModeOn
                        gameInfo.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                            if error == nil {
                                self.entersoundlow?.play()
                                self.itemOptionsSystemTimer.invalidate()
                               self.performSegueWithIdentifier("showPointLocationViewControllerFromItemOptionsViewController", sender: nil)
                            }
                            else if error != nil {
                                gameInfo.saveEventually { (success: Bool, error: NSError?) -> Void in
                                    if error == nil {
                                        self.entersoundlow?.play()
                                        self.itemOptionsSystemTimer.invalidate()
                                        self.performSegueWithIdentifier("showPointLocationViewControllerFromItemOptionsViewController", sender: nil)
                                    }
                                }
                            }
                        }
                        
                    }
                }
                
            }
        
        
        
    }

    //system timer
    func itemOptionsSystemTimerUpdate() {
        if(itemOptionsSystemTimerCount > 0)
        {
            itemOptionsSystemTimerCount--
        }
        if(itemOptionsSystemTimerCount == 0)
        {
            itemOptionsSystemTimerCount = 3
            
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.backsound?.play()
        self.itemOptionsSystemTimer.invalidate()
        self.performSegueWithIdentifier("showGameOptionsViewControllerFromItemOptionsViewController", sender: nil)
        self.saveSettings()
    }
    
    //pickers
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
        return offenseData.count
        }
        else {
        return defenseData.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
        return offenseData[row]
        }
        else {
            return defenseData[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1{
        offenseButtonLabel.setTitle(offenseData[row], forState: UIControlState.Normal)
        globalOffenseSelect = offenseData[row]
    
        }
        else {
            defenseButtonLabel.setTitle(defenseData[row], forState: UIControlState.Normal)
            globalDefenseSelect = defenseData[row]
        }
    }

    @IBAction func startingFundsButton(sender: AnyObject) {
        displayAlert("Starting funds", message: "Sets the amount of money that players start with.  Money can be used to purchase items at any point during the game.")
    }
    
    @IBAction func abundanceButton(sender: AnyObject) {
        displayAlert("Item abundance", message: "Sets item generation frequency.  Very low: ~3 minutes, Low: ~1.5 minutes, Normal: ~1 minute, High ~45 seconds, Very high ~30 seconds.")
    }
    
    @IBAction func modeButton(sender: AnyObject) {
        displayAlert("Drop mode", message: "In the regular mode, most items drop on the map and must be picked up by walking to them.  In direct mode, generated items go directly to players.")
    }
    
    
    @IBAction func offenseButton(sender: AnyObject) {
        if offensePicker.hidden == false {
            offensePicker.hidden = true
        }
        else {
            offensePicker.hidden = false
        }
        
    }
    
    @IBAction func defenseButton(sender: AnyObject) {
        if defensePicker.hidden == false {
            defensePicker.hidden = true
        }
        else {
            defensePicker.hidden = false
        }
    }
    
    @IBAction func offenseItemSettingsButton(sender: AnyObject) {
        self.saveSettings()
        self.performSegueWithIdentifier("showOffenseItemSettingsViewControllerFromItemOptionsViewController", sender: nil)
    }
    
    @IBAction func defenseItemSettingsButton(sender: AnyObject) {
        self.saveSettings()
        self.performSegueWithIdentifier("showDefenseItemSettingsViewControllerFromItemOptionsViewController", sender: nil)
    }
    
    
    func saveSettings() {
        
        if globalOffenseSelect == "very low" {
            offenseAbundance = 1
        }
        if globalOffenseSelect == "low" {
            offenseAbundance = 2
        }
        if globalOffenseSelect == "normal" {
            offenseAbundance = 3
        }
        if globalOffenseSelect == "high" {
            offenseAbundance = 4
        }
        if globalOffenseSelect == "very high" {
            offenseAbundance = 5
        }
        if globalDefenseSelect == "very low" {
            defenseAbundance = 1
        }
        if globalDefenseSelect == "low" {
            defenseAbundance = 2
        }
        if globalDefenseSelect == "normal" {
            defenseAbundance = 3
        }
        if globalDefenseSelect == "high" {
            defenseAbundance = 4
        }
        if globalDefenseSelect == "very high" {
            defenseAbundance = 5
        }
        
        offenseStartingFunds = Int(self.offenseStartingFundsTextField.text!)!
        defenseStartingFunds = Int(self.defenseStartingFundsTextField.text!)!
        itemModeOn = self.itemModeSwitch.on
        
    }
}
