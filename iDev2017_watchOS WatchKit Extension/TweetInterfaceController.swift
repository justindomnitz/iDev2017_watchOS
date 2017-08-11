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
        print("TweetInterfaceController - \(#function)")

        super.awake(withContext: context)
    }
    
    override func willActivate() {
        print("TweetInterfaceController - \(#function)")

        super.willActivate()
    }
    
    override func didAppear() {
        print("TweetInterfaceController - \(#function)")

        clearTwitterData()
        getTwitterData()
    }
    
    override func willDisappear() {
        print("TweetInterfaceController - \(#function)")

        clearTwitterData()
    }
    
    override func didDeactivate() {
        print("TweetInterfaceController - \(#function)")

        super.didDeactivate()
    }
    
    //MARK: - Helper Methods
    
    func clearTwitterData() {
        tweetTable.setHidden(true)
    }
    
    func getTwitterData() {
        
        loadingLabel.setHidden(false)
        startActivityIndicator()
        
        //Static data.
        /*
        delay(1) {
            var validTweets = [Tweet]()
            
            let tweet1 = Tweet()
            var user1 = User()
            tweet1?.text = "Winter is coming!"
            user1.screenName = "John Snow"
            tweet1?.user = user1
            if let tweet1 = tweet1 {
                validTweets.append(tweet1)
            }
            let tweet2 = Tweet()
            var user2 = User()
            tweet2?.text = "I'm the queen of dragons!"
            user2.screenName = "Daenerys Targaryen"
            tweet2?.user = user2
            if let tweet2 = tweet2 {
                validTweets.append(tweet2)
            }
            
            self.loadingLabel.setHidden(true)
            self.tweetTable.setHidden(false)
            self.stopActivityIndicator()
            self.tweetTable.setNumberOfRows(validTweets.count, withRowType: "tweetRowController")
            for (index, tweet) in validTweets.enumerated() {
                if let row = self.tweetTable.rowController(at: index) as? TweetRowController {
                    row.tweetLabel.setText(tweet.text)
                    row.tweetImage.setImage(UIImage(named: "DaenerysTargaryen"))
                }
            }
        }
        */
        
        //Data from server.
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
                                if let profileImageURL = tweet.user.profileImageURL {
                                    if let imageData = try? Data(contentsOf: profileImageURL as URL) { // TO-DO: blocks main thread!
                                        row.tweetImage.setImage(UIImage(data: imageData))
                                    }
                                }
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

    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
}
