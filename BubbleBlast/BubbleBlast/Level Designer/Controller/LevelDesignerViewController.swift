//
//  ViewController.swift
//  LevelDesigner
//
//  Created by Jie Liang Ang on 28/1/19.
//  Copyright © 2019 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class LevelDesignerViewController: UIViewController {

    @IBOutlet private var bubbleContainerView: UIView!
    @IBOutlet private var currentLevel: UILabel!
    @IBOutlet private var gridToggle: UISegmentedControl!

    private var bubbleGridViewController: BubbleGridViewController?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bubbleGrid" {
            guard let childVC = segue.destination as? BubbleGridViewController else {
                fatalError("Error while setting BubbleGridViewController")
            }
            bubbleGridViewController = childVC
            bubbleGridViewController?.delegate = self
        } else if segue.identifier == "levelToPlay" {
            guard let childVC = segue.destination as? GameViewController else {
                fatalError("Error while setting GameViewController")
            }
            guard let game = bubbleGridViewController?.game else {
                fatalError("Error while setting GameViewController")
            }
            childVC.game = game
        }
    }

    @IBAction func gridToggled(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            bubbleGridViewController?.updateGridLayout(isHex: true)
        case 1:
            bubbleGridViewController?.updateGridLayout(isHex: false)
        default:
            break
        }
    }

    // MARK: Bubble Buttons in Palette Area
    /// Current bubble selected in palette area
    private var currentBubble: UIButton? {
        didSet {
            let type: BubbleType?
            switch currentBubble?.titleLabel?.text {
            case "ButtonYellow": type = .colorYellow
            case "ButtonRed": type = .colorRed
            case "ButtonBlue": type = .colorBlue
            case "ButtonGreen": type = .colorGreen
            case "ButtonErase": type = .empty
            case "ButtonIndestructible": type = .indestructible
            case "ButtonLightning": type = .lightning
            case "ButtonBomb": type = .bomb
            case "ButtonStar": type = .star
            default: type = nil
            }
            bubbleGridViewController?.currentSelectedType = type
            print(bubbleGridViewController?.currentSelectedType?.rawValue ?? "no")
        }
    }

    @IBAction func bubblePressed(_ sender: UIButton) {
        currentBubble?.alpha = 0.3
        if sender == currentBubble {
            currentBubble = nil
        } else {
            currentBubble = sender
            currentBubble?.alpha = 1
        }
    }

    // MARK: Text Buttons in Palette Area
    @IBAction func loadButtonPressed(_ sender: UIButton) {
        let tableViewController = PopOverViewController()
        tableViewController.delegate = self
        tableViewController.modalPresentationStyle = UIModalPresentationStyle.popover

        present(tableViewController, animated: true, completion: nil)

        let popoverPresentationController = tableViewController.popoverPresentationController
        popoverPresentationController?.sourceView = sender
    }

    @IBAction func resetButtonPressed(_ sender: UIButton) {
        bubbleGridViewController?.reset()
        currentLevel.text = ""
    }

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController.saveAlert(originalName: self.currentLevel?.text) {
            self.handleName($0)
        }
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: Helper Functions for Saving
extension LevelDesignerViewController {

    // Check for validity of input level name for saving
    private func handleName(_ name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard isValidName(trimmedName) else {
            let invalidNameAlert = UIAlertController.invalidNameAlert()
            self.present(invalidNameAlert, animated: true, completion: nil)
            return
        }

        guard !StorageManager.fileExists(trimmedName) else {
            let duplicateAlert = UIAlertController.duplicateAlert(name: trimmedName) {
                self.save($0)
            }
            self.present(duplicateAlert, animated: true, completion: nil)
            return
        }

        self.save(trimmedName)
    }

    private func isValidName(_ name: String) -> Bool {
        return !name.isEmpty && name.count <= 30
    }

    private func save(_ name: String) {
        do {
            try bubbleGridViewController?.save(name: name)
            self.currentLevel.text = name
        } catch StorageError.cannotSave(let errorMessage) {
            displayErrorAlert((errorMessage))
        } catch {
            displayErrorAlert("Unknown error")
        }
    }

    private func displayErrorAlert(_ errorMessage: String) {
        let errorAlert = UIAlertController.errorAlert(errorMessage: errorMessage)
        self.present(errorAlert, animated: true, completion: nil)
    }
}

// MARK: LoadDelegate
extension LevelDesignerViewController: LoadDelegate {
    func onNameSelected(name: String) throws {
        try bubbleGridViewController?.loadDataFrom(name)
        self.currentLevel.text = name
    }
}

// MARK: SegmentedControlDelegate
extension LevelDesignerViewController: SegmentedControlDelegate {
    func onHexagonalSelected(_ isHexagonal: Bool) {
        gridToggle.selectedSegmentIndex =  isHexagonal ? 0 : 1
    }
}
