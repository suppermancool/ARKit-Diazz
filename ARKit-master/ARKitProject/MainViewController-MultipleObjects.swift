import ARKit
import Foundation
import SceneKit
import UIKit
import Photos
import ARVideoKit


// MARK: - ARKit / ARSCNView
extension MainViewController {
    
    @IBAction func chooseObject(_ button: UIButton) {
//        // Abort if we are about to load another object to avoid concurrent modifications of the scene.
//        if isLoadingObject { return }
//
//        virtualObjectSelectionViewController(nil, object: VirtualObjectSelectionViewController.getDownloadObject())
        // Abort if we are about to load another object to avoid concurrent modifications of the scene.
        if isLoadingObject { return }
        
        textManager.cancelScheduledMessage(forType: .contentPlacement)
        
        let rowHeight = 45
        let popoverSize = CGSize(width: 250, height: rowHeight * VirtualObjectSelectionViewController.COUNT_OBJECTS)
        
        let objectViewController = VirtualObjectSelectionViewController(size: popoverSize)
        objectViewController.delegate = self
        objectViewController.modalPresentationStyle = .popover
        objectViewController.popoverPresentationController?.delegate = self
        self.present(objectViewController, animated: true, completion: nil)
        
        objectViewController.popoverPresentationController?.sourceView = button
        objectViewController.popoverPresentationController?.sourceRect = button.bounds
    }
    
    
}
