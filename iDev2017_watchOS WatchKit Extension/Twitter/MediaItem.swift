//
//  MediaItem.swift
//  iDev2017_watchOS WatchKit Extension
//
//  Created by Justin Domnitz on 7/11/17.
//  Copyright © 2017 Lowyoyo, LLC. All rights reserved.
//

import Foundation

// holds the network url and aspectRatio of an image attached to a Tweet
// created automatically when a Tweet object is created

public struct MediaItem
{
    public var url1: URL!
    public var aspectRatio: Double = 0
    
    public var description: String { return url1.absoluteString + " (aspect ratio = \(aspectRatio))" }
    
    // MARK: - Private Implementation

    init?(data: NSDictionary?) {
        var valid = false
        if let urlString = data?.value(forKeyPath: TwitterKey.MediaURL) as? NSString {
            if let url = URL(string: urlString as String) {
                url1 = url
                let h = data?.value(forKeyPath: TwitterKey.Height) as? NSNumber
                let w = data?.value(forKeyPath: TwitterKey.Width) as? NSNumber
                if h != nil && w != nil && h?.doubleValue != 0 {
                    aspectRatio = w!.doubleValue / h!.doubleValue
                    valid = true
                }
            }
        }
        if !valid {
            return nil
        }
    }
    
    struct TwitterKey {
        static let MediaURL = "media_url_https"
        static let Width = "sizes.small.w"
        static let Height = "sizes.small.h"
    }
}
