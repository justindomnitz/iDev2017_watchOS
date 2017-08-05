//
//  TweetInterfaceController.swift
//  iDev2017_watchOS WatchKit Extension
//
//  Created by Justin Domnitz on 7/11/17.
//  Copyright © 2017 Lowyoyo, LLC. All rights reserved.
//

import WatchKit
import Foundation

class TweetInterfaceController: WKInterfaceController {

    @IBOutlet var tweetTable: WKInterfaceTable!
    @IBOutlet var loadingLabel: WKInterfaceLabel!
    @IBOutlet var activityIndicatorGroup: WKInterfaceGroup!
    
    var tweets = [[Tweet]]()
    var hashtag = "360iDev"
    
    //MARK: - Lifecycle Methods
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        print("TweetInterfaceController - awake")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        print("TweetInterfaceController - willActivate")
        
        getTwitterData()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    
        print("TweetInterfaceController - didDeactivate")
    }
    
    //MARK: - Helper Methods
    
    func getTwitterData() {
        
        tweetTable.setHidden(true)
        loadingLabel.setHidden(false)
        startActivityIndicator()
        
        TwitterInterface().requestTwitterSearchResults(hashtag, completion: { (tweets, error) -> Void in
            if error == nil {
                DispatchQueue.main.async {
                    
                    self.loadingLabel.setHidden(true)
                    self.tweetTable.setHidden(false)
                    self.stopActivityIndicator()
                    
                    if let validTweets = tweets {
                        self.tweets.removeAll()
                        self.tweets.insert(validTweets, at: 0)
                        self.tweetTable.setNumberOfRows(validTweets.count, withRowType: "tweetRowController")
                        for (index, tweet) in validTweets.enumerated() {
                            if let row = self.tweetTable.rowController(at: index) as? TweetRowController {
                                row.tweetLabel.setText(tweet.text)
//                                if let profileImageURL = tweet.user.profileImageURL {
//                                    if let imageData = try? Data(contentsOf: profileImageURL as URL) { // TO-DO: blocks main thread!
//                                        row.tweetImage.setImage(UIImage(data: imageData))
//                                    }
//                                }
                            }
                        }
                    }
                }
            }
            else {
                print(error.debugDescription)
            }
        })
    }
    
    func startActivityIndicator() {
        activityIndicatorGroup.setHidden(false)
        activityIndicatorGroup.setBackgroundImageNamed("spinner")
        activityIndicatorGroup.startAnimatingWithImages(in: NSMakeRange(1,42), duration: 1.5, repeatCount: -1)
    }
    
    func stopActivityIndicator() {
        activityIndicatorGroup.stopAnimating()
        activityIndicatorGroup.setHidden(true)
    }

}
