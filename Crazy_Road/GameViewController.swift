//
//  GameViewController.swift
//  Crazy_Road
//
//  Created by Mert Çelik on 21.02.2022.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    var sceneView: SCNView!
    var scene: SCNScene!
    
    var cameraNode = SCNNode()
    var lightNode = SCNNode()
    var playerNode = SCNNode()
    var mapNode = SCNNode()
    var lanes = [LaneNode]()
    var laneCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupPlayer()
        setupFloor()
        setupCamera()
        setupLight()
    }
    

    // Setup View
    func setupView() {
        sceneView = (view as! SCNView)
        sceneView.backgroundColor = .black
    }
    
    // Setup Scene
    func setupScene() {
        scene = SCNScene()
        sceneView.scene = scene
        
        scene.rootNode.addChildNode(mapNode)
        
        for _ in 0..<20 {
            let type = randomBool(odds: 3) ? LaneType.grass : LaneType.road
            let lane = LaneNode(type: type, width: 21)
            lane.position = SCNVector3(x: 0, y: 0, z: 5 - Float(laneCount))
            laneCount += 1
            lanes.append(lane)
            mapNode.addChildNode(lane)
        }
    }
    
    // Setup Player
    func setupPlayer() {
        guard let playerScene = SCNScene(named: "art.scnassets/Chicken.scn") else {
            return
        }
        if let player = playerScene.rootNode.childNode(withName: "player", recursively: true) {
            playerNode = player
            playerNode.position = SCNVector3(x: 0, y: 0.3, z: 0)
            scene.rootNode.addChildNode(playerNode)
        }
            
    }
    
    // Setup Floor
    func setupFloor() {
        let floor = SCNFloor()
        floor.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/darkgrass.png")
        floor.firstMaterial?.diffuse.wrapS = .repeat
        floor.firstMaterial?.diffuse.wrapT = .repeat
        floor.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(12.5, 12.5, 12.5)
        
        floor.reflectivity = 0.0
        
        let floorNode = SCNNode(geometry: floor)
        scene.rootNode.addChildNode(floorNode)
    }
    
    // Setup Camera
    func setupCamera() {
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 0)
        cameraNode.eulerAngles = SCNVector3(x: -toRadians(angle: 72), y: toRadians(angle: 9), z: 0)
        scene.rootNode.addChildNode(cameraNode)
    }
    
    // Setup Light
    func setupLight() {
        let ambientNode = SCNNode()
        ambientNode.light = SCNLight()
        ambientNode.light?.type = .ambient
        
        let directonelNode = SCNNode()
        directonelNode.light = SCNLight()
        directonelNode.light?.type = .directional
        directonelNode.light?.castsShadow = true
        directonelNode.light?.shadowColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        directonelNode.position = SCNVector3(x: -5, y: 5, z: 0)
        directonelNode.eulerAngles = SCNVector3(x: 0, y: -toRadians(angle: 90), z: -toRadians(angle: 45))
        
        lightNode.addChildNode(ambientNode)
        lightNode.addChildNode(directonelNode)
        lightNode.position = cameraNode.position
        scene.rootNode.addChildNode(lightNode)
    }
    
}
