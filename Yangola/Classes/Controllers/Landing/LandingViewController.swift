//
//  LandingViewController.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 7/22/16.
//  Copyright © 2016 Lasith Hettiarachchi. All rights reserved.
//

import UIKit
import ionicons
import Crashlytics
import MZFormSheetPresentationController
import Onboard
import MessageUI
import GoogleMobileAds
import FirebaseRemoteConfig

protocol ParentDelegate {
    
    func selectionStateChanged(toState state:Bool)
    func fetchData(_ landingScreenIndex:LandingScreenIndex)
    func reloadCollectionView()
    func reloadCollectionView(sortIndex: SortIndex)
    func newFileFolder(_ fileFolder: FileFolder)
    func deleteFileFolders(fileFolders:[FileFolder])
    func reloadCollectionView(forKeyword keyword: String)
    func getSelectedFileFolders() -> [FileFolder]
    func resetSelectedData(toState state:Bool)
    func updateCollectionView(removefileFolders: [FileFolder], updatefileFolders: [FileFolder], completion: ((Bool) -> Void)?)
    func reloadCollectionViewCells(fileFolders: [FileFolder], completion: ((Bool) -> Void)?)
    func getCurrentSortIndex() -> SortIndex?
}

class LandingViewController: ParentViewController, UITabBarDelegate, FilesDelegate {
    
    //IBOutlets
    @IBOutlet weak var tabFolders: UITabBarItem!
    @IBOutlet weak var tabFiles: UITabBarItem!
    @IBOutlet weak var tabFavourites: UITabBarItem!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var constToolbarBottom: NSLayoutConstraint!
    @IBOutlet weak var constTabBarBottom: NSLayoutConstraint!
    @IBOutlet weak var constToolbarTop: NSLayoutConstraint!
    @IBOutlet weak var constTabBarTop: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lblTitleView: UILabel!
    @IBOutlet weak var lblTitleImageView: UIImageView!
    @IBOutlet weak var btnDropDown: UIButton!
    @IBOutlet weak var moreBottomButton: UIBarButtonItem!
    @IBOutlet weak var shareBottomButton: UIBarButtonItem!
    @IBOutlet weak var deleteBottomButton: UIBarButtonItem!
    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var adViewTop: GADNativeExpressAdView!
    
    //Constants
    let TAB_ITEM_ICON_SIZE: CGFloat = 27
    
    //public members
    var parentDelegate: ParentDelegate?
    var isSearch: Bool = false
    var currentFileFolder: FileFolder?
    
    //Private members
    fileprivate var alert: LIHAlert?
    fileprivate var processingAlert: LIHAlert?
    fileprivate var optionsDropdownAlert: LIHAlert?
    fileprivate var shouldShowSearchResults = false
    fileprivate var collectionViewHeader: UIView?
    fileprivate var searchController: UISearchController?
    fileprivate var isDropdownVisible = false {
        didSet {
            self.configDropdownIcon()
        }
    }
    //observer
    fileprivate var fileObserver : DirectoryMonitor?
    fileprivate var airDropMonitor: DirectoryMonitor?
    fileprivate var inboxMonitor: DirectoryMonitor?
    fileprivate var observeRefreshDelay: Timer?
    //bar buttons
    fileprivate var searchBarButton: UIBarButtonItem!
    fileprivate var cancelSelectionBarButton: UIBarButtonItem!
    //selection
    fileprivate var selectionState: Bool = false {
        didSet {
            if self.selectionState {
                self.navigationItem.rightBarButtonItem = self.cancelSelectionBarButton
            } else {
                self.navigationItem.rightBarButtonItem = self.searchBarButton
            }
        }
    }
    
    
    
    //////////////////////////////////////////
    //MARK: - View Controller
    //////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !self.isSearch, AdManager.shared.isAdsEnabled() {
            self.setupAdView()
        }
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        if let title = self.title {
            self.lblTitleView.text = title
        }
        
        self.configBottomBarButtons()
        
        self.configDropdownIcon()
        
        let fileManager = FileHandler()
        if let docs = fileManager.getDocumentsDirectory(), self.currentFileFolder == nil, !self.isSearch {
            self.currentFileFolder = fileManager.getFileFolder(fromURL: docs)
        }
        
        
        if self.currentFileFolder?.URL == FileHandler().getDocumentsDirectory() {
            self.lblTitleImageView.isHidden = false
            self.lblTitleView.isHidden = true
        } else {
            self.lblTitleImageView.isHidden = true
            self.lblTitleView.isHidden = false
        }
        
        self.addNavigationBarBlurView()
        
        self.constToolbarBottom.constant = -50
        
        //bar buttons
        self.searchBarButton = self.navigationItem.rightBarButtonItem
        self.cancelSelectionBarButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(LandingViewController.cancelSelectionState))
        
        //Tabs configurations
        self.configTabbar()
        
        //toolbar configurations
        self.configureToolbarConstraints()
        
        self.tabBar.selectedItem = self.tabFolders
        
        //Alerts configurations
        self.initAlerts()
        
        //File monitor
        if let curURL = self.currentFileFolder?.URL {
            self.fileObserver = DirectoryMonitor(url: curURL)
            self.fileObserver?.startMonitoring()
            self.fileObserver?.delegate = self
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData), name: NSNotification.Name.airDropFileReceived, object: nil)
        
        if self.isSearch {
            self.configureSearchController()
        }
        
        self.setDefaultValues()
        
        super.logEvent(with: "FileBrowser")
        if self.lblTitleView != nil, let name = self.lblTitleView.text {
            super.setUserProperty(value: name, name: AnalyticsUserProperty.folderName.rawValue)
        }
        
        self.fetchRemoteConfig()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.sendBlurviewBack()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addNavigationBarBlurView()
        self.sendBlurviewBack()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.sendBlurviewBack()
        
        if !UserData.welcomeScreensWatched() {
            self.showWelcomeScreen()
        }
        
        if self.isSearch {
            
            DispatchQueue.main.async {
                self.searchController?.searchBar.becomeFirstResponder()
            }
        } else {
            
        }
        
        self.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowFiles" {
            if let vc = segue.destination as? FilesViewController {
                vc.landingScreenIndex = LandingScreenIndex.folders
                self.parentDelegate = vc.self
                vc.delegate = self
                vc.collectionviewHeader = self.collectionViewHeader
                vc.type = self.isSearch ? FilesType.search : FilesType.normal
                vc.filesSourceUrl = self.currentFileFolder?.URL
            }
        } else if segue.identifier == "ShowMenu" {
            if let nvc = segue.destination as? UINavigationController, let vc = nvc.viewControllers.first as? MenuViewController {
                vc.delegate = self
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        
        self.fileObserver?.stopMonitoring()
        self.inboxMonitor?.stopMonitoring()
        self.airDropMonitor?.stopMonitoring()
        NotificationCenter.default.removeObserver(self)
    }
    
    //////////////////////////////////////////
    //MARK: - Private functions
    //////////////////////////////////////////
    
    fileprivate func fetchRemoteConfig() {
        
        if !self.isSearch, self.currentFileFolder?.URL == FileHandler().getDocumentsDirectory() {
            let remoteConfig = RemoteConfig.remoteConfig()
            remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
            
            var renewInterval = 3600 * 24
            if AppData.getAppEnvironment() == AppEnvironment.Dev {
                renewInterval = 0
            }
            
            remoteConfig.fetch(withExpirationDuration: TimeInterval(renewInterval), completionHandler: { (status, error) in
                if let e = error {
                    NSLog("Couldn't fetch remote config \(e.localizedDescription)")
                } else {
                    remoteConfig.activateFetched()
                    if let latest = remoteConfig[RemoteConfigKey.laterstVersion.rawValue].stringValue {
                        if let cur = AppData.getAppVersion() {
                            if cur < latest {
                                self.showUpdateNotice(forVersion: latest)
                            }
                        }
                    }
                }
            })
        }
    }
    
    fileprivate func showUpdateNotice(forVersion version: String) {
        
        if let v = AppVersion.__where("version='\(version)'", sortBy: "Id", accending: true).first as? AppVersion {
            if !v.noticeShown {
                
                let alert = UIAlertController(title: "Hey!", message: "A new version of Yangola is available", preferredStyle: UIAlertControllerStyle.alert)
                
                let updateAction = UIAlertAction(title: "Update", style: UIAlertActionStyle.default) { (_) in
                    if let url = URL(string: "http://itunes.apple.com/app/id1274504389?mt=8") {
                        UIApplication.shared.openURL(url)
                    }
                }
                alert.addAction(updateAction)
                
                let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(dismissAction)
                
                self.showVC(vc: alert)
                
                v.noticeShown = true
                v.update()
            }
        } else {
            
            self.saveAppVersion(version: version)
        }
    }
    
    fileprivate func saveAppVersion(version: String) {
        
        let v = AppVersion()
        v.version = version
        v.noticeShown = false
        v.save()
    }
    
    fileprivate func setDefaultValues() {
        
        if !UserData.getBoolUserData(forKey: UserDefaultKey.firstLaunchFinished) {
            
            UserData.setBoolUserData(value: true, forKey: UserDefaultKey.playPause)
            UserData.setBoolUserData(value: true, forKey: UserDefaultKey.jumpBackward)
            UserData.setBoolUserData(value: true, forKey: UserDefaultKey.jumpForward)
            UserData.setBoolUserData(value: true, forKey: UserDefaultKey.swipeSeek)
            UserData.setBoolUserData(value: true, forKey: UserDefaultKey.swipeVolume)
            UserData.setBoolUserData(value: true, forKey: UserDefaultKey.swipeBrightness)
            UserData.setJumpInterval(jumpInterval: JumpInterval.short)
            UserData.setContinuePlayback(continuePlayback: ContinuePlayback.continue)
            
            UserData.setBoolUserData(value: true, forKey: UserDefaultKey.firstLaunchFinished)
        }
    }
    
    fileprivate func setupAdView() {
        
        AdManager.shared.setupHomeListTopAd(forView: self.adViewTop, root: self)
    }
    
    fileprivate func showWelcomeScreen() {
        
        if let vc = Onboard().getOnboardViewController(type: OnboardType.all) {
            self.showVC(vc: vc)
            UserData.setWelcomescreensWatched(watched: true)
        }
    }
    
    fileprivate func initAlerts() {
        
        self.alert = AlertManager().getErrorAlert(withMessage: "")
        self.alert?.initAlert(self.view)
        
        self.processingAlert = AlertManager().getProcessingAlert(withMessage: "")
        self.processingAlert?.initAlert(self.view)
        
        //dropdown
        let storyboard = UIStoryboard(name: "Support", bundle: Bundle.main)
        if let OptionsDropDown = storyboard.instantiateViewController(withIdentifier: "OptionsDropDownVc") as? OptionsDropDownViewController {
            let itemHeight: CGFloat = 50
            let numberOfItems = 3
            OptionsDropDown.delegate = self
            self.isDropdownVisible = false
            let customView = OptionsDropDown.view
            customView?.frame.size.height = itemHeight * CGFloat(numberOfItems)
            customView?.backgroundColor = UIColor.clear
            self.optionsDropdownAlert = LIHAlertManager.getCustomViewAlert(customView: customView!)
            self.optionsDropdownAlert?.autoCloseEnabled = false
            self.optionsDropdownAlert?.alertHeight = itemHeight * CGFloat(numberOfItems)
            self.optionsDropdownAlert?.touchBackgroundToDismiss = true
            self.optionsDropdownAlert?.touchBackgroundHandler = {
                self.isDropdownVisible = false
            }
            self.addChildViewController(OptionsDropDown)
            OptionsDropDown.didMove(toParentViewController: self)
            
            self.optionsDropdownAlert?.initAlert(self.view)
        }
    }
    
    fileprivate func configureToolbarConstraints() {
        
        if self.currentFileFolder?.URL != FileHandler().getDocumentsDirectory() {
            
            self.constToolbarTop.isActive = true
            self.constTabBarTop.isActive = false
            self.constTabBarBottom.constant = self.tabBar.frame.size.height * -1
            
        } else {
            let menuIcon = IonIcons.image(withIcon: ion_navicon, size: 30, color: UIColor.white)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: menuIcon, style: UIBarButtonItemStyle.plain, target: self, action: #selector(LandingViewController.menuPressed(_:)))
            self.constToolbarTop.isActive = false
            self.constTabBarTop.isActive = true
        }
    }
    
    fileprivate func getHeight(for width: CGFloat) -> CGFloat {
        
        return width / 507 * 285;
    }
    
    fileprivate func showProcessingAlert(withMessage message: String) {
        
        self.processingAlert?.contentText = message
        self.processingAlert?.show(nil, hidden: nil)
    }
    
    fileprivate func hideProcessingAlert() {
        self.processingAlert?.hideAlert(nil)
    }
    
    fileprivate func configBottomBarButtons() {
        
//        self.favouriteBottomButton.image = self.getFavImage(withColor: UIColor.white.withAlphaComponent(1))
        
        let moreImage = IonIcons.image(withIcon: ion_ios_more_outline, size: 30, color: UIColor.white)
        
        self.moreBottomButton.image = moreImage
    }
    
    fileprivate func showAlert(_ alert: LIHAlert?, withMessage message: String?) {
        if let msg = message {
            alert?.contentText = msg
        }
        alert?.show(nil, hidden: nil)
    }

    fileprivate func sendBlurviewBack() {
        if let nav = self.navigationController {
            for item in nav.navigationBar.subviews {
                if let blur = item as? UIVisualEffectView {
                    self.navigationController?.navigationBar.sendSubview(toBack: blur)
                }
            }
        }
    }
    
    fileprivate func isBlurViewExists() -> Bool {
        if let nav = self.navigationController {
            for item in nav.navigationBar.subviews {
                if let _ = item as? UIVisualEffectView {
                    return true
                }
            }
        }
        return false
    }
    
    fileprivate func addNavigationBarBlurView() {
        if let bounds = self.navigationController?.navigationBar.bounds, self.currentFileFolder?.URL == FileHandler().getDocumentsDirectory(), !isBlurViewExists() {
            let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            visualEffectView.tag = 10
            visualEffectView.frame = CGRect(x: 0, y: -20, width: bounds.width, height: bounds.height+20)
            visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.navigationController?.navigationBar.insertSubview(visualEffectView, at: 0)
            visualEffectView.isUserInteractionEnabled = false
        }
    }
    
    fileprivate func addNavigationBarBlurView(nav: UINavigationController) {
        let bounds = nav.navigationBar.bounds
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.tag = 10
        visualEffectView.frame = CGRect(x: 0, y: -20, width: bounds.width, height: bounds.height+20)
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        nav.navigationBar.insertSubview(visualEffectView, at: 0)
        visualEffectView.isUserInteractionEnabled = false
        
    }
    
    fileprivate func configTabbar() {
        self.tabFolders.image = UIImage.fontAwesomeIcon(name: FontAwesome.folderO, textColor: UIColor.black, size: CGSize(width: TAB_ITEM_ICON_SIZE, height: TAB_ITEM_ICON_SIZE))
        self.tabFolders.selectedImage = UIImage.fontAwesomeIcon(name: FontAwesome.folder, textColor: UIColor.black, size: CGSize(width: TAB_ITEM_ICON_SIZE, height: TAB_ITEM_ICON_SIZE))
        
        self.tabFiles.image = UIImage.fontAwesomeIcon(name: FontAwesome.fileVideoO, textColor: UIColor.black, size: CGSize(width: TAB_ITEM_ICON_SIZE, height: TAB_ITEM_ICON_SIZE))
        self.tabFiles.selectedImage = UIImage.fontAwesomeIcon(name: FontAwesome.fileVideoO, textColor: UIColor.black, size: CGSize(width: TAB_ITEM_ICON_SIZE, height: TAB_ITEM_ICON_SIZE))
    }
    
    fileprivate func configDropdownIcon() {
        let dropIcon = IonIcons.image(withIcon: isDropdownVisible ? ion_ios_arrow_up : ion_ios_arrow_down, size: 15, color: UIColor.white)
        self.btnDropDown.setImage(dropIcon, for: UIControlState.normal)
    }
    
    fileprivate func addFolder() {
        let alert = YangolaAlertController(title: "Create new folder", message: "Enter a name for the new directory.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField(configurationHandler: nil)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Create", style: UIAlertActionStyle.default, handler: { (_) in
            
            let fileManager = FileHandler()
            if let folderName = alert.textFields?.first?.text, let docDir = self.currentFileFolder?.URL {
                
                let isCreated = fileManager.createFolder(folderName: folderName, inDirectory: docDir)
                
                if !isCreated {
                    FeedbackGenerator.shared.generateError()
                    self.showAlert(self.alert, withMessage: "Failed to create the folder")
                } else  {
                    let newUrl = docDir.appendingPathComponent("\(folderName)")
                    let newFile = FileHandler().getFileFolder(fromURL: newUrl)
                    self.parentDelegate?.newFileFolder(newFile)
                }
            }
            
        }))
        
        DispatchQueue.main.async {
            
            self.showViewController(vc: alert)
        }
    }
    
    fileprivate func selectPressed() {
        self.selectionState = true
        self.constToolbarBottom.constant = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
        self.parentDelegate?.selectionStateChanged(toState: self.selectionState)
    }
    
    fileprivate func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
//        searchController?.searchBar.tintColor = THEME_COLOR
        searchController?.searchResultsUpdater = self
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Search"
        self.searchController?.searchBar.delegate = self
        definesPresentationContext = true
        searchController?.searchBar.sizeToFit()
        self.navigationItem.titleView = searchController?.searchBar
        self.searchController?.hidesNavigationBarDuringPresentation = false
        self.navigationItem.rightBarButtonItem = nil
        self.searchController?.searchBar.keyboardAppearance = UIKeyboardAppearance.dark
    }
    
    fileprivate func openSearch() {
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "LandingVc") as? LandingViewController {
            vc.title = "Search"
            vc.currentFileFolder = nil
            vc.isSearch = true
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    fileprivate func showOptionsDropdown() {
        
        self.optionsDropdownAlert?.show(nil, hidden: nil)
        self.isDropdownVisible = true
    }
    
    fileprivate func hideOptionsDropdown() {
        
        self.optionsDropdownAlert?.hideAlert(nil)
        self.isDropdownVisible = false
    }
    
    fileprivate func enableBarButton(barButton: UIBarButtonItem, enabled: Bool) {
        
        barButton.isEnabled = enabled
        barButton.tintColor = enabled ? UIColor.white : UIColor.white.withAlphaComponent(0.5)
    }
    
    fileprivate func getTabBarIndex() -> LandingScreenIndex? {
        
        if let item = self.tabBar.selectedItem {
            if item == self.tabFolders {
                return LandingScreenIndex.folders
                
            } else if item == self.tabFiles {
                return LandingScreenIndex.files
                
            } else if item == self.tabFavourites {
                return LandingScreenIndex.favourites
            }
        }
        return nil
    }
    
    fileprivate func compressFiles(urls: [URL], completion: @escaping ([URL])->Void) {
        
        self.showProcessingAlert(withMessage: "Prepairing..")
        Archiver.sharedInstance().clearArchives(completion: {
            Archiver.sharedInstance().archive(withURLs: urls) { (duplicates) in
                self.hideProcessingAlert()
                completion(duplicates)
            }
        })
    }
    
    fileprivate func shareURL(file: URL) {
        let activityController = UIActivityViewController(activityItems: [file], applicationActivities: nil)
        
        let excludedActivities = [UIActivityType.postToWeibo, UIActivityType.message, UIActivityType.postToTencentWeibo, UIActivityType.print, UIActivityType.assignToContact, UIActivityType.saveToCameraRoll, UIActivityType.addToReadingList, UIActivityType.openInIBooks, UIActivityType.postToFlickr]
        
        activityController.excludedActivityTypes = excludedActivities
        
        self.showViewController(vc: activityController, barButtonItem: self.shareBottomButton)
    }
    
    fileprivate func shareURLs(files: [URL]) {
        let activityController = UIActivityViewController(activityItems: files, applicationActivities: nil)
        
        let excludedActivities = [UIActivityType.postToWeibo, UIActivityType.message, UIActivityType.postToTencentWeibo, UIActivityType.print, UIActivityType.assignToContact, UIActivityType.saveToCameraRoll, UIActivityType.addToReadingList, UIActivityType.openInIBooks, UIActivityType.postToFlickr]
        
        activityController.excludedActivityTypes = excludedActivities
        
        self.showViewController(vc: activityController, barButtonItem: self.shareBottomButton)

    }
    
    fileprivate func showViewController(vc: UIViewController) {
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            present(vc, animated: true, completion: nil)
        } else if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            vc.popoverPresentationController?.barButtonItem = self.shareBottomButton
            present(vc, animated: true, completion: nil)
        }
    }
    
    fileprivate func showViewController(vc: UIViewController, barButtonItem: UIBarButtonItem) {
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            present(vc, animated: true, completion: nil)
        } else if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            vc.popoverPresentationController?.barButtonItem = barButtonItem
            present(vc, animated: true, completion: nil)
        }
    }
    
    fileprivate func removeSelectedData() {
        
        self.selectionState = false
        self.constToolbarBottom.constant = -50
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
        self.parentDelegate?.resetSelectedData(toState: self.selectionState)
    }
    
    fileprivate func allFavs(fileFolders: [FileFolder]) -> Bool {
        
        var allFavs = true
        for fileFolder in fileFolders {
            if !fileFolder.fav {
                allFavs = false
                break
            }
        }
        
        return allFavs
    }
    
    fileprivate func openEmail() {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients(["chryma.yangola@gmail.com"])
        mailVC.setSubject("Yangola - Contact <Yeur subject here>")
//        mailVC.setMessageBody("Email message string", isHTML: false)
        
        if let nav = mailVC.navigationController {
            nav.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            nav.navigationBar.isTranslucent = true
            nav.navigationBar.tintColor = UIColor.white
            self.addNavigationBarBlurView(nav: nav)
        }
        
         self.present(mailVC, animated: true, completion: nil)
    }
    
    
    //ionicons
    fileprivate func getMoreImage(withColor color: UIColor) -> UIImage {
        return IonIcons.image(withIcon: ion_ios_more_outline, size: 30, color: color)
    }
    
    //Debug
    fileprivate func addForceCrashButton() {
        let button = UIButton(type: UIButtonType.roundedRect)
        button.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
        button.setTitle("Crash", for: UIControlState.normal)
        button.addTarget(self, action: #selector(LandingViewController.crashButtonTapped(sender:)), for: UIControlEvents.touchUpInside)
        view.addSubview(button)
    }
    
    @IBAction func crashButtonTapped(sender: AnyObject) {
        Crashlytics.sharedInstance().crash()
    }

    
    //////////////////////////////////////////
    //MARK: - Events
    //////////////////////////////////////////
    
    func menuPressed(_ sender: AnyObject) {
        
//        let alert = YangolaAlertController(title: "Debug options", message: "Select an option", preferredStyle: UIAlertControllerStyle.alert)
//        
//        let flex = UIAlertAction(title: "Flex", style: UIAlertActionStyle.default) { (_) in
//            
//            FLEXManager.shared().showExplorer()
//        }
//        
//        let alpha = UIAlertAction(title: "Alpha", style: UIAlertActionStyle.default) { (_) in
//            
//            ALPHAManager.default().isInterfaceHidden = false
//        }
//        
//        alert.addAction(flex)
//        alert.addAction(alpha)
//        
//        self.present(alert, animated: true, completion: nil)
        
//        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreditsVc") as? CreditsViewController {
//            self.navigationController?.pushViewController(vc, animated: true)
//        } 

        performSegue(withIdentifier: "ShowMenu", sender: nil)
    }
    
    func reloadData() {
        
        self.observeRefreshDelay?.invalidate()
        if let index = self.getTabBarIndex() {
            self.parentDelegate?.fetchData(index)
            self.parentDelegate?.reloadCollectionView()
        }
    }
    
    func cancelSelectionState() {
        self.selectionState = false
        self.constToolbarBottom.constant = -50
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
        self.parentDelegate?.selectionStateChanged(toState: self.selectionState)
    }
    
    @IBAction func searchPressed(_ sender: UIBarButtonItem) {
        self.openSearch()
    }
    
    @IBAction func titlePressed(_ sender: UIButton) {
        
        self.cancelSelectionState()
        if self.isDropdownVisible {
            self.hideOptionsDropdown()
        } else {
            self.showOptionsDropdown()
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        
        if let selected = self.parentDelegate?.getSelectedFileFolders() {
            
            let alert = YangolaAlertController(title: "", message: "Are you sure you want to delete \(selected.count) files?", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (_) in
                for file in selected {
                    if let url = file.URL {
                        let fHandler = FileHandler()
                        
                        let success = fHandler.deleteItemAtURL(url)
                        if success {
                            if let sub = file.subtitle {
                                _ = fHandler.deleteItemAtURL(sub)
                            }
                            _ = file.mediaInfo?.delete()
                            self.cancelSelectionState()
                            self.parentDelegate?.deleteFileFolders(fileFolders: selected)
                            
                        } else {
                            
                            self.cancelSelectionState()
                        }
                        
                    }
                }
            })
            
            alert.addAction(deleteAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
            self.showViewController(vc: alert, barButtonItem: self.deleteBottomButton)
        }
    }
    
    @IBAction func favouritePressed(_ sender: UIBarButtonItem) {
        
        if let selectedFiles = self.parentDelegate?.getSelectedFileFolders() {
            
            var fav = true
            if self.allFavs(fileFolders: selectedFiles) {
                fav = false
            } else {
                fav = true
            }
            
            for selected in selectedFiles {
                
                selected.mediaInfo?.setFavourite(fav: fav)
            }
            
            self.removeSelectedData()
            self.parentDelegate?.reloadCollectionViewCells(fileFolders: selectedFiles, completion: nil)
        }
        
    }
    
    @IBAction func sharePressed(_ sender: UIBarButtonItem) {
        
        if let selectedFileFolders = self.parentDelegate?.getSelectedFileFolders() {
            
            var selectedUrls: [URL] = []
            var selectedUrlsWithSub: [URL] = []
            for selected in selectedFileFolders {
                if let validUrl = selected.URL {
                    selectedUrls.append(validUrl)
                    selectedUrlsWithSub.append(validUrl)
                    if let sub = selected.subtitle {
                        selectedUrlsWithSub.append(sub)
                    }
                }
            }
            
            let alert = YangolaAlertController(title: "Select how do you want to share.", message: "By selecting 'Share to Yangola' you will be able to receive videos to other iOS devices with subtitles, but this may take a while to prepare.", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let iPhone = UIAlertAction(title: "Share to Yangola", style: UIAlertActionStyle.default, handler: { (_) in
                
                self.compressFiles(urls: selectedUrlsWithSub, completion: { (urls) in
                    
                    self.shareURLs(files: urls)
                })
            })
            let share = UIAlertAction(title: "Share to other", style: UIAlertActionStyle.default, handler: { (_) in
                
                self.shareURLs(files: selectedUrls)
            })
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            
            alert.addAction(iPhone)
            alert.addAction(share)
            alert.addAction(cancel)
            self.showViewController(vc: alert, barButtonItem: self.shareBottomButton)

        }
    }
    
    @IBAction func morePressed(_ sender: UIBarButtonItem) {
        
        let selectedCount = self.parentDelegate?.getSelectedFileFolders().count
        
        let alert = YangolaAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let moveAction = UIAlertAction(title: "Move", style: UIAlertActionStyle.default) { (_) in
            
            if let movenav = self.storyboard?.instantiateViewController(withIdentifier: "MoveNavVc") as? UINavigationController, let vc = movenav.viewControllers.first as? MoveViewController {
                vc.view.clipsToBounds = true
                vc.delegate = self
                let formsheet = PopupManager.createPopup(with: movenav, type: PopupType.Move)
                self.showViewController(vc: formsheet)
            }
        }
        
        let renameAction = UIAlertAction(title: "Rename", style: UIAlertActionStyle.default) { (_) in
            
            if let nav = self.storyboard?.instantiateViewController(withIdentifier: "RenameNavVc") as? UINavigationController, let vc = nav.viewControllers.first as? RenameViewController {
                
                if let selected = self.parentDelegate?.getSelectedFileFolders().first, let name = selected.URL?.deletingPathExtension().lastPathComponent {
                    vc.name = name
                    vc.delegate = self
                    let formsheet = PopupManager.createPopup(with: nav, type: PopupType.Rename)
                    self.showViewController(vc: formsheet)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        if let count = selectedCount {
            if count > 0 {
                alert.addAction(moveAction)
            }
            
            if count == 1 {
                alert.addAction(renameAction)
            }
        }
        
        alert.addAction(cancelAction)
        
        self.showViewController(vc: alert, barButtonItem: self.moreBottomButton)
    }
    
    //////////////////////////////////////////
    //MARK: - Tab bar Delegate
    //////////////////////////////////////////

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        self.selectionState = false
        
        if let index = self.getTabBarIndex() {
            
            self.parentDelegate?.fetchData(index)
        }
        
        self.parentDelegate?.reloadCollectionView()
    }
    
    //////////////////////////////////////////
    //MARK: - Files Delegate
    //////////////////////////////////////////
    
    func playVideo(withFile file: FileFolder) {
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoPlayerVc") as? VideoPlayerViewController {
            
            vc.fileFolder = file
            if self.isSearch {
                self.view.endEditing(true)
            }
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func openFolder(withFolder url: FileFolder) {
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "LandingVc") as? LandingViewController {
            vc.title = url.Name
            vc.currentFileFolder = url
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func enableDeleteButton(enabled: Bool) {
        self.enableBarButton(barButton: self.deleteBottomButton, enabled: enabled)
    }
    
    func enableShareButton(enabled: Bool) {
        self.enableBarButton(barButton: self.shareBottomButton, enabled: enabled)
    }
    
    func enableMoreButton(enabled: Bool) {
        
        self.moreBottomButton.isEnabled = enabled
        self.moreBottomButton.image = self.getMoreImage(withColor: enabled ? UIColor.white.withAlphaComponent(1) : UIColor.white.withAlphaComponent(0.25))

    }
    
    func showVC(vc: UIViewController) {
        self.present(vc, animated: true, completion: nil)
    }
    
    func getSearchQuery() -> String? {
        
        return self.searchController?.searchBar.text
    }
    
    func enableSelectState() {
        self.selectPressed()
    }
    
    func isSelectionStateEnabled() -> Bool {
        
        return self.selectionState
    }
}


extension LandingViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchString = searchController.searchBar.text {
            self.parentDelegate?.reloadCollectionView(forKeyword: searchString)
        }
    }
}


extension LandingViewController: OptionsDropdownDelegate {
    
    func itemSelected(item: OptionsDropdownItem) {
        
        if let title = item.optionTitle {
            
            self.hideOptionsDropdown()
            
            let item = OptionsDropdownOption(rawValue: title)
            
            if item == OptionsDropdownOption.Select {
                self.selectPressed()
                
            } else if item == OptionsDropdownOption.Sort {
                
                if let nav = self.storyboard?.instantiateViewController(withIdentifier: "ListNav") as? UINavigationController {
                    
                    let popup = PopupManager.createPopup(with: nav, type: PopupType.SortBy)
                    if let vc = nav.viewControllers.first as? ListViewController {
                        
                        let list = SortByList.getList()
                        if let si = self.parentDelegate?.getCurrentSortIndex() {
                            list[si.rawValue].selected = true
                        }
                        vc.items = list
                        vc.delegate = self
                        vc.type = ListType.sort
                        vc.title = "Sort by"
                    }
                    
                    self.showVC(vc: popup)
                }
                
            } else if item == OptionsDropdownOption.NewFolder {
                
                if self.getTabBarIndex() != LandingScreenIndex.folders {
                    FeedbackGenerator.shared.generateError()
                    self.showAlert(self.alert, withMessage: "Please go to \"Folders\" tab to create folders")
                } else {
                    self.addFolder()
                }
            }
        }
    }
}

extension LandingViewController: DirectoryMonitorDelegate {
    
    func directoryMonitorDidObserveChange(directoryMonitor: DirectoryMonitor) {
        
        DispatchQueue.main.async {
            if let timer = self.observeRefreshDelay, timer.isValid {
                self.observeRefreshDelay?.invalidate()
            }
            
            self.observeRefreshDelay = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(LandingViewController.reloadData), userInfo: nil, repeats: false)
        }
        
    }    
}

extension LandingViewController: MoveViewControllerDelegate {
    
    func move(to: FileFolder?) {
        
        if let selected = self.parentDelegate?.getSelectedFileFolders(), let destination = to {
            
            for ff in selected {
                if let dest = to {
                    let moved = ff.move(to: dest)
                    if moved {
                        self.removeSelectedData()
                        if self.getTabBarIndex() == LandingScreenIndex.folders {
                            self.parentDelegate?.updateCollectionView(removefileFolders: selected, updatefileFolders: [destination], completion: { (finished) in
                                self.parentDelegate?.reloadCollectionView()
                            })
                        } else if self.getTabBarIndex() == LandingScreenIndex.files {
                            self.parentDelegate?.fetchData(LandingScreenIndex.files)
                        }
                        
                    }
                }
            }
            
        }
    }
    
    func moveCancelled() {
        
        self.cancelSelectionState()
    }
}

extension LandingViewController: RenameDelegate {
    
    func nameChanged(to: String) {
        
        if let item = self.parentDelegate?.getSelectedFileFolders().first {
            
            let success = item.rename(to: to)
            
            if !success {
                FeedbackGenerator.shared.generateError()
                self.showAlert(self.alert, withMessage: "Failed to rename")
            } else {
                self.removeSelectedData()
                self.reloadData()
            }
        }
    }
}

extension LandingViewController: ListDelegate {
    
    func itemSelected(at index: Int, of type: ListType?) {
        
        if let sortIndex = SortIndex(rawValue: index) {
            
            self.parentDelegate?.reloadCollectionView(sortIndex: sortIndex)
            
        } else {
            print("❎")
        }
    }
}

extension LandingViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension LandingViewController: UIGestureRecognizerDelegate {
    
}

extension LandingViewController: MenuDelegate {
    
    func menuItemSeleceted(item: MenuItem) {
        
        DispatchQueue.main.async {
            if item == MenuItem.credits {
                self.performSegue(withIdentifier: "ShowCredits", sender: nil)
            } else if item == MenuItem.contact {
                self.openEmail()
            } else if item == MenuItem.settings {
                self.performSegue(withIdentifier: "ShowSettings", sender: nil)
            } else if item == MenuItem.Instructions {
                self.showWelcomeScreen()
            }
        }
    }
}

extension LandingViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
    }
}
