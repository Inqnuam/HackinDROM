//
//  Downloader.swift
//  HackinDROM EFI
//
//  Created by Inqnuam 05/02/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import Foundation

class FileDownloader {
    
    static func loadFileSync(url: URL, completion: @escaping (String?, Error?) -> Void) {
        let documentsUrl = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        do {
            try  fileManager.removeItem(at: URL(fileURLWithPath: destinationUrl.path))
        } catch {
            
        }
        if fileManager.fileExists(atPath: destinationUrl.path) {
            completion(destinationUrl.path, nil)
        } else if let dataFromURL = NSData(contentsOf: url) {
            if dataFromURL.write(to: destinationUrl, atomically: true) {
                completion(destinationUrl.path, nil)
            } else {
                print("error saving file")
                let error = NSError(domain: "Error saving file", code: 1001, userInfo: nil)
                completion(destinationUrl.path, error)
            }
        } else {
            let error = NSError(domain: "Error downloading file", code: 1002, userInfo: nil)
            completion(destinationUrl.path, error)
        }
    }
    
    static func loadFileAsync(url: URL, completion: @escaping (String?, Error?) -> ()) {
        let documentsUrl =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        do {
            try  fileManager.removeItem(at: URL(fileURLWithPath: destinationUrl.path))
        } catch {
            
        }
        if fileManager.fileExists(atPath: destinationUrl.path) {
            completion(destinationUrl.path, nil)
        } else {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler: {
                data, response, error in
                if error == nil {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            if let data = data {
                                if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic) {
                                    completion(destinationUrl.path, error)
                                } else {
                                    completion(destinationUrl.path, error)
                                }
                            } else {
                                completion(destinationUrl.path, error)
                            }
                        }
                    }
                } else {
                    completion(destinationUrl.path, error)
                }
            })
            task.resume()
        }
    }
}

func downloadtoHD(url: URL) async -> String? {
    let destinationUrl = URL(fileURLWithPath: tmp + "/" + url.lastPathComponent)
    
   
    if fileManager.fileExists(atPath: destinationUrl.path) {
        do {
            try  fileManager.removeItem(at: URL(fileURLWithPath: destinationUrl.path))
        } catch {
            print(error)
        }
    }
    
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let response = response as? HTTPURLResponse else { return nil}
            guard response.statusCode == 200 else {return nil}
            
            if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic) {
                return (destinationUrl.path)
                
            } else {
                return nil
            }
        } catch {
            print(error)
            return nil
        }
      
}
