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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear() {
        let s : Service = Service()
//        s.start()

    }
    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func onLowerOutputBoundChange(_ sender: AnyObject) {
        UserDefaults.standard.set(lowerOutputBound.doubleValue , forKey: "lowerOutputBound")
    }
    
    @IBAction func onupperOutputBoundChange(_ sender: AnyObject) {
        UserDefaults.standard.set(upperOutputBound.doubleValue , forKey: "upperOutputBound")
        print(UserDefaults.standard.object(forKey: "upperOutputBound"))
    }
    
    @IBAction func onScaleFactorChange(_ sender: AnyObject) {
        UserDefaults.standard.set(scaleFactor.doubleValue , forKey: "scaleFactor")
    }
}
