/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The virtual chair.
*/

import Foundation
import SceneKit

let POINT_SIZE = CGFloat(0.0006)
var lineColor = UIColor.white

class PointNode: SCNNode {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(color: UIColor, vector vector1: SCNVector3) {
        super.init()
        let boxGeo = SCNSphere(radius: POINT_SIZE)
        boxGeo.firstMaterial?.diffuse.contents = UIColor.red
        let object = SCNNode(geometry: boxGeo)
        self.addChildNode(object)
        self.position = vector1
    }
    
    class func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
    
    class func lineNodeFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNNode {
        let line = lineFrom(vector: vector1, toVector: vector2)
        let lineNode = SCNNode(geometry: line)
        lineNode.geometry?.firstMaterial?.diffuse.contents = lineColor
        return lineNode
    }
    
    class func bigPointNodeFrom(vector vector1: SCNVector3, color: UIColor = UIColor.red) -> SCNNode {
        let boxGeo = SCNSphere(radius: POINT_SIZE)
        boxGeo.firstMaterial?.diffuse.contents = color
        let object = SCNNode(geometry: boxGeo)
        object.position = vector1
        return object
    }
    
    class func pointNodeFrom(vector vector1: SCNVector3) -> SCNNode {
        let indices: [Int32] = [0]
        let source = SCNGeometrySource(vertices: [vector1])
        let element = SCNGeometryElement(indices: indices, primitiveType: .point)
        let point = SCNGeometry(sources: [source], elements: [element])
        
        let pointNode = SCNNode(geometry: point)
        pointNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        return pointNode
    }
}
