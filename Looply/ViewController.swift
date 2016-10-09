//
//  ViewController.swift
//  Looply
//
//  Created by Ehsan Asdar on 10/8/16.
//  Copyright © 2016 Ehsan and Neil. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let s : Service = Service()
        s.start()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear() {
    }
    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

