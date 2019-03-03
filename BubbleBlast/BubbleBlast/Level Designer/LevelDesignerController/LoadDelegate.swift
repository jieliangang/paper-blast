//
//  LoadDelegate.swift
//  LevelDesigner
//
//  Created by Jie Liang Ang on 8/2/19.
//  Copyright © 2019 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

protocol LoadDelegate: class {
    func onNameSelected(name: String) throws
}
