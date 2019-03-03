//
//  BubbleGridViewController.swift
//  LevelDesigner
//
//  Created by Jie Liang Ang on 9/2/19.
//  Copyright © 2019 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class BubbleGridViewController: UICollectionViewController {

    var game = GameBubbleSet(numberOfRows: Constants.LevelDesigner.numOfRows)

    var currentSelectedType: BubbleType?

    var totalNumberOfBubbles = Constants.LevelDesigner.totalNumOfBubblesInHex

    weak var delegate: SegmentedControlDelegate?

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

    // MARK: Grid Handling
    func updateGridLayout(isHex: Bool) {
        game.updateGridLayout(toHex: isHex)
        setGridLayout(isHex: isHex)
    }

    private func setGridLayout(isHex: Bool) {
        isHex ? setToHexagonalGrid() : setToRectangularGrid()
    }

    private func setToHexagonalGrid() {
        bubbleArea.collectionViewLayout.invalidateLayout()
        totalNumberOfBubbles = Constants.LevelDesigner.totalNumOfBubblesInHex
        bubbleArea.collectionViewLayout = AlternatingBubbleLayout()
        bubbleArea.reloadData()
    }

    private func setToRectangularGrid() {
        bubbleArea.collectionViewLayout.invalidateLayout()
        totalNumberOfBubbles = Constants.LevelDesigner.totalNumOfBubblesInRect
        bubbleArea.collectionViewLayout = RectangularGridLayout()
        bubbleArea.reloadData()
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
        setGridLayout(isHex: game.isHexagonal)
        delegate?.onHexagonalSelected(game.isHexagonal)
    }

    func save(name: String) throws {
        let screenshot = bubbleArea.getImage()
        let imageString = screenshot.pngData()
        try StorageManager.store(self.game, as: name, screenshot: imageString)
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
        return totalNumberOfBubbles
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bubbleCell",
                                                            for: indexPath) as? BubbleCell else {
                return BubbleCell()
        }
        if let bubble = game.bubble(at: indexPath.item) {
            cell.setImage(UIImage(named: ResourceManager.imageName(of: bubble.type)))
        }
        return cell
    }
}

extension UIView {
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func getImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}
