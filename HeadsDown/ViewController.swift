//
//  ViewController.swift
//  HeadsDown
//
//  Created by Utkarsh Sengar on 5/12/20.
//  Copyright © 2020 Area42. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!
    
    var appsAsArry = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshAppList()
    }

    @IBAction func onChangeApp(_ sender: NSButton) {
        var apps = UserPreferences.apps
        if sender.state == NSControl.StateValue.on {
            apps[sender.title] = true
        } else {
            apps[sender.title] = false
        }
        
        UserPreferences.apps = apps
    }
    
    override var representedObject: Any? {
        didSet {
            if let url = representedObject as? URL {
                print("Represented object: \(url)")
            }
        }
    }
    
    @IBAction func addApp(_ sender: Any) {
        let dialog = createDialog()
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file

            if (result != nil) {
                let path: String = result!.path
                if (applicationSelected(path: path)) {
                    let appSelected = result!.lastPathComponent
                    // if path is an application add it to the user preferences
                    if (appSelected != "") {
                        let appName = String(appSelected.split(separator: ".")[0])
                        var apps = UserPreferences.apps
                        apps[appName] = true
                        UserPreferences.apps = apps
                        // Reset apps list
                        refreshAppList()
                    }
                }
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    func createDialog() -> NSOpenPanel {
        let dialog = NSOpenPanel()

        dialog.title                   = "Choose an Application"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.directoryURL = URL(string: "/Applications")
        return dialog
    }
    
    func applicationSelected(path: String) -> Bool {
        return path.hasPrefix("/Applications")
    }
    
    func refreshAppList() {
        appsAsArry.removeAll()
        for app in UserPreferences.apps {
            appsAsArry.append(app.key)
        }
        appsAsArry = appsAsArry.sorted{$0.compare($1, options: .caseInsensitive) == .orderedAscending }
        tableView.reloadData()
    }
}

extension ViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return UserPreferences.apps.count
    }

}

extension ViewController: NSTableViewDelegate {

    fileprivate enum CellIdentifiers {
        static let NameCell = "NameCellID"
    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        var text: String = ""
        var enabled: Bool = false
        var cellIdentifier: String = ""

        // 1
        let item = appsAsArry[row]

        // 2
        if tableColumn == tableView.tableColumns[0] {
            text = item
            enabled = UserPreferences.apps[item] ?? false
            cellIdentifier = CellIdentifiers.NameCell
        }

        // 3
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? TableCellViewWithCheckbox {
            cell.app.title = text
            if enabled {
                cell.app.state = NSControl.StateValue.on
            } else {
                cell.app.state = NSControl.StateValue.off
            }
            
            return cell
        }
        return nil
    }

}
