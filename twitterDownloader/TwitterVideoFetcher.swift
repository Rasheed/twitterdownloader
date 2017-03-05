//
//  TwitterVideoFetcher.swift
//  twitterDownloader
//
//  Created by Rasheed Wihaib on 04/03/2017.
//  Copyright © 2017 Rasheed Wihaib. All rights reserved.
//

import Foundation
import Fabric
import TwitterKit

class TwitterVideoFetcher {
    
    let twitter = Twitter.sharedInstance()
    
    func fetchVideoUrl(forUrl url: URL, _ completion: @escaping ((URL?)->())) {
        
        if let tweetId = url.tweetId,
            let userID = twitter.sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/show.json"
            let params = ["id": tweetId, "include_entities":"true"]
            var clientError : NSError?
            let request = client.urlRequest(withMethod: "GET", url: statusesShowEndpoint, parameters: params, error: &clientError)
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    print("Error: \(connectionError)")
                }
                
                if let data = data, let variant = self.parse(data: data)?[0] {
                
                    completion(variant.url)
                }
            }
        }
    }
    
    func parse(data: Data) -> [VideoVariant]? {
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary,
                let extendedEntitites = json.object(forKey: "extended_entities") as? NSDictionary,
                let media = extendedEntitites.object(forKey: "media") as? NSArray,
                let firstMedia = media.firstObject as? NSDictionary {
                
//                let type = firstMedia.object(forKey: "type") as! String
                let videoInfo = firstMedia.object(forKey: "video_info") as! NSDictionary
                let videoVariants = videoInfo.object(forKey: "variants") as! NSArray
                
                return self.videoVariants(fromArray: videoVariants)
            }
        } catch let jsonError as NSError {
            print("json error: \(jsonError.localizedDescription)")
        }
        return nil
    }
    
    private func videoVariants(fromArray array: NSArray) -> [VideoVariant] {
        var variants: [VideoVariant] = []
        for dictionary in array {
            if let usableDict = dictionary as? [String : Any],
                let videoVariant = VideoVariant(dictionary: usableDict) {
                variants.append(videoVariant)
            }
        }
        return variants.sorted(by: { (variant1, variant2) -> Bool in
            return variant1.bitRate > variant2.bitRate
        })
    }
}


enum ContentType {
    
    case mp4
    
    init?(string: String) {
        switch string {
        case "video/mp4": self = .mp4
        default: return nil
        }
    }
}

struct VideoVariant {
    
    let contentType: ContentType
    let bitRate: Int
    let url: URL
    
    init?(dictionary: [String: Any]) {
        
        if let bitrate = dictionary["bitrate"] as? Int,
            let contentTypeString = dictionary["content_type"] as? String,
            let contentType = ContentType(string: contentTypeString),
            let urlString = dictionary["url"] as? String,
            let url = URL(string: urlString) {
            
            self.bitRate = bitrate
            self.url = url
            self.contentType = contentType
        } else {
            return nil
        }
    }
}

extension URL {
    
    var tweetId: String? {
        get {
            for pathComponent in pathComponents {
                if let _ = Int(pathComponent) {
                    return pathComponent
                }
            }
            return nil
        }
    }
}
