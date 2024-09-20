//
//  FileSystem.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 12/22/22.
//

import Foundation


public final class FileSystem {
  
    public enum FSError: Error {
        case error(_: Error)
        case urlFail
    }
    
    public enum Folder: String {
        case layers
        case rasters
        case presets
    }
    
    public enum PathType: String {
        case documents
        case group
    }
    
    private var documentsDirectoryURL: URL?
    
    init() {
        documentsDirectoryURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    }
}

@available(iOS 16.0, *)
public extension FileSystem {
    
    static var atlasGroupURL: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.alpinelis.atlas")!
    }
    
    static var appDocumentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    static var appSupportURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }
    
    static func move(at sourceURL: URL, destinationURL: URL, overrideIfExists: Bool = true) throws {
        try FileManager.default.createDirectory(at: destinationURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        
        if FileManager.default.fileExists(atPath: destinationURL.path(percentEncoded: false)) {
            if overrideIfExists {
                try FileManager.default.removeItem(at: destinationURL)
            }
            else {
                throw CoreError("Cannot move file, it already exists at destination.", type: .fileSystem)
            }
        }
        try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
    }
    
    static func copy(at sourceURL: URL, destinationURL: URL, overrideIfExists: Bool = true) throws {
        if FileManager.default.fileExists(atPath: destinationURL.path(percentEncoded: false)) {
            if overrideIfExists {
                try FileManager.default.removeItem(at: destinationURL)
            }
            else {
                throw CoreError("Cannot copy file, it already exists at destination.", type: .fileSystem)
            }
        }
        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
    }
    
    static func createDirectory(for path: FSPath, in pathType: FS.PathType) throws {
        try FileManager.default.createDirectory(at: getURL(for: pathType).appending(path: path.rawValue), withIntermediateDirectories: true)
    }
    
    static func createDirectory(at url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    static func deleteFile(for path: FSPath, in pathType: FS.PathType) throws {
        try deleteFile(at: getURL(for: pathType).appending(path: path.rawValue))
    }

    static func deleteFile(at url: URL) throws {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            throw CoreError("Cannot delete file or directory.", type: .fileSystem)
        }
    }
    
    static func getURL(for pathType: FS.PathType) -> URL {
        switch pathType {
        case .documents:
            return appDocumentsURL
        case .group:
            return atlasGroupURL
        }
    }
}

@available(iOS 16.0, *)
public extension FileSystem {
    
    static func directoryContents(at path: String) throws -> [String] {
        try FileManager.default.contentsOfDirectory(atPath: path)
    }
    
    static func fileExists(at url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path(percentEncoded: false))
    }
    
    static func fileExists(at path: FSPath, in pathType: FS.PathType) -> Bool {
        return fileExists(at: getURL(for: pathType).appending(path: path.rawValue))
    }
    
    static func removeIfExists(at url: URL) throws {
        if fileExists(at: url) {
            try FileManager.default.removeItem(at: url)
        }
    }
}

public extension FileSystem { //MARK: NEW
    
    static var documentsDirectory: URL {
        return FS.shared.documentsDirectoryURL
        ?? URL(string: "/Users/jenya/Library/Developer/CoreSimulator/Devices/8FE8FE32-8BF7-4A22-B975-55851D2E44AA/data/Containers/Data/Application/3303E29B-C936-438A-A1EF-539494B81BD7/Documents/")! // FOR PREVIEW USE ONLY
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
    
    @discardableResult
    static func findOrCreateDirectoryPath(for path: FSPath) -> FSPath {
        let fullPath = documentsDirectory.absoluteString.appending("/\(path.rawValue)")
        if !FileManager.default.fileExists(atPath: fullPath) {
            do {
                try FileManager.default.createDirectory(atPath: fullPath, withIntermediateDirectories: true)
            } catch {
                assertionFailure("Create Directory Error")
            }
        }
        return path
    }
    
    static func exists(at path: FSPath) -> Bool {
        var str = documentsDirectory.path()
        let delimiter = str.last == "/" ? "" : "/"
        str = str.appending("\(delimiter)\(path.rawValue)")
        return FileManager.default.fileExists(atPath: str)
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
            deleteFile(at: path.rawValue, isDirectory: isDirectory)
        }
        findOrCreateDirectoryPath(for: path)
    }
    
    @discardableResult
    static func deleteFile(at path: String, isDirectory: Bool) -> Result<Void, Error> {
        do {
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(path, isDirectory: isDirectory)
            
            try FileManager.default.removeItem(at: url)
        }
        catch {
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
