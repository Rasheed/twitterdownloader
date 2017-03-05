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
import WCLShineButton
import ZAlertView

class ViewController: UIViewController {
    
    let twitter = Twitter.sharedInstance()
    
    @IBOutlet weak var activityIndicator: InstagramActivityIndicator!
    @IBOutlet weak var linkField: UITextField!
    @IBOutlet weak var downloadButton: WCLShineButton!
    
    let peach = UIColor(rgb: (r:231, g:136, b:114))
    let purple = UIColor(rgb: (r:51, g:40, b:96))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        activityIndicator.strokeColor = peach
        activityIndicator.alpha = 0.8
        
        var shineParams = WCLShineParams()
        shineParams.bigShineColor = peach
        shineParams.smallShineColor = purple
        
        downloadButton.params = shineParams
        downloadButton.image = .custom(#imageLiteral(resourceName: "download"))
        downloadButton.fillColor = purple
        downloadButton.color = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let urlString = UIPasteboard.general.string, urlString.isTwitterURL {
            linkField.text = urlString
        }
    }
    
    @IBAction func clickedDownloadButton(_ sender: UIControl) {
        
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
    
    private func downloadVideo() {
        
        if let text = linkField.text, let url = URL(string: text) {
            
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            let videoFetcher = TwitterVideoFetcher()
            videoFetcher.fetchVideoUrl(forUrl: url, { (videoUrl) in
                if let videoUrl = videoUrl {
                    let videoPersister = VideoPersister()
                    videoPersister.saveVideo(videoUrl, { (success) in
                        
                        if success {
                            DispatchQueue.main.async {
                                self.activityIndicator.isHidden = true
                                self.activityIndicator.stopAnimating()
                                self.showAlert(withTitle: "Video Saved!", message: "Your video is now in your camera roll")
                            }
                        }
                    })
                } else {
                    DispatchQueue.main.async {
                        
                        self.showAlert(withTitle: "Couldn't find video in tweet", message: nil)
                    }
                }
            })
        } else {
            showAlert(withTitle: "Invalid Link", message: nil)
        }
    }
    
    func showAlert(withTitle title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
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

extension String {
    
    var isTwitterURL: Bool {
        
        if let url = URL(string: self), url.host == "twitter.com" {
            return true
        }
        return false
    }
}

