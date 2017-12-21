import ARKit
import Foundation
import SceneKit
import UIKit
import Photos
import ARVideoKit


// MARK: - ARKit / ARSCNView
extension MainViewController {
    func setUpVideoRecorder()  {
        
        recorder = RecordAR(ARSceneKit: sceneView)
//        recorder?.delegate = self
//        recorder?.renderAR = self
        recorder?.onlyRenderWhileRecording = false
        recorder?.inputViewOrientations = [.portrait]
        recorder?.deleteCacheWhenExported = false
    }
    
    @IBAction func takeScreenShot(_ sender: UIButton) {
        //Record
        if recorder?.status == .readyToRecord {
            if let image = self.recorder?.photo() {
                self.exportMessage(success: true, status: nil, any: image)
            }
        }
    }
    
    @IBAction func record(_ sender: UIButton) {
        //Record
        if recorder?.status == .readyToRecord {
            recordingQueue.async {
                self.recorder?.record()
            }
            recordBtn.isHidden = true
            stopRecordBtn.isHidden = false
        }
    }
    
    @IBAction func stopRecord(_ sender: UIButton) {
        if recorder?.status == .recording {
            recorder?.stop() { path in
                DispatchQueue.main.sync {
                    self.exportMessage(success: true, status: nil, any: path)
                    self.recordBtn.isHidden = false
                    self.stopRecordBtn.isHidden = true
                }
//                self.recorder?.export(video: path) { saved, status in
//                    DispatchQueue.main.sync {
//                        self.exportMessage(success: saved, status: status)
//                        self.recordBtn.isHidden = false
//                        self.stopRecordBtn.isHidden = true
//                    }
//                }
            }
            recordBtn.isHidden = true
            stopRecordBtn.isHidden = true
        }
    }
    
    
    @IBAction func shareCsv(sender: AnyObject) {
        //Your CSV text
        //        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "videoExample", ofType: "mp4")!)
        let fileURL = Bundle.main.path(forResource: "videoExample", ofType: "mp4")!
        print("Size \(fileURL.fileSize())")
        //        let destFile = Bundle.main.path(forResource: "videoExample", ofType: "mp4")
        //        NetManager.shared.modelTextureFilePath
        
        shareAny(URL(fileURLWithPath: fileURL))
        
    }
    
    func shareAny(_ any: Any) {
        let objectsToShare = [any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    // MARK: - Exported UIAlert present method
    func exportMessage(success: Bool, status:PHAuthorizationStatus?, any: Any) {
        if success {
            let alert = UIAlertController(title: "Exported", message: "Media exported successfully! Do you want to share to you friend!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Awesome", style: .cancel, handler: {
                _ in
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (_) in
                    self.shareAny(any)
                })
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
