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

        //clearTwitterData()
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
        print("TweetInterfaceController - \(#function)")

        tweetTable.setHidden(true)
    }
    
    func getTwitterData() {
        print("TweetInterfaceController - \(#function)")

        loadingLabel.setHidden(false)
        startActivityIndicator()
        
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
                self.populateWithStaticData()
            }
        })
        
    }
    
    func populateWithStaticData() {
        //Static data.
        delay(1) {
            var validTweets = [Tweet]()
            
            let staticTweets = [["Winter is coming!"        , "John Snow"         , "JohnSnow"         ],
                                ["Hodor"                    , "Hodor"             , "Hodor"            ],
                                ["Dragon stone rocks!"      , "The Team"          , "Dragonstone"      ],
                                ["I'm the queen of dragons!", "Daenerys Targaryen", "DaenerysTargaryen"]]
            
            for staticTweet in staticTweets {
                let tweet = Tweet()
                var user = User()
                tweet?.text = staticTweet[0]
                user.screenName = staticTweet[1]
                tweet?.user = user
                if let tweet = tweet {
                    validTweets.append(tweet)
                }
            }
            
            self.loadingLabel.setHidden(true)
            self.tweetTable.setHidden(false)
            self.stopActivityIndicator()
            self.tweetTable.setNumberOfRows(validTweets.count, withRowType: "tweetRowController")
            for (index, tweet) in validTweets.enumerated() {
                if let row = self.tweetTable.rowController(at: index) as? TweetRowController {
                    row.tweetLabel.setText(tweet.text)
                    row.tweetImage.setImage(UIImage(named: staticTweets[index][2]))
                }
            }
        }
    }
    
    func startActivityIndicator() {
        print("TweetInterfaceController - \(#function)")

        activityIndicatorGroup.setHidden(false)
        activityIndicatorGroup.setBackgroundImageNamed("spinner")
        activityIndicatorGroup.startAnimatingWithImages(in: NSMakeRange(1,42), duration: 1.5, repeatCount: -1)
    }
    
    func stopActivityIndicator() {
        print("TweetInterfaceController - \(#function)")

        activityIndicatorGroup.stopAnimating()
        activityIndicatorGroup.setHidden(true)
    }

    func delay(_ delay:Double, closure:@escaping ()->()) {
        print("TweetInterfaceController - \(#function)")

        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
}
