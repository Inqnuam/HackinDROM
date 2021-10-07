//
//  Login.swift
//  HackinDROM
//
//  Created by Inqnuam 23/02/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import Foundation

// User Authentifications
struct AuthGet: Codable {

    var id: String = ""
}
struct ErrStatus: Decodable {
    var error: String
}

func LogIn(username: String, password: String, completion : @escaping (String)->()) {
    let url = URL(string: "https://hackindrom.zapto.org/app/login")

    guard let requestUrl = url else { fatalError() }

    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
    

    // Set HTTP Request Header
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")


    let jsonData = try! JSONEncoder().encode(["username": username, "password": password])

    request.httpBody = jsonData

    let logIn =  URLSession.shared.dataTask(with: request) { (data, response, error) in

        if let error = error {
            print("Error took place \(error)")
            return
        }
        guard let data = data else {return}

        do {

      
            if let httpResponse = response as? HTTPURLResponse {

                if (httpResponse.statusCode) == 200 {
                    let valod = try JSONDecoder().decode(AuthGet.self, from: data)

                    completion(valod.id)
                    
                   
                } else {

                    completion("nul")
                }
             
//                let cookies = HTTPCookie.cookies(withResponseHeaderFields: httpResponse.allHeaderFields as! [String : String], for: response!.url!)
//                 dump(cookies) // for testing.
            }

        } catch let jsonErr {
            print(jsonErr)
            completion("nul")
        }

    }
    logIn.resume()
}

func logged() -> HTTPCookie {
   
    var cookieVal = HTTPCookie()
    let cookieJar = HTTPCookieStorage.shared
    
    for cookie in cookieJar.cookies! {
        
        if cookie.name == "HDSESS" {
            cookieVal = cookie
            
          
            
        }
    }
    
 return cookieVal
}

struct InitialLoad: Codable {

    var version: String = ""
    var username: String = "nul"
    var userid: String = "nul"
    var online: Bool = false
}

func imOnline(completion: @escaping(InitialLoad)->()) {
   var request = URLRequest(url: URL(string: "https://hackindrom.zapto.org/app/imOnline")!)
    request.httpMethod = "GET"
    request.timeoutInterval = 10.0
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let task =  URLSession.shared.dataTask(with: request) { (data, response, error) in

        if let error = error {
            print("Error took place \(error)")
            completion(InitialLoad(online: false))
          
        }
       

        do {

          if error != nil {
              completion(InitialLoad(online: false))
            } else {

                let httpResponse = response as? HTTPURLResponse
                    if (httpResponse!.statusCode) == 200 {
                        let valod = try JSONDecoder().decode(InitialLoad.self, from: data!)

                        completion(valod)
                       
                    }

            }

        } catch let jsonErr {
            print(jsonErr)
            completion(InitialLoad(online: false))
        }

    }
    task.resume()
}

func LogoutReq(completion : @escaping (Bool)->()) {

    let url = URL(string: "https://hackindrom.zapto.org/app/logout")
    // let url = URL(string: "https://ffsharedData.zapto.org/")
    guard let requestUrl = url else { fatalError() }

    var request = URLRequest(url: requestUrl)
    request.httpMethod = "GET"

    // Set HTTP Request Header
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let task =  URLSession.shared.dataTask(with: request) { (_, response, error) in

        if let error = error {
            print("Error took place \(error)")
            completion(false)

        }

          if error != nil {
            completion(false)
            } else {

                let httpResponse = response as? HTTPURLResponse
                    if (httpResponse!.statusCode) == 200 {

                        completion(true)

                    } else {
                        completion(false)
                    }

            }

    }
    task.resume()

}
func ChangeMyBuildName(UserID: String, id: String, name: String) -> String {

    var gang: AuthGet = AuthGet()
    let group = DispatchGroup()
    group.enter()
    let rawurl = "https://hackindrom.zapto.org/app/ChangeBuildName?x=\(UserID)&id=\(id)&name=\(name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let url = URL(string: rawurl)
    guard let requestUrl = url else { fatalError() }

    var request = URLRequest(url: requestUrl)
    request.httpMethod = "GET"
    let task =  URLSession.shared.dataTask(with: request) { (data, response, error) in

        if let error = error {
            print("Error took place \(error)")
            return
        }
        guard let data = data else {return}

        do {

            //  print("Response data:\n \(todoItemModel.firstname)")
            if let httpResponse = response as? HTTPURLResponse {

                if (httpResponse.statusCode) == 200 {
                  let valod = try JSONDecoder().decode(AuthGet.self, from: data)
                  
                    gang.id = valod.id

                } else {

                    gang.id = "nul"
                }
            }

            group.leave()
        } catch let jsonErr {
            print(jsonErr)
            gang.id = "nul"
        }

    }
    task.resume()
    group.wait()
    return gang.id

}

func ChangeSPN(UserID: String, id: String, name: String) -> String {

    var gang: AuthGet = AuthGet()
    let group = DispatchGroup()
    group.enter()
    let rawurl = "https://hackindrom.zapto.org/app/ChangeSPN?id=\(id)&SPN=\(name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let url = URL(string: rawurl)
    guard let requestUrl = url else { fatalError() }

    var request = URLRequest(url: requestUrl)
    request.httpMethod = "GET"

    let task =  URLSession.shared.dataTask(with: request) { (data, response, error) in

        if let error = error {
            print("Error took place \(error)")
            return
        }
        guard let data = data else {return}

        do {

            //  print("Response data:\n \(todoItemModel.firstname)")
            if let httpResponse = response as? HTTPURLResponse {

                if (httpResponse.statusCode) == 200 {
                    let valod = try JSONDecoder().decode(AuthGet.self, from: data)

                    gang.id = valod.id

                } else {

                    gang.id = "nul"
                }
            }

            group.leave()
        } catch let jsonErr {
            print(jsonErr)
            gang.id = "nul"
        }

    }
    task.resume()
    group.wait()
    return gang.id

}

func EditReleaseNotesandLink(link: String, notes: String, id: String, uid: String) -> String {

    var gang: AuthGet = AuthGet()
    let group = DispatchGroup()
    group.enter()
    let url = URL(string: "https://hackindrom.zapto.org/app/EditRNaL?id=\(id)")
    guard let requestUrl = url else { fatalError() }

    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"

    // Set HTTP Request Header
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

  
    let jsonData = try! JSONEncoder().encode(["username": link, "password": notes])

    request.httpBody = jsonData

    let task =  URLSession.shared.dataTask(with: request) { (data, response, error) in

        if let error = error {
            print("Error took place \(error)")
            return
        }
        guard let data = data else {return}

        do {

            //  print("Response data:\n \(todoItemModel.firstname)")
            if let httpResponse = response as? HTTPURLResponse {

                if (httpResponse.statusCode) == 200 {
                    let valod = try JSONDecoder().decode(AuthGet.self, from: data)

                    gang.id = valod.id

                } else {

                    gang.id = "nul"
                }
            }

            group.leave()
        } catch let jsonErr {
            print(jsonErr)
            gang.id = "nul"
        }

    }
    task.resume()
    group.wait()
    return gang.id

}
