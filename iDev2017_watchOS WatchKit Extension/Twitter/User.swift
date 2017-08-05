//
//  User.swift
//  iDev2017_watchOS WatchKit Extension
//
//  Created by Justin Domnitz on 7/11/17.
//  Copyright © 2017 Lowyoyo, LLC. All rights reserved.
//

import Foundation

// container to hold data about a Twitter user

public struct User: CustomStringConvertible
{
    public var screenName: String
    public var name: String
    public var profileImageURL: URL?
    public var verified1: Bool = false
    public let id: String!
    
    public var description: String { let v = verified1 ? " ✅" : ""; return "\(screenName)\n\(name)\(v)" }

    // MARK: - Private Implementation

    init?(data: NSDictionary?) {
        let name = data?.value(forKeyPath: TwitterKey.Name) as? String
        let screenName = data?.value(forKeyPath: TwitterKey.ScreenName) as? String
        if name != nil && screenName != nil {
            self.name = name!
            self.screenName = screenName!
            self.id = data?.value(forKeyPath: TwitterKey.ID) as? String
            if let verified = (data?.value(forKeyPath: TwitterKey.Verified) as AnyObject).boolValue {
                verified1 = verified
            }
            if let urlString = data?.value(forKeyPath: TwitterKey.ProfileImageURL) as? String {
                profileImageURL = URL(string: urlString)
            }
        } else {
            return nil
        }
    }
    
    var asPropertyList: AnyObject {
        var dictionary = Dictionary<String,String>()
        dictionary[TwitterKey.Name] = self.name
        dictionary[TwitterKey.ScreenName] = self.screenName
        dictionary[TwitterKey.ID] = self.id
        dictionary[TwitterKey.Verified] = verified1 ? "YES" : "NO"
        dictionary[TwitterKey.ProfileImageURL] = profileImageURL?.absoluteString
        return dictionary as AnyObject
    }

    
    init() {
        screenName = "Unknown"
        name = "Unknown"
        id = ""
    }
    
    struct TwitterKey {
        static let Name = "name"
        static let ScreenName = "screen_name"
        static let ID = "id_str"
        static let Verified = "verified"
        static let ProfileImageURL = "profile_image_url_https"
    }
}
