//
//  ItemsInstructionsViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 1/31/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ItemsInstructionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //background colors
        if globalIsOffense == false {
            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
        }
        
        if globalIsOffense == true {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
        }


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    

}
