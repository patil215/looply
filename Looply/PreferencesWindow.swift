//
//  PreferencesWindow.swift
//  Looply
//
//  Created by Ehsan Asdar on 10/9/16.
//  Copyright © 2016 Ehsan and Neil. All rights reserved.
//

import Cocoa


class PreferencesWindow: NSWindowController {

    @IBOutlet weak var lowerOutputBound: NSTextField!
    @IBOutlet weak var upperOutputBound: NSTextField!
    @IBOutlet weak var scaleFactor: NSTextField!
    var storage : Storage = Storage()

    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        lowerOutputBound.doubleValue = storage.getMinPoint()[1]
        upperOutputBound.doubleValue = storage.getMaxPoint()[1]
        scaleFactor.doubleValue = storage.getScaleFactor()
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    @IBAction func onLowerOutputBoundChange(_ sender: AnyObject) {
        storage.setMinPoint(minPoint: [0, lowerOutputBound.doubleValue])
    }
    @IBAction func onUpperOutputBoundChange(_ sender: AnyObject) {
        storage.setMaxPoint(maxPoint: [0.75, upperOutputBound.doubleValue])

    }
    @IBAction func onScaleFactorChange(_ sender: AnyObject) {
        storage.setScaleFactor(scaleFactor: scaleFactor.doubleValue)
    }
}
