//
//  Tweet.swift
//  iDev2017_watchOS WatchKit Extension
//
//  Created by Justin Domnitz on 7/11/17.
//  Copyright © 2017 Lowyoyo, LLC. All rights reserved.
//

import Foundation

// a simple container class which just holds the data in a Tweet
// IndexedKeywords are substrings of the Tweet's text
// for example, a hashtag or other user or url that is mentioned in the Tweet
// note carefully the comments on the two range properties in an IndexedKeyword
// Tweet instances re created by fetching from Twitter using a TwitterRequest

open class Tweet : CustomStringConvertible
{
    open var text: String
    open var user: User
    open var created: Date
    open var id: String?
    open var media = [MediaItem]()
    open var hashtags = [IndexedKeyword]()
    open var urls = [IndexedKeyword]()
    open var userMentions = [IndexedKeyword]()

    public struct IndexedKeyword: CustomStringConvertible
    {
        public var keyword: String              // will include # or @ or http:// prefix
        public var range: Range<String.Index>   // index into the Tweet's text property only
        public var nsrange: NSRange             // index into an NS[Attributed]String made from the Tweet's text

        public init?(data: NSDictionary?, inText: String, prefix: String?) {
            let indices = data?.value(forKeyPath: TwitterKey.Entities.Indices) as? NSArray
            if let startIndex = (indices?.firstObject as? NSNumber)?.intValue {
                if let endIndex = (indices?.lastObject as? NSNumber)?.intValue {
                    let length = inText.count
                    if length > 0 {
                        let start = max(min(startIndex, length-1), 0)
                        let end = max(min(endIndex, length-1), 0)
                        if end > start {
                            range = Range(uncheckedBounds: (inText.index(inText.startIndex, offsetBy: start),
                                                            inText.index(inText.startIndex, offsetBy: end-1)))
                            keyword = String(inText[range])
                            
                            //Placeholder initialization added here...
                            nsrange = inText.rangeOfString("", nearRange: NSMakeRange(0,0))
                            
                            if prefix != nil && !keyword.hasPrefix(prefix!) && start > 0 {
                                range = Range(uncheckedBounds: (inText.index(inText.startIndex, offsetBy: start-1),
                                                                inText.index(inText.startIndex, offsetBy: end-2)))
                                keyword = String(inText[range])
                            }
                            if prefix == nil || keyword.hasPrefix(prefix!) {
                                nsrange = inText.rangeOfString(keyword as NSString, nearRange: NSMakeRange(startIndex, endIndex-startIndex))
                                if nsrange.location != NSNotFound {
                                    return
                                }
                            }
                        }
                    }
                }
            }
            return nil
        }

        public var description: String { get { return "\(keyword) (\(nsrange.location), \(nsrange.location+nsrange.length-1))" } }
    }
    
    open var description: String { return "\(user) - \(created)\n\(text)\nhashtags: \(hashtags)\nurls: \(urls)\nuser_mentions: \(userMentions)" + (id == nil ? "" : "\nid: \(id!)") }

    // MARK: - Private Implementation

    init?(data: NSDictionary?) {
        if let user = User(data: data?.value(forKeyPath: TwitterKey.User) as? NSDictionary) {
            self.user = user
            if let text = data?.value(forKeyPath: TwitterKey.Text) as? String {
                self.text = text
                if let created = (data?.value(forKeyPath: TwitterKey.Created) as? String)?.asTwitterDate {
                    self.created = created
                    id = data?.value(forKeyPath: TwitterKey.ID) as? String
                    if let mediaEntities = data?.value(forKeyPath: TwitterKey.Media) as? NSArray {
                        for mediaData in mediaEntities {
                            if let mediaItem = MediaItem(data: mediaData as? NSDictionary) {
                                media.append(mediaItem)
                            }
                        }
                    }
                    let hashtagMentionsArray = data?.value(forKeyPath: TwitterKey.Entities.Hashtags) as? NSArray
                    hashtags = getIndexedKeywords(hashtagMentionsArray, inText: text, prefix: "#")
                    let urlMentionsArray = data?.value(forKeyPath: TwitterKey.Entities.URLs) as? NSArray
                    urls = getIndexedKeywords(urlMentionsArray, inText: text, prefix: "h")
                    let userMentionsArray = data?.value(forKeyPath: TwitterKey.Entities.UserMentions) as? NSArray
                    userMentions = getIndexedKeywords(userMentionsArray, inText: text, prefix: "@")
                    return
                }
            }
        }
        // we've failed
        // but compiler won't let us out of here with non-optional values unset
        // so set them to anything just to able to return nil
        // we could make these implicitly-unwrapped optionals, but they should never be nil, ever
        self.text = ""
        self.user = User()
        self.created = Date()
        return nil
    }
    
    init?() {
        self.text = ""
        self.user = User()
        self.created = Date()
    }

    fileprivate func getIndexedKeywords(_ dictionary: NSArray?, inText: String, prefix: String? = nil) -> [IndexedKeyword] {
        var results = [IndexedKeyword]()
        if let indexedKeywords = dictionary {
            for indexedKeywordData in indexedKeywords {
                if let indexedKeyword = IndexedKeyword(data: indexedKeywordData as? NSDictionary, inText: inText, prefix: prefix) {
                    results.append(indexedKeyword)
                }
            }
        }
        return results
    }
}

struct TwitterKey {
    static let User = "user"
    static let Text = "text"
    static let Created = "created_at"
    static let ID = "id_str"
    static let Media = "entities.media"
    struct Entities {
        static let Hashtags = "entities.hashtags"
        static let URLs = "entities.urls"
        static let UserMentions = "entities.user_mentions"
        static let Indices = "indices"
    }
    
    // keys in Twitter responses/queries
    
    static let Count = "count"
    static let Query = "q"
    static let Tweets = "statuses"
    static let ResultType = "result_type"
    static let ResultTypeRecent = "recent"
    static let ResultTypePopular = "popular"
    static let Geocode = "geocode"
    static let SearchForTweets = "search/tweets"
    static let MaxID = "max_id"
    static let SinceID = "since_id"
    struct SearchMetadata {
        static let MaxID = "search_metadata.max_id_str"
        static let NextResults = "search_metadata.next_results"
        static let Separator = "&"
    }
}

private extension NSString {
    func rangeOfString(_ substring: NSString, nearRange: NSRange) -> NSRange {
        var start = max(min(nearRange.location, length-1), 0)
        var end = max(min(nearRange.location + nearRange.length, length), 0)
        var done = false
        while !done {
            let range = self.range(of: substring as String, options: NSString.CompareOptions(), range: NSMakeRange(start, end-start))
            if range.location != NSNotFound {
                return range
            }
            done = true
            if start > 0 { start -= 1 ; done = false }
            if end < length { end += 1 ; done = false }
        }
        return NSMakeRange(NSNotFound, 0)
    }
}

private extension String {
    var asTwitterDate: Date? {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
            return dateFormatter.date(from: self)
        }
    }
}
