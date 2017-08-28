//
//  FileManager.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 7/21/16.
//  Copyright © 2016 Lasith Hettiarachchi. All rights reserved.
//

import Foundation
import VideoToolbox

class FileHandler {
    
    func moveDB() {
        
        if let libraryDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first {
            
            let db = libraryDir.appending("/Yangola.sqlite")
            
            if let url = URL(string: db) {
                _ = deleteItemAtURL(url)
                
                _ = self.moveFile(at: url, to: getDocumentsDirectory()!)
            }
            
        }
        
    }
    
    func createFolder(folderName name: String, inDirectory path: URL) -> Bool {
        
        let dataPath = path.appendingPathComponent(name)
        do {
            try Foundation.FileManager.default.createDirectory(at: dataPath, withIntermediateDirectories: false, attributes: nil)
            return true
        } catch let error as NSError {
            NSLog("[createFolder] \(error.localizedDescription)")
            return false
        }
    }
    
    
    
    func getThumbnailDirectory() -> URL? {
        
        if let cachesURL = Foundation.FileManager.default.urls(for: Foundation.FileManager.SearchPathDirectory.cachesDirectory, in: .userDomainMask).first {
            let thumbDir = DIR_THUMB
            let mediaCachDir: URL = cachesURL.appendingPathComponent(thumbDir)
            if self.isFileExistsAtPath(mediaCachDir) {
                return mediaCachDir
            } else {
                _ = self.createFolder(folderName: thumbDir, inDirectory: cachesURL)
                return mediaCachDir
            }
            
        }
        
        return nil
    }
    
    
    
    func getDocumentsDirectory() -> URL? {
        
        return Foundation.FileManager.default.urls(for: Foundation.FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).first
    }
    
    func getArchivesDirectory() -> URL? {
        
        if  let docs = self.getDocumentsDirectory() {
            let arc = docs.appendingPathComponent(DIR_ARCHIVES)
            if self.isFileExistsAtPath(arc) {
                return arc
            } else {
                let success = self.createFolder(folderName: DIR_ARCHIVES, inDirectory: docs)
                return success ? arc : nil
            }
        }
        return nil
    }
    
    func getAirDropDirectory() -> URL? {
        
        if  let docs = self.getDocumentsDirectory() {
            let arc = docs.appendingPathComponent(DIR_AIRDROP)
            if self.isFileExistsAtPath(arc) {
                return arc
            } else {
                let success = self.createFolder(folderName: DIR_AIRDROP, inDirectory: docs)
                return success ? arc : nil
            }
        }
        return nil
    }
    
    func getInboxDirectory() -> URL? {
        
        if  let docs = self.getDocumentsDirectory() {
            let arc = docs.appendingPathComponent(DIR_INBOX)
            if self.isFileExistsAtPath(arc) {
                return arc
            }
        }
        return nil
    }
    
    func getContentsOfAPath(_ path: URL) -> [URL] {
        
        do {
            return try Foundation.FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: Foundation.FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
        } catch let error as NSError {
            NSLog("[getContentsOfAPath] \(error.localizedDescription)")
            return []
        }
    }
    
    func getAllContentsOfAPath(_ path: URL) -> [URL] {
        
        let enumerator = Foundation.FileManager.default.enumerator(at: path, includingPropertiesForKeys: [URLResourceKey.nameKey], options: Foundation.FileManager.DirectoryEnumerationOptions.skipsHiddenFiles) { (url, error) -> Bool in
            
            return true
        }
        
        var files: [URL] = []
        for en in enumerator! {
            if let url = en as? URL {
                files.append(url)
            }
        }
        
        
        return files
    }
    
    func getFileFolders(inDirectory directory: URL) -> [FileFolder] {
        
        let urls = self.getContentsOfAPath(directory)
        
        var fileFolders: [FileFolder] = []
        for url in urls {
            fileFolders.append(self.getFileFolder(fromURL: url))
        }
        
        return fileFolders
    }
    
    func getAllFiles(inDirectory directory: URL) -> [FileFolder] {
        
        let urls = self.getAllContentsOfAPath(directory)
        
        var fileFolders: [FileFolder] = []
        for url in urls {
            let fileFolder = self.getFileFolder(fromURL: url)
            if fileFolder.Type == FileFolderType.file {
                fileFolders.append(self.getFileFolder(fromURL: url))
            }
        }
        
        return fileFolders
    }
    
    func getAllFilesAndFolders(inDirectory directory: URL) -> [FileFolder] {
        
        let urls = self.getAllContentsOfAPath(directory)
        
        var fileFolders: [FileFolder] = []
        for url in urls {
            fileFolders.append(self.getFileFolder(fromURL: url))
        }
        
        return fileFolders
    }
    
    func getFileFolder(fromURL url: URL) -> FileFolder {
        
        let fileFolder = FileFolder()
        fileFolder.URL = url
        fileFolder.Path = url.absoluteString
        fileFolder.Type = FileHandler().isDirectory(url) ? FileFolderType.folder : FileFolderType.file
        fileFolder.Name = url.lastPathComponent
        fileFolder.Extension = url.pathExtension
        fileFolder.vlcMedia = VLCMedia(url: url)
        
        return fileFolder
    }
    
    
    
    func isDirectory(_ path: URL) -> Bool {
        
        var isDir : ObjCBool = false
        if Foundation.FileManager.default.fileExists(atPath: path.path, isDirectory: &isDir) {
            
            if isDir.boolValue {
                return true
            } else {
                return false
            }
            
        } else {
            return false
        }
    }
    
    func isFileExistsAtPath(_ path: URL) -> Bool{
        
        let filePath = path.path
        if Foundation.FileManager.default.fileExists(atPath: filePath) {
            
            return true
        }
        return false
    }
    
    
    
    func deleteContentsAtURL(_ path: URL) {
        
        let contents = self.getContentsOfAPath(path)
        
        for item in contents {
            self.deleteItemAtURL(item)
        }
    }
    
    func deleteItemAtURL(_ path: URL) -> Bool {
        
        do {
            try Foundation.FileManager.default.removeItem(at: path)
            return true
        } catch let error as NSError {
            NSLog("[deleteItemAtURL] \(error.localizedDescription)")
            return false
        }
    }
    
    func getFileSize(ofURL url: URL) -> UInt64 {
        
        let filePath = url.path
        var fileSize : UInt64 = 0
        
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: filePath)
            fileSize = attr[FileAttributeKey.size] as! UInt64
            
            let dict = attr as NSDictionary
            fileSize = dict.fileSize()
        } catch {
            NSLog("[getFileSize] Error: \(error)")
        }
        
        return fileSize
    }
    
    func getFolderSize(ofURL url: URL) -> UInt64 {
        
        var fileSize : UInt64 = 0
        
        for fileurl in getAllContentsOfAPath(url) {
            
            if (fileurl.absoluteString as NSString).isSupportedMediaFormat() {
                fileSize += self.getFileSize(ofURL: fileurl)
            }
        }
        
        return fileSize
    }
    
    func getModificationDate(ofUrl url: URL) -> Date? {
        
        let filePath = url.path
        var creationDate : Date?
        
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: filePath)
            
            let dict = attr as NSDictionary
            creationDate = dict.fileModificationDate()
        } catch {
            NSLog("[getAddedDate] Error: \(error)")
        }
        
        return creationDate
    }
    
    
    func getUniqueId(ofURL url: URL) -> Int {
        
        let filePath = url.path
        var fileSize : Int = 0
        
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: filePath)
            
            let dict = attr as NSDictionary
            fileSize = dict.fileSystemFileNumber()
            
        } catch {
            NSLog("[getUniqueId] Error: \(error)")
        }
        return fileSize
    }
    
    func renameFile(atURL url: URL, to: URL) -> Bool {
        
        do {
            try FileManager.default.moveItem(at: url, to: to)
            return true
        } catch let e {
            NSLog("Failed to rename file for \(url.absoluteString) to \(to.absoluteString) | \(e.localizedDescription)")
        }
        
        return false
    }
    
    func getLastModifiedDate(forURL url: URL) -> Date? {
        
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
    
    func processAirdropFile(url:URL) {
        
        var dest = url
        
        if url.pathExtension == EXT_YANGOLA, let airDir = self.getAirDropDirectory() {
            dest = airDir.appendingPathComponent(url.deletingPathExtension().lastPathComponent)
            
        } else if let airDir = self.getAirDropDirectory() {
            dest = airDir.appendingPathComponent(url.lastPathComponent)
        }
        
        _ = self.renameFile(atURL: url, to: dest)
        _ = self.deleteItemAtURL(url)
        
        NotificationCenter.default.post(name: NSNotification.Name.airDropFileReceived, object: nil, userInfo: nil)
    }
    
    func duplicateFile(atURL url: URL, extensionString: String, destinationFolder: URL) -> URL? {
        
        let destination = destinationFolder.appendingPathComponent(url.lastPathComponent).appendingPathExtension(extensionString)
        do {
            try FileManager.default.copyItem(at: url, to: destination)
            return destination
        } catch let e {
            NSLog("Failed to duplicate file for \(url.absoluteString) to \(destinationFolder.absoluteString) | \(e.localizedDescription)")
        }
        
        return nil
    }
    
    func bytesToMb(bytes: UInt64) -> Float {
        
        return Float((bytes / 1024) / 1024)
    }
    
    func constructName(forURL url: URL) -> String {
        
        let name = url.lastPathComponent
        let ext = url.pathExtension
        let size = Int(self.bytesToMb(bytes: self.getFileSize(ofURL: url)))
        let nameX = "\(name)_\(size)_\(ext)"
        return nameX
    }
    
    
    func moveFile(at: URL, to: URL) -> Bool {
        
        let fileManager = FileManager.default
        
        do {
            try fileManager.moveItem(at: at, to: to)
            return true
        } catch let e {
            NSLog("Moving file failed from \(at.absoluteString) to \(to.absoluteString) | \(e.localizedDescription)")
            return false
        }
    }
}
