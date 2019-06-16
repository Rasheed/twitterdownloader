import UIKit
import Photos
import TwitterKit
import WCLShineButton
import Firebase

class ViewController: UIViewController {
    
    let twitter = Twitter.sharedInstance()
    
    @IBOutlet weak var activityIndicator: InstagramActivityIndicator!
    @IBOutlet weak var linkField: UITextField!
    @IBOutlet weak var downloadButton: WCLShineButton!
    
    let purple = UIColor(rgb: (r: 138, g: 43, b: 226))
    let blue = UIColor(rgb: (r :0, g: 206, b: 209))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        linkField.delegate = self
        
        activityIndicator.isHidden = true
        activityIndicator.strokeColor = purple
        activityIndicator.alpha = 0.8
        
        var shineParams = WCLShineParams()
        shineParams.bigShineColor = purple
        shineParams.smallShineColor = purple
        shineParams.enableFlashing = true
        shineParams.colorRandom = [blue, purple, .white, blue, purple, .white]
        
        downloadButton.params = shineParams
        downloadButton.image = .custom(#imageLiteral(resourceName: "download"))
        downloadButton.fillColor = purple
        downloadButton.color = UIColor.white
        
        if !twitter.isUserLoggedIn {
            twitter.logIn { (session, error) in

            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func applicationDidBecomeActive() {
        if let urlString = UIPasteboard.general.string, urlString.isTwitterURL {
            linkField.text = urlString
        }
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
            
            showActivityIndicator()
            let videoFetcher = TwitterVideoFetcher()
            videoFetcher.fetchVideoUrl(forUrl: url, { (videoUrl) in
                if let videoUrl = videoUrl {
                    let videoPersister = VideoPersister()
                    videoPersister.saveVideo(videoUrl, { (success) in
                        
                        if success {
                            Analytics.logEvent("save_success", parameters: [
                                "urlString": text as NSObject,
                            ])
                            DispatchQueue.main.async {
                                self.hideActivityIndicator()
                                self.showAlert(withTitle: "Video Saved!", message: "Your video is now in your camera roll")
                            }
                        }
                    })
                } else {
                    Analytics.logEvent("save_error", parameters: [
                        "urlString": text as NSObject,
                    ])
                    DispatchQueue.main.async {
                        self.hideActivityIndicator()
                        self.showAlert(withTitle: "Couldn't find video in tweet", message: nil)
                    }
                }
            })
        } else {
            DispatchQueue.main.async {
                self.hideActivityIndicator()
                self.showAlert(withTitle: "Invalid Link", message: nil)
            }
        }
    }

    func hideActivityIndicator() {
        
        guard !self.activityIndicator.isHidden else {
            return
        }
        
        self.activityIndicator.isHidden = true
        self.activityIndicator.alpha = 1.0
        UIView.animate(withDuration: 0.3, animations: {
            self.activityIndicator.alpha = 0.0
            self.activityIndicator.stopAnimating()
        })
        
        self.downloadButton.isSelected = false
    }
    
    func showActivityIndicator() {
        
        self.activityIndicator.isHidden = true
        self.activityIndicator.alpha = 0.0
        UIView.animate(withDuration: 0.45, animations: {
            self.activityIndicator.alpha = 1.0
            self.activityIndicator.startAnimating()
        })
    }
    
    func showAlert(withTitle title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
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

extension ViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
}
