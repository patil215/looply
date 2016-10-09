//
//  ViewController.swift
//  Looply
//
//  Created by Ehsan Asdar on 10/8/16.
//  Copyright © 2016 Ehsan and Neil. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    

    @IBOutlet weak var lowerOutputBound: NSTextField!
    @IBOutlet weak var upperOutputBound: NSTextField!
    @IBOutlet weak var scaleFactor: NSTextField!
    
    var storage : Storage = Storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //lowerOutputBound.doubleValue = storage.getMinPoint()[1]
        //upperOutputBound.doubleValue = storage.getMaxPoint()[1]
        //scaleFactor.doubleValue = storage.getScaleFactor()
    }
    override func viewDidAppear() {
        var s : Service = Service()
        
    }
    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    /*@IBAction func onLowerOutputBoundChange(_ sender: AnyObject) {
        storage.setMinPoint(minPoint: [0, lowerOutputBound.doubleValue])
    }
    
    @IBAction func onupperOutputBoundChange(_ sender: AnyObject) {
        storage.setMaxPoint(maxPoint: [0.75, upperOutputBound.doubleValue])
    }
    
    @IBAction func onScaleFactorChange(_ sender: AnyObject) {
        storage.setScaleFactor(scaleFactor: scaleFactor.doubleValue)
    }*/
}
