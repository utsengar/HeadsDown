//
//  AppDelegate.swift
//  HeadsDown
//
//  Created by Utkarsh Sengar on 5/6/20.
//  Copyright © 2020 Area42. All rights reserved.
//

import Cocoa
import Sentry
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    let query = NSMetadataQuery()
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        SentrySDK.start(options: [
            "dsn": "https://6021f1a7d8e94533b72041a700d310ee@o409520.ingest.sentry.io/5282246",
            "debug": false
        ])
        MSAppCenter.start("e874a8f4-fc72-4c9c-a805-c8e9b5e40106", withServices:[
          MSAnalytics.self,
          MSCrashes.self
        ])
        MSAnalytics.trackEvent("AppLaunched")
        
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
        MSAnalytics.trackEvent("HDToggled")
    }
    
    @objc func openSettings(_ sender: Any?){
        let window = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "WindowController") as! WindowController
        NSApp.activate(ignoringOtherApps: true)
        window.showWindow(self)
        MSAnalytics.trackEvent("SettingsOpened")
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
    }
    
    @objc dynamic private func switchDND(_ notification: NSNotification) {
        MSAnalytics.trackEvent("DNDToggledAttempted")
        if !UserPreferences.isEnabled {
            return
        }

        //If DND is enabled, it will remain in that state for 1min.
        // if DoNotDisturb.isEnabled && getDateDiff(start: UserPreferences.timeStarted, end: Date()) <= 60 {
        //    return
        //}
        
        let app = notification.userInfo!["NSWorkspaceApplicationKey"] as! NSRunningApplication
        let appName = app.localizedName ?? ""
        
        if UserPreferences.apps[appName] ?? false {
            DoNotDisturb.isEnabled = true
            UserPreferences.timeStarted = Date()
        } else {
            DoNotDisturb.isEnabled = false
        }
        MSAnalytics.trackEvent("DNDToggled")
        constructMenu()
    }
    
    func getDateDiff(start: Date, end: Date) -> Int  {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([Calendar.Component.second], from: start, to: end)

        let seconds = dateComponents.second
        return Int(seconds!)
    }
}

