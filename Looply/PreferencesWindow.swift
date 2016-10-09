//
//  PreferencesWindow.swift
//  Looply
//
//  Created by Ehsan Asdar on 10/9/16.
//  Copyright © 2016 Ehsan and Neil. All rights reserved.
//

import Cocoa
import AudioToolbox
import AVFoundation

class PreferencesWindow: NSWindowController {

    
    @IBOutlet weak var upperOutputBoundButton: NSButton!
    @IBOutlet weak var lowerOutputBoundButton: NSButton!
    @IBOutlet weak var scaleFactor: NSSlider!
    @IBOutlet weak var upperOutputBound: NSSlider!
    @IBOutlet weak var lowerOutputBound: NSSlider!
    var storage : Storage = Storage()
    var backgroundMusicPlayer = AVAudioPlayer()

    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        lowerOutputBound.doubleValue = storage.getMinPoint()[1] * 100
        upperOutputBound.doubleValue = storage.getMaxPoint()[1] * 100
        scaleFactor.doubleValue = storage.getScaleFactor() * 100
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
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
    
    
    func playBackgroundMusic(filename: String) {
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        guard let newURL = url else {
            print("Could not find file: \(filename)")
            return
        }
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: newURL)
            backgroundMusicPlayer.numberOfLoops = 1
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    @IBAction func onTestUpperOutputBoundChange(_ sender: AnyObject) {
        updateVolume(amplitude: upperOutputBound.doubleValue / 100)
        playBackgroundMusic(filename: "Stirling.wav")
    }
    
    @IBAction func onTestLowerOutputBoundChange(_ sender: AnyObject) {
        updateVolume(amplitude: lowerOutputBound.doubleValue / 100)
        playBackgroundMusic(filename: "Stirling.wav")
    }
    
    @IBAction func onLowerOutputBoundChange(_ sender: AnyObject) {
        storage.setMinPoint(minPoint: [0, lowerOutputBound.doubleValue / 100])
        print(lowerOutputBound.doubleValue / 100)
    }
    
    @IBAction func onUpperOutputBoundChange(_ sender: AnyObject) {
        storage.setMaxPoint(maxPoint: [0.75, upperOutputBound.doubleValue / 100])
    }
    
    @IBAction func onScaleFactorChange(_ sender: AnyObject) {
        storage.setScaleFactor(scaleFactor: scaleFactor.doubleValue / 100)
    }
}
