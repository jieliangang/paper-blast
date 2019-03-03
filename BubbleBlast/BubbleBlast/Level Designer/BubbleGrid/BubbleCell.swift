//
//  BubbleCell.swift
//  LevelDesigner
//
//  Created by Jie Liang Ang on 30/1/19.
//  Copyright © 2019 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

/**
 Represent cells within the custom UICollectionView
 Adapted from PS3
 */
class BubbleCell: UICollectionViewCell {

    @IBOutlet private var bubbleImage: UIImageView!

    func setImage(_ image: UIImage?) {
        self.bubbleImage.image = image
    }
}
