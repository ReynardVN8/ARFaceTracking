//
//  ViewController.swift
//  ARFaceTracking
//
//  Created by Reynard Vincent Nata on 07/11/19.
//  Copyright © 2019 Reynard Vincent Nata. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var faceLabel: UILabel!
    @IBOutlet weak var labelView: UIView!
    
    var analysis = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1
        labelView.layer.cornerRadius = 10
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines
        return node
    }
    
    // Update face mesh
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
            expression(anchor: faceAnchor)
            print("\nLook at Point : x:\(faceAnchor.lookAtPoint.x), y:\(faceAnchor.lookAtPoint.y), z:\(faceAnchor.lookAtPoint.z)")
            
            DispatchQueue.main.async {
                self.faceLabel.text = self.analysis
            }
        }
    }
    
    func expression(anchor: ARFaceAnchor) {
        
        // eye looking down
        let eyeLookDownLeft = anchor.blendShapes[.eyeLookDownLeft]
        let eyeLookDownRight = anchor.blendShapes[.eyeLookDownRight]
        
        let eyeLookInLeft = anchor.blendShapes[.eyeLookInLeft]
        let eyeLookInRight = anchor.blendShapes[.eyeLookInRight]
        
        let eyeLookOutLeft = anchor.blendShapes[.eyeLookOutLeft]
        let eyeLookOutRight = anchor.blendShapes[.eyeLookOutRight]
        
        //  eye looking up
        let eyeLookUpLeft = anchor.blendShapes[.eyeLookUpLeft]
        let eyeLookUpRight = anchor.blendShapes[.eyeLookUpRight]
        
        self.analysis = ""
        
        if ((eyeLookDownLeft?.decimalValue ?? 0.0) + (eyeLookDownRight?.decimalValue ?? 0.0)) > 0.9 {
            self.analysis += "You are looking down"
        }
        
        if ((eyeLookUpLeft?.decimalValue ?? 0.0) + (eyeLookUpRight?.decimalValue ?? 0.0)) > 0.9 {
            self.analysis += "You are looking up"
        }
        
    }

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
