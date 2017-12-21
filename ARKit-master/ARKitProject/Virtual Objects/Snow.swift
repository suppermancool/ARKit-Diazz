import Foundation
import ARKit

class Snow: VirtualObject {
    
    override init() {
        super.init(modelName: "snow", fileExtension: "scn", thumbImageFilename: "snow", title: "Snow")
    }
    
    override func loadModel() {
        if let snowScene = SCNScene(named: "art.scnassets/snow.scn") {
            if let particles = SCNParticleSystem.init(named: "Snow", inDirectory: nil) {
                if let box = snowScene.rootNode.childNode(withName: "box", recursively: true){
                    box.addParticleSystem(particles)
                }
            }
            loadModel(scene: snowScene)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
