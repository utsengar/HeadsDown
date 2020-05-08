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
    let focusApps = ["Xcode", "Code - Insiders", "Sublime Text", "IntelliJ IDEA", "Figma", "Sketch"]

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Read the current state and show in UI accordingly. Need to honor existing setting.
        
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
        constructMenu()
        updateIcon()
    }
    
    @objc func toggleHeadsDown(_ sender: Any?) {
        print(UserPreferences.isEnabled)
        UserPreferences.isEnabled.toggle()
        DoNotDisturb.isEnabled = false
        constructMenu()
        updateIcon()
    }
    
    func constructMenu() {
        updateIcon()
        
        let menu = NSMenu()
        var statusMessage = "Focus"
        if DoNotDisturb.isEnabled {
            statusMessage = "Unfocus"
        }
        
        var isEnabled = "Enable"
        if !UserPreferences.isEnabled {
            menu.addItem(NSMenuItem(title: "\(statusMessage)", action: #selector(AppDelegate.toggleDND(_:)), keyEquivalent: "P"))
            isEnabled = "Disable"
        }

        
        menu.addItem(NSMenuItem(title: "\(isEnabled)", action: #selector(AppDelegate.toggleHeadsDown(_:)), keyEquivalent: "P"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit HeadsDown", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu

    }
    
    func updateIcon() {
        var imageName = "HDInactive"
        
        if DoNotDisturb.isEnabled {
            imageName = "HDActive"        }
        
        if UserPreferences.isEnabled {
            imageName = "HDDisabled"
        }
        
        if let button = statusItem.button {
          button.image = NSImage(named:NSImage.Name(imageName))
          button.action = #selector(toggleDND(_:))
        }
    }
    
    @objc dynamic private func switchDND(_ notification: NSNotification) {
        if !UserPreferences.isEnabled {
            return
        }
        
        // Logic should be: If you have not used one of these apps in the last X minutes, disable it
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

