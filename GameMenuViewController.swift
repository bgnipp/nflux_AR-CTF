//
//  GameMenuViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 11/21/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class GameMenuViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet var mapSwitch: UISwitch!
    
    @IBOutlet var offense1Label: UILabel!
    @IBOutlet var offense2Label: UILabel!
    @IBOutlet var offense3Label: UILabel!
    @IBOutlet var offense4Label: UILabel!
    @IBOutlet var offense5Label: UILabel!
    @IBOutlet var defense1Label: UILabel!
    @IBOutlet var defense2Label: UILabel!
    @IBOutlet var defense3Label: UILabel!
    @IBOutlet var defense4Label: UILabel!
    @IBOutlet var defense5Label: UILabel!
    @IBOutlet var offense1Label2: UILabel!
    @IBOutlet var offense2Label2: UILabel!
    @IBOutlet var offense3Label2: UILabel!
    @IBOutlet var offense4Label2: UILabel!
    @IBOutlet var offense5Label2: UILabel!
    @IBOutlet var defense1Label2: UILabel!
    @IBOutlet var defense2Label2: UILabel!
    @IBOutlet var defense3Label2: UILabel!
    @IBOutlet var defense4Label2: UILabel!
    @IBOutlet var defense5Label2: UILabel!
    
    //menu refresh timer
    var menuRefreshTimer = NSTimer()
    var menuRefreshTimerCount: Int = 10
    
    //lock in portrait orientation
    override func shouldAutorotate() -> Bool {
        return false }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide keyboard
        self.testRadiusTextField.delegate = self
        self.testTextField2.delegate = self
        
        //background colors
        if globalIsOffense == false {
            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
        }
        
        if globalIsOffense == true {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
        }
        
        quittingGame = false
        
        
        if testFeaturesOn == false {
            self.testTextField2.hidden = true
            self.testRadiusTextField.hidden = true
            self.setTestRadiusButtonLabel.hidden = true
            self.hideTestViewButtonLabel.hidden = true
            
        }
        else {
            self.testTextField2.hidden = false
            self.testRadiusTextField.hidden = false
            self.setTestRadiusButtonLabel.hidden = false
            self.hideTestViewButtonLabel.hidden = false
        }
        
        //switch off color
        self.mapSwitch.tintColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.mapSwitch.backgroundColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.mapSwitch.layer.cornerRadius = 16.0
        
        if map3d == false {
            self.mapSwitch.on = false
        }
        if map3d == true {
            self.mapSwitch.on = true
        }
        
        //populate player names
        self.offense1Label.text = offense1var
        self.offense2Label.text = offense2var
        self.offense3Label.text = offense3var
        self.offense4Label.text = offense4var
        self.offense5Label.text = offense5var
        self.defense1Label.text = defense1var
        self.defense2Label.text = defense2var
        self.defense3Label.text = defense3var
        self.defense4Label.text = defense4var
        self.defense5Label.text = defense5var
        
        self.updateStatus()
        
        //start refresh timer
        self.menuRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("menuRefreshTimerUpdate"), userInfo: nil, repeats: true)
        self.menuRefreshTimer.tolerance = 0.2

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
    
    @IBAction func returnToGameButton(sender: AnyObject) {
        
        map3d = self.mapSwitch.on
        
        self.menuRefreshTimer.invalidate()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func quitGamebutton(sender: AnyObject) {
        quittingGame = true
        
        self.menuRefreshTimer.invalidate()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet var testRadiusTextField: UITextField!
    @IBOutlet var testTextField2: UITextField!
    @IBOutlet var setTestRadiusButtonLabel: UIButton!
    @IBOutlet var hideTestViewButtonLabel: UIButton!
    
    
    @IBAction func hideTestViewButton(sender: AnyObject) {
        if testViewHidden == false {
            testViewHidden = true
        }
        else {
            testViewHidden = false
        }
    }
    
    @IBAction func setTestRadiusButton(sender: AnyObject) {
//        testRadius = Double(testRadiusTextField.text!)!
        testAnnCaption = testRadiusTextField.text!
        testAnnType = testTextField2.text!
        print(testAnnType)
        print(testAnnCaption)
        if testAnnType == "pu" {
            puhack = true
        }
    }
    
    //menu refresh timer
    func menuRefreshTimerUpdate() {
        if(menuRefreshTimerCount > 0)
        {
            menuRefreshTimerCount--
        }
        if(menuRefreshTimerCount == 0)
        {
           menuRefreshTimerCount = 4
            self.updateStatus()
        }
    }
    
    
    func updateStatus() {
        
        //populate player statuses
        
        if offense1var != "" {
        if offense1Status == 1  {
            self.offense1Label2.text = "active"
        }
        else if offense1Status == 0 {
            self.offense1Label2.text = "tagged"
        }
        else if offense1Status == 2 {
            self.offense1Label2.text = "starting"
        }
            }
        else {
            self.offense1Label2.text = ""
        }
        
        if offense2var != "" {
        if offense2Status == 1 {
            self.offense2Label2.text = "active"
        }
        else if offense2Status == 0 {
            self.offense2Label2.text = "tagged"
        }
        else if offense2Status == 2 {
            self.offense2Label2.text = "starting"
        }
            }
        else {
            self.offense2Label2.text = ""
        }
        
        if offense3var != "" {
        if offense3Status == 1 {
            self.offense3Label2.text = "active"
        }
        else if offense3Status == 0 {
            self.offense3Label2.text = "tagged"
        }
        else if offense3Status == 2 {
            self.offense3Label2.text = "starting"
        }
            }
        else {
            self.offense3Label2.text = ""
        }
        
        if offense4var != "" {
        if offense4Status == 1 {
            self.offense4Label2.text = "active"
        }
        else if offense4Status == 0  {
            self.offense4Label2.text = "tagged"
        }
        else if offense4Status == 2 {
            self.offense4Label2.text = "starting"
        }
            }
        else {
            self.offense4Label2.text = ""
        }
        
        if offense5var != "" {
        if offense5Status == 1 {
            self.offense5Label2.text = "active"
        }
        else if offense5Status == 0 {
            self.offense5Label2.text = "tagged"
        }
        else if offense5Status == 2 {
            self.offense5Label2.text = "starting"
        }
            }
        else {
            self.offense5Label2.text = ""
        }
        
        
        if defense1var != "" {
        if defense1Status == 1 {
            self.defense1Label2.text = "active"
        }
        else if defense1Status == 0 {
            self.defense1Label2.text = "tagged"
        }
        else if defense1Status == 2 {
            self.defense1Label2.text = "starting"
        }
            }
        else {
            self.defense1Label2.text = ""
        }
        
        if defense2var != "" {
        if defense2Status == 1 {
            self.defense2Label2.text = "active"
        }
        else if defense2Status == 0 {
            self.defense2Label2.text = "tagged"
        }
        else if defense2Status == 2 {
            self.defense2Label2.text = "starting"
        }
            }
        else {
            self.defense2Label2.text = ""
        }
        
        if defense3var != "" {
        if defense3Status == 1 {
            self.defense3Label2.text = "active"
        }
        else if defense3Status == 0 {
            self.defense3Label2.text = "tagged"
        }
        else if defense3Status == 2 {
            self.defense3Label2.text = "starting"
        }
            }
        else {
            self.defense3Label2.text = ""
        }
        
        if defense4var != "" {
        if defense4Status == 1 {
            self.defense4Label2.text = "active"
        }
        else if defense4Status == 0 {
            self.defense4Label2.text = "tagged"
        }
        else if defense4Status == 2 {
            self.defense4Label2.text = "starting"
        }
            }
        else {
            self.defense4Label2.text = ""
        }
        
        if defense5var != "" {
        if defense5Status == 1 {
            self.defense5Label2.text = "active"
        }
        else if defense5Status == 0 {
            self.defense5Label2.text = "tagged"
        }
        else if defense5Status == 2 {
            self.defense5Label2.text = "starting"
        }
        }
        else {
            self.defense5Label2.text = ""
        }
        
        //update status for local player
        
        if globalIsOffense == true {
        if localPlayerPosition == "offense1" {
            if localPlayerStatus == 1 {
                self.offense1Label2.text = "active"
            }
            else if localPlayerStatus == 0 {
                self.offense1Label2.text = "tagged"
            }
            else if localPlayerStatus == 2 {
                self.offense1Label2.text = "starting"
            }
        }
        else if localPlayerPosition == "offense2" {
            if localPlayerStatus == 1 {
                self.offense2Label2.text = "active"
            }
            else if localPlayerStatus == 0 {
                self.offense2Label2.text = "tagged"
            }
            else if localPlayerStatus == 2 {
                self.offense2Label2.text = "starting"
            }
            }
        else if localPlayerPosition == "offense3" {
            if localPlayerStatus == 1 {
                self.offense3Label2.text = "active"
            }
            else if localPlayerStatus == 0 {
                self.offense3Label2.text = "tagged"
            }
            else if localPlayerStatus == 2 {
                self.offense3Label2.text = "starting"
            }
            }
        else if localPlayerPosition == "offense4" {
            if localPlayerStatus == 1 {
                self.offense4Label2.text = "active"
            }
            else if localPlayerStatus == 0 {
                self.offense4Label2.text = "tagged"
            }
            else if localPlayerStatus == 2 {
                self.offense4Label2.text = "starting"
            }
            }
        else if localPlayerPosition == "offense5" {
            if localPlayerStatus == 1 {
                self.offense5Label2.text = "active"
            }
            else if localPlayerStatus == 0 {
                self.offense5Label2.text = "tagged"
            }
            else if localPlayerStatus == 2 {
                self.offense5Label2.text = "starting"
            }
            }
        }
        
        else {
            if localPlayerPosition == "defense1" {
                if localPlayerStatus == 1 {
                    self.defense1Label2.text = "active"
                }
                else if localPlayerStatus == 0 {
                    self.defense1Label2.text = "tagged"
                }
                else if localPlayerStatus == 2 {
                    self.defense1Label2.text = "starting"
                }
            }
            
            if localPlayerPosition == "defense2" {
                if localPlayerStatus == 1 {
                    self.defense2Label2.text = "active"
                }
                else if localPlayerStatus == 0 {
                    self.defense2Label2.text = "tagged"
                }
                else if localPlayerStatus == 2 {
                    self.defense2Label2.text = "starting"
                }
            }
            
            if localPlayerPosition == "defense3" {
                if localPlayerStatus == 1 {
                    self.defense3Label2.text = "active"
                }
                else if localPlayerStatus == 0 {
                    self.defense3Label2.text = "tagged"
                }
                else if localPlayerStatus == 2 {
                    self.defense3Label2.text = "starting"
                }
            }
            
            if localPlayerPosition == "defense4" {
                if localPlayerStatus == 1 {
                    self.defense4Label2.text = "active"
                }
                else if localPlayerStatus == 0 {
                    self.defense4Label2.text = "tagged"
                }
                else if localPlayerStatus == 2 {
                    self.defense4Label2.text = "starting"
                }
            }
            
            if localPlayerPosition == "defense5" {
                if localPlayerStatus == 1 {
                    self.defense5Label2.text = "active"
                }
                else if localPlayerStatus == 0 {
                    self.defense5Label2.text = "tagged"
                }
                else if localPlayerStatus == 2 {
                    self.defense5Label2.text = "starting"
                }
            }
            
        }
    
        //indicate which player has the flag
        if playerCapturedPointPosition == "offense1" {
            self.offense1Label2.text = "has flag"
        }
        if playerCapturedPointPosition == "offense2" {
            self.offense2Label2.text = "has flag"
        }
        if playerCapturedPointPosition == "offense3" {
            self.offense3Label2.text = "has flag"
        }
        if playerCapturedPointPosition == "offense4" {
            self.offense4Label2.text = "has flag"
        }
        if playerCapturedPointPosition == "offense5" {
            self.offense5Label2.text = "has flag"
        }
        
    }

}
