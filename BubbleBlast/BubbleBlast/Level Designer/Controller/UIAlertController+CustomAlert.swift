//
//  UIAlertController+CustomAlert.swift
//  LevelDesigner
//
//  Created by Jie Liang Ang on 10/2/19.
//  Copyright © 2019 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

extension UIAlertController {

    static func saveAlert(originalName: String?, closure: @escaping(_ name: String) -> Void) -> UIAlertController {
        let saveAlertController = UIAlertController(title: "Enter level name", message: nil, preferredStyle: .alert)
        saveAlertController.addTextField { textField in
            textField.text = originalName
        }
        saveAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _  in
            print("Cancel")
        })
        saveAlertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let name = saveAlertController.textFields?.first?.text else {
                return
            }
            closure(name)
        })
        return saveAlertController
    }

    static func duplicateAlert(name: String, closure: @escaping(_ name: String) -> Void) -> UIAlertController {
        let duplicateAlertController = UIAlertController(title: "Level with the same name found.",
                                               message: "Overwrite and save?",
                                               preferredStyle: .alert)
        duplicateAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _  in
            print("Cancel")
        })
        duplicateAlertController.addAction(UIAlertAction(title: "Overwrite", style: .destructive) { _  in
            closure(name)
        })
        return duplicateAlertController
    }

    static func invalidNameAlert() -> UIAlertController {
        let invalidStringAlertController = UIAlertController(title: "Invalid name",
                                                   message: "Name cannot be empty or exceed 30 characters",
                                                   preferredStyle: .alert)
        invalidStringAlertController.addAction(UIAlertAction(title: "Ok", style: .default) { _  in
            print("Invalid name")
        })
        return invalidStringAlertController
    }

    static func errorAlert(errorMessage: String) -> UIAlertController {
        let errorAlertController = UIAlertController(title: "Error",
                                           message: errorMessage,
                                           preferredStyle: .alert)
        errorAlertController.addAction(UIAlertAction(title: "Ok", style: .default) { _  in
            print(errorMessage)
        })
        return errorAlertController
    }
}
