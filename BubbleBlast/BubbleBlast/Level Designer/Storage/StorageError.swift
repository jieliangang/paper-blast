//
//  StorageError.swift
//  LevelDesigner
//
//  Created by Jie Liang Ang on 9/2/19.
//  Copyright © 2019 nus.cs3217.a0101010. All rights reserved.
//

enum StorageError: Error {
    case cannotSave(String)
    case cannotLoad(String)
    case cannotRemove(String)
    case unknown(String)
}
