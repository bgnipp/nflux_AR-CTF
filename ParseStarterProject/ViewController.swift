//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse
import CoreBluetooth
import CoreLocation
import AVFoundation

var globalUserName = ""
var globalGameName = ""
var globalAppendedGameName = ""
var globalIsOffense = true
var globalMatchRequestObjectID = ""
var globalAppendedUserName = "n"
var bluetoothOn = false

class ViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate, CBPeripheralManagerDelegate {

    var peripheralManager = CBPeripheralManager()
    //self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    
    //sounds
    var entersound : AVAudioPlayer?
    
    //lock in portrait orientation
    override func shouldAutorotate() -> Bool {
        return false }
    
    var locationManager:CLLocationManager!
    
    var isBackgroundRed = false
    
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController (title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBOutlet var userName: UITextField!
    @IBOutlet var gameName: UITextField!
    @IBOutlet var offenseTrueSwitch: UISwitch!
    @IBOutlet var nstructionsOutlet: UIButton!
    
    
    
    @IBAction func letsPlay(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == false {
            displayAlert("No internet connection", message: "nFlux requires an active internet/data connection.  Make sure airplane mode on your phone is OFF, and that you have an active data plan.")
        }
//        else if bluetoothOn == false {
//            displayAlert("Bluetooth disabled", message: "nFlux requires bluetooth in order to determine when players get tagged by opponents. Make sure airplane mode on your phone is OFF, and that bluetooth is enabled and authorized.")
//        }
        else if userName.text == "" || gameName.text == "" {
            displayAlert("Missing Field(s)", message: "Username and game name are required")
        }
            //note - must add 12 to desired limit (to account for optional("")  )
        else if String(userName.text).characters.count > 24 {
            displayAlert("Name too long", message: "Please limit your name to 12 characters, sorry!")
        }
        else {
            //get day and month
            let date = NSDate()
            let calendar = NSCalendar.currentCalendar()
            let day = calendar.component(NSCalendarUnit.Day, fromDate: date)
            let month = calendar.component(NSCalendarUnit.Month, fromDate: date)

            globalUserName = userName.text!
            let userNameSuffix = String(String(arc4random_uniform(999999)))
            globalAppendedUserName = "\(globalUserName)\(userNameSuffix)"
            globalGameName = gameName.text!
            globalAppendedGameName = "\(globalGameName)-\(month)-\(day)"
            globalIsOffense = offenseTrueSwitch.on
            
        //check whether game/user name is taken
            let nameCheckQuery = PFQuery(className: "matchRequest")
            nameCheckQuery.whereKey("appendedGameName", equalTo: globalAppendedGameName)
            nameCheckQuery.whereKey("userName", equalTo: globalUserName)
            nameCheckQuery.getFirstObjectInBackgroundWithBlock {
                (matchRequest: PFObject?, error: NSError?) -> Void in
                if error == nil && matchRequest != nil {
                        self.displayAlert("Error", message: "User name already taken!")
                    }
                else {
            
            var user = PFUser()
            user.username = globalAppendedUserName
            user.password = "abc"
            user["isOffense"] = self.offenseTrueSwitch.on
            user["gameName"] = self.gameName.text
            user["appendedGameName"] = globalAppendedGameName
            user.signUpInBackgroundWithBlock {
                (succeded, error) -> Void in
                if let error = error {
                    if let errorString = error.userInfo["error"] as? String {
                        self.displayAlert("Pairing failed", message: errorString)
                    }

                    
                } else {
                    
                    PFUser.logInWithUsernameInBackground(globalAppendedUserName, password:"abc") {
                        (user: PFUser?, error: NSError?) -> Void in
                    
                    let matchRequest = PFObject(className: "matchRequest")
                    matchRequest["userName"] = self.userName.text
                    matchRequest["isOffense"] = self.offenseTrueSwitch.on
                    matchRequest["gameName"] = self.gameName.text
                    matchRequest["appendedGameName"] = globalAppendedGameName
                    matchRequest["heartbeat"] = "n"

                    matchRequest.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                        if error == nil {
                        print("Object has been saved.")
                            if user != nil {
                                
                                globalMatchRequestObjectID = matchRequest.objectId!
                                
                                    self.entersound?.play()
                                
                                self.performSegueWithIdentifier("login", sender:self)
                                }
                            else {
                                if let errorString = error?.userInfo["error"] as? String {
                                    self.displayAlert("Pair failed", message: errorString)
                                }
                            }
                        }
                        if error != nil {
                            self.displayAlert("Error", message: "Trying to connect to network..")
                            matchRequest.saveEventually { (success: Bool, error: NSError?) -> Void in
                                if error == nil {
                                    print("Object has been saved.")
                                    if user != nil {
                                        globalMatchRequestObjectID = matchRequest.objectId!
                                        
                                        self.entersound?.play()
                                        
                                        self.performSegueWithIdentifier("login", sender:self)
                                    }
                                    else {
                                        if let errorString = error?.userInfo["error"] as? String {
                                            self.displayAlert("Pair failed", message: errorString)
                                        }
                                    }
                                }
                                if error != nil {
                                    self.displayAlert("Error", message: "Network connection issues. Please make sure you airplane mode is disabled and you have an active network connection, and restart the game.")
                                }
                                }
                            }
                        }
                        
                    }
                }

            }
                    
                }
            }
        }
    }
    @IBOutlet var defenseOutlet: UILabel!
    @IBOutlet var letsPlayOutlet: UIButton!
    @IBOutlet var offenseOutlet: UILabel!
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        //UI labels
//        let fontsize = self.defenseOutlet.font.pointSize
//        self.offenseOutlet.font = UIFont(name: self.offenseOutlet.font.fontName, size: fontsize)
//        self.defenseOutlet.font = UIFont(name: self.defenseOutlet.font.fontName, size: fontsize)
//        self.letsPlayOutlet.titleLabel?.font = UIFont(name: (self.letsPlayOutlet.titleLabel?.font.fontName)!, size: fontsize)
//        self.nstructionsOutlet.titleLabel?.font = UIFont(name: (self.nstructionsOutlet.titleLabel?.font.fontName)!, size: fontsize)
        
        print("offense label \(self.offenseOutlet.font.pointSize)")
        print("defense label \(self.defenseOutlet.font.pointSize)")
        print("begin label \(self.letsPlayOutlet.titleLabel?.font.pointSize)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if globalIsOffense == false {
            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
            self.isBackgroundRed = true
        }
        
        if globalIsOffense == true {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
            self.isBackgroundRed = false
        }
        
        
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        //labels
//        self.nstructionsOutlet.titleLabel?.adjustsFontSizeToFitWidth = true
//        self.letsPlayOutlet.titleLabel?.adjustsFontSizeToFitWidth = true
        //self.offenseOutlet.adjustsFontSizeToFitWidth = true
        //self.defenseOutlet.adjustsFontSizeToFitWidth = true
        
        let rand = String(arc4random_uniform(999999))
        self.userName.text = rand
        
        //get day and month
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let day = calendar.component(NSCalendarUnit.Day, fromDate: date)
        let month = calendar.component(NSCalendarUnit.Month, fromDate: date)
        let minute = calendar.component(NSCalendarUnit.Minute, fromDate: date)
        
        self.gameName.text = "\(month)-\(day)-\(minute)"
        
        
        //sounds 
        if let entersound = self.setupAudioPlayerWithFile("entersound", type:"mp3") {
            self.entersound = entersound
        }
        
        //set switch
        offenseTrueSwitch.on = globalIsOffense
        
        //switch off color
        self.offenseTrueSwitch.tintColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.offenseTrueSwitch.backgroundColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.offenseTrueSwitch.layer.cornerRadius = 16.0
        
        //request location use authorization
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
//        locationManager.requestAlwaysAuthorization()
        
        //hide keyboard
        self.userName.delegate = self
        self.gameName.delegate = self
        
        //hide keyboard when tap on background
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        //check for internet connection
        if Reachability.isConnectedToNetwork() == false {
            displayAlert("No internet connection", message: "You must have an active internet/data connection to play.  Make sure airplane mode on your phone is OFF, and that you have an active data plan.")
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    // Dismiss the keyboard when the user taps the "Return" key or its equivalent
    // while editing a text field.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }

    @IBAction func didSwitch(sender: AnyObject) {
        if self.isBackgroundRed == false {
            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
            self.isBackgroundRed = true
            globalIsOffense = false
        }
        
        else {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
            self.isBackgroundRed = false
            globalIsOffense = true
        }

    }

    //hide keyboard when background is tapped
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func button(sender: AnyObject) {
        let url = NSURL(string: "https://twitter.com/2080ar")
        UIApplication.sharedApplication().openURL(url!)
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
    
    @IBAction func nStructionsButton(sender: AnyObject) {
        globalIsOffense = offenseTrueSwitch.on
        self.performSegueWithIdentifier("showInstructionsViewControllerFromViewController", sender:self)
    }
    
}
