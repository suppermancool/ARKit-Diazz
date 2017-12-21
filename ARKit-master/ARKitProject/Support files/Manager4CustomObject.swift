//
//  Manager4CustomObject.swift
//  ARKitProject
//
//  Created by dat on 12/17/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation

class Manager4CustomObject {
    static let shared = Manager4CustomObject()
    let maxNumberOfFile = 5
    var currentPath: URL?
    
    var numberOfFile: Int = -1
    
    init() {
        numberOfFile = maxNumberOfFile
        for i in 0..<maxNumberOfFile {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let path = documentsURL.appendingPathComponent("\(i)").appendingPathComponent("pig.scn")
            if !FileManager.default.fileExists(atPath: path.path) {
                self.numberOfFile = i
                break
            }
        }
    }
    
    func getPathAtIndex(_ i: Int) -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(i)/")
    }
    
    func switch2NextPath() -> URL {
        if numberOfFile == maxNumberOfFile {
            currentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(0)/")
            // move old file into 1 next folder
            for i in stride(from: maxNumberOfFile-1, through: 1, by: -1) {
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let from = documentsURL.appendingPathComponent("\(i-1)/")
                let to = documentsURL.appendingPathComponent("\(i)/")
                do {
                let directoryContents = try FileManager.default.contentsOfDirectory(at: from, includingPropertiesForKeys: nil, options: [])
                print(directoryContents)
                    for fileFrom in directoryContents {
                        let fileName = fileFrom.lastPathComponent
                        let fromFile = "\(from)/\(fileName)"
                        let toFile = "\(to)/\(fileName)"
                        try FileManager.default.moveItem(at: URL(fileURLWithPath: fromFile), to: URL(fileURLWithPath: toFile))
                    }
                } catch {
                    
                }
            }
        } else {
            currentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(numberOfFile)/")
            numberOfFile += 1
        }
        return currentPath!
    }
}
