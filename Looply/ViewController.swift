//
//  ViewController.swift
//  Looply
//
//  Created by Ehsan Asdar on 10/8/16.
//  Copyright © 2016 Ehsan and Neil. All rights reserved.
//

import Cocoa
import AudioKit

class ViewController: NSViewController {
    
    var mic : AKMicrophone? = nil
    var tracker : AKFrequencyTracker? = nil
    var silence : AKBooster? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mic = AKMicrophone()
        tracker = AKFrequencyTracker.init(mic!)
        silence = AKBooster(tracker!,gain : 0)
        
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear() {
        AudioKit.output = silence;
        AudioKit.start()
        
        while(true) {
            updateUI()
            usleep(200)
        }
    }
    func updateUI(){
        print("hi")
        print(tracker?.amplitude)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

