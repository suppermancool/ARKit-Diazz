import ARKit
import Foundation
import SceneKit
import UIKit
import Photos
import ARVideoKit


// MARK: - ARKit / ARSCNView
extension MainViewController {
    
    @IBAction func uploadImage(_ sender: UIButton) {
        //Record
        if let image = getCameraImg() {
            NetManager.shared.uploadImage2SV(uiimage: image, finish: { (isSuccess) in
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Uploaded", message: isSuccess ? "Success" : "Fail", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    func setUpGet2dImage() {
//        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (_) in
//            if let img = self.getCameraImg() {
//                self.testImgV.image = img
//            }
//        }

    }
    
    func getCameraImg() -> UIImage? {
        self.sceneView.session.currentFrame?.capturedDepthData
        if let captureImage = (self.sceneView.session.currentFrame?.capturedImage) {
            return UIImage(pixelBuffer: captureImage, scale: 1)
//            image = image?.scaleAndSquareImage(0.25)
//            return image
        } else {
            return nil
        }
    }
}
