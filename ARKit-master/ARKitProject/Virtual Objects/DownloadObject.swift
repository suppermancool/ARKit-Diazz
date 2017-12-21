import Foundation
import ARKit

class DownloadObject: VirtualObject {

    var index: Int
    
//    override init() {
//        index = 0
//        super.init(modelName: "custom", fileExtension: "scn", thumbImageFilename: "customIcon", title: "Custom")
//    }
    
    init(index: Int) {
        self.index = index
		super.init(modelName: "custom", fileExtension: "scn", thumbImageFilename: "customIcon", title: "Custom \(index+1)")
	}
    
    override func loadModel() {
        loadModel(url: Manager4CustomObject.shared.getPathAtIndex(index).appendingPathComponent("pig.scn"))
    }

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
