//
//  LevelSelectionViewController.swift
//  BubbleBlast
//
//  Created by Jie Liang Ang on 2/3/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import UIKit

class LevelSelectionViewController: UIViewController {

    @IBOutlet private var levels: UICollectionView!

    var levelData = StorageManager.fileNames()
    var multiplayer = false

    override func viewDidLoad() {
        super.viewDidLoad()
        levels.dataSource = self
        levels.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "selectToPlay" {
            guard let childVC = segue.destination as? GameViewController else {
                fatalError("Error while setting GameViewController")
            }
            guard let index = levels.indexPathsForSelectedItems?.first?.item else {
                return
            }
            let fileName = levelData[index]
            do {
                let game = try StorageManager.retrieve(fileName, as: GameBubbleSet.self)
                childVC.game = game
                childVC.multiplayer = multiplayer
            } catch {
                print("Couldn't retreive game data")
            }
        }
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func playerSelection(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: multiplayer = false
        case 1: multiplayer = true
        default: break
        }
    }
}

extension LevelSelectionViewController: UICollectionViewDataSource, UICollectionViewDelegate,
                                        UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return levelData.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelCell", for: indexPath)
            as? LevelCell else {
            return LevelCell()
        }
        let filename = levelData[indexPath.item]
        do {
            cell.configure(image: try StorageManager.retrieveScreenshot(filename), name: filename)
        } catch {
            print("image not found")
        }

        cell.layer.cornerRadius = cell.frame.width / 20
        cell.contentView.layer.cornerRadius = cell.frame.width / 20
        cell.contentView.layer.masksToBounds = true

        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        cell.layer.shadowRadius = cell.frame.width / 20
        cell.layer.shadowOpacity = 0.2
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds,
                                             cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "selectToPlay", sender: nil)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: levels.frame.width/2.5, height: levels.frame.height/2.25)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 50
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 25
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
    }
}
