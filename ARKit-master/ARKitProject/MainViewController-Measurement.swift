import ARKit
import Foundation
import SceneKit
import UIKit
import Photos
import ARVideoKit


// MARK: - ARKit / ARSCNView
extension MainViewController {
    
    
    func resetValues() {
        startValue = SCNVector3()
        endValue =  SCNVector3()
    }
    
    func detectObjects() {
        guard let worldPosition = sceneView.realWorldVector(screenPosition: view.center) else { return }
//        if lines.isEmpty {
//            messageLabel.text = "Hold screen & move your phone…"
//        }
        if isMeasuring {
            if startValue == self.vectorZero {
                startValue = worldPosition
                currentLine = Line(sceneView: sceneView, startVector: startValue, unit: unit)
            }
            endValue = worldPosition
            currentLine?.update(to: endValue)
            messageLabel.text = currentLine?.distance(to: endValue) ?? "Calculating…"
        }
    }
    
    func fakeTouchesBegan() {
        resetValues()
        targetImageView.image = UIImage(named: "targetGreen")
    }
    
    func fakeTouchesEnded() {
        targetImageView.image = UIImage(named: "targetWhite")
        if let line = currentLine {
            lines.append(line)
            currentLine = nil
        }
    }
    
    
}
