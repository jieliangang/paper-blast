//
//  LevelCell.swift
//  BubbleBlast
//
//  Created by Jie Liang Ang on 2/3/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import UIKit

class LevelCell: UICollectionViewCell {

    @IBOutlet var screenshot: UIImageView!
    @IBOutlet var levelName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func configure(image: UIImage?, name: String) {
        screenshot.image = image
        levelName.text = name
    }
}
