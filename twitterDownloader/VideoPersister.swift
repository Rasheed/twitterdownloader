//
//  VideoPersister.swift
//  twitterDownloader
//
//  Created by Rasheed Wihaib on 04/03/2017.
//  Copyright © 2017 Rasheed Wihaib. All rights reserved.
//

import Foundation
import Photos

class VideoPersister {
    
    func saveVideo(_ url: URL) {
        
        DispatchQueue.main.async {
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
