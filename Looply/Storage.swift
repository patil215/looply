//
//  Storage.swift
//  Looply
//
//  Created by Neil Patil on 10/8/16.
//  Copyright © 2016 Ehsan and Neil. All rights reserved.
//

import Foundation

class Storage {
    
    let defaults = UserDefaults.standard
    
    func getLastUserSetPoint() -> [Double] {
        return readPoint(prefix: "user")
    }
    
    func setLastUserSetPoint(userPoint : [Double]) {
        writePoint(point: userPoint, prefix: "user")
    }
    
    func getMinPoint() -> [Double] {
        return readPoint(prefix: "min")
    }
    
    func setMinPoint(minPoint: [Double]) {
        writePoint(point: minPoint, prefix: "min")
    }
    
    func getMaxPoint() -> [Double] {
        return readPoint(prefix: "max")
    }
    
    func setMaxPoint(maxPoint: [Double]) {
        writePoint(point: maxPoint, prefix: "max")
    }
    
    func getLastVolumeSetting() -> Double {
        return defaults.double(forKey: "volume")
    }
    
    func setLastVolumeSetting(volume : Double) {
        defaults.set(volume, forKey: "volume")
    }
    
    private func writePoint(point: [Double], prefix: String) {
        defaults.set(point[0], forKey: prefix + "Background")
        defaults.set(point[1], forKey: prefix + "Volume")
    }
    
    private func readPoint(prefix: String) -> [Double] {
        let x : Double = defaults.double(forKey: prefix + "Background")
        let y : Double = defaults.double(forKey: prefix + "Volume")
        return [x, y]
    }
    
    
    
}
