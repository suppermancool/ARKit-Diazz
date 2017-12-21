//
//  NetManager.swift
//  ARKitDraw
//
//  Created by dat on 12/9/17.
//  Copyright © 2017 Felix Lapalme. All rights reserved.
//

import UIKit
import Alamofire
import ARKit
import SwiftRandom

class NetManager: NSObject {
    static let shared = NetManager()
    var depthImgV: UIImageView?
    var leftImgV: UIImageView?
    var rightImgV: UIImageView?
    var lblLog: UILabel?
    var isReduceNoice: Bool = false
    
    var width: Int = 0
    var height: Int = 0
    var maxDepth: Int = 0
    var depths: [Int]?
    var cameraPos: SCNVector3?
    var mat: SCNMatrix4?
    var alamoFireManager: SessionManager
    
    override init() {
        let configuration = URLSessionConfiguration.default
//        configuration.timeoutIntervalForRequest = 60 // seconds
//        configuration.timeoutIntervalForResource = 60
        self.alamoFireManager = Alamofire.SessionManager(configuration: configuration)
    }
    var endPoint: String {
        let endPoint = UserDefaults.standard.string(forKey: "server_ip")!
        return endPoint
    }
    
    var uploadEndPoint: String {
        let endPoint = UserDefaults.standard.string(forKey: "server_upload_ip")!
        return endPoint
    }
    
    var imgL: UIImage? {
        didSet {
            DispatchQueue.main.async {
                if self.imgL != nil {
                    self.leftImgV?.image = self.imgL
                } else {
                    self.leftImgV?.alpha = 0.5
                }
            }
        }
    }
    var imgR: UIImage? {
        didSet {
            if imgR != nil {
                DispatchQueue.main.async { self.rightImgV?.image = self.imgR }
                uploadImage2SV()
            } else {
                DispatchQueue.main.async { self.rightImgV?.alpha = 0.5 }
            }
        }
    }
    
    func resetCache() {
        self.imgL = nil
        self.imgR = nil
        self.width = 0
        self.height = 0
        self.maxDepth = 0
        self.depths = nil
        self.mat = nil
        self.cameraPos = nil
    }

    func addImg2Queue(img: UIImage, imgVL: UIImageView, imgVR: UIImageView, imgVD: UIImageView, lblLog: UILabel, isReduceNoice: Bool, cameraPos: SCNVector3?, mat: SCNMatrix4?) {
        self.lblLog = lblLog
        self.isReduceNoice = isReduceNoice
        depthImgV = imgVD
        leftImgV = imgVL
        rightImgV = imgVR
        guard imgL != nil else {
            imgL = img
            return
        }
        guard imgR != nil else {
            imgR = img
            self.cameraPos = cameraPos
            self.mat = mat
            return
        }
    }
    
    var modelFilePath: URL {
        let fileURL = Manager4CustomObject.shared.switch2NextPath().appendingPathComponent("pig.scn")
        return fileURL
    }
    
    var modelTextureFilePath: URL {
        let fileURL = Manager4CustomObject.shared.currentPath!.appendingPathComponent("model_dense_mesh_refine_texture.png")
        return fileURL
    }
    
    var videoRecordFilePath: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("recordVideo")
        return fileURL
    }
    
    func downloadModel(finished: @escaping (Bool) -> Void, label: UILabel) {
        let destinationModel: DownloadRequest.DownloadFileDestination = { _, _ in
            let fileURL = self.modelFilePath
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        let destinationModelTexture: DownloadRequest.DownloadFileDestination = { _, _ in
            let fileURL = self.modelTextureFilePath
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        alamoFireManager.download(endPoint + "/download_model", to: destinationModel).response { response in
            if response.error == nil, let filePath = response.destinationURL?.path {
                print("File \(filePath)")
                print("Size \(filePath.fileSize())")
                Alamofire.download(self.endPoint + "/download_texture", to: destinationModelTexture).response { response in
                    if response.error == nil, let filePath = response.destinationURL?.path {
                        print("File \(filePath)")
                        print("Size \(filePath.fileSize())")
                        finished(true)
                    } else {
                        finished(false)
                    }
                    }.downloadProgress(closure: { (progress) in
                        let realProcess = Int(progress.fractionCompleted*100/2 + 50)
                        label.text = "\(realProcess)%"
                        print("Download Progress: \(progress.fractionCompleted)")
                    })
            } else {
                finished(false)
            }
        }.downloadProgress { (progress) in
            let realProcess = Int(progress.fractionCompleted*100/2)
            label.text = "\(realProcess)%"
            print("Download Progress: \(progress.fractionCompleted)")
        }
    }
    
    func uploadImage2SV() {
        //        let imageData = UIImagePNGRepresentation(image)!
        //        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        //        let imageURL = docDir.appendingPathComponent("tmp.png")
        //        try! imageData.write(to: imageURL)
        
        let imgDataL = UIImageJPEGRepresentation(imgL!,0.9)!
        let imgDataR = UIImageJPEGRepresentation(imgR!,0.9)!
//        let imgDataL = UIImagePNGRepresentation(imgL!)!
//        let imgDataR = UIImagePNGRepresentation(imgR!)!
        
        let finish = {
            (width: Int, height: Int, maxDepth: Int, depths: [Int]?) in
            self.width = width
            self.height = height
            self.maxDepth = maxDepth
            self.depths = depths
            
            DispatchQueue.main.async {
                self.lblLog?.text = "Log"
            }
            
        }
        lblLog?.text = "Processing ... "
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgDataL, withName: "imgL",fileName: "imgL.jpg", mimeType: "image/jpg")
            multipartFormData.append(imgDataR, withName: "imgR",fileName: "imgR.jpg", mimeType: "image/jpg")
//        },to:"http://192.168.0.107:8081/profile")
//        },to:"http://192.168.0.107:8081/profiletxt")
        },to: endPoint + "/profiletxt")
//        },to:"http://169.254.158.163:8081/profile")
//        },to:"http://169.254.158.163:8081/profiletxt")
//        },to:"http://169.254.120.39:8081/profiletxt")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                upload.responseData(completionHandler: { (response) in
                    print(response.result.value ?? "")
                    if let value = response.result.value {
                        DispatchQueue.global().async {
                            var valueStr = String(data: value, encoding: String.Encoding.utf8) as String!
                            print("result")
                            var bunchStrs = valueStr?.characters.split{$0 == " "}.map(String.init)
                            let width = Int((bunchStrs?.removeFirst())!)!
                            let height = Int((bunchStrs?.removeFirst())!)!
                            let max = Int((bunchStrs?.removeLast())!)!
                            var depthValue = (bunchStrs?.map { Int($0)! })!
                            if self.isReduceNoice { UIImage.reduceNoises(width: width, height: height, max: max, depths: &depthValue) }
                            DispatchQueue.main.async {
                                if let depthIV = self.depthImgV,
                                    !depthIV.isHidden {
                                    depthIV.image = UIImage.renderGray(width: width, height: height, max: max, depths: depthValue)
                                }
                            }
                            finish(width, height, max, depthValue)
                        }
                    } else {
                        finish(0, 0, 0, nil)
                    }
                })
                
            case .failure(let encodingError):
                finish(0, 0, 0, nil)
                print(encodingError)
            }
        }
    }
    
    func uploadImage2SV(uiimage: UIImage, finish: @escaping (Bool) -> Void) {
        
        
        let imgDataL = UIImageJPEGRepresentation(uiimage,1.0)
        let name = Randoms.randomInt(0, 10000)
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgDataL!, withName: "img2d",fileName: "photo-\(name).jpg", mimeType: "image/jpg")
        },to: uploadEndPoint + "/uploadimg2d")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                upload.responseData(completionHandler: { (response) in
                    finish(true)
                })
                
            case .failure(let encodingError):
                finish(false)
            }
        }
    }
}
