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
    
    var jumpFovardAction: SCNAction?
    var jumpRightAction: SCNAction?
    var jumpLeftAction: SCNAction?
    var jumpDownAction: SCNAction?
    
    var driveRightAction: SCNAction?
    var driveLeftAction: SCNAction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupPlayer()
        setupFloor()
        setupCamera()
        setupLight()
        setupGesture()
        setupActions()
        setupTraffic()
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
        sceneView.delegate = self
        
        scene.rootNode.addChildNode(mapNode)
        
        for _ in 0..<20 {
            createNewLanes()
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
        cameraNode.eulerAngles = SCNVector3(x: -toRadians(angle: 60), y: toRadians(angle: 20), z: 0)
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
    
    // Setup swipe or tap gestures
    func setupGesture() {
        let jumpTap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(jumpTap)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRight.direction = .right
        sceneView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRight.direction = .left
        sceneView.addGestureRecognizer(swipeLeft)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeDown.direction = .down
        sceneView.addGestureRecognizer(swipeDown)
    }
    
    // Setup actions
    func setupActions() {
        // Jump animation
        let upAnimationAction = SCNAction.moveBy(x: 0, y: 1.0, z: 0, duration: 0.1)
        let downAnimationAction = SCNAction.moveBy(x: 0, y: -1.0, z: 0, duration: 0.1)
        upAnimationAction.timingMode = .easeOut
        downAnimationAction.timingMode = .easeIn
        let jumpAction = SCNAction.sequence([upAnimationAction, downAnimationAction])
        
        let moveFowardAction = SCNAction.moveBy(x: 0, y: 0, z: -1.0, duration: 0.2)
        let moveRightAction = SCNAction.moveBy(x: 1.0, y: 0, z: 0, duration: 0.2)
        let moveLeftAction = SCNAction.moveBy(x: -1.0, y: 0, z: 0, duration: 0.2)
        let moveDownAction = SCNAction.moveBy(x: 0, y: 0, z: 1.0, duration: 0.2)

        let turnFowardAction = SCNAction.rotateTo(x: 0, y: toRadians(angle: 180), z: 0, duration: 0.2, usesShortestUnitArc: true)
        let turnRightAction = SCNAction.rotateTo(x: 0, y: toRadians(angle: 90), z: 0, duration: 0.2, usesShortestUnitArc: true)
        let turnLeftAction = SCNAction.rotateTo(x: 0, y: toRadians(angle: -90), z: 0, duration: 0.2, usesShortestUnitArc: true)
        let turnDownAction = SCNAction.rotateTo(x: 0, y: toRadians(angle: 360), z: 0, duration: 0.2, usesShortestUnitArc: true)

        jumpFovardAction = SCNAction.group([turnFowardAction, jumpAction, moveFowardAction])
        jumpRightAction = SCNAction.group([turnRightAction, jumpAction, moveRightAction])
        jumpLeftAction = SCNAction.group([turnLeftAction, jumpAction, moveLeftAction])
        jumpDownAction = SCNAction.group([turnDownAction, jumpAction, moveDownAction])

        driveRightAction = SCNAction.repeatForever(SCNAction.moveBy(x: 2.0, y: 0, z: 0, duration: 1.0))
        driveLeftAction = SCNAction.repeatForever(SCNAction.moveBy(x: -2.0, y: 0, z: 0, duration: 1.0))

    }
    
    // Setup traffic
    func setupTraffic() {
        for lane in lanes {
            if let trafficNode = lane.trafficNode {
                addActions(for: trafficNode)
            }
        }
    }
    
    // Jump foward Character
    func jumpFowardCharacter() {
        let action = jumpFovardAction
        playerNode.runAction(action!)
        
        addLanes()
    }
    
    // Update camera position
    func updateCameraPosition() {
        let diffX = (playerNode.position.x + 1 - cameraNode.position.x)
        let diffZ = (playerNode.position.z + 2 - cameraNode.position.z)
        cameraNode.position.x += diffX
        cameraNode.position.z += diffZ
        
        lightNode.position = cameraNode.position
    }
    
    // Update Traffic
    func updateTraffic() {
        for lane in lanes {
            guard let trafficNode = lane.trafficNode else {
                continue
            }
            for vehicle in trafficNode.childNodes {
                if vehicle.position.x > 10 {
                    vehicle.position.x = -10
                } else if vehicle.position.x < -10 {
                    vehicle.position.x = 10
                }
            }
        }
    }
    
    // Game add lanes
    func addLanes() {
        for _ in 0...1 {
            createNewLanes()
        }
        removeUnsedLanes()
    }
    
    // Create new lanes
    func createNewLanes() {
        let type = randomBool(odds: 3) ? LaneType.grass : LaneType.road
        let lane = LaneNode(type: type, width: 21)
        lane.position = SCNVector3(x: 0, y: 0, z: 5 - Float(laneCount))
        laneCount += 1
        lanes.append(lane)
        mapNode.addChildNode(lane)
        
        if let trafficNode = lane.trafficNode {
            addActions(for: trafficNode)
        }
    }
    
    // Remove no used lanes
    func removeUnsedLanes() {
        for child in mapNode.childNodes {
            if !sceneView.isNode(child, insideFrustumOf: cameraNode) && child.worldPosition.z > playerNode.worldPosition.z {
                child.removeFromParentNode()
                lanes.removeFirst()
            }
        }
    }
    
    // Traffic action
    func addActions(for trafficNode: TrafficNode) {
        guard let driveAction = trafficNode.directionRight ? driveRightAction : driveLeftAction else {return}
        driveAction.speed = 1/CGFloat(trafficNode.type + 1) + 0.5
        for vehicle in trafficNode.childNodes {
            vehicle.runAction(driveAction)
        }
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        updateCameraPosition()
        updateTraffic()
    }
}

extension GameViewController {
    
    @objc func handleTap(_ sender:UITapGestureRecognizer) {
       jumpFowardCharacter()
    }
    
    @objc func handleSwipe(_ sender:UISwipeGestureRecognizer) {
        switch sender.direction {
            case UISwipeGestureRecognizer.Direction.left:
            if playerNode.position.x > -10 {
                let action = jumpLeftAction
                playerNode.runAction(action!)
            }
            break
            case UISwipeGestureRecognizer.Direction.right:
            if playerNode.position.x < 10 {
                let action = jumpRightAction
                playerNode.runAction(action!)
            }
            break
            case UISwipeGestureRecognizer.Direction.down:
                let action = jumpDownAction
            playerNode.runAction(action!)
            break
            default:
            break
        }
    }

}
