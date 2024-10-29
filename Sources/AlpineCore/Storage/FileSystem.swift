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
        case file
        case folder
    }
    
    public enum PathRoot: String {
        case documents
        case group
    }
    
    public static var atlasGroupURL: URL {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.alpinelis.atlas") else {
            fatalError("Failed to retrieve container URL for app group.")
        }
        return url
    }
    
    public static var atlasGroupTempURL: URL {
        atlasGroupURL.appending(component: "Temp/")
    }
    
    public static var atlasGroupCloud: URL {
        atlasGroupURL.appending(component: "Alpine Cloud/")
    }
    
    public static var atlasGroupCloudCommunity: URL {
        atlasGroupCloud.appending(component: "Community/")
    }
    
    public static var appDocumentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    public static var appSupportURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }
    
    private init() {}
}

@available(iOS 16.0, *)
public extension FileSystem {
    
    static func createFolderIfNeeded(at url: URL) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                print("Created folder at path: \(url.path)")
            } catch {
                print("Failed to create folder at path: \(url.path), error: \(error)")
            }
        } else {
            print("Folder already exists at path: \(url.path)")
        }
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
        } else {
            let folderURL = destinationURL.deletingLastPathComponent()
            if !FileManager.default.fileExists(atPath: folderURL.path(percentEncoded: false)) {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            }
        }
        
        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
    }
    
    static func createDirectory(for path: FSPath, in pathType: FS.PathRoot) throws {
        try FileManager.default.createDirectory(at: getURL(for: pathType).appending(path: path.rawValue), withIntermediateDirectories: true)
    }
    
    static func createDirectory(at url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    static func deleteFile(for path: FSPath, in pathType: FS.PathRoot) throws {
        try deleteFile(at: getURL(for: pathType).appending(path: path.rawValue))
    }
    
    static func deleteFile(at url: URL) throws {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            throw CoreError("Cannot delete file or directory.", type: .fileSystem)
        }
    }
    
    static func getURL(for pathType: FS.PathRoot) -> URL {
        switch pathType {
        case .documents:
            return appDocumentsURL
        case .group:
            return atlasGroupURL
        }
    }
    
    static func addExtensionToFile(at fileURL: URL, newName: String? = nil, extension ext: String) throws -> URL {
        let fileName = newName ?? fileURL.deletingPathExtension().lastPathComponent
        let newFileURL = fileURL.deletingLastPathComponent().appendingPathComponent(fileName).appendingPathExtension(ext)
        
        if FileManager.default.fileExists(atPath: newFileURL.path) {
            try FileManager.default.removeItem(at: newFileURL)
        }
        try FileManager.default.moveItem(at: fileURL, to: newFileURL)
        return newFileURL
    }
    
    static func renameFile(at fileURL: URL, newName: String) throws -> URL {
        let fileExtension = fileURL.pathExtension.isEmpty ? "" : ".\(fileURL.pathExtension)"
        let newFileURL = fileURL.deletingLastPathComponent().appendingPathComponent(newName + fileExtension)
        
        if FileManager.default.fileExists(atPath: newFileURL.path) {
            try FileManager.default.removeItem(at: newFileURL)
        }
        
        try FileManager.default.moveItem(at: fileURL, to: newFileURL)
        return newFileURL
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
    
    static func fileExists(at path: FSPath, in pathType: FS.PathRoot) -> Bool {
        return fileExists(at: getURL(for: pathType).appending(path: path.rawValue))
    }
    
    static func removeIfExists(at url: URL) throws {
        if fileExists(at: url) {
            try FileManager.default.removeItem(at: url)
        }
    }
}

public extension FileSystem { //MARK: NEW
    
    static func getDirectoryContents(in path: FSPath) -> [String]? {
        do {
            let path = appDocumentsURL.absoluteString.appending("/\(path.rawValue)")
            return try FileManager.default.contentsOfDirectory(atPath: path)
        }
        catch {
            assertionFailure(error.localizedDescription)
        }
        
        return nil
    }
    
    @discardableResult
    static func findOrCreateDirectoryPath(for path: FSPath) -> FSPath {
        let fullPath = appDocumentsURL.path(percentEncoded: false).appending(path.rawValue)
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
        var str = appDocumentsURL.path()
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
        let path = appDocumentsURL.absoluteString.appending("/\(folder.capitalized)")
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
        let path = appDocumentsURL.absoluteString.appending("/\(path.capitalized)")
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
        return FileManager.default.fileExists(atPath: appDocumentsURL.path(percentEncoded: false).appending(path))
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
