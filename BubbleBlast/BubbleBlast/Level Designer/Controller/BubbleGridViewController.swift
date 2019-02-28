//
//  BubbleGridViewController.swift
//  LevelDesigner
//
//  Created by Jie Liang Ang on 9/2/19.
//  Copyright © 2019 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class BubbleGridViewController: UICollectionViewController {

    var game = GameBubbleSet(numberOfRows: 12)

    var currentSelectedType: BubbleType?

    @IBOutlet private var bubbleArea: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bubbleArea.dataSource = self
        bubbleArea.isScrollEnabled = false
        bubbleArea.collectionViewLayout = AlternatingBubbleLayout()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        bubbleArea.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan))
        bubbleArea.addGestureRecognizer(panGesture)

        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        bubbleArea.addGestureRecognizer(longGesture)
    }

    // MARK: Gesture Recognizer Actions of Bubble Area
    @objc
    func tap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.bubbleArea)
        guard let bubbleType = currentSelectedType else {
            cycleCell(at: location)
            return
        }
        updateCell(at: location, to: bubbleType)
    }

    @objc
    func pan(sender: UIPanGestureRecognizer) {
        guard let type = currentSelectedType else {
            return
        }
        switch sender.state {
        case .began, .changed:
            let location = sender.location(in: self.bubbleArea)
            updateCell(at: location, to: type)
        default:
            return
        }
    }

    @objc
    func longPress(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            let location = sender.location(in: self.bubbleArea)
            updateCell(at: location, to: .empty)
        default:
            return
        }
    }

    func loadDataFrom(_ name: String) throws {
        try game = StorageManager.retrieve(name, as: GameBubbleSet.self)
        bubbleArea.reloadData()
    }

    func save(name: String) throws {
        try StorageManager.store(self.game, as: name)
    }

    func reset() {
        game.reset()
        bubbleArea.reloadData()
    }

    private func updateCell(at point: CGPoint, to type: BubbleType) {
        if let indexPath = bubbleArea.indexPathForItem(at: point) {
            game.updateBubble(at: indexPath.item, to: type)
            UIView.setAnimationsEnabled(false)
            bubbleArea.reloadItems(at: [indexPath])
        }
    }

    private func cycleCell(at point: CGPoint) {
        if let indexPath = bubbleArea.indexPathForItem(at: point) {
            game.cycleBubble(at: indexPath.item)
            UIView.setAnimationsEnabled(false)
            bubbleArea.reloadItems(at: [indexPath])
        }
    }
}

// MARK: Data Source
extension BubbleGridViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game.numberOfBubbles
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bubbleCell",
                                                            for: indexPath) as? BubbleCell else {
                return BubbleCell()
        }
        if let bubble = game.bubble(at: indexPath.item) {
            cell.setImage(UIImage(named: imageName(of: bubble.type)))
        }
        return cell
    }

    private func imageName(of type: BubbleType) -> String {
        let name: String
        switch type {
        case .colorBlue: name = "bubble-blue.png"
        case .colorYellow: name = "bubble-orange.png"
        case .colorRed: name = "bubble-red.png"
        case .colorGreen: name = "bubble-green.png"
        default: name = "bubble-translucent_white.png"
        }
        return name
    }
}
