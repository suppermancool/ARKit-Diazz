import Foundation
import ARKit

class Wolf: VirtualObject {
    
    override init() {
        super.init(modelName: "wolf", fileExtension: "scn", thumbImageFilename: "dog", title: "Dog")
    }
    
    override func loadModel() {
        if let wolfScene = SCNScene(named: "art.scnassets/wolf.dae") {
            loadModel(scene: wolfScene)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
