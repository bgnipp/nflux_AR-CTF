//
//  PointLocationViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 9/22/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import MapKit
import Parse
import CoreLocation
import CoreBluetooth
import AudioToolbox
import AVFoundation

class PointLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, CBPeripheralManagerDelegate {
    
    //sounds
    var entersoundlow : AVAudioPlayer?
    var backsound : AVAudioPlayer?
    
    //lock in portrait orientation
    override func shouldAutorotate() -> Bool {
        return false }

    @IBOutlet var mapView: MKMapView!
    
    var locationManager:CLLocationManager!
    var mapCamera = MKMapCamera()
    var initialMapSetup = false
    var initialMapSetup2 = false
    
    
    //point location submitted, 0 = none have been submitted, 1 = "point" has been, 2 = both "point" and base have been submitted
    var pointLocationSubmitted = 0
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
    var pointCircle = MKCircle()
    var pointDropPin = MKPointAnnotation()
    var pointRegionRadius: Double = 0
    var pointCoordinate = CLLocationCoordinate2D()
    var baseCircle = MKCircle()
    var baseDropPin = CustomPinBase(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Offense's base")
    
    //refresh timer
    var pointLocationSystemTimer = NSTimer()
    var pointLocationSystemTimerCount: Int = 3
    
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var feetLabel: UILabel!
    @IBOutlet var radiusTextField: UITextField!
    @IBOutlet var selectButtonText: UIButton!
    @IBOutlet var pin: UIImageView!
    @IBOutlet var helpButtonOutlet: UIButton!
    
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController (title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func selectButton(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == false {
            displayAlert("No internet connection", message: "nFlux requires an active internet/data connection. Make sure airplane mode on your phone is OFF, and that you have an active data plan.")
        }
//        else if bluetoothOn == false {
//            displayAlert("Bluetooth disabled", message: "nFlux requires bluetooth in order to determine when players get tagged by opponents. Make sure airplane mode on your phone is OFF, and that bluetooth is enabled and authorized.")
//        }
        else if self.radiusTextField.text == "" && self.pointLocationSubmitted != 2 {
            
            self.displayAlert("Error", message: "Enter radius")
        }
            
        else if self.pointLocationSubmitted == 2 {
            
            var query = PFQuery(className:"gameInfo")
            query.getObjectInBackgroundWithId(gameInfoObjectID) {
                (gameInfo: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    self.displayAlert("Error", message: "Network error, try again")
                    
                } else if let gameInfo = gameInfo {
                    gameInfo["isActive"] = true
                    gameInfo.saveInBackground()
                  
                    self.pointLocationSystemTimer.invalidate()
                    self.performSegueWithIdentifier("showWaitingViewController", sender: nil)
                
                }
            }
            }
        
        else if self.pointLocationSubmitted == 1 && self.radiusTextField.text != "" {
            
            var screenCoordinate = mapView.centerCoordinate
            let baseRegionRadius: Double = Double(self.radiusTextField.text!)!
            let baseCoordinate = CLLocationCoordinate2D(latitude: screenCoordinate.latitude, longitude: screenCoordinate.longitude)
            let radiusCheck: Double = self.pointRegionRadius + baseRegionRadius
            let checkRegion = CLCircularRegion(center: baseCoordinate, radius: radiusCheck, identifier: "temp")
            
                if checkRegion.containsCoordinate(self.pointCoordinate) {
                    self.displayAlert("Error", message: "Flag and base zones can't overlap!")
                    self.backsound?.play()
                    
                    }
            
                else {
                        var query = PFQuery(className:"gameInfo")
                        query.getObjectInBackgroundWithId(gameInfoObjectID) {
                (gameInfo: PFObject?, error: NSError?) -> Void in
                if error != nil {
                   self.displayAlert("Error", message: "Network error, try again")
                } else if let gameInfo = gameInfo {
                    gameInfo["baseLat"] = screenCoordinate.latitude
                    gameInfo["baseLong"] = screenCoordinate.longitude
                    gameInfo["baseRadius"] = Int(self.radiusTextField.text!)
                    gameInfo.saveInBackground()
                    
                    self.entersoundlow?.play()
                    
                    //add base annotation pin to map view
                    self.baseDropPin.coordinate = screenCoordinate
                    self.baseDropPin.title = "Offense's base"
                    self.mapView.addAnnotation(self.baseDropPin)
            
            
                    //set up circle overlay on base region
                    self.baseCircle = MKCircle(centerCoordinate: screenCoordinate, radius: CLLocationDistance(Double(self.radiusTextField.text!)!))
                    self.mapView.addOverlay(self.baseCircle)
                    
                    self.pin.hidden = true
                    self.selectButtonText.setTitle("begin", forState: UIControlState.Normal)
                    self.headerLabel.text = "ready to begin"
                    self.pointLocationSubmitted = 2
                    self.radiusTextField.hidden = true
                    self.feetLabel.hidden = true
                }
            }
            }
            
        }
        
        else if self.pointLocationSubmitted == 0 && self.radiusTextField.text != "" {
            
        var screenCoordinate = mapView.centerCoordinate
        var query = PFQuery(className:"gameInfo")
        query.getObjectInBackgroundWithId(gameInfoObjectID) {
            (gameInfo: PFObject?, error: NSError?) -> Void in
            if error != nil {
                self.displayAlert("Error", message: "Network error, try again")
            } else if let gameInfo = gameInfo {
                gameInfo["inGameInfoObjectID"] = inGameInfoObjectID
                gameInfo["itemInfoObjectID"] = itemInfoObjectID
                gameInfo["pointLat"] = screenCoordinate.latitude
                gameInfo["pointLong"] = screenCoordinate.longitude
                gameInfo["pointRadius"] = Int(self.radiusTextField.text!)
                self.pointCoordinate = CLLocationCoordinate2D(latitude: screenCoordinate.latitude, longitude: screenCoordinate.longitude)
                self.pointRegionRadius = Double(self.radiusTextField.text!)!
               
                gameInfo.saveInBackground()
                
                //play sound
                self.entersoundlow?.play()
                
                //add flag annotation pin to map view
                self.pointDropPin.coordinate = screenCoordinate
                self.pointDropPin.title = "Flag"
                self.mapView.addAnnotation(self.pointDropPin)
              
                //set up circle overlay on flag region
                self.pointCircle = MKCircle(centerCoordinate: screenCoordinate, radius: CLLocationDistance(Double(self.radiusTextField.text!)!))
                self.mapView.addOverlay(self.pointCircle)
                self.selectButtonText.setTitle("select", forState: UIControlState.Normal)
                self.headerLabel.text = "select base zone"
                self.pin.contentMode = UIViewContentMode.ScaleAspectFit
                self.pin.image = UIImage(named:"basePin.png")
                self.pointLocationSubmitted = 1
                self.radiusTextField.text = "40"
                
                }
            }
        }
   
    }
    
    
    @IBAction func clearButton(sender: AnyObject) {
        
        if pointLocationSubmitted == 1 {
        
            self.selectButtonText.setTitle("select", forState: UIControlState.Normal)
            self.headerLabel.text = "select flag zone"
            self.pin.frame.size.height = 120
            self.pin.frame.size.width = 80
            self.pin.image = UIImage(named:"robotFlag.png")
            self.pin.hidden = false
            self.mapView.removeAnnotation(self.pointDropPin)
            self.mapView.removeOverlay(self.pointCircle)
            
            self.backsound?.play()
        
            self.pointLocationSubmitted = 0
        }
       
        else if pointLocationSubmitted == 2 {
            
            self.selectButtonText.setTitle("select", forState: UIControlState.Normal)
            self.headerLabel.text = "select base zone"
            self.pin.image = UIImage(named:"basePin.png")
            self.pin.frame.size.height = 80
            self.pin.frame.size.width = 29
            self.mapView.removeAnnotation(self.baseDropPin)
            self.mapView.removeOverlay(self.baseCircle)
            self.radiusTextField.hidden = false
            self.feetLabel.hidden = false
            self.pin.hidden = false
            
            self.backsound?.play()
            
            self.pointLocationSubmitted = 1
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
        
        //set radius field
        self.radiusTextField.text = "40"
        
        //sounds
        if let entersoundlow = self.setupAudioPlayerWithFile("entersoundlow", type:"mp3") {
            self.entersoundlow = entersoundlow
        }
        self.entersoundlow?.volume = 0.8
        if let backsound = self.setupAudioPlayerWithFile("backsound", type:"mp3") {
            self.backsound = backsound
        }
        self.backsound?.volume = 0.8
        
        //hide keyboard when tap on background
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        //background colors
        if globalIsOffense == false {
            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
        }
        
        if globalIsOffense == true {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
        }
        
        //numpad keyboard
        self.radiusTextField.keyboardType = UIKeyboardType.NumberPad
        
        
        //start system
        self.pointLocationSystemTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("pointLocationSystemTimerUpdate"), userInfo: nil, repeats: true)
        self.pointLocationSystemTimer.tolerance = 0.3
        
        //keyboard hide
        self.radiusTextField.delegate = self
        
        self.mapView.delegate = self
        mapView.showsUserLocation = true
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        //locationManager.startMonitoringSignificantLocationChanges()
        self.mapView.mapType = MKMapType.Hybrid
        self.mapView.showsBuildings = true

    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        if self.initialMapSetup == false {
//            self.initialMapSetup = true
//        self.mapCamera = MKMapCamera(lookingAtCenterCoordinate: CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude), fromDistance: 400, pitch: 0, heading: 45)
//        self.mapView.setCamera(self.mapCamera, animated: false)
//            self.mapView.setCamera(self.mapCamera, animated: false)
//        }
//    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.initialMapSetup2 == false {
            let center = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004))
            self.initialMapSetup2 = true
            self.mapView.setRegion(region, animated: false)
        }
    }

    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("location manager fired:)")
        var location:CLLocationCoordinate2D = manager.location!.coordinate
        
        self.latitude = location.latitude
        self.longitude = location.longitude
        //self.mapView.setRegion(region, animated: false)
        
        if self.initialMapSetup == false {
            let center = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004))
            self.initialMapSetup = true
        self.mapView.setRegion(region, animated: false)
        }
        
    }
    
    
    //RADIUS OVERLAY ON POINT AND BASE PIN MAP ANNOTATIONS
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay as! MKCircle  == self.baseCircle {
            var overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
            overlayRenderer.lineWidth = 3.0
            overlayRenderer.strokeColor = UIColor.blueColor()
            return overlayRenderer
        }
            
        else {
            var overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
            overlayRenderer.lineWidth = 3.0
            overlayRenderer.strokeColor = UIColor.redColor()
            return overlayRenderer
        }
    }

    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        //set offense pins to blue color
//        if annotation is CustomPinBlue {
//            let pin3 = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin3")
//            pin3.pinTintColor = UIColor.blueColor()
//            pin3.canShowCallout = true
//            return pin3
//        }
        
        if annotation is CustomPinBase {
            let baseDropPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "baseDropPin")
            baseDropPin.canShowCallout = true
            baseDropPin.image = UIImage(named:"basePin.png")
            baseDropPin.frame.size.height = 110
            baseDropPin.frame.size.width = 37
            return baseDropPin
        }
        
        //set flag graphic
        let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        //pin.pinTintColor = UIColor.redColor()
        pin.canShowCallout = true
        pin.image = UIImage(named:"robotMapFlag.png")
        pin.frame.size.height = 120
        pin.frame.size.width = 80
        return pin
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

    @IBAction func cancelButton(sender: AnyObject) {
    
    self.backsound?.play()
    self.pointLocationSystemTimer.invalidate()
        if itemsOn == false {
            self.performSegueWithIdentifier("showGameOptionsViewControllerFromPointLocationViewController", sender: nil)
        }
        else {
        self.performSegueWithIdentifier("showItemOptionsViewControllerFromPointLocationViewController", sender: nil)
        }
    }
    
    //system timer
    func pointLocationSystemTimerUpdate() {
        if(pointLocationSystemTimerCount > 0)
        {
            pointLocationSystemTimerCount--
        }
        if(pointLocationSystemTimerCount == 0)
        {
            pointLocationSystemTimerCount = 3
            
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
    
    @IBAction func helpButton(sender: AnyObject) {
        
        if self.pointLocationSubmitted == 0 {
        self.displayAlert("Select flag zone", message: "Enter radius")
        }
        else if self.pointLocationSubmitted == 1 {
            self.displayAlert("Select base zone", message: "Enter radius")
        }
        else if self.pointLocationSubmitted == 2 {
            self.displayAlert("Begin Game", message: "Allows other players to join the game.  The game begins when after everybody joins.")
        }
        
    }
    
    
    //hide keyboard when background is tapped
    func dismissKeyboard() {
        view.endEditing(true)
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
    
    
}
