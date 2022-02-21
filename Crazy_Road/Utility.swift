//
//  Utility.swift
//  Crazy_Road
//
//  Created by Mert Çelik on 21.02.2022.
//

import Foundation
import SceneKit

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
