import ARKit
import Foundation
import SceneKit
import UIKit
import Photos
import ARVideoKit
import Vision


// MARK: - ARKit / ARSCNView
extension MainViewController {
    
    func setUpVirtualObjects() {
        for moVirtualObject in MOHelper.getAllMOVirtualObject() {
            let worldCoord : SCNVector3 = SCNVector3Make(moVirtualObject.posX, moVirtualObject.posY, moVirtualObject.posZ)
            let angle : SCNVector3 = SCNVector3Make(moVirtualObject.anglesX, moVirtualObject.anglesY, moVirtualObject.anglesZ)
            let scale : SCNVector3 = SCNVector3Make(moVirtualObject.scaleX, moVirtualObject.scaleY, moVirtualObject.scaleZ)
            if let virtualObject = VirtualObject.createVirtualObject(moVirtualObject.modelName!) {
                virtualObject.position = worldCoord
                virtualObject.eulerAngles = angle
                virtualObject.scale = scale
                addVirtualObject2Scene(object: virtualObject)
            }
        }
    }
    
    func loadVirtualObject(object: VirtualObject) {
        // Show progress indicator
        let spinner = UIActivityIndicatorView()
        spinner.center = addObjectButton.center
        spinner.bounds.size = CGSize(width: addObjectButton.bounds.width - 5, height: addObjectButton.bounds.height - 5)
        addObjectButton.setImage(#imageLiteral(resourceName: "buttonring"), for: [])
        sceneView.addSubview(spinner)
        spinner.startAnimating()
        
        DispatchQueue.global().async {
            self.isLoadingObject = true
            object.viewController = self
            self.virtualObject = object
            
            object.loadModel()
            
            DispatchQueue.main.async {
                if let lastFocusSquarePos = self.focusSquare?.lastPosition {
                    self.setNewVirtualObjectPosition(lastFocusSquarePos)
                } else {
                    self.setNewVirtualObjectPosition(SCNVector3Zero)
                }
                
                spinner.removeFromSuperview()
                
                // Update the icon of the add object button
                let buttonImage = UIImage.composeButtonImage(from: object.thumbImage)
                let pressedButtonImage = UIImage.composeButtonImage(from: object.thumbImage, alpha: 0.3)
                self.addObjectButton.setImage(buttonImage, for: [])
                self.addObjectButton.setImage(pressedButtonImage, for: [.highlighted])
                self.isLoadingObject = false
            }
        }
    }
    
    func setNewVirtualObjectPosition(_ pos: SCNVector3) {
        
        guard let object = virtualObject, let cameraTransform = session.currentFrame?.camera.transform else {
            return
        }
        
        recentVirtualObjectDistances.removeAll()
        
        let cameraWorldPos = SCNVector3.positionFromTransform(cameraTransform)
        var cameraToPosition = pos - cameraWorldPos
        cameraToPosition.setMaximumLength(DEFAULT_DISTANCE_CAMERA_TO_OBJECTS)
        
        object.position = cameraWorldPos + cameraToPosition
        
        if object.parent == nil {
            addVirtualObject2Scene(object: object)
            MOHelper.createMOVirtualObject(virtualObject: object)
        }
    }
    
    func addVirtualObject2Scene(object: VirtualObject) {
        if object.parent == nil {
            sceneView.scene.rootNode.addChildNode(object)
            if !objectArray.contains(object) {
                objectArray.append(object)
                
            }
        }
    }
}
