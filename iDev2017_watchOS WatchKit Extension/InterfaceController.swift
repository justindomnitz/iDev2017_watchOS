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

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @available(watchOSApplicationExtension 4.0, *)
    @IBAction func orderButtonPressed() {
        let orderPostURL = URL(string: "https://www.google.com/")!
        
        let session = NetworkUtilities() //.backgroundSession
        _ = session.downloadTask(with: orderPostURL)
        WKExtension.shared().isFrontmostTimeoutExtended = true
        triggerFallbackLocalNotification()
        WKInterfaceController.reloadRootPageControllers(withNames: ["orderController"],
            contexts: nil, orientation: .horizontal, pageIndex: 0)
    }
    
    func triggerFallbackLocalNotification() {
        //to do
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                         withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
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
        // to do
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        let fireDate = Date()
        
        for task in backgroundTasks {
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Perform functions as needed
                WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate: fireDate, userInfo: nil) { error in
                    // code
                }
                backgroundTask.setTaskCompleted()
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set // your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            default:
                break
            }
        }
    }
}
