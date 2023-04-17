//
//  StorageFileManager.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 1/3/23.
//

import SwiftUI

public typealias FM = StorageFileManager

public class StorageFileManager {
    
    public enum FileStatus: String {
        case fetching
        case fetched
        case downloaded
        case downloading
        case localMissing
        case localExists
        
        case error
    }
    
    public enum FileExtension: String {
        case tif
        case jp2
        case shp
        case json
        case unknown
    }
    
    public enum DirectoryStatus {
        case online
        case offline
        case error(_ error: Error)
    }
    
    public enum DownloadViewType {
        case fullscreen
        case inline
    }
    
    public enum CustomError: Swift.Error {
        case noZip
        case noDownloadFunction
    }
    
    public struct Error {
        var message: String
        var error: Swift.Error
    }
    
    public struct Root {
        public var container: String
        public var path: String
        public var name: String
        
        public var info: Any? = nil
        
        public var downloadActions: DownloadManager.DownloadTask?
        
        public var directorySelectAction: ((_ root: inout Root, _ directory: inout Directory) -> ())? = nil
        public var fileSelectAction: ((_ root: inout Root, _ info: Any?) -> ())? = nil
        
//        var downloadAction: ((_ file: SFile, _ info: Any?) -> ())? = nil
//        var afterDownloadAction: ((_ file: SFile, _ info: Any?) -> ())? = nil
    }
    
    public struct Directory: Identifiable {
        public var id = UUID()
        public var name: String
        public var isFinal: Bool = false
        
        public var items: [Item]
    }
    
    public struct File: Codable {
        public var name: String
        public var hash: String
        public var size: Int
    }
    
    public struct Item: Codable {
        public var name: String
        public var hash: String?
        public var size: Int?
        public var isDirectory: Bool
    }
    
//    static func getFileType(_ file: String) -> FileType {
//        guard let range = file.range(of: ".") else {
//            return .unknown
//        }
//
//        let fileExtension = file[range.upperBound...]
//
//        guard let fileType = FileType(rawValue: String(fileExtension)) else {
//            return .unknown
//        }
//
//        return fileType
//    }
    
    public static func fileSize(_ bytes: Int) -> String {
        let kb = Double(bytes / 1000)
        switch kb {
        case 0..<1024:
            return "\(Int(kb)) KB"
        case 0..<1_048_576:
            return "\(round((kb * 0.001) * 10) / 10) MB"
        default:
            return "\(round((kb * 0.000001) * 10) / 10) GB"
        }
    }
    
    public static func isSupportedFileType(_ fileName: String) -> Bool {
        if let ext = fileName.components(separatedBy: ".").last {
            if let _ = FM.FileExtension(rawValue: ext) {
                return true
            }
        }
        return false
    }
}

public extension StorageFileManager.Root {
    
    func filePath() -> String {
        return self.container + "/" + path
    }
    
    func folderPath() -> String {
        let index = path.lastIndex(of: "/")!
        let appendedPath = path.dropLast(path.distance(from: index, to: path.endIndex))
        
        return self.container + "/" + String(appendedPath)
    }
}



