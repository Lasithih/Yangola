//
//  ThumbnailManager.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 1/22/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import Foundation
import UIKit

class ThumbnailManager: NSObject {
    
    fileprivate static var aInstance: ThumbnailManager?
    fileprivate static var queue: [(URL,VLCMediaThumbnailerDelegate)] = []
    fileprivate static var currentJobs: Int = 0
    
    fileprivate let parellelFetches = 3
    
    static func getInstance() -> ThumbnailManager {
        if self.aInstance == nil {
            self.aInstance = ThumbnailManager()
        }
        return self.aInstance!
    }
    
    fileprivate override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fetchthumbnail(forURL url: URL, delegate: VLCMediaThumbnailerDelegate) {
        
        ThumbnailManager.queue.append((url,delegate))
        self.checkAndFetchNext()
        
    }

    func checkAndFetchNext() {
        
        if ThumbnailManager.currentJobs < self.parellelFetches {
            if let (url, delegate) = ThumbnailManager.queue.first, let vlcMedia = VLCMedia(url: url) {
                ThumbnailManager.currentJobs += 1
                VLCMediaThumbnailer(media: vlcMedia, andDelegate: delegate).fetchThumbnail()
                _ = ThumbnailManager.queue.removeFirst()
            }
        }
    }
    
    func jobFinished() {
        
        ThumbnailManager.currentJobs -= 1
        
        if ThumbnailManager.currentJobs < 0 {
            ThumbnailManager.currentJobs = 0
        }
        
        self.checkAndFetchNext()
    }
}
