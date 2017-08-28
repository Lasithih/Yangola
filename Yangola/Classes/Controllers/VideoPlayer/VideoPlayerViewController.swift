//
//  VideoPlayerViewController.swift
//  VidPlayer
//
//  Created by Lasith Hettiarachchi on 7/17/16.
//  Copyright © 2016 Lasith Hettiarachchi. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import ionicons

private var playbackLikelyToKeepUpContext = 0
private var doubleTapInterval = 0.5

enum PanDirection {
    case horizontal, vertical
}

enum ScreenArea {
    case backward, forward, playPause, left, right
}


class VideoPlayerViewController: ParentViewController {

    //IBOutlets
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var seekSlider: UISlider!
    @IBOutlet weak var lblPlayingTime: UILabel!
    @IBOutlet weak var lblPlayTime: UILabel!
    @IBOutlet weak var gestureView: UIView!
    @IBOutlet weak var volumeView: VolumeView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var viewTopControls: UIView!
    @IBOutlet weak var viewBottomControls: UIView!
    @IBOutlet weak var playPauseButton: UIImageView!
    @IBOutlet weak var forwardButton: UIImageView!
    @IBOutlet weak var backwardButton: UIImageView!
    @IBOutlet weak var outButtomHeight: NSLayoutConstraint!
    @IBOutlet weak var forwardButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var backwardButtonHeight: NSLayoutConstraint!
    @IBOutlet var singleTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var doubleTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var btnSubtitles: UIButton!
    @IBOutlet var btnPlayPause: UIButton!
    @IBOutlet var btnScreenLock: UIButton!
    @IBOutlet weak var lblAlert: UILabel!
    
    //Private Variables
    fileprivate let vlcPlayer = VLCMediaPlayer()
    fileprivate var playingBeforeSeek: Bool = false
    fileprivate var panDirection: PanDirection?
    fileprivate var volumeSlider: UISlider?
    fileprivate var seekPosition: Float = 0.0
    fileprivate var controlsTimer: Timer?
    fileprivate var doubleTapedForward: Date = Date()
    fileprivate var doubleTapedBackward: Date = Date()
    
    //Public Variables
    var fileFolder: FileFolder? = nil
    
    
    ////////////////////////////////////////////////////////////
    // MARK: - View Controller Methods
    ////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpAnalyticsData()
        
        self.doubleTapGestureRecognizer.numberOfTapsRequired = 2
        self.singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        
        self.btnSubtitles.setImage(IonIcons.image(withIcon: ion_closed_captioning, size: 20, color: UIColor.white), for: UIControlState.normal)
        
        self.setupUI()
        if let file = self.fileFolder {
            
            if let url = file.URL {
                self.vlcPlayer.media = VLCMedia(path: url.path)
                self.vlcPlayer.drawable = self.videoView
                self.vlcPlayer.delegate = self
                self.vlcPlayer.media.delegate = self
                if !self.vlcPlayer.media.isParsed {
                    self.vlcPlayer.media.parse()
                }
            }
            
            if let length = file.length {
                self.lblPlayTime.text = length
            } else {
                self.lblPlayTime.text = ""
            }
        }
        
        self.vlcPlayer.addObserver(self, forKeyPath: "isPlaying", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if UserData.getContinuePlayback() == ContinuePlayback.continue || UserData.getContinuePlayback() == nil {
            if let info = self.fileFolder?.mediaInfo {
                
                DispatchQueue.main.async(){
                    if info.posision < 0.95 {
                        self.vlcPlayer.position = info.posision
                    }
                }
            }
        }
        
        self.vlcPlayer.play()
        self.setupSubtitlesButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showControls()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.vlcPlayer.removeObserver(self, forKeyPath: "isPlaying")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "isPlaying" {
            if self.vlcPlayer.isPlaying {
                self.btnPlayPause.setImage(IonIcons.image(withIcon: ion_ios_pause, size: 30, color: UIColor.white), for: UIControlState.normal)
            } else {
                self.btnPlayPause.setImage(IonIcons.image(withIcon: ion_ios_play, size: 30, color: UIColor.white), for: UIControlState.normal)
            }
        }
    }
    
    // Force the view into landscape mode (which is how most video media is consumed.)
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        
        if self.btnScreenLock.state == UIControlState.selected {
            let cur = UIApplication.shared.statusBarOrientation
            if cur == UIInterfaceOrientation.landscapeLeft {
                return UIInterfaceOrientationMask.landscapeLeft
            } else if cur == UIInterfaceOrientation.landscapeRight {
                return UIInterfaceOrientationMask.landscapeRight
            } else if cur == UIInterfaceOrientation.portrait {
                return UIInterfaceOrientationMask.portrait
            } else if cur == UIInterfaceOrientation.portraitUpsideDown {
                return UIInterfaceOrientationMask.portraitUpsideDown
            }
        }
        
        return UIInterfaceOrientationMask.all
    }
    
    
    ///////////////////////////////////
    //MARK: - Private Methods
    ///////////////////////////////////
    fileprivate func setUpAnalyticsData(){
        super.logEvent(with: "Player")
        if let name = self.fileFolder?.Name {
            super.setUserProperty(value: name, name: AnalyticsUserProperty.videoName.rawValue)
        }
        if let name = self.fileFolder?.Extension {
            super.setUserProperty(value: name, name: AnalyticsUserProperty.videoExtension.rawValue)
        }
        if let name = self.fileFolder?.length {
            super.setUserProperty(value: name, name: AnalyticsUserProperty.videoLength.rawValue)
        }
        if let name = self.fileFolder?.sizeString {
            super.setUserProperty(value: name, name: AnalyticsUserProperty.videoSize.rawValue)
        }
        super.setUserProperty(value: "\(self.vlcPlayer.numberOfSubtitlesTracks)", name: AnalyticsUserProperty.subCount.rawValue)
    }
    
    fileprivate func setupUI() {
        
        self.btnDone.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        self.btnDone.setImage(IonIcons.image(withIcon: ion_ios_close_empty, size: 30, color: UIColor.white), for: UIControlState.normal)
        self.btnDone.setTitle("", for: UIControlState.normal)
        
        let seekBarHead_normal = IonIcons.image(withIcon: ion_record, size: 10, color: THEME_COLOR)
        self.seekSlider.setThumbImage(seekBarHead_normal, for: UIControlState.normal)
        
        let seekBarHead_focused = IonIcons.image(withIcon: ion_record, size: 30, color: THEME_COLOR)
        self.seekSlider.setThumbImage(seekBarHead_focused, for: UIControlState.highlighted)
        
        self.volumeView.setVolumeThumbImage(seekBarHead_normal, for: UIControlState.normal)
        self.volumeView.setVolumeThumbImage(seekBarHead_focused, for: UIControlState.highlighted)
        self.volumeView.tintColor = THEME_COLOR
        
        
        for subview in self.volumeView.subviews {
            
            if let slider = subview as? UISlider {
                self.volumeSlider = slider
                self.volumeSlider?.value = AVAudioSession.sharedInstance().outputVolume
                self.volumeSlider?.maximumTrackTintColor = UIColor.white
            }
        }
        
        self.resetPlaypauseButton()
        self.resetForwardButton()
        self.resetBackwardButton()
        self.forwardButton.image = IonIcons.image(withIcon: ion_ios_fastforward, size: 150, color: UIColor.white)
        self.backwardButton.image = IonIcons.image(withIcon: ion_ios_rewind, size: 150, color: UIColor.white)
        
        self.lblAlert.layer.shadowColor = UIColor.black.cgColor
        self.lblAlert.layer.shadowRadius = 4
        self.lblAlert.layer.shadowOpacity = 0.9
        self.lblAlert.layer.shadowOffset = CGSize.zero
        self.lblAlert.layer.masksToBounds = false
        
        self.btnScreenLock.imageView?.contentMode = UIViewContentMode.scaleAspectFit
    }
    
    fileprivate func resetPlaypauseButton() {
        self.playPauseButton.isHidden = true
        self.playPauseButton.image = nil
        self.outButtomHeight.constant = 50
        self.playPauseButton.alpha = 1
        self.view.layoutIfNeeded()
    }
    
    fileprivate func resetForwardButton() {
        self.forwardButton.isHidden = true
        self.forwardButtonHeight.constant = 50
        self.forwardButton.alpha = 1
        self.view.layoutIfNeeded()
    }
    
    fileprivate func resetBackwardButton() {
        self.backwardButton.isHidden = true
        self.backwardButtonHeight.constant = 50
        self.backwardButton.alpha = 1
        self.view.layoutIfNeeded()
    }
    
    fileprivate func resetAlertLabel() {
        
        self.lblAlert.isHidden = true
        self.lblAlert.text = ""
        self.lblAlert.alpha = 1
    }
    
    fileprivate func secondsToHMS (_ seconds : Int) -> String {
        let (h,m,s) = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        return "\(self.roundToTwoDigits(h)):\(self.roundToTwoDigits(m)):\(self.roundToTwoDigits(s))"
    }
    
    fileprivate func roundToTwoDigits(_ digit :Int) -> String {
        
        var d = "\(digit)"
        if d.characters.count == 1 {
            d = "0\(d)"
        }
        return d
    }
    
    fileprivate func panDirection(_ velocity: CGPoint) -> PanDirection {
        
        let modulusX = velocity.x > 0 ? velocity.x : (velocity.x * -1)
        let modulusY = velocity.y > 0 ? velocity.y : (velocity.y * -1)
        
        if modulusX > modulusY {
            return PanDirection.vertical
        } else {
            return PanDirection.horizontal
        }
    }
    
    fileprivate func showControls() {
        
        self.viewBottomControls.isHidden = false
        self.viewTopControls.isHidden = false
        self.startControlsTimer()
    }
    
    fileprivate func startControlsTimer() {
        self.controlsTimer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(VideoPlayerViewController.hideControls), userInfo: nil, repeats: false)
    }
    
    fileprivate func showControlOption(withImage image: UIImage?) {
        
        self.resetPlaypauseButton()
        self.playPauseButton.isHidden = false
        self.playPauseButton.image = image
        self.outButtomHeight.constant = 150
        UIView.animate(withDuration: 0.5, animations: {
            self.playPauseButton.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { (finished) in
            self.resetPlaypauseButton()
        })
    }
    
    fileprivate func showFastForward() {
        
        self.resetForwardButton()
        self.forwardButton.isHidden = false
        self.forwardButtonHeight.constant = 150
        UIView.animate(withDuration: 0.5, animations: {
            self.forwardButton.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { (finished) in
            self.resetForwardButton()
        })
    }
    
    fileprivate func showBackward() {
        
        self.resetBackwardButton()
        self.backwardButton.isHidden = false
        self.backwardButtonHeight.constant = 150
        UIView.animate(withDuration: 0.5, animations: {
            self.backwardButton.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { (finished) in
            self.resetBackwardButton()
        })
    }
    
    fileprivate func showAlertLabel(text: String) {
        
        self.resetAlertLabel()
        self.lblAlert.text = text
        self.lblAlert.isHidden = false
    }
    
    fileprivate func shadeAlertLabel() {
        
        UIView.animate(withDuration: 1, animations: {
            self.lblAlert.alpha = 0
        }, completion: { (finished) in
            self.resetAlertLabel()
        })
    }
    
    fileprivate func close() {
        
        self.vlcPlayer.stop()
        if let info = self.fileFolder?.mediaInfo {
            let pos = self.vlcPlayer.position
            info.posision = pos
            info.playCount += 1
            info.lastPlayed = Date()
            info.update()
        }
        
        _ = self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func forwardJump() {
        var jump = JumpInterval.extraShort
        if let ji = UserData.getJumpInterval() {
            jump = ji
        }
        
        if jump == JumpInterval.extraShort {
            self.vlcPlayer.extraShortJumpForward()
        } else if jump == JumpInterval.short {
            self.vlcPlayer.shortJumpForward()
        } else if jump == JumpInterval.medium {
            self.vlcPlayer.mediumJumpForward()
        } else if jump == JumpInterval.long {
            self.vlcPlayer.longJumpForward()
        }
        self.doubleTapedForward = Date()
        self.showFastForward()
    }
    
    fileprivate func backwardJump() {
        var jump = JumpInterval.extraShort
        if let ji = UserData.getJumpInterval() {
            jump = ji
        }
        
        if jump == JumpInterval.extraShort {
            self.vlcPlayer.extraShortJumpBackward()
        } else if jump == JumpInterval.short {
            self.vlcPlayer.shortJumpBackward()
        } else if jump == JumpInterval.medium {
            self.vlcPlayer.mediumJumpBackward()
        } else if jump == JumpInterval.long {
            self.vlcPlayer.longJumpBackward()
        }
        self.doubleTapedBackward = Date()
        self.showBackward()
    }
    
    fileprivate func playPause() {
        if self.vlcPlayer.isPlaying {
            self.showControlOption(withImage: IonIcons.image(withIcon: ion_ios_pause, size: 150, color: UIColor.white))
            self.vlcPlayer.pause()
            self.showControls()
            
        } else {
            self.showControlOption(withImage: IonIcons.image(withIcon: ion_ios_play, size: 150, color: UIColor.white))
            self.vlcPlayer.play()
            self.hideControls()
        }
    }
    
    fileprivate func getThreePartsScreenArea(point: CGPoint) -> ScreenArea {
        
        let touchedPoint = point
        let screenSize = UIScreen.main.bounds
        
        let playpause = screenSize.width / 3
        let forward = screenSize.width / 3 * 2
        
        if touchedPoint.x < playpause {
            return ScreenArea.backward
            
        } else if touchedPoint.x < forward {
            
            return ScreenArea.playPause
            
        } else {
            return ScreenArea.forward
        }
    }
    
    fileprivate func getTwoPartsScreenArea(point: CGPoint) -> ScreenArea {
        
        let touchedPoint = point
        let screenSize = UIScreen.main.bounds
        
        let half = screenSize.width / 2
        
        if touchedPoint.x < half {
            return ScreenArea.left
            
        } else {
            return ScreenArea.right
        }
    }
    
    fileprivate func setupSubtitlesButton() {
        if self.vlcPlayer.numberOfSubtitlesTracks > 0 {
            self.btnSubtitles.isEnabled = true
            self.btnSubtitles.alpha = 1
        } else {
            self.btnSubtitles.isEnabled = false
            self.btnSubtitles.alpha = 0.5
        }
    }
    
    ///////////////////////////////////
    //MARK: - Events
    ///////////////////////////////////
    
    func hideControls() {
        self.controlsTimer?.invalidate()
        self.viewBottomControls.isHidden = true
        self.viewTopControls.isHidden = true
    }
    
    @IBAction func close(_ sender: UIButton) {
        
        self.close()
    }
    
    @IBAction func subtitlesPressed(_ sender: UIButton) {
        
        if let nav = self.storyboard?.instantiateViewController(withIdentifier: "ListNav") as? UINavigationController {
            
            if let vc = nav.viewControllers.first as? ListViewController {
                var items: [ListItem] = []
                
                if let names = self.vlcPlayer.videoSubTitlesNames as? [String] {
                    
                    for sub in 0..<names.count {
                        let item = ListItem(name: names[sub])
                        if let indexes = self.vlcPlayer.videoSubTitlesIndexes as? [Int32] {
                            if indexes[sub] == self.vlcPlayer.currentVideoSubTitleIndex {
                                item.selected = true
                            }
                        }
                        items.append(item)
                    }
                    vc.items = items
                    vc.delegate = self
                    vc.type = ListType.sub
                    
                }
            }
            
            let formsheet = PopupManager.createPopup(with: nav, type: PopupType.SubList)
            
            self.show(formsheet, sender: nil)
        }
    }
    
    @IBAction func playPausePressed(_ sender: UIButton) {
        
        self.playPause()
        self.showControls()
    }
    
    @IBAction func screenlockPressed(_ sender: UIButton) {
        
        if self.btnScreenLock.isSelected {
            self.btnScreenLock.isSelected = false
        } else {
            self.btnScreenLock.isSelected = true
        }
        self.showControls()
        
    }
    
    @IBAction func seekSliderValueChanged(_ sender: UISlider) {
        
        self.vlcPlayer.position = sender.value
    }
    
    @IBAction func sliderBeganTracking(_ sender: AnyObject) {
        self.playingBeforeSeek = self.vlcPlayer.isPlaying
        self.vlcPlayer.pause()
        self.controlsTimer?.invalidate()
    }
    
    @IBAction func sliderEndedTracking(_ sender: AnyObject) {
        if self.playingBeforeSeek {
            self.vlcPlayer.play()
        }
        startControlsTimer()
    }
    
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        
        
        
        let velocity = sender.velocity(in: self.view)
        
        if sender.state == UIGestureRecognizerState.began {
            self.panDirection = self.panDirection(velocity)
            self.showControls()
            self.controlsTimer?.invalidate()
        } else if sender.state == UIGestureRecognizerState.ended {
            self.hideControls()
        }
        
        if panDirection == PanDirection.vertical {
            
            if UserData.getBoolUserData(forKey: UserDefaultKey.swipeSeek) {
                if sender.state == UIGestureRecognizerState.began {
                    
                    self.vlcPlayer.pause()
                    self.seekPosition = self.seekSlider.value
                }
                
                let velocityX = velocity.x
                var forwardFactor: Float = 0.0
                if (velocityX > 0.0 && velocityX < 50.0) || (velocityX < 0.0 && velocityX > -50.0) {
                    forwardFactor = Float(velocityX / 250000)
                } else {
                    forwardFactor = Float(velocityX / 250000)
                }
                
                self.vlcPlayer.position = self.seekPosition + forwardFactor
                self.seekPosition += forwardFactor
                self.seekSlider.value = self.seekPosition
                var cur = Float(self.vlcPlayer.media.length.intValue) * self.seekPosition
                if cur < 0 {
                    cur = 0
                }
                let time = self.secondsToHMS(Int(cur / 1000))
                self.lblPlayingTime.text = time
                
                self.showAlertLabel(text: time)
                
                if sender.state == UIGestureRecognizerState.ended {
                    self.vlcPlayer.play()
                    self.shadeAlertLabel()
                }
            }
            
        } else if self.panDirection == PanDirection.horizontal {
            
            let area = self.getTwoPartsScreenArea(point: sender.location(in: self.videoView))
            if area == ScreenArea.right {
                if UserData.getBoolUserData(forKey: UserDefaultKey.swipeVolume) {
                    
                    if velocity.y > 0 {
                        self.volumeSlider?.value = AVAudioSession.sharedInstance().outputVolume - 0.01
                    } else {
                        self.volumeSlider?.value = AVAudioSession.sharedInstance().outputVolume + 0.01
                    }
                    if let vol = self.volumeSlider?.value {
                        self.showAlertLabel(text: "Volume \(Int(vol * 100))%")
                        if sender.state == UIGestureRecognizerState.ended {
                            self.shadeAlertLabel()
                        }
                    }
                }
                
            } else {
                if UserData.getBoolUserData(forKey: UserDefaultKey.swipeBrightness) {
                    if velocity.y > 0 {
                        UIScreen.main.brightness = UIScreen.main.brightness - 0.01
                    } else {
                        UIScreen.main.brightness = UIScreen.main.brightness + 0.01
                    }
                    self.showAlertLabel(text: "Brightness \(Int(UIScreen.main.brightness * 100))%")
                    
                    if sender.state == UIGestureRecognizerState.ended {
                        self.shadeAlertLabel()
                    }
                }
                
            }
        }
    }
    
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        
        if Date().timeIntervalSince(doubleTapedForward) < doubleTapInterval, self.getThreePartsScreenArea(point: sender.location(in: self.videoView)) == ScreenArea.forward {
            self.forwardJump()
            
        } else if Date().timeIntervalSince(doubleTapedBackward) < doubleTapInterval, self.getThreePartsScreenArea(point: sender.location(in: self.videoView)) == ScreenArea.backward {
            self.backwardJump()
            
        } else {
            
            if controlsTimer?.isValid == true {
                self.hideControls()
            } else {
                self.showControls()
            }
        }
    }
    
    @IBAction func doubleTapGesture(_ sender: UITapGestureRecognizer) {
        
        let touchedPoint = sender.location(in: self.videoView)
        let screenarea = self.getThreePartsScreenArea(point: touchedPoint)
        
        if screenarea == ScreenArea.backward {
            if UserData.getBoolUserData(forKey: UserDefaultKey.jumpBackward) {
                self.backwardJump()
            }
            
        } else if screenarea == ScreenArea.playPause {
            if UserData.getBoolUserData(forKey: UserDefaultKey.playPause) {
                self.playPause()
            }
            
        } else {
            if UserData.getBoolUserData(forKey: UserDefaultKey.jumpForward) {
                self.forwardJump()
            }
        }
        
    }
    
    @IBAction func pinchGesture(_ sender: UIPinchGestureRecognizer) {
        
    }
    
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        
//        switch sender.direction {
//        case UISwipeGestureRecognizerDirection.down:
//            self.close()
//        default:
//            break
//        }
    }

}


extension VideoPlayerViewController: VLCMediaPlayerDelegate {
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        
        if self.vlcPlayer.state == VLCMediaPlayerState.stopped {
            self.close()
        }
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        self.seekSlider.value = self.vlcPlayer.position
        self.lblPlayingTime.text = self.secondsToHMS(Int(self.vlcPlayer.time.intValue / 1000))
    }
}


extension VideoPlayerViewController: VLCMediaThumbnailerDelegate {
    
    func mediaThumbnailer(_ mediaThumbnailer: VLCMediaThumbnailer!, didFinishThumbnail thumbnail: CGImage!) {
        
        if let mediaURL = mediaThumbnailer.media.url {
            let thumb = UIImage(cgImage: thumbnail)
            ImageHandler().saveThumbnail(image: thumb, name: FileHandler().constructName(forURL: mediaURL))
        }
    }
    
    func mediaThumbnailerDidTimeOut(_ mediaThumbnailer: VLCMediaThumbnailer!) {
        
        NSLog("thumbnailer timed out")
    }
}


extension VideoPlayerViewController: VLCMediaDelegate {
    
    func mediaDidFinishParsing(_ aMedia: VLCMedia!) {
        
        self.setupSubtitlesButton()
    }
}


extension VideoPlayerViewController: ListDelegate {
    
    func itemSelected(at index: Int, of type: ListType?) {
        if self.vlcPlayer.videoSubTitlesIndexes.count > index, let ind = self.vlcPlayer.videoSubTitlesIndexes[index] as? Int32 {
            
            self.vlcPlayer.currentVideoSubTitleIndex = ind
        }
    }
}
