//
//  InterfaceController.swift
//  iDev2017_watchOS WatchKit Extension
//
//  Created by Justin Domnitz on 7/11/17.
//  Copyright © 2017 Lowyoyo, LLC. All rights reserved.
//

import WatchKit
import Foundation
import UserNotifications

class InterfaceController: WKInterfaceController, UNUserNotificationCenterDelegate {

    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var titleImageView: WKInterfaceImage!
    
    override func awake(withContext context: Any?) {
        print("InterfaceController - \(#function)")
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        print("InterfaceController - \(#function)")
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didAppear() {
        print("InterfaceController - \(#function)")
        super.didAppear()
        
        titleLabel.setText("Hello, Dragonstone!")
        titleImageView.setImage(UIImage(named: "Dragonstone"))
    }
    
    override func didDeactivate() {
        print("InterfaceController - \(#function)")
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func triggerFallbackLocalNotification() {
        print("InterfaceController - \(#function)")
        //to do
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                         withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("InterfaceController - \(#function)")
        cancelFallbackNotifications()
        if #available(watchOSApplicationExtension 4.0, *) {
            WKInterfaceController.reloadRootPageControllers(withNames: ["cookingController"],
                                                            contexts: nil, orientation: .horizontal, pageIndex: 0)
        } else {
            // Fallback on earlier versions
        }
        WKInterfaceDevice.current().play(.success)
        completionHandler(.alert)
    }
    
    func cancelFallbackNotifications() {
        print("InterfaceController - \(#function)")
        // to do
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        print("InterfaceController - \(#function)")
        let fireDate = Date()
        
        for task in backgroundTasks {
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Perform functions as needed
                WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate: fireDate, userInfo: nil) { error in
                    // code
                }
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set // your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            default:
                break
            }
        }
    }
    
    // MARK: - Future - Settings Menu
    
    func settingsMenuItemSelected() {
        //presentController(withName: "Settings", context: nil)
    }
    
    // MARK: - Future - Haptic Feedback

    func haptic() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 25 * 60) {
            WKInterfaceDevice.current().play(.success)
        }
        
        WKInterfaceDevice.current().play(.start)
    }
}
