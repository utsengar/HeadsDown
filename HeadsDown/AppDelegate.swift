//
//  AppDelegate.swift
//  HeadsDown
//
//  Created by Utkarsh Sengar on 5/6/20.
//  Copyright © 2020 Area42. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let focusApps = ["Xcode", "Code - Insiders", "Sublime Text", "IntelliJ IDEA"]

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Read the current state and show in UI accordingly. Need to honor existing setting.
        
        if let button = statusItem.button {
          button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
          button.action = #selector(toggleDND(_:))
        }
        
        NSWorkspace.shared.notificationCenter.addObserver(self,
            selector: #selector(switchDND(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object:nil)

        constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func toggleDND(_ sender: Any?) {
        DoNotDisturb.isEnabled.toggle()
        print("Toggle DND")
        constructMenu()
    }
    
    func constructMenu() {
        let menu = NSMenu()
        var statusMessage = "Enable"
        
        if DoNotDisturb.isEnabled {
            statusMessage = "Disable"
        }
        
        menu.addItem(NSMenuItem(title: "\(statusMessage)", action: #selector(AppDelegate.toggleDND(_:)), keyEquivalent: "P"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit HeadsDown", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc dynamic private func switchDND(_ notification: NSNotification) {
        if 1 != Int.random(in: 1..<5) {
            print("not executing")
            return;
        }
        
        let app = notification.userInfo!["NSWorkspaceApplicationKey"] as! NSRunningApplication
        let appName = app.localizedName!
        print(appName)
        
        if focusApps.contains(appName) {
            DoNotDisturb.isEnabled = true;
        } else {
            // Check for how long and then switch.
            DoNotDisturb.isEnabled = false;
        }
        constructMenu()
    }
}

