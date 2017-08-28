//
//  Archiver.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 2/20/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import Foundation

class Archiver {
    
    fileprivate static var sharedArchiver: Archiver?
    
    fileprivate init() {
        
    }
    
    static func sharedInstance() -> Archiver {
        
        if let shared = self.sharedArchiver {
            return shared
        } else {
            self.sharedArchiver = Archiver()
            return self.sharedArchiver!
        }
    }
    
    func archive(withURLs urls: [URL], completion:(([URL])->Void)?) {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            var duplicates: [URL] = []
            for url in urls {
                let fileHandler = FileHandler()
                if let archivesPath = fileHandler.getArchivesDirectory() {
                    
                    if let duplicate = fileHandler.duplicateFile(atURL: url, extensionString: EXT_YANGOLA, destinationFolder: archivesPath) {
                        duplicates.append(duplicate)
                    }
                }
            }
            
            DispatchQueue.main.async {
                completion?(duplicates)
            }
        }
    }
    
    func clearArchives(completion:(()->Void)?) {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            if let archivesPath = FileHandler().getArchivesDirectory() {
                
                let handler = FileHandler()
                
                let all = handler.getAllFilesAndFolders(inDirectory: archivesPath)
                
                for file in all {
                    if let url = file.URL {
                        _ = handler.deleteItemAtURL(url)
                    }
                }
                
                DispatchQueue.main.async {
                    NSLog("deleted \(all.count) file(s)")
                    completion?()
                }
            }
        }
        
        
    }
    
    func clearInboxArchives(completion:(()->Void)?) {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            let fManager = FileHandler()
            if let inbox = fManager.getInboxDirectory() {
                
                for url in fManager.getContentsOfAPath(inbox) {
                    if url.pathExtension == EXT_YANGOLA {
                        if let lastUpdated = fManager.getLastModifiedDate(forURL: url) {
                            if CLEAR_GARBAGE_INTERVAL <= Double(-1 * lastUpdated.timeIntervalSinceNow) {
                               _ = fManager.deleteItemAtURL(url)
                            }
                        } else {
                            _ = fManager.deleteItemAtURL(url)
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                completion?()
            }
        }
        
        
    }
}
