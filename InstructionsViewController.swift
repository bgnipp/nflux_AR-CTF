//
//  InstructionsViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 10/30/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import AVFoundation

class InstructionsViewController: UIViewController {
    
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
    
    //lock in portrait orientation
    override func shouldAutorotate() -> Bool {
        return false }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(globalIsOffense)
        
        if globalIsOffense == false {
            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
        }
        
        if globalIsOffense == true {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
        }
 

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func overviewButton(sender: AnyObject) {
        var url = NSURL(string: "https://youtu.be/ehLMjZt3FPA")
        UIApplication.sharedApplication().openURL(url!)
      
    }

}
