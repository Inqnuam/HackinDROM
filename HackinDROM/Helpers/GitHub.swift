//
//  GitHub.swift
//  HackinDROM EFI
//
//  Created by Inqnuam 07/02/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import Foundation
import Scout

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

                        KextData.GitHubV =  GetGitHubRepoLatestVersion(KextName).trimmingCharacters(in: .whitespacesAndNewlines)

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

func getKextVersion(_ KextName: String, _ drive: String) -> String {
    var returnthis = "nul"

    do {
        let dataX = try Data(contentsOf: URL(fileURLWithPath: "\(drive)/EFI/OC/Kexts/\(KextName).kext/Contents/Info.plist"))
        let decoder = PropertyListDecoder()
      let  settings = try decoder.decode(MySettings.self, from: dataX)

        returnthis = settings.CFBundleVersion

    } catch {
        returnthis = "nul"
    }

    return returnthis
}

struct MySettings: Codable {
  var CFBundleVersion: String
}

func GetGitHubRepoLatestVersion(_ repo: String) -> String {

    var returnthis = ""
    let username = "acidanthera"

    shell("curl --silent 'https://github.com/\(username)/\(repo)/releases.atom' | grep '<title>' | sed '1d' | head -n 1 | awk '{print $1}'") {request, _ in

        if request.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            returnthis = request.slice(from: "<title>", to: "</title>")  ?? ""

        }
    }

    return returnthis.trimmingCharacters(in: .whitespacesAndNewlines)
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

        let request =      req.slice(from: "\"", to: "\"") ?? "nul"

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

            //  print("Response data:\n \(todoItemModel.firstname)")
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
