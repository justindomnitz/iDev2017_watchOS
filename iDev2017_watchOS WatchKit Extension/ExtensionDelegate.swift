//
//  ExtensionDelegate.swift
//  iDev2017_watchOS WatchKit Extension
//
//  Created by Justin Domnitz on 7/11/17.
//  Copyright © 2017 Lowyoyo, LLC. All rights reserved.
//

import WatchKit
import UserNotifications

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        print("ExtensionDelegate - \(#function)")

        // Perform any final initialization of your application.
        
        UNUserNotificationCenter.current().delegate = self
        
        setExtensionBackgroundRefresh()
    }

    func applicationDidBecomeActive() {
        print("ExtensionDelegate - \(#function)")

        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        print("ExtensionDelegate - \(#function)")

        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    // MARK: - Snapshot Handling
    
    private func processSnapshot() {
        print("ExtensionDelegate - \(#function)")
        //NotificationCenter.default.post(name: Notification.Name(rawValue: "WhitewalkerInterfaceControllerBecomeCurrent"), object: nil)
    }
    
    // MARK: - Background Refresh
        
    private func setExtensionBackgroundRefresh() {
        print("ExtensionDelegate - \(#function)")

        if let preferredDate = Calendar.current.date(byAdding: .second, value: 30, to: Date()) {
            print("Scheduled background refresh date: \(preferredDate)")
            WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: preferredDate, userInfo: nil, scheduledCompletion: { error in
                if error != nil {
                    print("Scheduled background refresh failed with error: \(error.debugDescription)")
                }
            })
        }
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        print("ExtensionDelegate - \(#function)")

        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                print("Here's where we should refresh Twitter data in the background!")
                setExtensionBackgroundRefresh()
                backgroundTask.setTaskCompletedWithSnapshot(true)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                processSnapshot()
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(true)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(true)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(true)
            }
        }
    }

}

extension ExtensionDelegate: UNUserNotificationCenterDelegate {
 
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

}
