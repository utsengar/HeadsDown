//
//  AppDelegate.swift
//  HeadsDown
//
//  Created by Utkarsh Sengar on 5/6/20.
//  Copyright © 2020 Area42. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let focusAppsBootstrap = ["Xcode": true,
                     "Code - Insiders": true,
                     "Sublime Text": true,
                     "IntelliJ IDEA": true,
                     "Figma": true,
                     "Sketch": true,
                     "Code": true,
                     "Sublime Merge": true,
                     "WebStorm": true]

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSWorkspace.shared.notificationCenter.addObserver(self,
            selector: #selector(switchDND(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object:nil)
        
        constructMenu()
        
        // Sane defaults :)
        UserPreferences.isEnabled = true
        DoNotDisturb.isEnabled = false
        UserPreferences.apps = focusAppsBootstrap
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func toggleDND(_ sender: Any?) {
        DoNotDisturb.isEnabled.toggle()
        constructMenu()
    }
    
    @objc func toggleHeadsDown(_ sender: Any?) {
        UserPreferences.isEnabled.toggle()
        if !UserPreferences.isEnabled {
            DoNotDisturb.isEnabled = false
        } else {
            DoNotDisturb.isEnabled = true
        }
        constructMenu()
    }
    
    @objc func openSettings(_ sender: Any?){
        let window = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "WindowController") as! WindowController
        window.showWindow(self)
    }
    
    func constructMenu() {
        var imageName = ""
        var statusMessage = ""
        var statusOfHD = ""
        let menu = NSMenu()
        
        // When HD and DND are enabled
        if UserPreferences.isEnabled && DoNotDisturb.isEnabled {
            imageName = "HDActive"
            statusOfHD = "Disable"
            statusMessage = "Unfocus"
            menu.addItem(NSMenuItem(title: "\(statusMessage)", action: #selector(AppDelegate.toggleDND(_:)), keyEquivalent: "P"))
            menu.addItem(NSMenuItem(title: "\(statusOfHD)", action: #selector(AppDelegate.toggleHeadsDown(_:)), keyEquivalent: "D"))
        } else if UserPreferences.isEnabled && !DoNotDisturb.isEnabled {
            imageName = "HDInactive"
            statusOfHD = "Disable"
            statusMessage = "Focus 🎯"
            menu.addItem(NSMenuItem(title: "\(statusMessage)", action: #selector(AppDelegate.toggleDND(_:)), keyEquivalent: "P"))
            menu.addItem(NSMenuItem(title: "\(statusOfHD)", action: #selector(AppDelegate.toggleHeadsDown(_:)), keyEquivalent: "D"))
        } else if !UserPreferences.isEnabled {
            imageName = "HDDisabled"
            statusOfHD = "Enable"
            menu.addItem(NSMenuItem(title: "\(statusOfHD)", action: #selector(AppDelegate.toggleHeadsDown(_:)), keyEquivalent: "D"))
        }

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(AppDelegate.openSettings(_:)), keyEquivalent: "S"))
        menu.addItem(NSMenuItem(title: "Quit HeadsDown", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        if let button = statusItem.button {
          button.image = NSImage(named:NSImage.Name(imageName))
          button.action = #selector(toggleDND(_:))
        }
    }
    
    @objc dynamic private func switchDND(_ notification: NSNotification) {
        if !UserPreferences.isEnabled {
            return
        }

        //If DND is enabled, it will remain in that state for 1min.
        if DoNotDisturb.isEnabled && getDateDiff(start: UserPreferences.timeStarted, end: Date()) <= 60 {
            return
        }
        
        let app = notification.userInfo!["NSWorkspaceApplicationKey"] as! NSRunningApplication
        let appName = app.localizedName!
        
        if UserPreferences.apps[appName] ?? false {
            DoNotDisturb.isEnabled = true
            UserPreferences.timeStarted = Date()
        } else {
            DoNotDisturb.isEnabled = false
        }
        constructMenu()
    }
    
    func getDateDiff(start: Date, end: Date) -> Int  {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([Calendar.Component.second], from: start, to: end)

        let seconds = dateComponents.second
        return Int(seconds!)
    }
}

