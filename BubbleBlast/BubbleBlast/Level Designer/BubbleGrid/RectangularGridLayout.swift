//
//  RectangularGrid.swift
//  BubbleBlast
//
//  Created by Jie Liang Ang on 1/3/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import UIKit

class RectangularGridLayout: UICollectionViewLayout {
    private var cellSize = CGSize(width: 0, height: 0)
    private var radiusOfBubble: CGFloat = 0
    private let maxBubblesInRow = Constants.Game.numOfBubblesInEvenRow

    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {
            return
        }
        let totalWidth = collectionView.bounds.width
        radiusOfBubble = (totalWidth / CGFloat(maxBubblesInRow)) / 2
        cellSize = CGSize(width: radiusOfBubble * 2, height: radiusOfBubble * 2)
    }

    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return CGSize(width: 0, height: 0)
        }
        return CGSize(width: collectionView.bounds.width,
                      height: 2 * radiusOfBubble  * CGFloat(12))
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.center = centerForItem(at: indexPath)
        attributes.size = cellSize
        return attributes
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else {
            return nil
        }
        return (0..<collectionView.numberOfItems(inSection: 0))
            .map { IndexPath(item: $0, section: 0) }
            .filter { rect.intersects(rectForItem(at: $0)) }
            .compactMap { self.layoutAttributesForItem(at: $0) }
    }

    private func centerForItem(at indexPath: IndexPath) -> CGPoint {
        let row = indexPath.item / Constants.Game.numOfBubblesInEvenRow
        let col = indexPath.item % Constants.Game.numOfBubblesInEvenRow

        let xValue: CGFloat = radiusOfBubble + CGFloat(col) * (radiusOfBubble * 2)
        let yValue: CGFloat = radiusOfBubble + CGFloat(row) * (radiusOfBubble * 2)

        return CGPoint(x: xValue, y: yValue)
    }

    private func rectForItem(at indexPath: IndexPath) -> CGRect {
        let center = centerForItem(at: indexPath)
        return CGRect(x: center.x - radiusOfBubble, y: center.y - radiusOfBubble,
                      width: radiusOfBubble * 2, height: radiusOfBubble * 2)
    }

}
