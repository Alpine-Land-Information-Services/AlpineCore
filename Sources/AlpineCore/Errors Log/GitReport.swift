//
//  GitReport.swift
//  AlpineCore
//
//  Created by mkv on 1/24/24.
//

import Foundation

struct gitError: Error {
    var message: String
}

class GitReport {
    private let apiEndpoint: String = "https://api.github.com"
    
    func sendReport(owner: String,
                    repository: String,
                    token: String,
                    title: String,
                    message: String,
                    email: String,
                    completion: @escaping (Result<[String: AnyObject], gitError>) -> Void)
    {
        let accessToken = token.data(using: .utf8)!.base64EncodedString()
        let path = "repos/\(owner)/\(repository)/issues"
        let url = URL(string: path, relativeTo: URL(string: apiEndpoint)!)
        guard url != nil else { return completion(.failure(gitError(message: "URL is not valid")))}
        
        var request = URLRequest(url: url!)
        request.timeoutInterval = 30
        request.httpMethod = "POST"
        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "accept")
        request.addValue("Basic \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let appVersion = getAppVersion()
        let params: [String: Any] = ["title": email + ", " + title,
                                     "body": (appVersion != nil ? "(v\(appVersion!)) " : "") + "\n" + message]
        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
        } catch {
            return completion(.failure(gitError(message: error.localizedDescription)))
        }
        
        let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            guard error == nil else { return completion(.failure(gitError(message: error!.localizedDescription))) }
            guard data != nil else { return completion(.failure(gitError(message: "Data is empty"))) }
            
            if let error = error {
                completion(.failure(gitError(message: error.localizedDescription)))
            } else {
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: AnyObject]
                        if json["number"] != nil {
                            completion(.success(json))
                        } else {
                            completion(.failure(gitError(message: json["message"] as? String ?? "Unknown")))
                        }
                    } catch {
                        completion(.failure(gitError(message: error.localizedDescription)))
                    }
                }
            }
        }
        task.resume()
    }
    
    func getAppVersion() -> String? {
        "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown").\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")"
    }
}
