//
//  TagViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 9/13/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class TagViewController: UIViewController {

    override func viewDidLoad() {
  
        let query = PFQuery(className: "matchRequest")
        query.whereKey("userName", notEqualTo: PFUser.currentUser()!.username!)
        query.orderByDescending("createdAt")
        query.limit = 1
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            
            if let objects = objects {
                
                for object in objects {
                    
                    var pairedUserUUID = object["player1UUID"] as? String
                    var pairedUser = object["userName"] as? String
                        print(pairedUser)
                        print(pairedUserUUID)
                }
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
