//
//  StorageItem.swift
//  AlpineMapKit
//
//  Created by Jenya Lebid on 1/4/23.
//

import CoreData
//import Zip

public extension SItem {
    
    static func findExistingDirectoryContents(_ directory: FM.Directory, root: FM.Root, in context: NSManagedObjectContext) -> Int {
        let files = directory.items.filter({!$0.isDirectory}).map({$0.name})
        let request = Self.fetchRequest()
        request.predicate = NSPredicate(format: "path = %@ AND ANY name IN %@", root.filePath(), files)
        var result = 0
        
        context.performAndWait {
            do {
                result = try context.fetch(request).count
            } catch {
                print(error)
            }
        }
        return result
    }
    
//    func deleteItem() -> Result<Void, Error> {
////        let isDirectory = (self as? SFolder) != nil
//        var isDirectory = false
//
//        if let folder = self as? SFolder {
//            isDirectory = true
//            if let files = folder.files as? Set<SFile> {
//                for file in files {
//                    LayerManagerOLD.shared.deleteFile(file, redraw: false)
//                }
//            }
//        } else {
//            if let file = self as? SFile {
//                LayerManagerOLD.shared.deleteFile(file, redraw: false)
//            }
//        }
//        NotificationCenter.default.post(name: .AMK_MapRedraw, object: nil)
//
//        switch FS.deleteFile(at: "\(self.path!.capitalized)/\(self.name!)", isDirectory: isDirectory) {
//        case .failure(let error):
//            return .failure(error)
//        case .success(()):
//            self.delete(in: self.managedObjectContext)
//            return .success(())
//        }
//    }
}

public extension SFolder {
    
    static func create(_ folder: FM.Directory, at path: String, with file: SFile, type: DownloadManager.DownloadType, in context: NSManagedObjectContext) -> SFolder {
        context.performAndWait {
            let new = NSManagedObject(entity: NSEntityDescription.entity(forEntityName: SFolder.entityName, in: context)!, insertInto: context) as! SFolder
            new.guid = UUID()
            new.name = folder.name.capitalized
            new.path = path
            new.status = FM.FileStatus.downloading.rawValue
            new.size = file.size
            
            new.addToFiles(file)
            
            new.dateAdded = Date()
            new.dateModified = Date()
            
            new.save()
            
            return new
        }
    }
    
    static func find(_ path: String, name: String, in context: NSManagedObjectContext) -> SFolder? {
        return SFolder.findObject(by: NSPredicate(format: "path = %@ AND name = %@", path, name), in: context) as? SFolder
    }
    
    static func getZip(folder: SFolder) -> SFile? {
        guard let files = folder.files else {
            return nil
        }
        guard files.count == 1 else {
            return nil
        }
        return (files.allObjects as? [SFile])?.first
    }
    
    func unpackZip(as type: DownloadManager.DownloadType, in context: NSManagedObjectContext) -> [SFile]? {
        guard self.files?.count == 1 else {
            return nil
        }
        guard let file = (self.files?.allObjects as? [SFile])?.first else {
            return nil
        }
        guard file.name!.hasSuffix(".zip") else {
            return nil
        }
        guard let url = URL(string: FS.getFilePath(for: file.name!, in: file.path!) ?? "") else {
            return nil
        }
        guard let destination = URL(string: FS.getOrCreateDirectoryPath(for: file.path!)) else {
            return nil
        }
        
        do {
//            try Zip.unzipFile(url, destination: destination, overwrite: true, password: nil)

//            switch file.deleteItem() {
//            case .success(()):
//                break
//            case .failure(let error):
//                makeError(onAction: "Zip Delete", log: error.log, description: nil)
//            }
        }
        catch {
            makeError(onAction: "Folder Unzip", log: error.log, description: nil)
        }
        
        guard let newFiles = FS.getDirectoryContents(at: destination.absoluteString) else {
            return nil
        }
        
        var files = [SFile]()
        let path = self.path! + "/" + self.name!
        let id = self.guid!

        guard let folder = SFolder.findObject(by: NSPredicate(format: "guid = %@", id as CVarArg), in: context) as? SFolder
        else { return nil }
            
            for file in newFiles {
                guard FM.isSupportedFileType(file) else { continue }
                let size = FS.getFileSize(file, at: destination.absoluteString)
                let sFile = SFile.createForFolder(folder, name: file, size: size, at: path, type: type, in: context)
                files.append(sFile)
            }
            
            context.easySave()

        return files
    }
    
    func setFilesVisible() {
        guard let files = files as? Set<SFile> else { return }
        for file in files {
            file.isVisible = isVisible
        }
    }
}

public extension SFile {

    func fileType() -> FM.FileExtension {
        guard let ext = self.name!.components(separatedBy: ".").last else {
            return .unknown
        }
        
        return FM.FileExtension(rawValue: ext) ?? .unknown
    }
    
    static func createForFolder(_ folder: SFolder, name: String, size: Int?, at path: String, type: DownloadManager.DownloadType, in context: NSManagedObjectContext) -> SFile {
        context.performAndWait {
            let new = NSManagedObject(entity: NSEntityDescription.entity(forEntityName: SFile.entityName, in: context)!, insertInto: context) as! SFile
            new.guid = UUID()
            new.name = name
            new.size = Int64(size ?? 0)
            new.path = path
            new.status = FM.FileStatus.downloaded.rawValue
            
            new.folder = folder
            
            new.dateAdded = Date()
            new.dateModified = Date()

            return new
        }
    }
    
    static func create(_ file: FM.File, at path: String, folder: SFolder? = nil, type: DownloadManager.DownloadType, in context: NSManagedObjectContext) -> SFile {
        context.performAndWait {
            let new = NSManagedObject(entity: NSEntityDescription.entity(forEntityName: SFile.entityName, in: context)!, insertInto: context) as! SFile
            new.guid = UUID()
            new.name = file.name
            new.size = Int64(file.size)
            new.path = path
            new.status = type == .custom ? FM.FileStatus.downloaded.rawValue : FM.FileStatus.downloading.rawValue
            
            new.folder = folder
            
            new.dateAdded = Date()
            new.dateModified = Date()
            
            new.save()
            
            return new
        }
    }
    
    static func find(_ name: String, at path: String, in context: NSManagedObjectContext) -> SFile? {
        let request: NSFetchRequest<SFile> = Self.fetchRequest()
        request.predicate = NSPredicate(format: "path = %@ AND name = %@", path, name)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        var result: SFile?
        
        context.performAndWait {
            do {
                result = try context.fetch(request).first
            } catch {
                print(error)
            }
        }
        return result
    }
    
    static func find(_ file: FM.File, in directory: FM.Root, in context: NSManagedObjectContext) -> SFile? {
        let request: NSFetchRequest<SFile> = Self.fetchRequest()
        request.predicate = NSPredicate(format: "path = %@ AND name = %@", directory.filePath(), file.name)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        var result: SFile?
        
        context.performAndWait {
            do {
                result = try context.fetch(request).first
            } catch {
                print(error)
            }
        }
        return result
    }
    
    static func findDownloading(in context: NSManagedObjectContext) -> [SFile] {
        SFile.findObjects(by: NSPredicate(format: "status = %@", FM.FileStatus.downloading.rawValue), in: context) as! [SFile]
    }
    
    static func findLayers(in context: NSManagedObjectContext) -> [SFile]? {
        SFile.findObjects(by: NSPredicate(format: "name ENDSWITH %@ AND status != %@", FM.FileExtension.jp2.rawValue, FM.FileStatus.downloading.rawValue), in: context) as? [SFile]
    }
    
    func fullPath() -> URL {
        FS.documentsDirectory.appendingPathComponent(self.path!.capitalized, conformingTo: .folder).appendingPathComponent(self.name!, conformingTo: .item)
    }
}
