//
//  GameViewController.swift
//  Crazy_Road
//
//  Created by Mert Çelik on 21.02.2022.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit

enum GameState {
    case menu, playing, gameOver
}

class GameViewController: UIViewController {
    
    var sceneView: SCNView!
    var scene: SCNScene!
    var gameHUD: GameHUD!
    var gameState = GameState.menu
    var score = 0
    
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
    var dieAction: SCNAction?
    
    var driveRightAction: SCNAction?
    var driveLeftAction: SCNAction?
    
    var collisionNode = CollisionNode()
    var frontBlocked = false
    var rightBlocked = false
    var leftBlocked = false
    var downBlocked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialiseGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState {
        case .menu:
            setupGesture()
            gameHUD = GameHUD(with: sceneView.bounds.size, menu: false)
            sceneView.overlaySKScene = gameHUD
            sceneView.overlaySKScene?.isUserInteractionEnabled = false
            gameState = .playing
        default:
            break
        }
    }
    
    func resetGame() {
        scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        scene = nil
        gameState = .menu
        score = 0
        laneCount = 0
        lanes = [LaneNode]()
        initialiseGame()
    }
    
    func initialiseGame() {
        setupScene()
        setupPlayer()
        setupCollisionNode()
        setupFloor()
        setupCamera()
        setupLight()
        setupActions()
        setupTraffic()
    }


    // Setup Scene
    func setupScene() {
        sceneView = view as! SCNView
        sceneView.delegate = self
        
        scene = SCNScene()
        scene.physicsWorld.contactDelegate = self
        sceneView.present(scene, with: .fade(withDuration: 0.5), incomingPointOfView: nil, completionHandler: nil)
        
        DispatchQueue.main.async {
            self.gameHUD = GameHUD(with: self.sceneView.bounds.size, menu: true)
            self.sceneView.overlaySKScene = self.gameHUD
            self.sceneView.overlaySKScene?.isUserInteractionEnabled = false
        }
        
        
        scene.rootNode.addChildNode(mapNode)
        
        for _ in 0..<10 {
            createNewLanes(initial: true)
        }
        for _ in 0..<10 {
            createNewLanes(initial: false)
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
    
    // Setup Collision
    func setupCollisionNode() {
        collisionNode = CollisionNode()
        collisionNode.position = playerNode.position
        scene.rootNode.addChildNode(collisionNode)
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

        dieAction = SCNAction.moveBy(x: 0, y: 5, z: 0, duration: 1.0)
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
        playerNode.runAction(action!, completionHandler: {
            self.checkBlocks()
            self.score += 1
            self.gameHUD.pointsLabel?.text = "\(self.score)"
        })
        
        addLanes()
    }
    
    // Update camera position
    func updateCameraPosition() {
        collisionNode.position = playerNode.position
        
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
            createNewLanes(initial: false)
        }
        removeUnsedLanes()
    }
    
    // Create new lanes
    func createNewLanes(initial: Bool) {
        let type = randomBool(odds: 3) || initial ? LaneType.grass : LaneType.road
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
            vehicle.removeAllActions()
            vehicle.runAction(driveAction)
        }
    }
    
    func gameOver() {
        DispatchQueue.main.async {
            if let gestureRecognizers = self.sceneView.gestureRecognizers {
                for recognizer in gestureRecognizers {
                    self.sceneView.removeGestureRecognizer(recognizer)
                }
            }
        }
        gameState = .gameOver
        if let action = dieAction {
            playerNode.runAction(action, completionHandler:  {
                self.resetGame()
            })
        }
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        updateCameraPosition()
        updateTraffic()
    }
}

extension GameViewController: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        guard let categoryA = contact.nodeA.physicsBody?.categoryBitMask, let categoryB = contact.nodeB.physicsBody?.categoryBitMask else {
            return
        }
        
        let mask = categoryA | categoryB
        
        switch mask {
            case PhysicsCategory.chicken | PhysicsCategory.vehicle:
                gameOver()
            case PhysicsCategory.vegetation | PhysicsCategory.collisionTestFront:
                frontBlocked = true
            case PhysicsCategory.vegetation | PhysicsCategory.collisionTestRight:
                rightBlocked = true
            case PhysicsCategory.vegetation | PhysicsCategory.collisionTestLeft:
                leftBlocked = true
            case PhysicsCategory.vegetation | PhysicsCategory.collisionTestDown:
                downBlocked = true
            default:
                break
        }
        
    }
    
}

extension GameViewController {
    
    @objc func handleTap(_ sender:UITapGestureRecognizer) {
        if !frontBlocked {
            jumpFowardCharacter()
        }
    }
    
    @objc func handleSwipe(_ sender:UISwipeGestureRecognizer) {
        switch sender.direction {
            case UISwipeGestureRecognizer.Direction.left:
            if playerNode.position.x > -10 && !leftBlocked {
                let action = jumpLeftAction
                playerNode.runAction(action!, completionHandler: {
                    self.checkBlocks()
                })
            }
            break
            case UISwipeGestureRecognizer.Direction.right:
            if playerNode.position.x < 10 && !rightBlocked{
                let action = jumpRightAction
                playerNode.runAction(action!, completionHandler: {
                    self.checkBlocks()
                })
            }
            break
            case UISwipeGestureRecognizer.Direction.down:
            if !downBlocked {
                let action = jumpDownAction
                playerNode.runAction(action!, completionHandler: {
                self.checkBlocks()
                })
            }
            break
            default:
            break
        }
    }

    func checkBlocks() {
        if scene.physicsWorld.contactTest(with: collisionNode.front.physicsBody!, options: nil).isEmpty {
            frontBlocked = false
        }
        if scene.physicsWorld.contactTest(with: collisionNode.left.physicsBody!, options: nil).isEmpty {
            leftBlocked = false
        }
        if scene.physicsWorld.contactTest(with: collisionNode.right.physicsBody!, options: nil).isEmpty {
            rightBlocked = false
        }
        if scene.physicsWorld.contactTest(with: collisionNode.down.physicsBody!, options: nil).isEmpty {
            downBlocked = false
        }
    }
}
