//
//  AppDelegate.swift
//  Looply
//
//  Created by Ehsan Asdar on 10/8/16.
//  Copyright © 2016 Ehsan and Neil. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusBar = NSStatusBar.system()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var menuItem : NSMenuItem = NSMenuItem()
    var preferenceView: PreferencesWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //Add statusBarItem
        statusBarItem = statusBar.statusItem(withLength: -1)
        statusBarItem.menu = menu
        statusBarItem.title = "Looply"
        
        //Add menuItem to menu
        menuItem.title = "Preferences..."
        menuItem.action = #selector(AppDelegate.openPreferences)
        menuItem.keyEquivalent = ""
        menu.addItem(menuItem)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    func openPreferences(){
        preferenceView = PreferencesWindow()
        preferenceView.showWindow(nil)
    }

}

