//
//  MoveViewController.swift
//  Yangola
//
//  Created by Lasith Hettiarachchi on 8/6/17.
//  Copyright © 2017 Lasith Hettiarachchi. All rights reserved.
//

import UIKit
import ionicons

protocol MoveViewControllerDelegate {
    
    func move(to: FileFolder?)
    func moveCancelled()
}

class MoveViewController: ParentViewController {
    

    var currentFileFolder: FileFolder?
    var delegate: MoveViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.logEvent(with: "Move")
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        let closeIcon = IonIcons.image(withIcon: ion_ios_close_empty, size: 30, color: UIColor.white)
        let close = UIBarButtonItem(image: closeIcon, style: UIBarButtonItemStyle.plain, target: self, action: #selector(MoveViewController.cancelPressed(sender:)))
        
        let backIcon = IonIcons.image(withIcon: ion_ios_arrow_back, size: 30, color: UIColor.white)
        let back = UIBarButtonItem(image: backIcon, style: UIBarButtonItemStyle.plain, target: self, action: #selector(MoveViewController.backPressed(sender:)))
        var leftButtons = [close]
        if currentFileFolder != nil {
            leftButtons = [close, back]
        }
        self.navigationItem.setLeftBarButtonItems(leftButtons, animated: true)

        let fileManager = FileHandler()
        if let docs = fileManager.getDocumentsDirectory(), self.currentFileFolder == nil {
            self.currentFileFolder = fileManager.getFileFolder(fromURL: docs)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowFilesMove", let vc = segue.destination as? FilesViewController {
            vc.screenSize = CGRect(origin: CGPoint.zero, size: PopupManager.getMoveVcSize())
            vc.delegate = self
            vc.headerSize = CGSize.zero
            vc.type = FilesType.move
            vc.filesSourceUrl = self.currentFileFolder?.URL
        }
    }
    
    
    @IBAction func cancelPressed(sender: Any) {
        
        self.delegate?.moveCancelled()
        dismiss(animated: true, completion: nil)
    }
    
    
    func backPressed(sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func moveHerePressed(sender: Any) {
        
        self.delegate?.move(to: currentFileFolder)
        dismiss(animated: true, completion: nil)
    }
}


extension MoveViewController: FilesDelegate {
    
    func enableMoreButton(enabled: Bool) {
        
    }

    
    func showVC(vc: UIViewController) {
        
    }

    
    func playVideo(withFile file: FileFolder) {
        
    }
    
    func openFolder(withFolder url: FileFolder) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MoveVc") as? MoveViewController {
            vc.title = url.Name
            vc.currentFileFolder = url
            vc.delegate = self.delegate
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func enableShareButton(enabled: Bool) {
        
    }
    
    func enableDeleteButton(enabled: Bool) {
        
    }
    
    func getSearchQuery() -> String? {
        
        return nil
    }
    
    func enableSelectState() {
        
    }
    
    func isSelectionStateEnabled() -> Bool {
        return false
    }
}
