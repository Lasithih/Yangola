//
//  ImageHandler.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 1/22/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import Foundation
import UIKit

class ImageHandler {
    
    func saveThumbnail(image: UIImage, name: String) {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            if let url = FileHandler().getThumbnailDirectory() {
                
                let targetURL = url.appendingPathComponent("\(name).jpg")
                if let jpegImage = UIImageJPEGRepresentation(image, 1.0){
                    try? jpegImage.write(to: targetURL, options: [.atomic])
                }
            }
        }
    }
    
    func getSavedThumbnail(forURL url: URL) -> UIImage? {
        
        let fileManager = FileHandler()
        let name = fileManager.constructName(forURL: url)
        if let thumbUrl = FileHandler().getThumbnailDirectory() {
            let targetURL = thumbUrl.appendingPathComponent("\(name).jpg")
            
            if fileManager.isFileExistsAtPath(targetURL) {
                return UIImage(contentsOfFile: targetURL.path)
            }
        }
        
        return nil
    }
    
    func getSavedThumbnailURL(forURL url: URL) -> URL? {
        
        let fileManager = FileHandler()
        let name = fileManager.constructName(forURL: url)
        if let thumbUrl = FileHandler().getThumbnailDirectory() {
            let targetURL = thumbUrl.appendingPathComponent("\(name).jpg")
            
            if fileManager.isFileExistsAtPath(targetURL) {
                return targetURL
            }
        }
        
        return nil
    }
    
}
