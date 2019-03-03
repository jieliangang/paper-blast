//
//  Storage.swift
//  LevelDesigner
//
//  Created by Jie Liang Ang on 8/2/19.
//  Copyright © 2019 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

/**
 A utility class which contains functions related to storing and retrieving data in the documents directory
 */
class StorageManager {

    private init() {
    }

    /// Returns URL constructed from document directory
    static private func getDocumentURL() -> URL {
        if let url = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true) {
            return url
        } else {
            fatalError("Could not create URL for document directory!")
        }
    }

    static private func getGameURL() -> URL {
        let fileManager = FileManager.default
        let documentURL = getDocumentURL()
        let filePath = documentURL.appendingPathComponent("gameData")
        if !fileManager.fileExists(atPath: filePath.path) {
            do {
                try fileManager.createDirectory(atPath: filePath.path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                NSLog("Couldn't create game directory")
            }
        }
        NSLog("Document directory is \(filePath)")
        return filePath
    }

    static private func getScreenshotURL() -> URL {
        let fileManager = FileManager.default
        let documentURL = getDocumentURL()
        let filePath = documentURL.appendingPathComponent("screenshot")
        if !fileManager.fileExists(atPath: filePath.path) {
            do {
                try fileManager.createDirectory(atPath: filePath.path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                NSLog("Couldn't create screenshot directory")
            }
        }
        NSLog("Document directory is \(filePath)")
        return filePath
    }

    /// Store an encodable struct to the document directory on disk
    ///
    /// - Parameters:
    ///   - object: the encodable struct to store
    ///   - fileName: name where the struct data will be stored
    static func store<T: Encodable>(_ object: T, as fileName: String, screenshot: Data?) throws {
        let url = getGameURL().appendingPathComponent(fileName)

        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch is EncodingError {
            throw StorageError.cannotSave("Error while encoding")
        } catch {
            throw StorageError.cannotSave("Error while saving level")
        }

        let pictureName = fileName + ".png"
        let screenshotURL = getScreenshotURL().appendingPathComponent(pictureName)
        try? screenshot?.write(to: screenshotURL)
    }

    /// Retrieve and convert a struct from a file on disk
    ///
    /// - Parameters:
    ///   - fileName: name of the file where struct data is stored
    ///   - type: struct type (i.e. Message.self)
    /// - Returns: decoded struct model(s) of data
    static func retrieve<T: Decodable>(_ fileName: String, as type: T.Type) throws -> T {
        let url = getGameURL().appendingPathComponent(fileName, isDirectory: false)

        if !FileManager.default.fileExists(atPath: url.path) {
            throw StorageError.cannotLoad("Missing file")
        }

        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type, from: data)
                return model
            } catch {
                throw StorageError.cannotLoad("Error while decoding")
            }
        } else {
            throw StorageError.cannotLoad("Error while loading level")
        }
    }

    static func retrieveScreenshot(_ fileName: String) throws -> UIImage? {
        let pictureName = fileName + ".png"
        let screenshotURL = getScreenshotURL().appendingPathComponent(pictureName)
        let screenshot = UIImage(contentsOfFile: screenshotURL.relativePath)
        return screenshot
    }

    /// Remove specified file from specified directory
    static func remove(_ fileName: String) throws {
        let url = getGameURL().appendingPathComponent(fileName, isDirectory: false)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                throw StorageError.cannotRemove("Missing file")
            }
        }
        let pictureName = fileName + ".png"
        let screenshotURL = getScreenshotURL().appendingPathComponent(pictureName)
        try? FileManager.default.removeItem(at: screenshotURL)
    }

    /// Returns boolean on whether specified file at document directory exists
    static func fileExists(_ fileName: String) -> Bool {
        let url = getGameURL().appendingPathComponent(fileName, isDirectory: false)
        return FileManager.default.fileExists(atPath: url.path)
    }

    static func fileNames() -> [String] {
        let documentURL = getGameURL()
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(atPath: documentURL.path).sorted()
            return fileURLs
        } catch {
            print("Error while enumerating files")
        }
        return []
    }

}
