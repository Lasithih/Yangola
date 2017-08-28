//
//  FilesViewController.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 7/21/16.
//  Copyright © 2016 Lasith Hettiarachchi. All rights reserved.
//

import UIKit
import Darwin
import ionicons
//import TBEmptyDataSet
import DZNEmptyDataSet

enum FilesType {
    case normal, move, search
}

protocol FilesDelegate {
    
    func playVideo(withFile file: FileFolder)
    func openFolder(withFolder url: FileFolder)
    func enableDeleteButton(enabled: Bool)
    func enableShareButton(enabled: Bool)
    func enableMoreButton(enabled: Bool)
    func showVC(vc: UIViewController)
    func getSearchQuery() -> String?
    func enableSelectState()
    func isSelectionStateEnabled() -> Bool
}

class FilesViewController: ParentViewController, ParentDelegate {
    
    //IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    
    
    //Constants
    let CELL_MARGIN: CGFloat = 10
    
    //Public variables
    var landingScreenIndex = LandingScreenIndex.folders
    var delegate: FilesDelegate?
    var filesSourceUrl: URL?
    var collectionviewHeader: UIView?
    var screenSize = UIScreen.main.bounds
    var headerSize: CGSize?
    var type: FilesType = FilesType.normal
    
    //Private variables
    fileprivate var itemsOrg: [FileFolder] = []
    fileprivate var items: [FileFolder] = [] {
        didSet {
            self.saveMediaRecords()
        }
    }
    fileprivate var selectedItems: [FileFolder] = [] {
        didSet {
            self.delegate?.enableDeleteButton(enabled: self.selectedItems.count > 0)
            self.delegate?.enableShareButton(enabled: self.selectedItems.count > 0)
            self.delegate?.enableMoreButton(enabled: self.selectedItems.count > 0)
        }
    }
    fileprivate var selectionMode: Bool = false
    fileprivate var isLoading = true
    fileprivate var sortIndex: SortIndex?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.emptyDataSetSource = self
        self.collectionView.emptyDataSetDelegate = self
        if self.type == FilesType.search, let header = self.collectionviewHeader {
            self.collectionView.addSubview(header)
        }
        
        self.view.backgroundColor = UIColor.clear

        if self.filesSourceUrl == nil, self.type != FilesType.search {
            self.filesSourceUrl = FileHandler().getDocumentsDirectory() as URL?
        }
        
        if self.type == FilesType.search {
            self.fetchDataForSearch()
        } else {
            self.fetchData()
        }
        
        let lpress = UILongPressGestureRecognizer(target: self, action: #selector(FilesViewController.handleLongPress(gesture:)))
        lpress.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(lpress)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        flowLayout.invalidateLayout()
    }
    
    
    //////////////////////////////////////////
    //MARK: - Private functions
    //////////////////////////////////////////
    fileprivate func fetchData() {
        
        if let docsDir = self.filesSourceUrl {
            
            let fileManager = FileHandler()
            
            var contents = fileManager.getFileFolders(inDirectory: docsDir)
            contents = contents.sorted(by: { (first, second) -> Bool in
                
                return first.Type == FileFolderType.folder ? true : false
            })
            
            if self.landingScreenIndex == LandingScreenIndex.folders {
                
                self.items = contents
                
            } else if landingScreenIndex == LandingScreenIndex.files {
                
                self.items = fileManager.getAllFiles(inDirectory: docsDir)
                
            } else if landingScreenIndex == LandingScreenIndex.favourites {
                
                self.items = MediaPlayingInfo.getAllFavourites()
                
            }
            
            self.items = self.items.filter({ (file) -> Bool in
                
                if file.Type == FileFolderType.folder {
                    if let name = file.Name {
                        if name != DIR_ARCHIVES && name != DIR_INBOX {
                            return true
                        } else {
                            return false
                        }
                    } else {
                        return false
                    }
                } else {
                    if let url = file.URL {
                        if (url.absoluteString as NSString).isSupportedMediaFormat() || url.pathExtension == EXT_YANGOLA {
                            return true
                        } else {
                            return false
                        }
                    } else {
                        return false
                    }
                }
            })
            
            if let _ = self.sortIndex {
                self.sort()
            }
            
            self.fillThumbnails()
            self.fillLengths()
            
        }
        
    }
    
    fileprivate func fetchDataForSearch() {
        
        if let docsDir = FileHandler().getDocumentsDirectory() {
            
            let fileManager = FileHandler()
            
            var contents = fileManager.getAllFilesAndFolders(inDirectory: docsDir)
            contents = contents.sorted(by: { (first, second) -> Bool in
                
                return first.Type == FileFolderType.folder ? true : false
            })
            
            self.itemsOrg = contents
            
            self.itemsOrg = self.itemsOrg.filter({ (file) -> Bool in
                
                if file.Type == FileFolderType.folder {
                    if let name = file.Name {
                        if name != DIR_ARCHIVES {
                            return true
                        } else {
                            return false
                        }
                    } else {
                        return false
                    }
                } else {
                    if let url = file.URL {
                        if (url.absoluteString as NSString).isSupportedMediaFormat() {
                            return true
                        } else {
                            return false
                        }
                    } else {
                        return false
                    }
                }
            })
            
            
            self.fillOrgThumbnails()
            self.fillOrgThumbnails()
        }
    }
    
    fileprivate func saveMediaRecords() {
        
        for item in self.items {
            
            if let url = item.URL {
                let urlString = url.absoluteString
                if (urlString as NSString).isSupportedMediaFormat() || FileHandler().isDirectory(url) {
                    if let _ = MediaPlayingInfo.getObject(forUrl: urlString) {
                        //alredy saved
                    } else {
                        
                        let info = MediaPlayingInfo(url: urlString)
                        info.save()
                        
                    }
                }
                
            }
        }
    }
    
    fileprivate func fetchFileThumbnails() {
        for item in self.items.filter({$0.Type == FileFolderType.file}) {
            
            if let url = item.URL {
                if let thumb = ImageHandler().getSavedThumbnail(forURL: url) {
                    item.thumbnail = thumb
                } else {
                    self.fetchThumbnail(forURL: url)
                }
            }
        }
    }
    
    fileprivate func fetchFolderThumbnails() {
        for item in self.items.filter({$0.Type == FileFolderType.folder}) {
            
            if let url = item.URL {
                
                let all = FileHandler().getAllFilesAndFolders(inDirectory: url)
                
                var allFiles = all.filter({ (filefolder) -> Bool in
                    
                    if let url = filefolder.URL {
                        return filefolder.Type == FileFolderType.file && (url.absoluteString as NSString).isSupportedMediaFormat()
                    }
                    
                    return false
                })
                
                var cur = 1
                while cur <= 4 {
                    
                    if let first = allFiles.first?.URL {
                        _ = allFiles.removeFirst()
                        if let thumb = ImageHandler().getSavedThumbnail(forURL: first) {
                            if item.thumbnails.count < cur {
                                item.thumbnails.append(thumb)
                            }
                        } else {
                            self.fetchThumbnail(forURL: first)
                        }
                    }
                    
                    cur += 1
                }
                
            }
        }
    }
    
    fileprivate func fillThumbnails() {
        
        fetchFileThumbnails()
        
        fetchFolderThumbnails()
    }
    
    fileprivate func fillLengths() {
        
        for item in self.items.filter({$0.Type == FileFolderType.file}) {
            
            item.vlcMedia?.delegate = self
            item.vlcMedia?.parse()
        }
    }
    
    
    fileprivate func fillOrgThumbnails() {
        
        for item in self.itemsOrg.filter({$0.Type == FileFolderType.file}) {
            
            if let url = item.URL {
                if let thumb = ImageHandler().getSavedThumbnail(forURL: url) {
                    item.thumbnail = thumb
                } else {
                    self.fetchThumbnail(forURL: url)
                }
            }
        }
    }
    
    fileprivate func fillOrgLengths() {
        
        for item in self.itemsOrg.filter({$0.Type == FileFolderType.file}) {
            
            item.vlcMedia?.delegate = self
            item.vlcMedia?.parse()
        }
    }
    
    fileprivate func sort() {
        
        if sortIndex == SortIndex.AddedDate {
            self.items = self.items.sorted(by: { (f1, f2) -> Bool in
                if let f1 = f1.addedDate, let f2 = f2.addedDate {
                    return f1 > f2
                }
                return true
            })
            
        } else if sortIndex == SortIndex.MostPlayed {
            let files = self.items.filter(){$0.Type == FileFolderType.file}
            let folders = self.items.filter(){$0.Type == FileFolderType.folder}
            
            self.items = files.sorted(by: { (ff1, ff2) -> Bool in
                if let f1 = ff1.mediaInfo?.playCount, let f2 = ff2.mediaInfo?.playCount {
                    return f1 > f2
                }
                return true
            }) + folders
            
        } else if sortIndex == SortIndex.Size {
            self.items = self.items.sorted(by: { (f1, f2) -> Bool in
                if let f1 = f1.size, let f2 = f2.size {
                    return f1 > f2
                }
                return true
            })
            
        } else if sortIndex == SortIndex.Length {
            
            let files = self.items.filter(){$0.Type == FileFolderType.file}
            let folders = self.items.filter(){$0.Type == FileFolderType.folder}
            
            self.items = files.sorted(by: { (ff1, ff2) -> Bool in
                if let f1 = ff1.lengthNumber, let f2 = ff2.lengthNumber {
                    return f1 > f2
                }
                return true
            }) + folders
            
        } else if sortIndex == SortIndex.PlayedDate {
            
            let files = self.items.filter(){$0.Type == FileFolderType.file}
            let folders = self.items.filter(){$0.Type == FileFolderType.folder}
            
            self.items = files.sorted(by: { (ff1, ff2) -> Bool in
                if let f1 = ff1.mediaInfo?.lastPlayed, let f2 = ff2.mediaInfo?.lastPlayed {
                    return f1 > f2
                }
                return true
            }) + folders
        }
    }
    
    fileprivate func reloadData(forKeyword keyword: String) {
        
        self.items = self.itemsOrg.filter({ (file) -> Bool in
            if let nm = file.Name {
                return nm.lowercased().contains(keyword.lowercased())
            }
            
            if let nm = file.Extension {
                return nm.lowercased().contains(keyword.lowercased())
            }
            
            return false
        })
        self.collectionView.reloadData()
    }
    
    
    fileprivate func changeSelectionMode(_ newState: Bool) {
        
        self.selectionMode = newState
        self.selectedItems.removeAll(keepingCapacity: false)
        self.collectionView.reloadData()

    }
    
    
    fileprivate func addSelected(_ selected: FileFolder, atIndexPath indexPath: IndexPath) {
        
        self.selectedItems.append(selected)
        self.collectionView.reloadItems(at: [indexPath])
    }
    
    fileprivate func removeSelected(_ selectedPhoto: FileFolder, atIndexPath indexPath: IndexPath) {
        
        if let index = self.indexOfSelected(selectedPhoto) {
            self.selectedItems.remove(at: index)
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
    
    fileprivate func isSelected(_ fileFolder: FileFolder) -> Bool {
        
        for selected in self.selectedItems {
            
            if selected.URL == fileFolder.URL {
                
                return true
            }
        }
        
        return false
    }
    
    fileprivate func indexOfSelected(_ fileFolder: FileFolder) -> Int? {
        
        for n in 0...self.selectedItems.count {
            
            if self.selectedItems[n].URL == fileFolder.URL {
                return n
            }
        }
        
        return nil
    }
    
    fileprivate func insertFolder(_ fileFolder: FileFolder) {
        
        let foldersCount = self.items.filter(){$0.Type == FileFolderType.folder}.count
        self.items.insert(fileFolder, at: foldersCount)
        
        let newIndexPath = IndexPath(item: foldersCount, section: 0)
        self.collectionView.insertItems(at: [newIndexPath])
    }
    
    fileprivate func remove(fileFolders: [FileFolder]) {
        
        DispatchQueue.main.async {
            var ips:[IndexPath] = []
            for fileFolder in fileFolders {
                for n in 0..<self.items.count {
                    let item = self.items[n]
                    if item.URL == fileFolder.URL && fileFolder.URL != nil {
                        ips.append(IndexPath(item: n, section: 0))
                        break
                    }
                }
            }
            
            ips = ips.sorted(by: {$0.row > $1.row})
            for ip in ips {
                 self.items.remove(at: ip.item)
            }
            self.collectionView.deleteItems(at: ips)
        }
    }
    
    fileprivate func fetchThumbnail(forURL url: URL) {
        ThumbnailManager.getInstance().fetchthumbnail(forURL: url, delegate: self)
    }
    
    fileprivate func getCellWidth() -> CGFloat {
        let screenWidth = self.screenSize.width
        let screenHeight = self.screenSize.height
        
        var selected = screenWidth
        if UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeLeft || UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeRight {
            selected = max(screenWidth, screenHeight)
        } else {
            selected = min(screenWidth, screenHeight)
        }
        
        let itemsPerRow =  floor(selected / 170)
        
        let width: CGFloat = (selected - (CELL_MARGIN * (itemsPerRow + 1))) / itemsPerRow
        return width
    }
    
    
    //////////////////////////////////////////
    //MARK: - Delegate functions
    //////////////////////////////////////////
    func selectionStateChanged(toState state: Bool) {
        
        self.changeSelectionMode(state)
    }
    
    func fetchData(_ landingScreenIndex: LandingScreenIndex) {
        
        self.landingScreenIndex = landingScreenIndex
        if self.type == FilesType.search {
            self.fetchDataForSearch()
        } else {
            self.fetchData()
        }
    }
    
    func reloadCollectionView() {
        
        self.collectionView.reloadData()
        
    }
    
    func reloadCollectionView(sortIndex: SortIndex) {
        self.sortIndex = sortIndex
        self.sort()
        self.collectionView.reloadData()
        
    }
    
    func newFileFolder(_ fileFolder: FileFolder) {
        
        self.insertFolder(fileFolder)
        
    }
    
    func deleteFileFolders(fileFolders:[FileFolder]) {
        
        self.remove(fileFolders: fileFolders)
    }
    
    func reloadCollectionView(forKeyword keyword: String) {
        
        self.reloadData(forKeyword: keyword)
    }
    
    func getSelectedFileFolders() -> [FileFolder] {
        return self.selectedItems
    }
    
    func resetSelectedData(toState state: Bool) {
        self.selectionMode = state
        self.selectedItems.removeAll(keepingCapacity: false)
    }
    
    func updateCollectionView(removefileFolders: [FileFolder], updatefileFolders: [FileFolder], completion: ((Bool) -> Void)?) {
        
        fetchFolderThumbnails()
        
        DispatchQueue.main.async {
            var removeIps:[IndexPath] = []
            for fileFolder in removefileFolders {
                for n in 0..<self.items.count {
                    let item = self.items[n]
                    if item.URL == fileFolder.URL && fileFolder.URL != nil {
                        removeIps.append(IndexPath(item: n, section: 0))
                        break
                    }
                }
            }
            
            removeIps = removeIps.sorted(by: {$0.row > $1.row})
            for ip in removeIps {
                self.items.remove(at: ip.item)
            }
            
            
            var updateIps: [IndexPath] = []
            for fileFolder in updatefileFolders {
                for n in 0..<self.items.count {
                    let item = self.items[n]
                    if item.URL == fileFolder.URL && fileFolder.URL != nil {
                        updateIps.append(IndexPath(item: n, section: 0))
                        break
                    }
                }
            }
            
            self.collectionView.performBatchUpdates({ 
                
                self.collectionView.deleteItems(at: removeIps)
                self.collectionView.reloadItems(at: updateIps)
                
            }, completion: completion)
            
        }
    }
    
    func reloadCollectionViewCells(fileFolders: [FileFolder], completion: ((Bool) -> Void)?) {
        
        var ips: [IndexPath] = []
        for fileFolder in fileFolders {
            for n in 0..<self.items.count {
                let item = self.items[n]
                if item.URL == fileFolder.URL && fileFolder.URL != nil {
                    ips.append(IndexPath(item: n, section: 0))
                    break
                }
            }
        }
        self.collectionView.performBatchUpdates({ 
            self.collectionView.reloadItems(at: ips)
        }, completion: completion)
        
    }
    
    func getCurrentSortIndex() -> SortIndex? {
        
        return self.sortIndex
    }
    
    //Thumbnail delegate
    func thumbnailFetched(forURL url: URL, thumbnail: UIImage) {
        
        for n in 0..<self.items.count {
            let item = self.items[n]
            if item.URL == url {
                item.thumbnail = thumbnail
                
                let ip = IndexPath(item: n, section: 0)
                self.collectionView.reloadItems(at: [ip])
                break
            }
            
            if let folderurl = item.URL {
                if url.absoluteString.contains(folderurl.absoluteString) {
                    item.thumbnails.append(thumbnail)
                    let ip = IndexPath(item: n, section: 0)
                    self.collectionView.reloadItems(at: [ip])
                }
            }
        }
        
    }
}


extension FilesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = self.items[indexPath.item]
        
        if item.Type == FileFolderType.file {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileCell", for: indexPath) as! FileCollectionViewCell
            cell.setItem(item, selected: self.isSelected(item), cellWidth: self.getCellWidth())
            
            return cell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderCell", for: indexPath) as! FolderCollectionViewCell
            cell.setItem(item, selected: self.isSelected(item))
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = self.items[indexPath.item]
        
        if self.selectionMode == true {
            if self.isSelected(item) {
                self.removeSelected(item, atIndexPath: indexPath)
            } else {
                self.addSelected(item, atIndexPath: indexPath)
            }
        } else {
            
            if item.Type == FileFolderType.folder {
                self.delegate?.openFolder(withFolder: item)
            } else {
                self.delegate?.playVideo(withFile: item)
            }
        }
    }
    
    
    
    //////////////////////////////////////////
    //MARK: - Collection view layout
    //////////////////////////////////////////
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = self.getCellWidth()
    
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return CELL_MARGIN
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        var top = CELL_MARGIN
        if self.type != FilesType.move {
            top = top + 64
        }
        if self.type == FilesType.normal {
            if AdManager.shared.isAdsEnabled() {
                top = top + 80
            }
        }
        return UIEdgeInsetsMake(top, CELL_MARGIN, CELL_MARGIN, CELL_MARGIN)
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
//        if let size = self.headerSize {
//            return size
//        } else {
//            return CGSize(width: screenSize.width, height: 50)
//        }
        
        return CGSize.zero
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        
//        if self.items.count > 0 {
//            return CGSize(width: screenSize.width, height: 100)
//        } else {
//            return CGSize.zero
//        }
//    }
    

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionFooter {
            
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "filesFooter", for: indexPath) as! FilesFooterCollectionReusableView
            
            if self.items.count > 0, self.landingScreenIndex == LandingScreenIndex.folders, let url = self.filesSourceUrl {
                let ff = FileHandler().getFileFolder(fromURL: url)
                let size = ff.sizeString
                let count = "\(ff.filesCount) videos"
                footer.setData(size: size != nil ? size! : "", files: count)
            } else {
                footer.setData(size: "", files: "")
            }
            
            return footer
            
        } else {
        
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "filesHeader", for: indexPath) as! FilesHeaderCollectionReusableView
            if let relative = self.filesSourceUrl?.relativePath {
                
                do {
                    let regex = try NSRegularExpression(pattern: "/Documents/(.)+", options: [])
                    
                    let match = regex.firstMatch(in: relative, options: [], range: NSMakeRange(0, relative.characters.count))
                    
                    if let matchedString = match {
                        var path = (relative as NSString).substring(with: matchedString.rangeAt(0))
                        path = path.replacingOccurrences(of: "/Documents/", with: "Home/").replacingOccurrences(of: "/", with: " > ")
                        header.setData(path: path)
                        
                    }
                    
                } catch let e {
                    NSLog("regex failed \(e.localizedDescription)")
                }
            }
            
            return header
        }

    }
}


extension FilesViewController: VLCMediaThumbnailerDelegate {
    
    func mediaThumbnailer(_ mediaThumbnailer: VLCMediaThumbnailer!, didFinishThumbnail thumbnail: CGImage!) {
        if let mediaURL = mediaThumbnailer.media.url {
            let thumb = UIImage(cgImage: thumbnail)
            self.thumbnailFetched(forURL: mediaURL, thumbnail: thumb)
            ImageHandler().saveThumbnail(image: thumb, name: FileHandler().constructName(forURL: mediaURL))
        }
        
        ThumbnailManager.getInstance().jobFinished()
    }
    
    func mediaThumbnailerDidTimeOut(_ mediaThumbnailer: VLCMediaThumbnailer!) {
        
        NSLog("thumbnailer timed out")
        ThumbnailManager.getInstance().jobFinished()
    }
}




extension FilesViewController: VLCMediaDelegate {
    
    func mediaDidFinishParsing(_ aMedia: VLCMedia!) {
        
        
        if self.type == FilesType.search {
            
            for n in 0..<self.itemsOrg.count {
                let item = self.itemsOrg[n]
                if item.vlcMedia == aMedia {
                    if let length = aMedia.length {
                        item.lengthNumber = length.intValue
                        item.length = item.getLength(length: length.intValue)
                    }
                }
            }
            
        } else {
            
            for n in 0..<self.items.count {
                let item = self.items[n]
                if item.vlcMedia == aMedia {
                    if let length = aMedia.length {
                        item.lengthNumber = length.intValue
                        item.length = item.getLength(length: length.intValue)
                        let ip = IndexPath(item: n, section: 0)
                        if self.collectionView.indexPathsForVisibleItems.contains(ip) {
                            self.collectionView.reloadItems(at: [ip])
                        }
                        
                    }
                }
            }
        }
        
        
    }
}

extension FilesViewController: UIGestureRecognizerDelegate {
    
    func handleLongPress(gesture : UILongPressGestureRecognizer) {
//        if gesture.state != .ended {
//            return
//        }
        if self.type == FilesType.normal {
            let p = gesture.location(in: self.collectionView)
            
            if let indexPath = self.collectionView.indexPathForItem(at: p), let del = self.delegate {
                
                if let cell = self.collectionView.cellForItem(at: indexPath) as? FileCollectionViewCell {
                    if let item = cell.item, !del.isSelectionStateEnabled() {
                        FeedbackGenerator.shared.generateImpact()
                        self.delegate?.enableSelectState()
                        self.addSelected(item, atIndexPath: indexPath)
                    }
                } else if let cell = self.collectionView.cellForItem(at: indexPath) as? FolderCollectionViewCell {
                    if let item = cell.item, !del.isSelectionStateEnabled() {
                        FeedbackGenerator.shared.generateImpact()
                        self.delegate?.enableSelectState()
                        self.addSelected(item, atIndexPath: indexPath)
                    }
                }
                
            } else {
                NSLog("couldn't find index path")
            }
        }
    }
}


extension FilesViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        
        if self.type == .search {
            return nil
        } else {
            return UIImage(named: "yangolalogo_light_withbg")
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        if self.type == .search {
            return NSAttributedString(string: "")
        } else {
            return NSAttributedString(string: "Your Library is Empty")
        }
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        if self.type == .search {
            var msg = ""
            if let sq = self.delegate?.getSearchQuery(), sq != "" {
                msg = "No matches found for \"\(sq)\""
            }
            return NSAttributedString(string: msg)
            
        } else {
            return NSAttributedString(string: "You can use iTunes to upload media to your library")
        }
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        
        if self.type == .search {
            return NSAttributedString(string: "")
        } else {
            return NSAttributedString(string: "See how", attributes: [NSForegroundColorAttributeName: UIColor.white])
        }
        
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        
        if self.type == FilesType.search {
            return UIScreen.main.bounds.height / 4 * -1
        } else {
            return 0
        }
    }
    
    //delegate
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        
        if let vc = Onboard().getOnboardViewController(type: OnboardType.addMedia) {
            self.delegate?.showVC(vc: vc)
        }
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        
        if self.type == .search {
            return true
        } else if type == .normal {
            return self.filesSourceUrl == FileHandler().getDocumentsDirectory()
        }
        return false
    }
}
