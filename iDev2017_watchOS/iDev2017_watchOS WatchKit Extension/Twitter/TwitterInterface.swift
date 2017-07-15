//
//  TwitterInterface.swift
//  iDev2017_watchOS WatchKit Extension
//
//  Created by Justin Domnitz on 7/11/17.
//  Copyright © 2017 Lowyoyo, LLC. All rights reserved.
//

import Foundation

class TwitterInterface {
    
    /******************************************************************************/
    /*                                                                            */
    /* requestTwitterSearchResults                                                */
    /*                                                                            */
    /******************************************************************************/
    
    func requestTwitterSearchResults(_ twitterSearch:String, completion: @escaping (_ tweets: [Tweet]?, _ error: NSError?) -> Void) {
        
        //
        //Get the bearer token...
        //
        
        let sessionConfig = URLSessionConfiguration.ephemeral

        //idev2016
        
        let consumerKey = "6S4NXilPssIavciPF1cjbGPHH"
        let consumerSecret = "y8GLmeOvwu8WUMm2PxL7TB5buQhnoX4ltnQDHnlVoz0k81CR4N"
        let escapedString = consumerKey + ":" + consumerSecret
        let data = escapedString.data(using: String.Encoding.utf8)
        let base64encoded = data?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        
        sessionConfig.httpAdditionalHeaders =
            ["Authorization": "Basic \(base64encoded!)"]
        
        let session = URLSession(configuration: sessionConfig)
        let serviceUrl = URL(string:"https://api.twitter.com/oauth2/token")!
        var request = URLRequest(url: serviceUrl)  //NSMutableURLRequest.init(url: serviceUrl!)
        request.httpMethod = "POST"
        let dataString = "grant_type=client_credentials"
        let theData = dataString.data(using: String.Encoding.ascii, allowLossyConversion: true)
        
        print("\(serviceUrl)")
        
        //CFANetworkUtilities().sendRequest(request, completion: { (any, data, response, error) -> Void in
        let _ = session.uploadTask(with: request, from: theData,  completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print("Twitter returned error: \(error!.localizedDescription); \(error!)")
                completion(nil, error as NSError?)
                return
            }
            do {
                let tokenJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                self.parseTwitterToken(tokenJson, completion:{ bearerToken, error in
                    //TO-DO: Improved errr handling
                    
                    if bearerToken != nil {
                    
                        //
                        //Get the Twitter search results using the bearer token...
                        //
                        
                        let sessionConfigSearch = URLSessionConfiguration.ephemeral

                        sessionConfigSearch.httpAdditionalHeaders =
                            ["Authorization": "Bearer \(bearerToken!)"]
                        let sessionSearch = URLSession(configuration: sessionConfigSearch)
                        let serviceUrlSearch =
                            URL(string:"https://api.twitter.com/1.1/search/tweets.json?q=" +
                                twitterSearch.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
                        var requestSearch = URLRequest.init(url: serviceUrlSearch!)
                        requestSearch.httpMethod = "GET"
                        let _ = sessionSearch.dataTask(with: requestSearch, completionHandler: { (data, response, error) -> Void in
                            if (error != nil) {
                                print("Twitter returned error: \(error!.localizedDescription); \(error!)")
                                completion(nil, error as NSError?)
                                return
                            }
                            do {
                                let searchJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                                self.parseTwitterSearchResults(searchJson, completion:{ tweets, error in
                                    //TO-DO: Error handling
                                    
                                    //print(tweets)
                                    completion(tweets, nil)
                                })
                            }
                            catch let caught { // JSONObjectWithData failed
                                let strData1 = NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue)
                                print(strData1 ?? "")
                                let error = NSError(domain: "Error - \("TBD") \(caught)", code: 0, userInfo: nil)
                                completion(nil, error)
                                return
                            }
                        })
                        .resume()
                        
                    }
                    
                })
            }
            catch let caught { // JSONObjectWithData failed
                let strData = NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue)
                print(strData ?? "")
                let error = NSError(domain: "Error - \("TBD") \(caught)", code: 0, userInfo: nil)
                completion(nil, error)
                return
            }
        })
        .resume()
    }
    
    /******************************************************************************/
    /*                                                                            */
    /* parseTwitterToken                                                          */
    /*                                                                            */
    /******************************************************************************/
    
    func parseTwitterToken(_ json: NSDictionary, completion: (_ token: String?, _ error: NSError?) -> Void) {
        if let token = json["access_token"] as? String {
            completion(token, nil)
        }
        else {
            completion(nil, nil)
        }
    }
    
    /******************************************************************************/
    /*                                                                            */
    /* parseTwitterSearchResults                                                  */
    /*                                                                            */
    /******************************************************************************/
    
    func parseTwitterSearchResults(_ json: NSDictionary, completion: (_ tweets: [Tweet]?, _ error: NSError?) -> Void) {
        var tweets = [Tweet]()
        var tweetArray: NSArray?
        if let tweets = json[TwitterKey.Tweets] as? NSArray {
            tweetArray = tweets
        } else if let tweet = Tweet(data: json) {
            tweets = [tweet]
        }
        if tweetArray != nil {
            for tweetData in tweetArray! {
                if let tweet = Tweet(data: tweetData as? NSDictionary) {
                    tweets.append(tweet)
                }
            }
        }
        completion(tweets, nil)
    }
    
}
