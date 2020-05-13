//
//  ViewController.swift
//  HeadsDown
//
//  Created by Utkarsh Sengar on 5/12/20.
//  Copyright © 2020 Area42. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    let focusApps = ["Xcode", "Code - Insiders", "Sublime Text", "IntelliJ IDEA", "Figma", "Sketch"]

    @IBOutlet weak var tableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    override var representedObject: Any? {
        didSet {
            if let url = representedObject as? URL {
                print("Represented object: \(url)")
            }
        }
    }
}

extension ViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return focusApps.count
    }

}

extension ViewController: NSTableViewDelegate {

    fileprivate enum CellIdentifiers {
        static let NameCell = "NameCellID"
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        var text: String = ""
        var cellIdentifier: String = ""

        // 1
        let item = focusApps[row]

        // 2
        if tableColumn == tableView.tableColumns[0] {
            text = item
            cellIdentifier = CellIdentifiers.NameCell
        }

        // 3
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? TableCellViewWithCheckbox {
            
            cell.app.title = text
            return cell
        }
        return nil
    }

}
