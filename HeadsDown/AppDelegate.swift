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
    let query = NSMetadataQuery()
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSWorkspace.shared.notificationCenter.addObserver(self,
            selector: #selector(switchDND(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object:nil)
        
        constructMenu()
        
        // Sane defaults :)
        UserPreferences.isEnabled = true
        DoNotDisturb.isEnabled = false
        
        NSApp.activate(ignoringOtherApps: true)
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
        NSApp.activate(ignoringOtherApps: true)
        window.showWindow(self)
    }
    
    func constructMenu() {
        var imageName = ""
        //var statusMessage = ""
        var statusOfHD = ""
        let menu = NSMenu()
        
        // When HD and DND are enabled
        if UserPreferences.isEnabled && DoNotDisturb.isEnabled {
            imageName = "HDActive"
            statusOfHD = "Disable"
            //statusMessage = "Unfocus"
            //menu.addItem(NSMenuItem(title: "\(statusMessage)", action: #selector(AppDelegate.toggleDND(_:)), keyEquivalent: "P"))
            menu.addItem(NSMenuItem(title: "\(statusOfHD)", action: #selector(AppDelegate.toggleHeadsDown(_:)), keyEquivalent: "D"))
        } else if UserPreferences.isEnabled && !DoNotDisturb.isEnabled {
            imageName = "HDInactive"
            statusOfHD = "Disable"
            //statusMessage = "Focus 🎯"
            //menu.addItem(NSMenuItem(title: "\(statusMessage)", action: #selector(AppDelegate.toggleDND(_:)), keyEquivalent: "P"))
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
        
        queryApps()
    }
    
    @objc dynamic private func switchDND(_ notification: NSNotification) {
        if !UserPreferences.isEnabled {
            return
        }

        //If DND is enabled, it will remain in that state for 1min.
        // if DoNotDisturb.isEnabled && getDateDiff(start: UserPreferences.timeStarted, end: Date()) <= 60 {
        //    return
        //}
        
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
    
    func queryApps() {
        let predicate = NSPredicate(format: "kMDItemKind == 'Application'")
        query.predicate = predicate
        query.start()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.finishQuery),
                                               name:NSNotification.Name.NSMetadataQueryDidFinishGathering,
                                               object: nil)
    }
    
    @objc func finishQuery(notification: NSNotification) {
        query.stop()

        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil)
    }
    
    func getDateDiff(start: Date, end: Date) -> Int  {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([Calendar.Component.second], from: start, to: end)

        let seconds = dateComponents.second
        return Int(seconds!)
    }
}

