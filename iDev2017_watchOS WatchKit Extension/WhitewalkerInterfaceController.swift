//
//  WhitewalkerInterfaceController.swift
//  iDev2017_watchOS WatchKit Extension
//
//  Created by Justin Domnitz on 8/13/17.
//  Copyright © 2017 Lowyoyo, LLC. All rights reserved.
//

import WatchKit
import Foundation


class WhitewalkerInterfaceController: WKInterfaceController {

    @IBOutlet var radarImageView: WKInterfaceImage!
    
    override func awake(withContext context: Any?) {
        print("WhitewalkerInterfaceController - \(#function)")
        super.awake(withContext: context)
        
        // Configure interface objects here.
        NotificationCenter.default.addObserver(self, selector: #selector(becomeCurrent), name: Notification.Name(rawValue: "WhitewalkerInterfaceControllerBecomeCurrent"), object: nil)
    }

    override func willActivate() {
        print("WhitewalkerInterfaceController - \(#function)")
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didAppear() {
        print("WhitewalkerInterfaceController - \(#function)")
        super.didAppear()
        
        radarImageView.setImage(UIImage(named:"ic_leak_add_white_48dp"))
    }
    
    override func didDeactivate() {
        print("WhitewalkerInterfaceController - \(#function)")
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @objc func becomeCurrent() {
        becomeCurrentPage()
    }
    
}
