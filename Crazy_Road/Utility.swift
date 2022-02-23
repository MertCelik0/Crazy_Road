//
//  Utility.swift
//  Crazy_Road
//
//  Created by Mert Çelik on 21.02.2022.
//

import Foundation
import SceneKit

struct Models {
    private static let treeScene = SCNScene(named: "art.scnassets/Tree.scn")!
    static let tree = treeScene.rootNode.childNode(withName: "tree", recursively: true)!
    
    private static let hedgeScene = SCNScene(named: "art.scnassets/Hedge.scn")!
    static let hedge = hedgeScene.rootNode.childNode(withName: "hedge", recursively: true)!
    
    private static let blueTruckScene = SCNScene(named: "art.scnassets/BlueTruck.scn")!
    static let blueTruck = blueTruckScene.rootNode.childNode(withName: "truck", recursively: true)!
    
    private static let fireTruckScene = SCNScene(named: "art.scnassets/FireTruck.scn")!
    static let fireTruck = fireTruckScene.rootNode.childNode(withName: "truck", recursively: true)!
    
    private static let purpleCarScene = SCNScene(named: "art.scnassets/PurpleCar.scn")!
    static let purpleCar = purpleCarScene.rootNode.childNode(withName: "car", recursively: true)!
    
    private static let redCarScene = SCNScene(named: "art.scnassets/RedCar.scn")!
    static let redCar = redCarScene.rootNode.childNode(withName: "car", recursively: true)!
    
}

let degressPerRadians = Float(Double.pi/180)
let radiansPerDegress = Float(180/Double.pi)

func toRadians(angle: Float) -> Float {
    return angle * degressPerRadians
}

func toRadians(angle: CGFloat) -> CGFloat {
    return angle * CGFloat(degressPerRadians)
}

func randomBool(odds: Int) -> Bool {
    let random = arc4random_uniform(UInt32(odds))
    if random < 1 {
        return true
    }
    else {
        return false
    }
}
