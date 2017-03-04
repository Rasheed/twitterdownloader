//
//  ViewController.swift
//  twitterDownloader
//
//  Created by Rasheed Wihaib on 14/02/2017.
//  Copyright © 2017 Rasheed Wihaib. All rights reserved.
//

import UIKit
import Photos
import Fabric
import TwitterKit

class ViewController: UIViewController {
    
    let twitter = Twitter.sharedInstance()
    
    @IBOutlet weak var linkField: UITextField!
    
    @IBAction func didClickDownload(_ sender: Any) {
        
        guard twitter.isUserLoggedIn else {
            twitter.logIn { (session, error) in
                if session != nil {
                    self.downloadVideo()
                }
            }
            return
        }
        downloadVideo()
    }
    
    func downloadVideo() {
        
        if let text = linkField.text, let url = URL(string: text) {
            let videoFetcher = TwitterVideoFetcher()
            videoFetcher.fetchVideoUrl(forUrl: url, { (videoUrl) in
                let videoPersister = VideoPersister()
                videoPersister.saveVideo(videoUrl)
            })
        } else {
            // invalid url
        }
    }
}

extension Twitter {
    
    var isUserLoggedIn: Bool {
        if let session = sessionStore.session() {
            return !session.userID.isEmpty
        }
        return false
    }
}


