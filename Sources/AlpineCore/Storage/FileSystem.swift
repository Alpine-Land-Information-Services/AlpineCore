//
//  FileSystem.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 12/22/22.
//

import Foundation

public typealias FS = FileSystem

public class FileSystem {
    
    public enum FSError: Error {
        case error(_: Error)
        case urlFail
    }
    
    public enum Folder: String {
        case layers
        case rasters
        case presets
    }
    
}


public extension FileSystem { //MARK: NEW
    
    static var documentsDirectory: URL {
        let urls = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return URL(string: urls[0])
        ??
        URL(string: "/Users/jenya/Library/Developer/CoreSimulator/Devices/8FE8FE32-8BF7-4A22-B975-55851D2E44AA/data/Containers/Data/Application/3303E29B-C936-438A-A1EF-539494B81BD7/Documents/")! // FOR PREVIEW USE ONLY
    }
    
    static func getDirectoryContents(in path: FSPath) -> [String]? {
        do {
            let path = documentsDirectory.absoluteString.appending("/\(path.rawValue)")
            return try FileManager.default.contentsOfDirectory(atPath: path)
        }
        catch {
            assertionFailure(error.localizedDescription)
        }
        
        return nil
    }
    
    static func findOrCreateDirectoryPath(for path: FSPath) -> FSPath {
        let path = documentsDirectory.absoluteString.appending("/\(path.rawValue)")
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            } catch {
                assertionFailure("Create Directory Error")
            }
        }
        return path.fsPath
    }
    
    static func exists(at path: FSPath) -> Bool {
        let path = documentsDirectory.absoluteString.appending("/\(path.rawValue)")
        return FileManager.default.fileExists(atPath: path)
    }
}

public extension FileSystem { //MARK: OLD
    
    static func createNewFilePath(in path: String, for fileName: String) -> String? {
        let filePath = path.appending("/\(fileName)")
        
        if !FileManager.default.fileExists(atPath: filePath) {
            return filePath
        }
        else {
            return nil
        }
    }
    
    static func getOrCreateInnerDirectoryPath(in parent: Folder, for folder: String) -> String {
        let path = getOrCreateDirectoryPath(for: parent).appending("/\(folder.capitalized)")
        
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            } catch {
                assertionFailure("Create Directory Error")
            }
        }
        return path
    }
    
    static func getOrCreateDirectoryPath(for folder: String) -> String {
        let path = documentsDirectory.absoluteString.appending("/\(folder.capitalized)")
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            } catch {
                assertionFailure("Create Directory Error")
            }
        }
        return path
    }
    
    static func directoryExists(at path: String) -> Bool? {
        let path = documentsDirectory.absoluteString.appending("/\(path.capitalized)")
        return FileManager.default.fileExists(atPath: path)
    }
    
    static func getOrCreateDirectoryPath(for folder: Folder) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0].appending("/\(folder.rawValue.capitalized)")
        
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            } catch {
                assertionFailure("Create Directory Error")
            }
        }
        return path
    }
    
    static func getFilePath(for file: String, in directory: String) -> String? {
        let filePath = (getOrCreateDirectoryPath(for: directory) as NSString).appendingPathComponent("\(file)")
        if FileManager.default.fileExists(atPath: filePath) {
            return filePath
        }
        return nil
    }
    
    static func getFilePath(for file: String, in directory: Folder) -> String? {
        let filePath = (getOrCreateDirectoryPath(for: directory) as NSString).appendingPathComponent("\(file)")
        if FileManager.default.fileExists(atPath: filePath) {
            return filePath
        }
        return nil
    }
    
    static func getDirectoryContents(at path: String) -> [String]? {
        do {
            return try FileManager.default.contentsOfDirectory(atPath: path)
        }
        catch {
            assertionFailure(error.localizedDescription)
        }
        
        return nil
    }
    
    static func getFileSize(_ file: String, at path: String) -> Int? {
        guard let att = try? FileManager.default.attributesOfItem(atPath: path.appending("/\(file)")) else {
            return nil
        }
        
        return att[.size] as? Int
    }
    
    static func fileExists(at path: String) -> Bool {
        return FileManager.default.fileExists(atPath: documentsDirectory.absoluteString.appending("/\(path)"))
    }
    
    static func fileExists(_ file: String, in directory: Folder) -> Bool {
        let directory = getOrCreateDirectoryPath(for: directory)
        return FileManager.default.fileExists(atPath: directory.appending("/\(file)"))
    }
    
    static func deleteIfExists(at path: String, isDirectory: Bool) -> Result<Void, Error> {
        if fileExists(at: path) {
            return deleteFile(at: path, isDirectory: isDirectory)
        }
        
        return .success(())
    }
    
    static func recreateDirectory(at path: FSPath, isDirectory: Bool) {
        if fileExists(at: path.rawValue) {
            _ = deleteFile(at: path.rawValue, isDirectory: isDirectory)
        }
        _ = findOrCreateDirectoryPath(for: path)
    }
    
    static func deleteFile(at path: String, isDirectory: Bool) -> Result<Void, Error> {
        do {
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(path, isDirectory: isDirectory)
            
            try FileManager.default.removeItem(at: url)
        }
        catch {
            print(error)
            return .failure(FSError.error(error))
        }
        
        return .success(())
    }
}

public extension FileSystem { //MARK: Custom Files
    
    static func getCustomFilesList(in folder: Folder) -> [String] {
        do {
            let path = FS.getOrCreateDirectoryPath(for: folder)
            return try FileManager.default.contentsOfDirectory(atPath: path)
        }
        catch {
            print(error)
        }
        return []
    }
}

public extension FileManager {
    
    func clearTmpDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach {[unowned self] file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try self.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}

