//
//  Service.swift
//  Looply
//
//  Created by Ehsan Asdar on 10/8/16.
//  Copyright © 2016 Ehsan and Neil. All rights reserved.
//

import Foundation
import AudioKit
import AudioToolbox

class Service {
    // TODO must prompt user to remove ambient noise detection? (or turn this flag off)
    
    var mic : AKMicrophone? = nil
    var tracker : AKFrequencyTracker? = nil
    var silence : AKBooster? = nil
    var storage : Storage? = nil
    
    var lowerMicBound: Double = 0.0
    var upperMicBound: Double = 0.75
    var lowerOutputBound: Double = 1/24
    var upperOutputBound: Double = 1
    var scaleFactor: Double = 1
    
    let MICROSECONDS_IN_SECOND : UInt32 = 1000000
    let SAMPLE_RATE_SECONDS : Double = 0.5
    let WINDOW_LENGTH_SECONDS : UInt32 = 5
    var SAMPLE_RATE : UInt32 = 0
    var WINDOW_LENGTH : UInt32 = 0
    let WAIT_LENGTH_SECONDS : UInt32 = 5
    var WAIT_LENGTH : UInt32 = 0
    
    func generateQuadraticCoefficients(xs : [Double], ys : [Double]) -> [Double] {
        let a : Double = ys[0]/((xs[0]-xs[1])*(xs[0]-xs[2])) + ys[1]/((xs[1]-xs[0])*(xs[1]-xs[2])) + ys[2]/((xs[2]-xs[0])*(xs[2]-xs[1]))
        
        let b : Double = -ys[0]*(xs[1]+xs[2])/((xs[0]-xs[1])*(xs[0]-xs[2]))
        -ys[1]*(xs[0]+xs[2])/((xs[1]-xs[0])*(xs[1]-xs[2]))
        -ys[2]*(xs[0]+xs[1])/((xs[2]-xs[0])*(xs[2]-xs[1]))
        
        let c : Double = ys[0]*xs[1]*xs[2]/((xs[0]-xs[1])*(xs[0]-xs[2]))
            + ys[1]*xs[0]*xs[2]/((xs[1]-xs[0])*(xs[1]-xs[2]))
            + ys[2]*xs[0]*xs[1]/((xs[2]-xs[0])*(xs[2]-xs[1]))
        
        return [c, b, a]
    }
    
    func generateLinearCoefficients(xs: [Double], ys: [Double]) -> [Double] {
        let m = ((ys[1] - ys[0]) / (xs[1] - xs[0]))
        let b = (ys[0] - (xs[0] * m))
        return [b, m]
    }
    
    // Note that this function is blocking
    func getVolumeAverage(tracker : AKFrequencyTracker) -> Double {
        var tick : UInt32 = 0
        var sum = 0.0
        var length = 0.0
        
        while tick < WINDOW_LENGTH {
            sum = sum + tracker.amplitude
            length += 1
            tick += SAMPLE_RATE
            usleep(SAMPLE_RATE)
        }
        
        return sum / length
    }
    
    
    func getOutputVolume (micLevel : Double) -> Double {
        if micLevel > upperMicBound {
            return upperOutputBound
        }
        if micLevel < lowerMicBound {
            return lowerOutputBound
        }
        
        let slope = ((upperOutputBound - lowerOutputBound) / (upperMicBound - lowerMicBound)) * scaleFactor
        let resultingVolume = (slope * (micLevel - lowerMicBound)) + lowerOutputBound
        if resultingVolume > upperMicBound {
            return upperOutputBound
        }
        if(resultingVolume < lowerMicBound) {
            return lowerOutputBound
        }
        return resultingVolume
    }
    
    func getVolumeLevel(coefficients : [Double], x : Double, minVolume : Double, maxVolume : Double) -> Double {
        var sum = 0.0
        for i in stride(from: coefficients.count - 1, to: -1, by: -1) {
            sum += coefficients[i] * pow(x, Double(i))
        }
        if sum > maxVolume {
            return maxVolume
        }
        if sum < minVolume {
            return minVolume
        }
        return sum
    }
    
    func getCurrentVolume() -> Double {
        var defaultOutputDeviceID = AudioDeviceID(0)
        var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
        
        var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultOutputDevice),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        let status1 = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &getDefaultOutputDevicePropertyAddress,
            0,
            nil,
            &defaultOutputDeviceIDSize,
            &defaultOutputDeviceID)
        
        if kAudioHardwareNoError != status1 {
            return -1
        }
        
        var volume : Float32 = 0.5
        var volumeSize = UInt32(MemoryLayout.size(ofValue: volume))
        let result = AudioHardwareServiceGetPropertyData(defaultOutputDeviceID, &getDefaultOutputDevicePropertyAddress, 0, nil, &volumeSize, &volume)
        
        return Double(volume)
    }
    
    func updateVolume(amplitude : Double) {
        var defaultOutputDeviceID = AudioDeviceID(0)
        var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
        
        var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultOutputDevice),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        let status1 = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &getDefaultOutputDevicePropertyAddress,
            0,
            nil,
            &defaultOutputDeviceIDSize,
            &defaultOutputDeviceID)
        
        var volume = Float32(amplitude) // 0.0 ... 1.0
        let volumeSize = UInt32(MemoryLayout.size(ofValue: volume))
        
        var volumePropertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwareServiceDeviceProperty_VirtualMasterVolume),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        let status2 = AudioHardwareServiceSetPropertyData(
            defaultOutputDeviceID,
            &volumePropertyAddress,
            0,
            nil,
            volumeSize,
            &volume)
    }

    func start() {
        mic = AKMicrophone()
        tracker = AKFrequencyTracker.init(mic!)
        silence = AKBooster(tracker!,gain : 0)
        storage = Storage()
        
        SAMPLE_RATE = UInt32(Double(MICROSECONDS_IN_SECOND) * SAMPLE_RATE_SECONDS)
        WINDOW_LENGTH = MICROSECONDS_IN_SECOND * WINDOW_LENGTH_SECONDS
        WAIT_LENGTH = MICROSECONDS_IN_SECOND * WAIT_LENGTH_SECONDS
        
        AudioKit.output = silence;
        AudioKit.start()
        
        while(true) {
            let lastVolumeSetting = storage?.getLastVolumeSetting()
            let currentVolume = getCurrentVolume()
            let epsilon = 0.01
            
            if !(lastVolumeSetting! - currentVolume < epsilon || currentVolume - lastVolumeSetting! < epsilon) {
                usleep(WAIT_LENGTH)
                storage?.setLastUserSetPoint(userPoint: [getVolumeAverage(tracker: tracker!), getCurrentVolume()])
                storage?.setLastVolumeSetting(volume: getCurrentVolume())
                continue
            }
            
            let lastPoint = storage?.getLastUserSetPoint()
            let minPoint = storage?.getMinPoint()
            let maxPoint = storage?.getMaxPoint()
            
            let average = getVolumeAverage(tracker: tracker!)
            
            
            var coefficients : [Double]? = nil
            
            if lastPoint?[0] != nil && lastPoint?[1] != nil {
                coefficients = generateQuadraticCoefficients(
                    xs: [(lastPoint?[0])!, (minPoint?[0])!, (maxPoint?[0])!],
                    ys: [(lastPoint?[1])!, (minPoint?[1])!, (maxPoint?[1])!]
                );
            } else {
                coefficients = generateLinearCoefficients(
                    xs: [(minPoint?[0])!, (maxPoint?[0])!],
                    ys: [(minPoint?[1])!, (maxPoint?[1])!]
                );
            }
            
            let volume = getVolumeLevel(coefficients: coefficients!, x: average, minVolume: (minPoint?[1])!, maxVolume: (maxPoint?[1])!)
            updateVolume(amplitude: volume)
            storage?.setLastVolumeSetting(volume: volume)
        }

        
    }
    


}
