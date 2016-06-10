//
//  OffenseItemShopViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 11/19/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

class OffenseItemShopViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var item1ButtonLabel: UIButton!
    @IBOutlet var item1PriceLabel: UILabel!
    @IBOutlet var item2ButtonLabel: UIButton!
    @IBOutlet var item2PriceLabel: UILabel!
    @IBOutlet var item3ButtonLabel: UIButton!
    @IBOutlet var item3PriceLabel: UILabel!
    @IBOutlet var item4ButtonLabel: UIButton!
    @IBOutlet var item4PriceLabel: UILabel!
    @IBOutlet var item5ButtonLabel: UIButton!
    @IBOutlet var item5PriceLabel: UILabel!
    @IBOutlet var item6ButtonLabel: UIButton!
    @IBOutlet var item6PriceLabel: UILabel!
    @IBOutlet var item7ButtonLabel: UIButton!
    @IBOutlet var item7PriceLabel: UILabel!
    @IBOutlet var item8ButtonLabel: UIButton!
    @IBOutlet var item8PriceLabel: UILabel!
    @IBOutlet var item9ButtonLabel: UIButton!
    @IBOutlet var item9PriceLabel: UILabel!
    @IBOutlet var item10ButtonLabel: UIButton!
    @IBOutlet var item10PriceLabel: UILabel!
    @IBOutlet var item11ButtonLabel: UIButton!
    @IBOutlet var item11PriceLabel: UILabel!
    @IBOutlet var item12ButtonLabel: UIButton!
    @IBOutlet var item12PriceLabel: UILabel!
    
    @IBOutlet var item1HelpButtonLabel: UIButton!
    @IBOutlet var item2HelpButtonLabel: UIButton!
    @IBOutlet var item3HelpButtonLabel: UIButton!
    @IBOutlet var item4HelpButtonLabel: UIButton!
    @IBOutlet var item5HelpButtonLabel: UIButton!
    @IBOutlet var item6HelpButtonLabel: UIButton!
    @IBOutlet var item7HelpButtonLabel: UIButton!
    @IBOutlet var item8HelpButtonLabel: UIButton!
    @IBOutlet var item9HelpButtonLabel: UIButton!
    @IBOutlet var item10HelpButtonLabel: UIButton!
    @IBOutlet var item11HelpButtonLabel: UIButton!
    @IBOutlet var item12HelpButtonLabel: UIButton!
    
    @IBOutlet var powerup1Slot: UIButton!
    @IBOutlet var powerup2Slot: UIButton!
    @IBOutlet var powerup3Slot: UIButton!
    
    var item1Price = 0
    var item2Price = 0
    var item3Price = 0
    var item4Price = 0
    var item5Price = 0
    var item6Price = 0
    var item7Price = 0
    var item8Price = 0
    var item9Price = 0
    var item10Price = 0
    var item11Price = 0
    var item12Price = 0
    
    var chaching : AVAudioPlayer?
    var backsound : AVAudioPlayer?
    
    
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
       
        if let chaching = self.setupAudioPlayerWithFile("chaching", type:"mp3") {
            self.chaching = chaching
        }
        self.chaching?.volume = 0.9
        if let backsound = self.setupAudioPlayerWithFile("backsound", type:"mp3") {
            self.backsound = backsound
        }
        self.backsound?.volume = 0.8
        
        //hide keyboard when tap on background
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)

        //background color
        //background colors
        if globalIsOffense == false {
            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
        }
        
        if globalIsOffense == true {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
        }
        

        //set labels
        self.headerLabel.text = "current funds - $\(currentFunds)"
            print(itemPrices)
        var item1PriceTemp = itemPrices[0] as? Int
            print(item1PriceTemp)
            

        self.item1PriceLabel.text = "$\(itemPrices[0])"
        self.item2PriceLabel.text = "$\(itemPrices[1])"
        self.item3PriceLabel.text = "$\(itemPrices[2])"
        self.item4PriceLabel.text = "$\(itemPrices[3])"
        self.item5PriceLabel.text = "$\(itemPrices[4])"
        self.item6PriceLabel.text = "$\(itemPrices[5])"
        self.item7PriceLabel.text = "$\(itemPrices[6])"
        self.item8PriceLabel.text = "$\(itemPrices[7])"
        self.item9PriceLabel.text = "$\(itemPrices[8])"
        self.item10PriceLabel.text = "$\(itemPrices[9])"
        self.item11PriceLabel.text = "$\(itemPrices[10])"
        self.item12PriceLabel.text = "$\(itemPrices[11])"
        

        self.item1Price = Int("\(itemPrices[0])")!
        self.item2Price = Int("\(itemPrices[1])")!
        self.item3Price = Int("\(itemPrices[2])")!
        self.item4Price = Int("\(itemPrices[3])")!
        self.item5Price = Int("\(itemPrices[4])")!
        self.item6Price = Int("\(itemPrices[5])")!
        self.item7Price = Int("\(itemPrices[6])")!
        self.item8Price = Int("\(itemPrices[7])")!
        self.item9Price = Int("\(itemPrices[8])")!
        self.item10Price = Int("\(itemPrices[9])")!
        self.item11Price = Int("\(itemPrices[10])")!
        self.item12Price = Int("\(itemPrices[11])")!
        
        if itemsDisabled[0] as! Bool == true {
            self.item1PriceLabel.text = ""
            self.item1ButtonLabel.setImage(UIImage(named:"scanT.png"), forState: UIControlState.Normal)
            self.item1ButtonLabel.enabled = false
            self.item1HelpButtonLabel.enabled = false
            self.item1HelpButtonLabel.hidden = true
            
        }
        if itemsDisabled[1] as! Bool == true {
            self.item2PriceLabel.text = ""
            self.item2ButtonLabel.setImage(UIImage(named:"superscanT.png"), forState: UIControlState.Normal)
            self.item2ButtonLabel.enabled = false
            self.item2HelpButtonLabel.enabled = false
            self.item2HelpButtonLabel.hidden = true
        }
        if itemsDisabled[2] as! Bool == true {
            self.item3PriceLabel.text = ""
            self.item3ButtonLabel.setImage(UIImage(named:"mine40T.png"), forState: UIControlState.Normal)
            self.item3ButtonLabel.enabled = false
            self.item3HelpButtonLabel.enabled = false
            self.item3HelpButtonLabel.hidden = true
        }
        if itemsDisabled[3] as! Bool == true {
            self.item4PriceLabel.text = ""
            self.item4ButtonLabel.setImage(UIImage(named:"supermineT.png"), forState: UIControlState.Normal)
            self.item4ButtonLabel.enabled = false
            self.item4HelpButtonLabel.enabled = false
            self.item4HelpButtonLabel.hidden = true
        }
        if itemsDisabled[4] as! Bool == true {
            self.item5PriceLabel.text = ""
            self.item5ButtonLabel.setImage(UIImage(named:"bombT.png"), forState: UIControlState.Normal)
            self.item5ButtonLabel.enabled = false
            self.item5HelpButtonLabel.enabled = false
            self.item5HelpButtonLabel.hidden = true
        }
        if itemsDisabled[5] as! Bool == true {
            self.item6PriceLabel.text = ""
            self.item6ButtonLabel.setImage(UIImage(named:"superbombT.png"), forState: UIControlState.Normal)
            self.item6ButtonLabel.enabled = false
            self.item6HelpButtonLabel.enabled = false
            self.item6HelpButtonLabel.hidden = true
        }
        if itemsDisabled[6] as! Bool == true {
            self.item7PriceLabel.text = ""
            self.item7ButtonLabel.setImage(UIImage(named:"jammerT.png"), forState: UIControlState.Normal)
            self.item7ButtonLabel.enabled = false
            self.item7HelpButtonLabel.enabled = false
            self.item7HelpButtonLabel.hidden = true
        }
        if itemsDisabled[7] as! Bool == true {
            self.item8PriceLabel.text = ""
            self.item8ButtonLabel.setImage(UIImage(named:"spybotT.png"), forState: UIControlState.Normal)
            self.item8ButtonLabel.enabled = false
            self.item8HelpButtonLabel.enabled = false
            self.item8HelpButtonLabel.hidden = true
        }
        if itemsDisabled[8] as! Bool == true {
            self.item9PriceLabel.text = ""
            self.item9ButtonLabel.setImage(UIImage(named:"healT.png"), forState: UIControlState.Normal)
            self.item9ButtonLabel.enabled = false
            self.item9HelpButtonLabel.enabled = false
            self.item9HelpButtonLabel.hidden = true
        }
        if itemsDisabled[9] as! Bool == true {
            self.item10PriceLabel.text = ""
            self.item10ButtonLabel.setImage(UIImage(named:"superhealT.png"), forState: UIControlState.Normal)
            self.item10ButtonLabel.enabled = false
            self.item10HelpButtonLabel.enabled = false
            self.item10HelpButtonLabel.hidden = true
        }
        if itemsDisabled[10] as! Bool == true {
            self.item11PriceLabel.text = ""
            self.item11ButtonLabel.setImage(UIImage(named:"shieldT.png"), forState: UIControlState.Normal)
            self.item11ButtonLabel.enabled = false
            self.item11HelpButtonLabel.enabled = false
            self.item11HelpButtonLabel.hidden = true
        }
        if itemsDisabled[11] as! Bool == true {
            self.item12PriceLabel.text = ""
            self.item12ButtonLabel.setImage(UIImage(named:"ghostT.png"), forState: UIControlState.Normal)
            self.item12ButtonLabel.enabled = false
            self.item12HelpButtonLabel.enabled = false
            self.item12HelpButtonLabel.hidden = true
        }
        
        
        
        if slot1Powerup == 1 {
            self.powerup1Slot.setImage(UIImage(named:"scan.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 2 {
            self.powerup1Slot.setImage(UIImage(named:"superscan.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 3 {
            self.powerup1Slot.setImage(UIImage(named:"mine40.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 4 {
            self.powerup1Slot.setImage(UIImage(named:"supermine.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 5 {
            self.powerup1Slot.setImage(UIImage(named:"bomb.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 6 {
            self.powerup1Slot.setImage(UIImage(named:"superbomb.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 7 {
            self.powerup1Slot.setImage(UIImage(named:"jammer.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 8 {
            self.powerup1Slot.setImage(UIImage(named:"spybot.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 9 {
            self.powerup1Slot.setImage(UIImage(named:"heal.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 10 {
            self.powerup1Slot.setImage(UIImage(named:"superheal.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 11 {
            self.powerup1Slot.setImage(UIImage(named:"shield.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 12 {
            self.powerup1Slot.setImage(UIImage(named:"ghost.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 13 {
            self.powerup1Slot.setImage(UIImage(named:"reach.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 14 {
            self.powerup1Slot.setImage(UIImage(named:"fist.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 15 {
            self.powerup1Slot.setImage(UIImage(named:"sickle.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 16 {
            self.powerup1Slot.setImage(UIImage(named:"lightning.png"), forState: UIControlState.Normal)
        }
        
        
        if slot2Powerup == 1 {
            self.powerup2Slot.setImage(UIImage(named:"scan.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 2 {
            self.powerup2Slot.setImage(UIImage(named:"superscan.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 3 {
            self.powerup2Slot.setImage(UIImage(named:"mine40.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 4 {
            self.powerup2Slot.setImage(UIImage(named:"supermine.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 5 {
            self.powerup2Slot.setImage(UIImage(named:"bomb.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 6 {
            self.powerup2Slot.setImage(UIImage(named:"superbomb.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 7 {
            self.powerup2Slot.setImage(UIImage(named:"jammer.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 8 {
            self.powerup2Slot.setImage(UIImage(named:"spybot.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 9 {
            self.powerup2Slot.setImage(UIImage(named:"heal.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 10 {
            self.powerup2Slot.setImage(UIImage(named:"superheal.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 11 {
            self.powerup2Slot.setImage(UIImage(named:"shield.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 12 {
            self.powerup2Slot.setImage(UIImage(named:"ghost.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 13 {
            self.powerup2Slot.setImage(UIImage(named:"reach.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 14 {
            self.powerup2Slot.setImage(UIImage(named:"fist.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 15 {
            self.powerup2Slot.setImage(UIImage(named:"sickle.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 16 {
            self.powerup2Slot.setImage(UIImage(named:"lightning.png"), forState: UIControlState.Normal)
        }
        
        
        if slot3Powerup == 1 {
            self.powerup3Slot.setImage(UIImage(named:"scan.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 2 {
            self.powerup3Slot.setImage(UIImage(named:"superscan.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 3 {
            self.powerup3Slot.setImage(UIImage(named:"mine40.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 4 {
            self.powerup3Slot.setImage(UIImage(named:"supermine.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 5 {
            self.powerup3Slot.setImage(UIImage(named:"bomb.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 6 {
            self.powerup3Slot.setImage(UIImage(named:"superbomb.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 7 {
            self.powerup3Slot.setImage(UIImage(named:"jammer.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 8 {
            self.powerup3Slot.setImage(UIImage(named:"spybot.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 9 {
            self.powerup3Slot.setImage(UIImage(named:"heal.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 10 {
            self.powerup3Slot.setImage(UIImage(named:"superheal.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 11 {
            self.powerup3Slot.setImage(UIImage(named:"shield.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 12 {
            self.powerup3Slot.setImage(UIImage(named:"ghost.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 13 {
            self.powerup3Slot.setImage(UIImage(named:"reach.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 14 {
            self.powerup3Slot.setImage(UIImage(named:"fist.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 15 {
            self.powerup3Slot.setImage(UIImage(named:"sickle.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 16 {
            self.powerup3Slot.setImage(UIImage(named:"lightning.png"), forState: UIControlState.Normal)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func item1Button(sender: AnyObject) {
        
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
            
        else if currentFunds <  self.item1Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
        
        else if currentFunds >= self.item1Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item1Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 1
                powerup1Slot.setImage(UIImage(named:"scan.png"), forState: UIControlState.Normal)
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 1
                powerup2Slot.setImage(UIImage(named:"scan.png"), forState: UIControlState.Normal)
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 1
                powerup3Slot.setImage(UIImage(named:"scan.png"), forState: UIControlState.Normal)
            }
            
        }

    }
    
    @IBAction func item2Button(sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
            
        else if currentFunds <  self.item2Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
            
        else if currentFunds >= self.item2Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item2Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 2
                powerup1Slot.setImage(UIImage(named:"superscan.png"), forState: UIControlState.Normal)
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 2
                powerup2Slot.setImage(UIImage(named:"superscan.png"), forState: UIControlState.Normal)
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 2
                powerup3Slot.setImage(UIImage(named:"superscan.png"), forState: UIControlState.Normal)
            }
            
        }
        
    }
    
    @IBAction func item3Button(sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
            
        else if currentFunds <  self.item3Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
            
        else if currentFunds >= self.item3Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item3Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 3
                powerup1Slot.setImage(UIImage(named:"mine40.png"), forState: UIControlState.Normal)
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 3
                powerup2Slot.setImage(UIImage(named:"mine40.png"), forState: UIControlState.Normal)
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 3
                powerup3Slot.setImage(UIImage(named:"mine40.png"), forState: UIControlState.Normal)
            }
            
        }
    }
    @IBAction func item4Button(sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
            
        else if currentFunds <  self.item4Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
            
        else if currentFunds >= self.item4Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item4Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 4
                powerup1Slot.setImage(UIImage(named:"supermine.png"), forState: UIControlState.Normal)
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 4
                powerup2Slot.setImage(UIImage(named:"supermine.png"), forState: UIControlState.Normal)
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 4
                powerup3Slot.setImage(UIImage(named:"supermine.png"), forState: UIControlState.Normal)
            }
            
        }
    }
    
    @IBAction func item5Button(sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
            
        else if currentFunds <  self.item5Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
            
        else if currentFunds >= self.item5Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item5Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 5
                powerup1Slot.setImage(UIImage(named:"bomb.png"), forState: UIControlState.Normal)
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 5
                powerup2Slot.setImage(UIImage(named:"bomb.png"), forState: UIControlState.Normal)
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 5
                powerup3Slot.setImage(UIImage(named:"bomb.png"), forState: UIControlState.Normal)
            }
            
        }
    }
    
    @IBAction func item6Button(sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
            
        else if currentFunds <  self.item6Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
            
        else if currentFunds >= self.item6Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item6Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 6
                powerup1Slot.setImage(UIImage(named:"superbomb.png"), forState: UIControlState.Normal)
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 6
                powerup2Slot.setImage(UIImage(named:"superbomb.png"), forState: UIControlState.Normal)
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 6
                powerup3Slot.setImage(UIImage(named:"superbomb.png"), forState: UIControlState.Normal)
            }
            
        }
    }
    
    @IBAction func item7Button(sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
            
        else if currentFunds <  self.item7Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
            
        else if currentFunds >= self.item7Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item7Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 7
                powerup1Slot.setImage(UIImage(named:"jammer.png"), forState: UIControlState.Normal)
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 7
                powerup2Slot.setImage(UIImage(named:"jammer.png"), forState: UIControlState.Normal)
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 7
                powerup3Slot.setImage(UIImage(named:"jammer.png"), forState: UIControlState.Normal)
            }
            
        }
    }
    
    @IBAction func item8Button(sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
            
        else if currentFunds <  self.item8Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
            
        else if currentFunds >= self.item8Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item8Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 8
                powerup1Slot.setImage(UIImage(named:"spybot.png"), forState: UIControlState.Normal)
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 8
                powerup2Slot.setImage(UIImage(named:"spybot.png"), forState: UIControlState.Normal)
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 8
                powerup3Slot.setImage(UIImage(named:"spybot.png"), forState: UIControlState.Normal)
            }
            
        }
    }

    @IBAction func item9Button(sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
            
        else if currentFunds <  self.item9Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
            
        else if currentFunds >= self.item9Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item9Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 9
                powerup1Slot.setImage(UIImage(named:"heal.png"), forState: UIControlState.Normal)
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 9
                powerup2Slot.setImage(UIImage(named:"heal.png"), forState: UIControlState.Normal)
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 9
                powerup3Slot.setImage(UIImage(named:"heal.png"), forState: UIControlState.Normal)
            }
            
        }
    }
    
    @IBAction func item10Button(sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
            
        else if currentFunds <  self.item10Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
            
        else if currentFunds >= self.item10Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item10Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 10
                powerup1Slot.setImage(UIImage(named:"superheal.png"), forState: UIControlState.Normal)
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 10
                powerup2Slot.setImage(UIImage(named:"superheal.png"), forState: UIControlState.Normal)
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 10
                powerup3Slot.setImage(UIImage(named:"superheal.png"), forState: UIControlState.Normal)
            }
            
        }
    }
    
    @IBAction func item11Button(sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
            
        else if currentFunds <  self.item11Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
            
        else if currentFunds >= self.item11Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item11Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 11
                powerup1Slot.setImage(UIImage(named:"shield.png"), forState: UIControlState.Normal)
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 11
                powerup2Slot.setImage(UIImage(named:"shield.png"), forState: UIControlState.Normal)
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 11
                powerup3Slot.setImage(UIImage(named:"shield.png"), forState: UIControlState.Normal)
            }
            
        }
    }
    
    @IBAction func item12Button(sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
            
        else if currentFunds <  self.item12Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
            
        else if currentFunds >= self.item12Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item12Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 12
                powerup1Slot.setImage(UIImage(named:"ghost.png"), forState: UIControlState.Normal)
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 12
                powerup2Slot.setImage(UIImage(named:"ghost.png"), forState: UIControlState.Normal)
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 12
                powerup3Slot.setImage(UIImage(named:"ghost.png"), forState: UIControlState.Normal)
            }
            
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
        displayAlert("Heal", message: "Recharges you (without having to return to base)")
    }
    
    @IBAction func item10HelpButton(sender: AnyObject) {
        displayAlert("Team Heal", message: "Recharges your whole team (without having to return to base)")
    }
    
    @IBAction func item11HelpButton(sender: AnyObject) {
        displayAlert("Shield", message: "Takes longer to get tagged")
    }
    
    @IBAction func item12HelpButton(sender: AnyObject) {
         displayAlert("Ghost", message: "All opponents lose all held items.  Your entire team becomes invisible to scans for one minute.")
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

}
