//
//  MOHelper.swift
//  ARKitProject
//
//  Created by dat on 12/17/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import ARKit
import CoreData

class MOHelper {
    
    class func clearAll() {
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "MONodeObject")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try CoreDataManager.shared.mainContext.execute(deleteRequest)
            CoreDataManager.shared.saveContext()
        }
        catch
        {
            print ("There was an error")
        }
    }
    
    class func createMOMarkup(text: String, pos: SCNVector3) {
        let moMarkup = NSEntityDescription.insertNewObject(forEntityName: "MOMarkup", into: CoreDataManager.shared.mainContext) as! MOMarkup
        moMarkup.text = text
        moMarkup.posX = pos.x
        moMarkup.posY = pos.y
        moMarkup.posZ = pos.z
        CoreDataManager.shared.saveContext()
    }
    
    class func createMOVirtualObject(virtualObject: VirtualObject) {
        guard !virtualObject.isKind(of: DownloadObject.self) else { return }
        let moVirtualObject = NSEntityDescription.insertNewObject(forEntityName: "MOVirtualObject", into: CoreDataManager.shared.mainContext) as! MOVirtualObject
        moVirtualObject.modelName = virtualObject.modelName
        virtualObject.moVirtualObject = moVirtualObject
        updateMOVirtualObject(virtualObject: virtualObject)
        CoreDataManager.shared.saveContext()
    }
    
    class func updateMOVirtualObject(virtualObject: VirtualObject) {
        guard !virtualObject.isKind(of: DownloadObject.self) else { return }
        let moVirtualObject = virtualObject.moVirtualObject
        moVirtualObject?.posX = virtualObject.position.x
        moVirtualObject?.posY = virtualObject.position.y
        moVirtualObject?.posZ = virtualObject.position.z
        moVirtualObject?.anglesX = virtualObject.eulerAngles.x
        moVirtualObject?.anglesY = virtualObject.eulerAngles.y
        moVirtualObject?.anglesZ = virtualObject.eulerAngles.z
        moVirtualObject?.scaleX = virtualObject.scale.x
        moVirtualObject?.scaleY = virtualObject.scale.y
        moVirtualObject?.scaleZ = virtualObject.scale.z
        CoreDataManager.shared.saveContext()
    }
    
    class func getAllMOMarkup() -> [MOMarkup] {
        let moMarkupFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "MOMarkup")
        do {
            let listMOMarkup = try CoreDataManager.shared.mainContext.fetch(moMarkupFetch) as! [MOMarkup]
            return listMOMarkup
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
    
    class func getAllMOVirtualObject() -> [MOVirtualObject] {
        let moVirtualObjectFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "MOVirtualObject")
        do {
            let listMOMarkup = try CoreDataManager.shared.mainContext.fetch(moVirtualObjectFetch) as! [MOVirtualObject]
            return listMOMarkup
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
}
