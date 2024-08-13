//
//  DBUploader.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/15/24.
//

import SwiftUI
import Zip

/// A class responsible for managing the archiving and uploading of data containers.
@Observable
public class DBUploader {
    
    /// An enumeration representing the type of container being managed.
    public enum ContainerType: String {
        case filesystem = "Atlas File System"
        case appData = "App Container"
        case userData = "Atlas User Data"
        case mapData = "Map Data"
    }
    
    /// An enumeration representing the status of the upload process.
    public enum Status: String {
        case none = ""
        case packing = "Packing..."
        case uploading = "Uploading..."
        case error = "Issue occurred."
        case success = "Container was successfully uploaded."
    }
    
    /// The current status of the upload process.
    public var status = Status.none
    
    /// A shared file manager for handling file operations.
    private let fileManager = FileManager.default
    
    /// The token used for authentication during uploads.
    var token: String
    
    /// Initializes a new instance of `DBUploader`.
    ///
    /// - Parameter token: The authentication token used for uploading data.
    public init(token: String) {
        self.token = token
    }
    
    /// Uploads a data container after preparing and zipping it.
    ///
    /// This method prepares the specified container by zipping it and then uploads the resulting zip file.
    ///
    /// - Parameters:
    ///   - containerPath: The file path of the container to be uploaded.
    ///   - containerType: The type of the container.
    public func upload(containerPath: String, containerType: ContainerType) async {
        do {
            let containerURL = try prepareContainerURL(containerPath: containerPath, containerType: containerType)
            let zipURL = try zipContainer(at: containerURL, containerType: containerType)
            try await uploadZip(zipURL: zipURL, destinationFolder: nil)
        } catch {
            handleError(error)
        }
    }
    
    /// Archives and uploads a data container to a specified folder.
    ///
    /// This method archives the specified container to Zip, moves it to the specified folder, and then uploads the archive.
    ///
    /// - Parameters:
    ///   - containerPath: The file path of the container to be archived and uploaded.
    ///   - folder: The destination folder for the archive.
    ///   - containerType: The type of the container.
    public func archiveAndUpload(containerPath: String, to folder: String, containerType: ContainerType) async {
        do {
            if let destinationURL = try await archiveAndMoved(containerPath: containerPath, to: folder, containerType: containerType) {
                try await uploadAndCleanup(fileURL: destinationURL, destinationFolder: nil)
            }
        } catch {
            handleError(error)
        }
    }
    
    /// Archives and moves a data container to a specified folder.
    ///
    /// This method prepares, zips, and moves the specified container to the specified folder.
    ///
    /// - Parameters:
    ///   - containerPath: The file path of the container to be archived and moved.
    ///   - folder: The destination folder for the archive.
    ///   - containerType: The type of the container.
    /// - Returns: The URL of the moved archive, or `nil` if an error occurs.
    public func archiveAndMoved(containerPath: String, to folder: String, containerType: ContainerType) async throws -> URL? {
        do {
            let containerURL = try prepareContainerURL(containerPath: containerPath, containerType: containerType)
            let zipURL = try zipContainer(at: containerURL, containerType: containerType)
            let destinationURL = try moveZipToDestination(zipURL: zipURL, to: folder, type: containerType)
            return destinationURL
        } catch {
            handleError(error)
            return nil
        }
    }
    
    /// Uploads files from a specified folder and cleans up after upload.
    ///
    /// This method uploads all files in the specified folder and removes them from the local filesystem after upload.
    ///
    /// - Parameters:
    ///   - folder: The folder containing the files to be uploaded.
    ///   - type: The type of the container associated with the files, if applicable.
    public func uploadFilesInFolderAndCleanup(folder: String, type: ContainerType? = nil ) async throws {
        let folderURL = getDataPackagesURL(folder: folder, type: type)
        
        guard fileManager.fileExists(atPath: folderURL.path) else {
            print(code: .warning, "Folder does not exist.")
            return
        }
        
        let files = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
        
        for fileURL in files {
            try await doUpload(from: fileURL, to: folder)
            try fileManager.removeItem(at: fileURL)
        }
        
        if isDirectoryEmpty(folderURL) {
            try fileManager.removeItem(at: folderURL)
        }
        resetStatus()
    }
    
    /// Cleans up error files in a specified folder.
    ///
    /// This method removes all files in the specified folder that are associated with an error.
    ///
    /// - Parameters:
    ///   - folderTag: The tag of the folder containing the error files.
    ///   - type: The type of the container associated with the error files, if applicable.
    public func cleanupErrorFilesFolder(folderTag: String?, type: ContainerType? = nil) throws {
        guard let folderTag else { return }
        let folderURL = getDataPackagesURL(folder: folderTag, type: type)
        try fileManager.removeItem(at: folderURL)
        print(code: .info, "Folder \(folderURL.lastPathComponent) removed")
    }

    /// Uploads a single file and cleans up after upload.
    ///
    /// This method uploads a single file to the server and removes it from the local filesystem after upload.
    ///
    /// - Parameters:
    ///   - fileURL: The URL of the file to be uploaded.
    ///   - destinationFolder: The destination folder on the server, if applicable.
    public func uploadFileAndCleanup(fileURL: URL, destinationFolder: String?) async throws {
        guard FS.fileExists(at: fileURL) else {
            throw CoreError("Zip does not exist at specified path: \(fileURL)", type: .upload)
        }
        try await doUpload(from: fileURL, to: destinationFolder)
        try fileManager.removeItem(at: fileURL)
        resetStatus()
    }
    
    /// Uploads a zip file and resets the status afterward.
    ///
    /// This method uploads the specified zip file and resets the status of the upload process.
    ///
    /// - Parameters:
    ///   - zipURL: The URL of the zip file to be uploaded.
    ///   - destinationFolder: The destination folder on the server, if applicable.
    private func uploadZip(zipURL: URL, destinationFolder: String?) async throws {
        try await doUpload(from: zipURL, to: destinationFolder)
        resetStatus()
    }
    
    /// Prepares the URL for a data container based on the specified path and type.
    ///
    /// This method validates the existence of the container at the specified path and returns its URL.
    ///
    /// - Parameters:
    ///   - containerPath: The file path of the container.
    ///   - containerType: The type of the container.
    /// - Returns: The URL of the prepared container.
    /// - Throws: A `CoreError` if the container does not exist.
    private func prepareContainerURL(containerPath: String, containerType: ContainerType) throws -> URL {
        let containerURL = getURL(path: containerPath, in: containerType)
        guard FS.fileExists(at: containerURL) else {
            throw CoreError("Container does not exist at specified path: \(containerURL)", type: .upload)
        }
        return containerURL
    }
    
    /// Zips the specified data container.
    ///
    /// This method creates a zip file of the specified container.
    ///
    /// - Parameters:
    ///   - url: The URL of the container to be zipped.
    ///   - containerType: The type of the container.
    /// - Returns: The URL of the created zip file.
    /// - Throws: An error if the zipping process fails.
    private func zipContainer(at url: URL, containerType: ContainerType) throws -> URL {
        let fileName = (Core.shared.defaultUserID.map { "\($0) " } ?? "") + containerType.rawValue
        setStatus(to: .packing)
        return try Zip.quickZipFiles([url], fileName: fileName)
    }
    
    /// Moves the zipped container to a specified destination folder.
    ///
    /// This method moves the zip file to the specified folder.
    ///
    /// - Parameters:
    ///   - zipURL: The URL of the zip file to be moved.
    ///   - folder: The destination folder for the zip file.
    ///   - type: The type of the container associated with the zip file.
    /// - Returns: The URL of the moved zip file.
    /// - Throws: An error if the move operation fails.
    private func moveZipToDestination(zipURL: URL, to folder: String, type: ContainerType) throws -> URL {
        let destinationFolderURL = getDataPackagesURL(folder: folder, type: type)
        if !fileManager.fileExists(atPath: destinationFolderURL.path) {
            try fileManager.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true)
        }
        let destinationURL = destinationFolderURL.appendingPathComponent(zipURL.lastPathComponent)
        try fileManager.moveItem(at: zipURL, to: destinationURL)
        
        return destinationURL
    }
    
    /// Uploads a zip file and performs cleanup after the upload.
    ///
    /// This method uploads the specified zip file and then removes it from the local filesystem.
    ///
    /// - Parameters:
    ///   - fileURL: The URL of the zip file to be uploaded.
    ///   - destinationFolder: The destination folder on the server, if applicable.
    private func uploadAndCleanup(fileURL: URL, destinationFolder: String?) async throws {
        try await doUpload(from: fileURL, to: destinationFolder)
        try fileManager.removeItem(at: fileURL)
        let parentDirectory = fileURL.deletingLastPathComponent()
        if isDirectoryEmpty(parentDirectory) {
            try fileManager.removeItem(at: parentDirectory)
        }
        resetStatus()
    }
        
    /// Checks if a directory is empty.
    ///
    /// This method checks if the specified directory contains any files.
    ///
    /// - Parameter directory: The URL of the directory to check.
    /// - Returns: `true` if the directory is empty, `false` otherwise.
    private func isDirectoryEmpty(_ directory: URL) -> Bool {
        guard let contents = try? fileManager.contentsOfDirectory(atPath: directory.path) else {
            return false
        }
        return contents.isEmpty
    }
    
    /// Performs the actual upload of a file to the server.
    ///
    /// This method uploads a file from the specified URL to the server, appending the path if provided.
    ///
    /// - Parameters:
    ///   - url: The URL of the file to be uploaded.
    ///   - path: The path to append to the upload URL, if applicable.
    /// - Throws: A `CoreError` if the upload fails.
    private func doUpload(from url: URL, to path: String? = nil) async throws {
        guard var uploadURL = URL(string: "https://alpine-storage.azurewebsites.net")?.appending(path: "ios-data").appending(path: "DB Files/") else {
            throw CoreError("Could not create upload URL.", type: .upload)
        }

        if let path = path {
            uploadURL.appendPathComponent(path + "/")
        }
        
        setStatus(to: .uploading)
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        request.addValue(token, forHTTPHeaderField: "ApiKey")
        request.addValue(url.lastPathComponent, forHTTPHeaderField: "A3-File-Name")
        
        let session = URLSession.shared
        let response = try await session.upload(for: request, fromFile: url)
        
        guard let httpResponse = response.1 as? HTTPURLResponse else {
            throw CoreError("Invalid upload response.", type: .upload)
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            setStatus(to: .success)
        case 400...599:
            throw CoreError("Something went wrong, HTTP response code: \(httpResponse.statusCode)", type: .upload)
        default:
            throw CoreError("Unrecognized HTTP response code: \(httpResponse.statusCode)", type: .upload)
        }
    }
    
    /// Handles errors that occur during the upload process.
    ///
    /// This method sets the status to `.error` and logs the error using the `Core` class.
    ///
    /// - Parameter error: The error to handle.
    private func handleError(_ error: Error) {
        setStatus(to: .error)
        Core.makeError(error: error)
        resetStatus()
    }
    
    /// Constructs a URL for a data container based on the provided path and container type.
    ///
    /// - Parameters:
    ///   - path: The file path of the container.
    ///   - container: The type of the container.
    /// - Returns: The constructed URL for the container.
    private func getURL(path: String, in container: ContainerType) -> URL {
        switch container {
        case .filesystem:
            return FS.atlasGroupURL.appending(component: "Library").appending(component: "Application Support").appending(component: path)
        case .appData:
            return FS.appSupportURL.appending(path: path)
        case .userData:
            return FS.appDocumentsURL.appending(component: "Atlas").appending(path: "Shared").appending(path: path)
        case .mapData:
            return FS.appDocumentsURL.appending(component: "Atlas").appending(path: path)
                .appending(component: "Map Data.sqlite")
        }
    }
    
    /// Constructs a URL for a data package based on the provided folder and container type.
    ///
    /// - Parameters:
    ///   - folder: The folder containing the data package.
    ///   - container: The type of the container, if applicable.
    /// - Returns: The constructed URL for the data package.
    private func getDataPackagesURL(folder: String, type container: ContainerType?) -> URL {
        guard let container else {
            return FS.appDocumentsURL.appending(component: "Data Packages").appending(component: folder)
        }
        
        switch container {
        case .filesystem, .appData, .userData, .mapData:
            return FS.appDocumentsURL.appending(component: "Data Packages").appending(component: folder)
        }
    }
    
    /// Sets the status of the upload process.
    ///
    /// This method updates the status of the upload process, ensuring that the UI reflects the change.
    ///
    /// - Parameter status: The new status to set.
    private func setStatus(to status: Status) {
        DispatchQueue.main.async {
            withAnimation {
                self.status = status
            }
        }
    }
    
    /// Resets the status of the upload process to `.none`.
    ///
    /// This method resets the status after a delay, typically used after completing an upload operation.
    private func resetStatus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                self.status = .none
            }
        }
    }
}
