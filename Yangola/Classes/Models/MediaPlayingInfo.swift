//
//  MediaPlayingInfo.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 3/19/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import Foundation
import OLCOrm

class MediaPlayingInfo: OLCModel {
    
    var Id: NSNumber?
    var mediaId: String?
    var url: String?
    var posision: Float = 0.0
    var playCount: Int = 0
    var favourite: String = "0"
    var addedDate: Date = Date()
    var lastPlayed: Date?
    
    override init() {
        super.init()
        
        if let urlString = self.url, let url = URL(string: urlString) {
            let unique = FileHandler().getUniqueId(ofURL: url)
            self.mediaId = "\(unique)"
        }
    }
    
    init(url: String) {
        super.init()
        self.url = url
        
        if let urlString = self.url, let url = URL(string: urlString) {
            let unique = FileHandler().getUniqueId(ofURL: url)
            self.mediaId = "\(unique)"
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func getObject(forUrl: String) -> MediaPlayingInfo? {
        
        if let mediaId = getMediaId(forUrl: forUrl) {
            
            let med =  MediaPlayingInfo.__where("mediaId='\(mediaId)'", sortBy: "Id", accending: true).first as? MediaPlayingInfo
            
            return med
        }
        return nil
    }
    
    static func getMediaId(forUrl: String) -> String? {
        if let url = URL(string: forUrl) {
            let unique = FileHandler().getUniqueId(ofURL: url)
            return "\(unique)"
        }
        return nil
    }
    
    static func getAllFavourites() -> [FileFolder] {
        
        if let mediaInfo = MediaPlayingInfo.__where("favourite='1'", sortBy: "Id", accending: true) as? [MediaPlayingInfo] {
            var filefolders: [FileFolder] = []
            let fileHandler = FileHandler()
            for info in mediaInfo {
                if let urlString = info.url, let url = URL(string: urlString) {
                    filefolders.append(fileHandler.getFileFolder(fromURL: url))
                }
            }
            return filefolders
            
        } else {
            return []
        }
    }
    
    func setFavourite(fav: Bool) {
        
        let favourite = fav ? "1" : "0"
        self.favourite = favourite
        self.update()
    }
    
    func move(to url: URL) {
        
        self.url = url.absoluteString
        self.update()
    }
    
}
