//
//  EventLogViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 12/19/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class EventLogViewController: UIViewController {
    
    @IBOutlet var e1: UILabel!
    @IBOutlet var e2: UILabel!
    @IBOutlet var e3: UILabel!
    @IBOutlet var e4: UILabel!
    @IBOutlet var e5: UILabel!
    @IBOutlet var e6: UILabel!
    @IBOutlet var e7: UILabel!
    @IBOutlet var e8: UILabel!
    @IBOutlet var e9: UILabel!
    @IBOutlet var e10: UILabel!
    @IBOutlet var e11: UILabel!
    @IBOutlet var e12: UILabel!
    
    //log refresh timer
    var logRefreshTimer = NSTimer()
    var logRefreshTimerCount: Int = 10
    
    //lock in portrait orientation
    override func shouldAutorotate() -> Bool {
        return false }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //background colors
        if globalIsOffense == false {
            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
        }
        
        if globalIsOffense == true {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
        }
        
        self.updateLog()
        
        //start refresh timer
        self.logRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("logRefreshTimerUpdate"), userInfo: nil, repeats: true)
        self.logRefreshTimer.tolerance = 0.2

    }

    @IBAction func backButton(sender: AnyObject) {
        
        self.logRefreshTimer.invalidate()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //log refresh timer
    func logRefreshTimerUpdate() {
        if(logRefreshTimerCount > 0)
        {
            logRefreshTimerCount--
        }
        if(logRefreshTimerCount == 0)
        {
            logRefreshTimerCount = 4
            self.updateLog()
        }
    }
    
    func updateLog() {
        
        print(gameTimerCount)
        
        if eventsArray.count >= 2 {
            var timeAgo = Int(eventsArray[0])! - gameTimerCount
            if timeAgo < 0 { timeAgo = 0 }
            let min = timeAgo / 60
            let sec = timeAgo % 60
            if min == 0 {
                self.e1.text = "\(sec)s  \(eventsArray[1])"
            }
            else {
                var secStr = String(sec)
                if secStr.characters.count == 1 {
                    secStr = "0\(secStr)"
                }
                self.e1.text = "\(min):\(secStr)  \(eventsArray[1])"
            }
        }
        
        if eventsArray.count >= 4 {
            var timeAgo = Int(eventsArray[2])! - gameTimerCount
            if timeAgo < 0 { timeAgo = 0 }
            let min = timeAgo / 60
            let sec = timeAgo % 60
            if min == 0 {
                self.e2.text = "\(sec)s  \(eventsArray[3])"
            }
            else {
                var secStr = String(sec)
                if secStr.characters.count == 1 {
                    secStr = "0\(secStr)"
                }
                self.e2.text = "\(min):\(secStr)  \(eventsArray[3])"
            }
        }
        
        if eventsArray.count >= 6 {
            var timeAgo = Int(eventsArray[4])! - gameTimerCount
            if timeAgo < 0 { timeAgo = 0 }
            let min = timeAgo / 60
            let sec = timeAgo % 60
            if min == 0 {
                self.e3.text = "\(sec)s  \(eventsArray[5])"
            }
            else {
                var secStr = String(sec)
                if secStr.characters.count == 1 {
                    secStr = "0\(secStr)"
                }
                self.e3.text = "\(min):\(secStr)  \(eventsArray[5])"
            }
        }
        
        if eventsArray.count >= 8 {
            var timeAgo = Int(eventsArray[6])! - gameTimerCount
            if timeAgo < 0 { timeAgo = 0 }
            let min = timeAgo / 60
            let sec = timeAgo % 60
            if min == 0 {
                self.e4.text = "\(sec)s  \(eventsArray[7])"
            }
            else {
                var secStr = String(sec)
                if secStr.characters.count == 1 {
                    secStr = "0\(secStr)"
                }
                self.e4.text = "\(min):\(secStr)  \(eventsArray[7])"
            }
        }
        
        if eventsArray.count >= 10 {
            var timeAgo = Int(eventsArray[8])! - gameTimerCount
            if timeAgo < 0 { timeAgo = 0 }
            let min = timeAgo / 60
            let sec = timeAgo % 60
            if min == 0 {
                self.e5.text = "\(sec)s  \(eventsArray[9])"
            }
            else {
                var secStr = String(sec)
                if secStr.characters.count == 1 {
                    secStr = "0\(secStr)"
                }
                self.e5.text = "\(min):\(secStr)  \(eventsArray[9])"
            }
        }
        
        if eventsArray.count >= 12 {
            var timeAgo = Int(eventsArray[10])! - gameTimerCount
            if timeAgo < 0 { timeAgo = 0 }
            let min = timeAgo / 60
            let sec = timeAgo % 60
            if min == 0 {
                self.e6.text = "\(sec)s  \(eventsArray[11])"
            }
            else {
                var secStr = String(sec)
                if secStr.characters.count == 1 {
                    secStr = "0\(secStr)"
                }
                self.e6.text = "\(min):\(secStr)  \(eventsArray[11])"
            }
        }
        
        if eventsArray.count >= 14 {
            var timeAgo = Int(eventsArray[12])! - gameTimerCount
            if timeAgo < 0 { timeAgo = 0 }
            let min = timeAgo / 60
            let sec = timeAgo % 60
            if min == 0 {
                self.e7.text = "\(sec)s  \(eventsArray[13])"
            }
            else {
                var secStr = String(sec)
                if secStr.characters.count == 1 {
                    secStr = "0\(secStr)"
                }
                self.e7.text = "\(min):\(secStr)  \(eventsArray[13])"
            }
        }
        
        if eventsArray.count >= 16 {
            var timeAgo = Int(eventsArray[14])! - gameTimerCount
            if timeAgo < 0 { timeAgo = 0 }
            let min = timeAgo / 60
            let sec = timeAgo % 60
            if min == 0 {
                self.e8.text = "\(sec)s  \(eventsArray[15])"
            }
            else {
                var secStr = String(sec)
                if secStr.characters.count == 1 {
                    secStr = "0\(secStr)"
                }
                self.e8.text = "\(min):\(secStr)  \(eventsArray[15])"
            }
        }
        
        if eventsArray.count >= 18 {
            var timeAgo = Int(eventsArray[16])! - gameTimerCount
            if timeAgo < 0 { timeAgo = 0 }
            let min = timeAgo / 60
            let sec = timeAgo % 60
            if min == 0 {
                self.e9.text = "\(sec)s  \(eventsArray[17])"
            }
            else {
                var secStr = String(sec)
                if secStr.characters.count == 1 {
                    secStr = "0\(secStr)"
                }
                self.e9.text = "\(min):\(secStr)  \(eventsArray[17])"
            }
        }
        
        if eventsArray.count >= 20 {
            var timeAgo = Int(eventsArray[18])! - gameTimerCount
            if timeAgo < 0 { timeAgo = 0 }
            let min = timeAgo / 60
            let sec = timeAgo % 60
            if min == 0 {
                self.e10.text = "\(sec)s  \(eventsArray[19])"
            }
            else {
                var secStr = String(sec)
                if secStr.characters.count == 1 {
                    secStr = "0\(secStr)"
                }
                self.e10.text = "\(min):\(secStr)  \(eventsArray[19])"
            }
        }
        
        if eventsArray.count >= 22 {
            var timeAgo = Int(eventsArray[20])! - gameTimerCount
            if timeAgo < 0 { timeAgo = 0 }
            let min = timeAgo / 60
            let sec = timeAgo % 60
            if min == 0 {
                self.e11.text = "\(sec)s  \(eventsArray[21])"
            }
            else {
                var secStr = String(sec)
                if secStr.characters.count == 1 {
                    secStr = "0\(secStr)"
                }
                self.e11.text = "\(min):\(secStr)  \(eventsArray[21])"
            }
        }
        
        if eventsArray.count >= 24 {
            var timeAgo = Int(eventsArray[22])! - gameTimerCount
            if timeAgo < 0 { timeAgo = 0 }
            let min = timeAgo / 60
            let sec = timeAgo % 60
            if min == 0 {
                self.e12.text = "\(sec)s  \(eventsArray[23])"
            }
            else {
                var secStr = String(sec)
                if secStr.characters.count == 1 {
                    secStr = "0\(secStr)"
                }
                self.e12.text = "\(min):\(secStr)  \(eventsArray[23])"
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
