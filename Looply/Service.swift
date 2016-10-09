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
    var lowerMicBound: Double = 0.0
    var upperMicBound: Double = 0.75
    var lowerOutputBound: Double = 1/24
    var upperOutputBound: Double = 1
    var scaleFactor: Double = 1
    
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
    
    func updateUI(){
        print("hi")
        updateVolume(amplitude: tracker!.amplitude)
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

    func start(){
        mic = AKMicrophone()
        tracker = AKFrequencyTracker.init(mic!)
        silence = AKBooster(tracker!,gain : 0)
        
        AudioKit.output = silence;
        AudioKit.start()
        while(true) {
            var sum = Double(0)
            for _ in 0...1000 {
                sum = sum + tracker!.amplitude
                usleep(2000)
            }
            updateVolume(amplitude: getOutputVolume(micLevel: (sum / 1000)))
            print(getOutputVolume(micLevel: (sum / 1000)))
            print(sum / 1000)
        }

        
    }
    


}
