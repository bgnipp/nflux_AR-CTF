//
//  DefenseItemsInstructionsViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 1/31/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class DefenseItemsInstructionsViewController: UIViewController {

    
    //set up UI alerts
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController (title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //lock in portrait orientation
    override func shouldAutorotate() -> Bool {
        return false }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //background colors
            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func scanButton(sender: AnyObject) {
        displayAlert("Scan", message: "Reveals the location of all opponents in a selected area of the map")
    }

    @IBAction func superscanButton(sender: AnyObject) {
        displayAlert("Super Scan", message: "Reveals the location of all opponents for about 20 seconds")
    }
    
    @IBAction func mineButton(sender: AnyObject) {
        displayAlert("Mine", message: "Plants a mine on the map that triggers when an opponent gets near, tagging them.  Must be planted within 20 feet from you, and can't be planted in the base or flag zones.")
    }
    
    @IBAction func supermineButton(sender: AnyObject) {
        displayAlert("Super Mine", message: "Plants a mine on the map that triggers when an opponent gets near, tagging all opponents in the area.  Must be planted within 20 feet from you, and can't be planted in the base or flag zones.")
    }
    
    @IBAction func bombButton(sender: AnyObject) {
        displayAlert("Bomb", message: "Tags all players (even teammates) in a selected area of the map.  Can't be dropped in the flag zone.")
    }
    
    @IBAction func superbombButton(sender: AnyObject) {
        displayAlert("Super Bomb", message: "Tags all players (even teammates) in a selected area of the map (larger reach than the regular bomb).  Can't be dropped in the flag zone.")
    }
    
    @IBAction func jammerButton(sender: AnyObject) {
        displayAlert("Jammer", message: "When an opponent scans, it will not reveal the location of any opponents.  Lasts one minute.")
    }
    
    @IBAction func spybotButton(sender: AnyObject) {
        displayAlert("Spybot", message: "Gets planted at a selected point on the map, and reveals the location of all opponents in that area.  Lasts two minutes.")
    }
    
    @IBAction func reachButton(sender: AnyObject) {
        displayAlert("Reach", message: "Can tag opponents from futher away.  Lasts one minute.")
    }
    
    @IBAction func senseButton(sender: AnyObject) {
        displayAlert("Sense", message: "Detects the location of opponents who are near.  Lasts one minute.")
    }
    
    @IBAction func sickleButton(sender: AnyObject) {
        displayAlert("Sickle", message: "Tags the opponent closest to you")
    }
    
    @IBAction func lightningButton(sender: AnyObject) {
        displayAlert("Lightning", message: "Tags all opponents")
    }
    

    
}
