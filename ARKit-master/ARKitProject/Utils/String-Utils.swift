//
//  String-Utils.swift
//  ARKitProject
//
//  Created by dat on 12/16/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation

extension String {
    
    func fileSize() -> UInt64 {
        let filePath = self
        var fileSize : UInt64 = 0
        
        do {
            //return [FileAttributeKey : Any]
            let attr = try FileManager.default.attributesOfItem(atPath: filePath)
            fileSize = attr[FileAttributeKey.size] as! UInt64
            
            //if you convert to NSDictionary, you can get file size old way as well.
            let dict = attr as NSDictionary
            fileSize = dict.fileSize()
        } catch {
            print("Error: \(error)")
        }
        
        return fileSize
    }
    
}
