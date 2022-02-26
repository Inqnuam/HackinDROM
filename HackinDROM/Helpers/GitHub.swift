//
//  GitHub.swift
//  HackinDROM EFI
//
//  Created by Inqnuam 07/02/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import Foundation
import FeedKit
import Version
func CreateTodayDate() -> String {
    
    let date = Date()
    let calendar = Calendar.current
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    let day = calendar.component(.day, from: date)
    let hour = calendar.component(.hour, from: date)
    let minutes = calendar.component(.minute, from: date)
    let secondes = calendar.component(.second, from: date)
    
    return "\(year)_\(month)_\(day)_\(hour)h\(minutes)-\(secondes)"
}

struct OcModifiedDates {
    var monthAndYear: String = ""
    var YearMonthDay: String = ""
    var fullDate: String = ""
}
func GetOCCreatedDate(_ url: String) -> OcModifiedDates {
    var returnthis = OcModifiedDates()
    let convertedurl = URL(fileURLWithPath: url)
    do {
        let attr = try fileManager.attributesOfItem(atPath: convertedurl.path)
        
        let calanderDate = Calendar.current.dateComponents([.day, .year, .month, .hour, .minute], from: attr[FileAttributeKey.modificationDate] as! Date)
        
        let month = calanderDate.month! >= 10 ? "\(calanderDate.month!)" : "0\(calanderDate.month!)"
        
        let day = calanderDate.day! >= 10 ? "\(calanderDate.day!)" : "0\(calanderDate.day!)"
        let hours = calanderDate.hour!
        // let minutes = calanderDate.minute!
        
        returnthis.monthAndYear = "\(calanderDate.year!)-\(month)"
        returnthis.YearMonthDay = "\(calanderDate.year!)-\(month)-\(day)"
        returnthis.fullDate = "\(calanderDate.year!)-\(month)-\(day)T\(hours)"
        
        
    } catch {
        
    }
    
    
    return  returnthis
}

func getMyKextList (_ url: String, _ Kexts: [KextStructs]) -> [KextStructs] {
    
    var KextList: [KextStructs] = []
    
    do {
        
        // MyEFI folder's Kexts
        let FindKexts = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "\(url)/EFI/OC/Kexts/"), includingPropertiesForKeys: nil)
        
        let kexts =  FindKexts.filter { $0.pathExtension == "kext" }
        let FileNames = kexts.map { $0.deletingPathExtension().lastPathComponent }
        
        if FileNames.count > 0 {
            
            for KextName in FileNames {
                
                var KextData = KextStructs(name: "nul", LocalV: "nul", GitHubV: "nul", DownloadLink: "nul")
                
                KextData.name = KextName
                
                if  (Kexts.firstIndex(where: {$0.name.localizedCaseInsensitiveContains(KextData.name)}) == nil) {
                    
                    KextData.LocalV =  getKextVersion(KextName, url)
                    if  KextData.LocalV != "nul" || KextData.LocalV != "" {
                        
                        if let gitHubV =  getGitReleasesVersions("acidanthera", KextName, true) {
                            KextData.GitHubV = gitHubV.first!
                        }
                        
                        
                    }
                    if  KextData.GitHubV.contains(".") {
                        
                        KextData.isUpdatable = {
                            
                            if KextData.LocalV.compare( KextData.GitHubV, options: .numeric).rawValue <= 0 {
                                
                                return false
                                
                            } else {
                                KextData.DownloadLink = "YES"
                                return true
                            }
                        }()
                        
                    }
                    
                }
                
                KextList.append(KextData)
            }
            
        }
    } catch {
        print("error: 0x41C06F")
    }
    
    return KextList
}

struct PlistInfoStruct: Codable {
    var CFBundleVersion: String
}


func getKextVersion(_ KextName: String, _ drive: String) -> String {
    do {
        let dataX = try Data(contentsOf: URL(fileURLWithPath: "\(drive)/EFI/OC/Kexts/\(KextName).kext/Contents/Info.plist"))
        let decoder = PropertyListDecoder()
        let  settings = try decoder.decode(PlistInfoStruct.self, from: dataX)
        
        return settings.CFBundleVersion
        
    } catch {
        return "nul"
    }
    
}

func getKextVersionFrom(path: String)-> Version {
    do {
        let dataX = try Data(contentsOf: URL(fileURLWithPath: "\(path).kext/Contents/Info.plist"))
        let decoder = PropertyListDecoder()
        let  settings = try decoder.decode(PlistInfoStruct.self, from: dataX)
        
        if let version = Version(tolerant: settings.CFBundleVersion) {
         
            return version
        } else {
            return Version("0.0.0")!
        }
        
        
    } catch {
        return Version("0.0.0")!
    }
}
func getGitHubRepoDownloadLinkfromHTML(_ kextInfo:GitHubInfo) async -> String? {
    
    // #FIXME: Use URLSession
    let output = await shellAsync("curl --silent https://github.com/\(kextInfo.owner)/\(kextInfo.repo)/releases/latest -L | grep '/\(kextInfo.owner)/\(kextInfo.repo)/releases/download' | grep '.zip' | awk '{print $2}'")
  
    if let request = output.slice(from: "\"", to: "\"") {
        
        return "https://github.com\(request)"
    } else {return nil}
}

func GetGitHubDownloadLink(_ repo: String) -> String {
    var downloadlink = "nul"
    let username = "acidanthera"
    
    var repository = ""
    if repo == "IntelMausi" {
        
        repository = "IntelMausiEthernet"
        
    } else {
        
        repository = repo
    }
    
    // shell("curl --silent \"https://api.github.com/repos/\(username)/\(repo)/releases/latest\" | grep -w 'browser_download_url' | awk '{if(/RELEASE/) print $2}'").slice(from: "\"", to: "\"") ?? "nul"
    
    shell("curl --silent https://github.com/\(username)/\(repository)/releases/latest -L | grep '/\(username)/\(repository)/releases/download' | grep 'RELEASE.zip' | awk '{print $2}'") {req, _ in
        
        let request = req.slice(from: "\"", to: "\"") ?? "nul"
        
        if request != "nul" {
            // let link = "https://github.com/\(username)/\(repo)/releases/download/1.4.9/\(repo)-1.4.9-RELEASE.zip"
            downloadlink = "https://github.com\(request)"
        }
    }
    return downloadlink
}


struct GitHubJsonStruct: Codable {
    var name: String
    var published_at: String
    var assets: [GitHubJsonAssets]
}

struct GitHubJsonAssets: Codable {
    var browser_download_url: String
}


func OpenCoreGitHubReleases() {
    var request = URLRequest(url: URL(string: "https://api.github.com/repos/acidanthera/OpenCorePkg/releases")!)
    request.httpMethod = "GET"
    
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    
    let logIn =  URLSession.shared.dataTask(with: request) { (data, response, error) in
        
        if let error = error {
            print("Error took place \(error)")
            return
        }
        guard let data = data else {return}
        
        do {
            if let httpResponse = response as? HTTPURLResponse {
                
                if (httpResponse.statusCode) == 200 {
                    let Releases = try JSONDecoder().decode([GitHubJsonStruct].self, from: data)
                    let encoder = PropertyListEncoder()
                    encoder.outputFormat = .xml
                    
                    do {
                        let data = try encoder.encode(Releases)
                        try data.write(to: URL(fileURLWithPath: tmp + "/").appendingPathComponent("ocreleases.plist"))
                    } catch {
                        print(error)
                    }
                    
                    
                } else {
                    
                    
                }
            }
            
        } catch let jsonErr {
            print(jsonErr)
            
        }
        
    }
    logIn.resume()
}

func getGitLatestCommitDate(_ link: String) -> Date? {
    let parser = FeedParser(URL: URL(string: link)!)
    let result = parser.parse()
    switch result {
        case .success(let feed):
            
            switch feed {
                case let .atom(feed):
                    if let updatedDate = feed.updated {
                      
                        return updatedDate
                    }
                    return nil
                    
                default:
                    return nil
                    
            }
            
        case .failure:
            return nil
    }
    
}

func getGitReleasesVersions(_ username:String, _ repo: String, _ onlyFirst:Bool = false) -> [String]? {
 
    
    var gitOCReleasesVersions: [String]? = []
    let feedURL = "https://github.com/\(username)/\(repo)/releases.atom"
    
    let parser = FeedParser(URL: URL(string: feedURL)!)
    let result = parser.parse()
    switch result {
        case .success(let feed):
            
            switch feed {
                case let .atom(feed):
                    if let entries = feed.entries {
                        if onlyFirst {
                            if !entries.isEmpty && entries[0].title != nil {
                                gitOCReleasesVersions!.append(entries[0].title!)
                            }
                        } else {
                            for itm in entries {
                                if itm.title != nil {
                                    gitOCReleasesVersions!.append(itm.title!)
                                }
                            }
                        }
                        
                    }
                    break
                    
                default:
                    gitOCReleasesVersions = nil
                    break
            }
            
        case .failure(let error):
            gitOCReleasesVersions = nil
            print(error)
    }
    
    if gitOCReleasesVersions != nil {
        gitOCReleasesVersions!.sort { (a, b) -> Bool in
            a.compare(b, options: String.CompareOptions.numeric, range: nil, locale: nil) == .orderedDescending
        }
        
      
        return (gitOCReleasesVersions!)
    } else {
        return nil
    }
}


extension URLSession {
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }
                
                continuation.resume(returning: (data, response))
            }
            
            task.resume()
        }
    }
    
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }
                
                continuation.resume(returning: (data, response))
            }
            
            task.resume()
        }
    }
}


func getRepoDataFromGhAPI(_ repoOwner: String, _ repoName: String) async -> [GitHubJSON]? {
    
    guard  let link = URL(string: "https://api.github.com/repos/\(repoOwner)/\(repoName)/releases")  else {return nil }
    
    var request = URLRequest(url: link)
    request.httpMethod = "GET"
    request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
    
    
    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
        let decoded = try JSONDecoder().decode([GitHubJSON].self, from: data)
        
        return decoded
        
        
    } catch {
        print(error)
        return nil
        
    }
    
}


struct GitHubJSON: Identifiable, Decodable {
    var id: Int
    var prerelease: Bool
    var tag_name: String
    var assets: [GitHubJSONAssets]
}

struct GitHubJSONAssets:Identifiable, Decodable {
    var id: Int
    var name: String
    var browser_download_url: String
}
