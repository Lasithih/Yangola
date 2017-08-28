//
//  FileFolder.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 7/21/16.
//  Copyright © 2016 Lasith Hettiarachchi. All rights reserved.
//

import Foundation
import UIKit

class FileFolder {
    
    var Name: String?
    var `Type`: FileFolderType?
    var Extension: String?
    var Path: String?
    var URL: Foundation.URL?
    var thumbnail: UIImage?
    var thumbnails: [UIImage] = []
    var vlcMedia: VLCMedia?
    var length: String?
    var lengthNumber: Int32?
    var fav: Bool {
        get {
            if let url = self.URL?.absoluteString {
                let mi = MediaPlayingInfo.getObject(forUrl: url)
                if mi?.favourite == "1" {
                    return true
                } else {
                    return false
                }
            }
            return false
        }
    }
    var subtitle: URL? {
        get {
            if let fileURL = self.URL {
                let folder = fileURL.deletingLastPathComponent()
                let name = fileURL.deletingPathExtension().lastPathComponent
                
                for file in FileHandler().getAllContentsOfAPath(folder) {
                    let fileName = file.deletingPathExtension().lastPathComponent
                    if fileName == name, (file.absoluteString as NSString).isSupportedSubtitleFormat() {
                        return file
                    }
                }
            }
            
            return nil
        }
    }
    
    var sizeString: String? {
        get {
            if let url = self.URL {
                let fileHandler = FileHandler()
                var bytes: UInt64 = 0
                if self.Type == FileFolderType.folder {
                    bytes = fileHandler.getFolderSize(ofURL: url)
                } else {
                    bytes = fileHandler.getFileSize(ofURL: url)
                }
                let megabytes = fileHandler.bytesToMb(bytes: bytes)
                
                if megabytes > 1024 {
                    let gb = megabytes / 1024
                    let rounded = self.roundToOneDecimal(number: gb)
                    return "\(rounded) GB"
                } else {
                    let rounded = self.roundToOneDecimal(number: megabytes)
                    return "\(rounded) MB"
                }
            }
            return ""
        }
    }
    var size: UInt64? {
        get {
            if let url = self.URL {
                let fileHandler = FileHandler()
                var bytes: UInt64 = 0
                if self.Type == FileFolderType.folder {
                    bytes = fileHandler.getFolderSize(ofURL: url)
                } else {
                    bytes = fileHandler.getFileSize(ofURL: url)
                }
                
                return bytes
            }
            return 0
        }
    }
    
    var modificationDate: Date? {
        get {
            if let url = self.URL {
                return FileHandler().getModificationDate(ofUrl: url)
            }
            return nil
        }
    }
    
    var addedDate: Date? {
        get {
            if let ad = self.mediaInfo?.addedDate {
                return ad
            }
            return nil
        }
    }
    
    var filesCount: Int {
        get {
            if let url = self.URL {
                let fileHandler = FileHandler()
                var videosCount = 0
                for file in fileHandler.getAllContentsOfAPath(url) {
                    if (file.absoluteString as NSString).isSupportedMediaFormat() {
                        videosCount += 1
                    }
                }
                return videosCount
            }
            return 0
        }
    }
    
    var mediaInfo: MediaPlayingInfo? {
        get {
            if let url = self.URL?.absoluteString {
                return MediaPlayingInfo.getObject(forUrl: url)
            }
            
            return nil
        }
    }
    
    func getLength(length: Int32) -> String {
        
        return self.secondsToHMS(Int(length / 1000))
    }
    
    func secondsToHMS (_ seconds : Int) -> String {
        let (h,m,s) = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        return "\(self.roundToTwoDigits(h)):\(self.roundToTwoDigits(m)):\(self.roundToTwoDigits(s))"
    }
    
    func roundToTwoDigits(_ digit :Int) -> String {
        
        var d = "\(digit)"
        if d.characters.count == 1 {
            d = "0\(d)"
        }
        return d
    }
    
    fileprivate func roundToOneDecimal(number: Float) -> Float {
        
        return Float(round(10*number)/10)
    }
    
    func rename(to: String) -> Bool {
        
        if let url = self.URL {
            let ih = ImageHandler()
            let thumburl = ih.getSavedThumbnailURL(forURL: url)
            
            let success = renameFile(url: url, to: to)
            
            if success, let subUrl = self.subtitle {
                _ = renameFile(url: subUrl, to: to)
            }
            
            if success {
                
                if let thumburl = thumburl {
                    
                    let fh = FileHandler()
                    _ = fh.deleteItemAtURL(thumburl)
                }
            }
            
            return true
        }
        
        return false
    }
    
    func move(to: FileFolder) -> Bool {
        
        if let at = self.URL, let dest = to.URL?.appendingPathComponent(at.lastPathComponent) {
            
            let fileHandler = FileHandler()
            let mediaInfo = self.mediaInfo
            let moved = fileHandler.moveFile(at: at, to: dest)
            if moved, let subUrl = self.subtitle, let subDest = to.URL?.appendingPathComponent(subUrl.lastPathComponent) {
                _ = fileHandler.moveFile(at: subUrl, to: subDest)
                
            }
            if moved {
                mediaInfo?.move(to: dest)
            }
            return moved
        }
        return false
    }
    
    fileprivate func createNewFileUrl(from url: URL, newName: String) -> URL {
        
        let ext = url.pathExtension
        let path = url.deletingLastPathComponent()
        
        var newUrl = path.appendingPathComponent(newName)
        if ext != "" {
            newUrl = newUrl.appendingPathExtension(ext)
        }
        
        return newUrl
    }
    
    fileprivate func renameFile(url: URL, to: String) -> Bool {
        
        let newUrl = self.createNewFileUrl(from: url, newName: to)
        let fh = FileHandler()
        return fh.renameFile(atURL: url, to: newUrl)
    }
}


