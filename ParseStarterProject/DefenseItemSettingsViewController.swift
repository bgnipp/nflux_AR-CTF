//
//  DefenseItemSettingsViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 11/20/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import AVFoundation

class DefenseItemSettingsViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var item1ButtonLabel: UIButton!
    @IBOutlet var item1TextField: UITextField!
    @IBOutlet var item2ButtonLabel: UIButton!
    @IBOutlet var item2TextField: UITextField!
    @IBOutlet var item3ButtonLabel: UIButton!
    @IBOutlet var item3TextField: UITextField!
    @IBOutlet var item4ButtonLabel: UIButton!
    @IBOutlet var item4TextField: UITextField!
    @IBOutlet var item5ButtonLabel: UIButton!
    @IBOutlet var item5TextField: UITextField!
    @IBOutlet var item6ButtonLabel: UIButton!
    @IBOutlet var item6TextField: UITextField!
    @IBOutlet var item7ButtonLabel: UIButton!
    @IBOutlet var item7TextField: UITextField!
    @IBOutlet var item8ButtonLabel: UIButton!
    @IBOutlet var item8TextField: UITextField!
    @IBOutlet var item9ButtonLabel: UIButton!
    @IBOutlet var item9TextField: UITextField!
    @IBOutlet var item10ButtonLabel: UIButton!
    @IBOutlet var item10TextField: UITextField!
    @IBOutlet var item11ButtonLabel: UIButton!
    @IBOutlet var item11TextField: UITextField!
    @IBOutlet var item12ButtonLabel: UIButton!
    @IBOutlet var item12TextField: UITextField!
    
    var item1Disabled1 = false
    var item2Disabled1 = false
    var item3Disabled1 = false
    var item4Disabled1 = false
    var item5Disabled1 = false
    var item6Disabled1 = false
    var item7Disabled1 = false
    var item8Disabled1 = false
    var item9Disabled1 = false
    var item10Disabled1 = false
    var item11Disabled1 = false
    var item12Disabled1 = false
    
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
    }
    
    //sounds
    var typeclick : AVAudioPlayer?
    var entersound : AVAudioPlayer?
    var backsound : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sounds
        if let typeclick = self.setupAudioPlayerWithFile("typeclick", type:"mp3") {
            self.typeclick = typeclick
        }
        self.typeclick?.volume = 0.9
        if let entersound = self.setupAudioPlayerWithFile("entersound", type:"mp3") {
            self.entersound = entersound
        }
        self.entersound?.volume = 0.6
        if let backsound = self.setupAudioPlayerWithFile("backsound", type:"mp3") {
            self.backsound = backsound
        }
        self.backsound?.volume = 0.8
        
        //hide keyboard when tap on background
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        //numpad keyboard
        self.item1TextField.keyboardType = UIKeyboardType.NumberPad
        self.item2TextField.keyboardType = UIKeyboardType.NumberPad
        self.item3TextField.keyboardType = UIKeyboardType.NumberPad
        self.item4TextField.keyboardType = UIKeyboardType.NumberPad
        self.item5TextField.keyboardType = UIKeyboardType.NumberPad
        self.item6TextField.keyboardType = UIKeyboardType.NumberPad
        self.item7TextField.keyboardType = UIKeyboardType.NumberPad
        self.item8TextField.keyboardType = UIKeyboardType.NumberPad
        self.item9TextField.keyboardType = UIKeyboardType.NumberPad
        self.item10TextField.keyboardType = UIKeyboardType.NumberPad
        self.item11TextField.keyboardType = UIKeyboardType.NumberPad
        self.item12TextField.keyboardType = UIKeyboardType.NumberPad
        
        //background colors
        if globalIsOffense == false {
            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
        }
        
        if globalIsOffense == true {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
        }
        
        //hide keyboard
        self.item1TextField.delegate = self
        self.item2TextField.delegate = self
        self.item3TextField.delegate = self
        self.item4TextField.delegate = self
        self.item5TextField.delegate = self
        self.item6TextField.delegate = self
        self.item7TextField.delegate = self
        self.item8TextField.delegate = self
        self.item9TextField.delegate = self
        self.item10TextField.delegate = self
        self.item11TextField.delegate = self
        self.item12TextField.delegate = self
        
        self.item1TextField.text = String(itemPricesDefense[0])
        self.item2TextField.text = String(itemPricesDefense[1])
        self.item3TextField.text = String(itemPricesDefense[2])
        self.item4TextField.text = String(itemPricesDefense[3])
        self.item5TextField.text = String(itemPricesDefense[4])
        self.item6TextField.text = String(itemPricesDefense[5])
        self.item7TextField.text = String(itemPricesDefense[6])
        self.item8TextField.text = String(itemPricesDefense[7])
        self.item9TextField.text = String(itemPricesDefense[8])
        self.item10TextField.text = String(itemPricesDefense[9])
        self.item11TextField.text = String(itemPricesDefense[10])
        self.item12TextField.text = String(itemPricesDefense[11])
        
        //hide disabled items 
        if itemsDisabledDefense[0] == true {
            self.item1Disabled1 = true
            self.item1ButtonLabel.setImage(UIImage(named:"scanT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item1Disabled1 = false
            self.item1ButtonLabel.setImage(UIImage(named:"scan.png"), forState: UIControlState.Normal)
        }
        
        if itemsDisabledDefense[1] == true {
            self.item2Disabled1 = true
            self.item2ButtonLabel.setImage(UIImage(named:"superscanT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item2Disabled1 = false
            self.item2ButtonLabel.setImage(UIImage(named:"superscan.png"), forState: UIControlState.Normal)
        }
        
        if itemsDisabledDefense[2] == true {
            self.item3Disabled1 = true
            self.item3ButtonLabel.setImage(UIImage(named:"mine40T.png"), forState: UIControlState.Normal)
        }
        else {
            self.item3Disabled1 = false
            self.item3ButtonLabel.setImage(UIImage(named:"mine40.png"), forState: UIControlState.Normal)
        }
        
        if itemsDisabledDefense[3] == true {
            self.item4Disabled1 = true
            self.item4ButtonLabel.setImage(UIImage(named:"supermineT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item4Disabled1 = false
            self.item4ButtonLabel.setImage(UIImage(named:"supermine.png"), forState: UIControlState.Normal)
        }
        
        if itemsDisabledDefense[4] == true {
            self.item5Disabled1 = true
            self.item5ButtonLabel.setImage(UIImage(named:"bombT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item5Disabled1 = false
            self.item5ButtonLabel.setImage(UIImage(named:"bomb.png"), forState: UIControlState.Normal)
        }
        
        if itemsDisabledDefense[5] == true {
            self.item6Disabled1 = true
            self.item6ButtonLabel.setImage(UIImage(named:"superbombT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item6Disabled1 = false
            self.item6ButtonLabel.setImage(UIImage(named:"superbomb.png"), forState: UIControlState.Normal)
        }
        
        if itemsDisabledDefense[6] == true {
            self.item7Disabled1 = true
            self.item7ButtonLabel.setImage(UIImage(named:"jammerT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item7Disabled1 = false
            self.item7ButtonLabel.setImage(UIImage(named:"jammer.png"), forState: UIControlState.Normal)
        }
        
        if itemsDisabledDefense[7] == true {
            self.item8Disabled1 = true
            self.item8ButtonLabel.setImage(UIImage(named:"spybotT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item8Disabled1 = false
            self.item8ButtonLabel.setImage(UIImage(named:"spybot.png"), forState: UIControlState.Normal)
        }
        
        if itemsDisabledDefense[8] == true {
            self.item9Disabled1 = true
            self.item9ButtonLabel.setImage(UIImage(named:"reachT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item9Disabled1 = false
            self.item9ButtonLabel.setImage(UIImage(named:"reach.png"), forState: UIControlState.Normal)
        }
        
        if itemsDisabledDefense[9] == true {
            self.item10Disabled1 = true
            self.item10ButtonLabel.setImage(UIImage(named:"fistT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item10Disabled1 = false
            self.item10ButtonLabel.setImage(UIImage(named:"fist.png"), forState: UIControlState.Normal)
        }
        
        if itemsDisabledDefense[10] == true {
            self.item11Disabled1 = true
            self.item11ButtonLabel.setImage(UIImage(named:"sickleT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item11Disabled1 = false
            self.item11ButtonLabel.setImage(UIImage(named:"sickle.png"), forState: UIControlState.Normal)
        }
        
        if itemsDisabledDefense[11] == true {
            self.item12Disabled1 = true
            self.item12ButtonLabel.setImage(UIImage(named:"lightningT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item12Disabled1 = false
            self.item12ButtonLabel.setImage(UIImage(named:"lightning.png"), forState: UIControlState.Normal)
        }
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func saveButton(sender: AnyObject) {
        
        if self.item1TextField.text == "" || self.item2TextField.text == "" || self.item3TextField.text == "" || self.item4TextField.text == "" || self.item5TextField.text == "" || self.item6TextField.text == "" || self.item7TextField.text == "" || self.item8TextField.text == "" || self.item9TextField.text == "" || self.item10TextField.text == "" || self.item11TextField.text == "" || self.item12TextField.text == "" {
            
            displayAlert("Error", message: "Missing fields")
            
        }
        else {
            self.entersound?.play()
            itemPricesDefense = [Int(self.item1TextField.text!)!, Int(self.item2TextField.text!)!, Int(self.item3TextField.text!)!, Int(self.item4TextField.text!)!, Int(self.item5TextField.text!)!, Int(self.item6TextField.text!)!, Int(self.item7TextField.text!)!, Int(self.item8TextField.text!)!, Int(self.item9TextField.text!)!, Int(self.item10TextField.text!)!, Int(self.item11TextField.text!)!, Int(self.item12TextField.text!)!]
            
            itemsDisabledDefense = [self.item1Disabled1, self.item2Disabled1, self.item3Disabled1, self.item4Disabled1, self.item5Disabled1, self.item6Disabled1, self.item7Disabled1, self.item8Disabled1, self.item9Disabled1, self.item10Disabled1, self.item11Disabled1, self.item12Disabled1]
            
            self.performSegueWithIdentifier("showItemOptionsViewControllerFromDefenseItemSettingsViewController", sender: nil)
        }
        
    }
    
    
    
    @IBAction func item1Button(sender: AnyObject) {
        self.typeclick?.play()
        if self.item1Disabled1 == false {
            self.item1Disabled1 = true
            self.item1ButtonLabel.setImage(UIImage(named:"scanT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item1Disabled1 = false
            self.item1ButtonLabel.setImage(UIImage(named:"scan.png"), forState: UIControlState.Normal)
        }
        
    }
    
    @IBAction func item2Button(sender: AnyObject) {
        self.typeclick?.play()
        if self.item2Disabled1 == false {
            self.item2Disabled1 = true
            self.item2ButtonLabel.setImage(UIImage(named:"superscanT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item2Disabled1 = false
            self.item2ButtonLabel.setImage(UIImage(named:"superscan.png"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func item3Button(sender: AnyObject) {
        self.typeclick?.play()
        if self.item3Disabled1 == false {
            self.item3Disabled1 = true
            self.item3ButtonLabel.setImage(UIImage(named:"mine40T.png"), forState: UIControlState.Normal)
        }
        else {
            self.item3Disabled1 = false
            self.item3ButtonLabel.setImage(UIImage(named:"mine40.png"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func item4Button(sender: AnyObject) {
        self.typeclick?.play()
        if self.item4Disabled1 == false {
            self.item4Disabled1 = true
            self.item4ButtonLabel.setImage(UIImage(named:"supermineT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item4Disabled1 = false
            self.item4ButtonLabel.setImage(UIImage(named:"supermine.png"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func item5Button(sender: AnyObject) {
        self.typeclick?.play()
        if self.item5Disabled1 == false {
            self.item5Disabled1 = true
            self.item5ButtonLabel.setImage(UIImage(named:"bombT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item5Disabled1 = false
            self.item5ButtonLabel.setImage(UIImage(named:"bomb.png"), forState: UIControlState.Normal)
        }
    }
    
    

    @IBAction func item6Button(sender: AnyObject) {
        self.typeclick?.play()
        if self.item6Disabled1 == false {
            self.item6Disabled1 = true
            self.item6ButtonLabel.setImage(UIImage(named:"superbombT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item6Disabled1 = false
            self.item6ButtonLabel.setImage(UIImage(named:"superbomb.png"), forState: UIControlState.Normal)
        }
    }
  
    
    @IBAction func item7Button(sender: AnyObject) {
        self.typeclick?.play()
        if self.item7Disabled1 == false {
            self.item7Disabled1 = true
            self.item7ButtonLabel.setImage(UIImage(named:"jammerT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item7Disabled1 = false
            self.item7ButtonLabel.setImage(UIImage(named:"jammer.png"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func item8Button(sender: AnyObject) {
        self.typeclick?.play()
        if self.item8Disabled1 == false {
            self.item8Disabled1 = true
            self.item8ButtonLabel.setImage(UIImage(named:"spybotT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item8Disabled1 = false
            self.item8ButtonLabel.setImage(UIImage(named:"spybot.png"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func item9Button(sender: AnyObject) {
        self.typeclick?.play()
        if self.item9Disabled1 == false {
            self.item9Disabled1 = true
            self.item9ButtonLabel.setImage(UIImage(named:"reachT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item9Disabled1 = false
            self.item9ButtonLabel.setImage(UIImage(named:"reach.png"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func item10Button(sender: AnyObject) {
        self.typeclick?.play()
        if self.item10Disabled1 == false {
            self.item10Disabled1 = true
            self.item10ButtonLabel.setImage(UIImage(named:"fistT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item10Disabled1 = false
            self.item10ButtonLabel.setImage(UIImage(named:"fist.png"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func item11Button(sender: AnyObject) {
        self.typeclick?.play()
        if self.item11Disabled1 == false {
            self.item11Disabled1 = true
            self.item11ButtonLabel.setImage(UIImage(named:"sickleT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item11Disabled1 = false
            self.item11ButtonLabel.setImage(UIImage(named:"sickle.png"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func item12Button(sender: AnyObject) {
        self.typeclick?.play()
        if self.item12Disabled1 == false {
            self.item12Disabled1 = true
            self.item12ButtonLabel.setImage(UIImage(named:"lightningT.png"), forState: UIControlState.Normal)
        }
        else {
            self.item12Disabled1 = false
            self.item12ButtonLabel.setImage(UIImage(named:"lightning.png"), forState: UIControlState.Normal)
        }
    }
    
    

    
    @IBAction func item1HelpButton(sender: AnyObject) {
        displayAlert("Scan", message: "Reveals the location of all opponents in a selected area of the map")
    }

    @IBAction func item2HelpButton(sender: AnyObject) {
         displayAlert("Super Scan", message: "Reveals the location of all opponents for about 20 seconds")
    }
    

    @IBAction func item3HelpButton(sender: AnyObject) {
        displayAlert("Mine", message: "Plants a mine on the map that triggers when an opponent gets near, tagging them.  Must be planted within 20 feet from you, and can't be planted in the base or flag zones.")
    }
    
    @IBAction func item4HelpButton(sender: AnyObject) {
        displayAlert("Super Mine", message: "Plants a mine on the map that triggers when an opponent gets near, tagging all opponents in the area.  Must be planted within 20 feet from you, and can't be planted in the base or flag zones.")
    }
    
    @IBAction func item5HelpButton(sender: AnyObject) {
        displayAlert("Bomb", message: "Tags all players (even teammates) in a selected area of the map.  Can't be dropped in the flag zone.")
    }
    
    @IBAction func item6HelpButton(sender: AnyObject) {
        displayAlert("Super Bomb", message: "Tags all players (even teammates) in a selected area of the map (larger reach than the regular bomb).  Can't be dropped in the flag zone.")
    }
    
    @IBAction func item7HelpButton(sender: AnyObject) {
        displayAlert("Jammer", message: "When an opponent scans, it will not reveal the location of any opponents.  Lasts one minute.")
    }
    
    @IBAction func item8HelpButton(sender: AnyObject) {
        displayAlert("Spybot", message: "Gets planted at a selected point on the map, and reveals the location of all opponents in that area.  Lasts two minutes.")
    }
    
    @IBAction func item9HelpButton(sender: AnyObject) {
        displayAlert("Reach", message: "Can tag opponents from futher away.  Lasts one minute.")
    }
    
    @IBAction func item10HelpButton(sender: AnyObject) {
        displayAlert("Sense", message: "Detects the location of opponents who are near.  Lasts one minute.")
    }
    
    @IBAction func item11HelpButton(sender: AnyObject) {
        displayAlert("Sickle", message: "Tags the opponent closest to you")
    }
    
    @IBAction func item12HelpButton(sender: AnyObject) {
        displayAlert("Lightning", message: "Tags all opponents")
    }
    
    
    // Dismiss the keyboard when the user taps the "Return" key or its equivalent
    // while editing a text field.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
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
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.backsound?.play()
        self.performSegueWithIdentifier("showItemOptionsViewControllerFromDefenseItemSettingsViewController", sender: nil)
    }

}
