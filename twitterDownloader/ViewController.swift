//
//  ViewController.swift
//  twitterDownloader
//
//  Created by Rasheed Wihaib on 14/02/2017.
//  Copyright © 2017 Rasheed Wihaib. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    @IBOutlet weak var linkField: UITextField!
    
    @IBAction func didClickDownload(_ sender: Any) {
        downloadVideo()
    }
    
    func downloadVideo() {
        DispatchQueue.main.async {
            if let urlString = self.linkField.text, let url = URL(string: urlString) {
                
                do {
                    let urlData = try NSData(contentsOf: url)
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                    let filePath="\(documentsPath)/tempFile.mp4";
                    DispatchQueue.main.async {
                        urlData?.write(toFile: filePath, atomically: true);
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                        }) { completed, error in
                            if completed {
                                print("Video is saved!")
                            }
                        }
                    }
                } catch {
                    
                }
            }
        }
    }
}

