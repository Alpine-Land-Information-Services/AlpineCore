//
//  FMDownloader.swift
//  AlpineMapKit
//
//  Created by Jenya Lebid on 1/6/23.
//

import CoreData
//import Zip

public class DownloadManager {

    public enum DownloadType: String {
        case preset
        case custom
        case unknown
    }

    public struct DownloadTask {
        var info: Any?
        var type: DownloadType?

        var downloadStart: (_ file: SFile, _ info: Any?) -> ()
        var downloadEnd: (_ file: SFile, _ info: Any?) -> ()
    }

    static public let shared = DownloadManager()
//
//    var downloadTasks = [FileDownloader]()
//
//    func addToTasks(file: FileDownloader) {
//        guard !downloadTasks.contains(where: {$0.file == file.file}) else {
//            return
//        }
//
//        downloadTasks.append(file)
//    }
//
//    func removeFromTasks(file: FileDownloader) {
//        if let index = downloadTasks.firstIndex(where: {$0.file == file.file}) {
//            downloadTasks.remove(at: index)
//        }
//    }
//
//    public func resumeDownloads() {
//        let context = NSManagedObjectContext.main()
//        context.performAndWait {
//            let files = SFile.findDownloading(in: context)
//            for file in files {
//                print("----->>>>> Resuming \(file.name!) download.")
//                switch DownloadType(rawValue: file.downloadType ?? "") {
//                case .preset:
//                    addToTasks(file: FileDownloader(
//                        file: file,
//                        task: DownloadTask(info: nil,
//                                           type: nil,
//                                           downloadStart: PresetGetter.downloadFile,
//                                           downloadEnd: PresetGetter.afterFileDownload)))
//                default:
//                    return
//                }
//            }
//        }
//    }
}
//
//class FolderDownloader {
//
//    var folder: SFolder
//    var task: DownloadManager.DownloadTask
//
//    var fileDownloader: FileDownloader?
//    var status: FM.FileStatus = .fetched
//
//    init(folder: SFolder, task: DownloadManager.DownloadTask) {
//        self.folder = folder
//        self.task = task
//
//        checkFolderStatus()
//    }
//
//    func checkFolderStatus() {
//        switch FM.FileStatus(rawValue: folder.status!) {
//        case .downloaded:
//            status = .downloaded
//        case .downloading:
//            guard let file = SFolder.getZip(folder: folder) else {
//                status = .error
//                FMTracker.makeError(message: "Getting Zip File", error: FM.CustomError.noZip, retryAction: nil)
//                return
//            }
//            fileDownloader = FileDownloader(file: file, task: task)
//            changeLocalFolderStatus(fileDownloader!.status)
//        default:
//            return
//        }
//    }
//
//    func changeLocalFolderStatus(_ status: FM.FileStatus) {
//        folder.status = status.rawValue
//        folder.save()
//
//        self.status = status
//    }
//}
//
//class FileDownloader {
//
//    var task: DownloadManager.DownloadTask
//    var file: SFile
//
//    var session: URLSession?
//    var status: FM.FileStatus = .fetched
//
//    init(file: SFile, task: DownloadManager.DownloadTask) {
//        self.file = file
//        self.task = task
//
//        checkFileStatus()
//
//        NotificationCenter.default.addObserver(self, selector: #selector(checkDownloadStatus(_ :)), name: .AMK_DownloadStorageProgress, object: nil)
//    }
//
//    @objc
//    func checkDownloadStatus(_ info: NSNotification) {
//        guard let session = info.object as? URLSession else {
//            return
//        }
//
//        if file.name == nil {
//            downloadEnd()
//            return
//        }
//
//        guard session.configuration.identifier == StorageGetter.downloadIdentifier(for: file.name!, in: file.path!) else {
//            return
//        }
//        guard let progress = info.userInfo?.values.first as? DownloadTask.Progress else {
//            return
//        }
//
//        if self.session == nil {
//            self.session = session
//        }
//
//        switch progress.status {
//        case .downloading:
//            return
//        case .done:
//            downloadEnd()
//        case .error(let error):
//            FMTracker.makeError(message: "Download", error: error, retryAction: nil)
//            DispatchQueue.main.async {
//                self.status = .error
//            }
//        default:
//            return
//        }
//    }
//
//    func checkFileStatus() {
//        switch FM.FileStatus(rawValue: file.status!) {
//        case .downloading:
//            if FS.getFilePath(for: file.name!, in: file.path!) != nil {
//                changeFileStatus(.downloaded)
//            }
//            else {
//                download()
//            }
//        case .downloaded:
//            status = .downloaded
//        default:
//            changeFileStatus(.error)
//        }
//    }
//
//    func download() {
//        if let filePath = FS.getFilePath(for: file.name!, in: file.path!) {
//            switch FS.deleteFile(at: filePath, isDirectory: false) {
//            case .success(()):
//                print("Local file deleted")
//
//            case .failure(let error):
//                changeFileStatus(.error)
//                FMTracker.makeError(message: "Download File Exists Delete Fail", error: error, retryAction: nil)
//                return
//            }
//        }
//
//        status = .downloading
//        DownloadManager.shared.addToTasks(file: self)
//
//        task.downloadStart(file, task.info)
//    }
//
//    func downloadEnd() {
//        changeFileStatus(.downloaded)
//        DownloadManager.shared.removeFromTasks(file: self)
//
//        task.downloadEnd(file, task.info)
//    }
//
//    func changeFileStatus(_ status: FM.FileStatus) {
//        guard let context = file.managedObjectContext else {
//            return
//        }
//
//        file.status = status.rawValue
//        if let folder = file.folder {
//            folder.status = status.rawValue
//        }
//
//        context.easySave()
//
//        self.status = status
//    }
//}
