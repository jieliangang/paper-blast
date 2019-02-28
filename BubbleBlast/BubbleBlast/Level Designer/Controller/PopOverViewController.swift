//
//  PopOverViewController.swift
//  LevelDesigner
//
//  Created by Jie Liang Ang on 8/2/19.
//  Copyright © 2019 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class PopOverViewController: UITableViewController {
    private var fileNames: [String] = StorageManager.fileNames()
    weak var delegate: LoadDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "dataCell")
        tableView.rowHeight = 50
        self.preferredContentSize = CGSize(width: 300, height: tableView.rowHeight * 5)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)
        cell.textLabel?.text = fileNames[indexPath.row]
        return cell
    }

     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         return true
     }

     // Override to support editing the table view.
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
            // Delete the row from the data source
            let name = fileNames[indexPath.row]
            do {
                try StorageManager.remove(name)
                fileNames.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Cannot delete")
                let cell = tableView.cellForRow(at: indexPath)
                cell?.textLabel?.textColor = UIColor.red
            }
         }
     }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = fileNames[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        do {
            try delegate?.onNameSelected(name: name)
        } catch {
            cell?.textLabel?.textColor = UIColor.red
        }
    }
}
