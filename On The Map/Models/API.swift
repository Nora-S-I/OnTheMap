//
//  API.swift
//  On The Map
//
//  Created by Norah Al Ibrahim on 1/30/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit

class API {
    
    static let shared = API()
    
    private init(){}
    
    func login(email: String, password: String, _ completionHandler: @escaping (Int?, String?, String?) -> Void) {
        let url = "\(URLBase.udacity)\(UdacityPath.session)"
        
        let params = "{ \"udacity\": { \"username\": \"\(email)\", \"password\": \"\(password)\" } }"
        
        let headers = ["Accept": "application/json", "Content-Type": "application/json"]
        
        post(url, body: params, headers: headers) { (data, response, error) in
            guard let data = data else {
                completionHandler(nil, nil, self.process(responseAndError: response, error: error))
                return
            }
            
            let range = 5 ..< data.count
            let subData = data.subdata(in: range)
            do {
                let json = try JSONSerialization.jsonObject(with: subData, options: .allowFragments)
                    as! [AnyHashable: Any]
                if let responseError = json["error"] {
                    completionHandler(nil, nil, responseError as? String)
                    return
                }
                
                let account = json["account"] as? [AnyHashable: Any]
                let session = json["session"] as? [AnyHashable: Any]
                
                if account != nil, session != nil {
                    // store the retrieved data in the app delegate
                    let accountKey = Int(account!["key"] as! String)
                    let sessionId = session!["id"] as! String
                    
                    completionHandler(accountKey, sessionId, nil)
                    return
                }
                completionHandler(nil, nil, APIError.Messages.unknownError)
            }
            catch {
                completionHandler(nil, nil, error.localizedDescription)
                return
            }
        }
    }
    
    func getPublicUserData(_ id: String, _ completionHandler: @escaping (String?) -> Void) {
        
        let url = "\(URLBase.udacity)\(UdacityPath.users)/\(id)"
        
        get(url, parameters: [:], headers: nil) { (data, response, error) in
            guard let data = data else {
                completionHandler(self.process(responseAndError: response, error: error))
                return
            }
            
            let range = 5 ..< data.count
            let subData = data.subdata(in: range)
            do {
                let json = try JSONSerialization.jsonObject(with: subData, options: .allowFragments)
                    as! [AnyHashable: Any]
                
                guard let user = json["user"] as? [AnyHashable: Any] else { return }
                
                let firstname = user["first_name"] as? String
                let lastname = user["last_name"] as? String
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.firstname = (firstname != nil) ? firstname! : ""
                appDelegate.lastname = (lastname != nil) ? lastname! : ""
            }
            catch {
                completionHandler(error.localizedDescription)
            }
        }
        
    }
    
    func logout(_ completionHandler: @escaping (String?) -> Void) {
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        guard let cookie = xsrfCookie else {
            completionHandler(APIError.Messages.cookieNotFound)
            return
        }
        
        let headers = [
            "X-XSRF-TOKEN": cookie.value
        ]
        
        delete(URLBase.udacity + UdacityPath.session, headers: headers) { (data, response, error) in
            if let error = error {
                completionHandler(self.process(responseAndError: response, error: error))
                return
            }
            
            completionHandler(nil)
        }
    }
    
    func getStudentLocation(_ uniqueKey: Int, _ completionHandler: @escaping (StudentInformation?, String?) -> Void) {
        
        let url = "\(URLBase.parse)\(ParsePath.studentLocation)"
        
        let headers = [
            "X-Parse-Application-Id": Parse.appId,
            "X-Parse-REST-API-Key": Parse.apiKey
        ]
        
        let _where = "{\"uniqueKey\":\"\(uniqueKey)\"}".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let params = [
            "where": _where,
            "limit": "100"
        ]
        
        get(url, parameters: params, headers: headers) { (data, response, error) in
            if let error = error {
                completionHandler(nil, self.process(responseAndError: response, error: error))
                return
            }
            
            guard let data = data else {
                completionHandler(nil, self.process(responseAndError: response, error: error))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [AnyHashable: Any]
                if let results = json["results"] {
                    for result in results as! [[AnyHashable: Any]] {
                        completionHandler(StudentInformation(object: result), nil)
                        return
                    }
                }
            }
            catch {
                completionHandler(nil, error.localizedDescription)
                return
            }
            
        }
        
    }
    
    func getLocations(_ completionHandler: @escaping ([StudentInformation]?, String?) -> Void) {
        
        let url = "\(URLBase.parse)\(ParsePath.studentLocation)"
        
        let headers = ["X-Parse-Application-Id": Parse.appId, "X-Parse-REST-API-Key": Parse.apiKey]
        
        let params = ["limit": "100", "order": "-updatedAt"]
        
        get(url, parameters: params, headers: headers) { (data, response, error) in
            if let error = error {
                completionHandler(nil, self.process(responseAndError: response, error: error))
                return
            }
            
            guard let data = data else {
                completionHandler(nil, self.process(responseAndError: response, error: error))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [AnyHashable: Any]
                if let results = json["results"] {
                    var studentInformations = [StudentInformation]()
                    for result in results as! [[AnyHashable: Any]] {
                        studentInformations.append(StudentInformation(object: result))
                    }
                    completionHandler(studentInformations, nil)
                    return
                }
            }
            catch {
                completionHandler(nil, error.localizedDescription)
                return
            }
            
        }
        
    }
    
    func updateLocation(_ studentInfo: StudentInformation, _ completionHandler: @escaping (String?) -> Void) {
        
        let url = URLBase.parse + ParsePath.studentLocation + "/" + studentInfo.objectId
        let headers = ["X-Parse-Application-Id": Parse.appId, "X-Parse-REST-API-Key": Parse.apiKey,"Content-Type": "application/json"]
        
        put(url, body: studentInfo.json, headers: headers) { (data, response, error) in
            if error != nil {
                completionHandler(self.process(responseAndError: response, error: error))
                return
            }
            completionHandler(nil)
        }
        
    }
    
    func submitLocation(_ studentInfo: StudentInformation, _ completionHandler: @escaping (String?) -> Void) {
        
        let url = URLBase.parse + ParsePath.studentLocation
        let headers = ["X-Parse-Application-Id": Parse.appId, "X-Parse-REST-API-Key": Parse.apiKey, "Content-Type": "application/json"]
        
        post(url, body: studentInfo.json, headers: headers) { (data, response, error) in
            if error != nil {
                completionHandler(self.process(responseAndError: response, error: error))
                return
            }
            completionHandler(nil)
        }
        
    }
    
}

extension API {
    
    func post(_ url: String, body requestBody: String, headers httpHeaders: [String: String]!,
              _ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        guard let nsUrl = URL(string: url) else {
            completionHandler(nil, nil, Common.error("Invalid URL", reason: "The provided URL is invalid", code: 0))
            return
        }
        
        var request = URLRequest(url: nsUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: TimeInterval(Default.timeout))
        
        request.httpMethod = "POST"
        
        // add the http headers
        if let httpHeaders = httpHeaders {
            for (index, value) in httpHeaders {
                request.addValue(value, forHTTPHeaderField: index)
            }
        }
        
        request.httpBody = requestBody.data(using: .utf8)
        
        // get the session and make the request
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            completionHandler(data, response, error)
        }
        
        task.resume()
    }
    
    func get(_ url: String, parameters params: [String: String], headers httpHeaders: [String: String]!,
             _ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        // append the parameters to the URL
        var stringParams = [String]()
        for (index, value) in params {
            stringParams.append("\(index)=\(value)")
        }
        
        guard let nsUrl = URL(string: url + "?" + stringParams.joined(separator: "&")) else {
            completionHandler(nil, nil, Common.error("Invalid URL", reason: "The provided URL is invalid", code: 0))
            return
        }
        
        var request = URLRequest(url: nsUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: TimeInterval(Default.timeout))
        
        request.httpMethod = "GET"
        
        // add the http headers
        if let httpHeaders = httpHeaders {
            for (index, value) in httpHeaders {
                request.addValue(value, forHTTPHeaderField: index)
            }
        }
        
        // get the session and make the request
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            completionHandler(data, response, error)
        }
        
        task.resume()
    }
    
    func process(responseAndError response: URLResponse?, error: Error?) -> String {
        
        if let error = error {
            let nsError = error as NSError
            
            switch nsError.code {
            case NSURLErrorTimedOut:
                return APIError.Messages.timedOut
            case APIError.invalidRequestBodyCode:
                return APIError.Messages.invalidRequestBody
            default:
                break
            }
        }
        
        if let response = response {
            let httpResponse = response as! HTTPURLResponse
            switch httpResponse.statusCode {
            case 403:
                return APIError.Messages.invalidCredentials
            default:
                return "\(httpResponse.statusCode): \( APIError.Messages.unknownError)"
            }
        }
        
        return APIError.Messages.unknownError + ((error != nil) ? (error?.localizedDescription)! : "")
    }
    
    func delete(_ url: String, headers httpHeaders: [String: String]!,
                _ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        guard let nsUrl = URL(string: url) else {
            completionHandler(nil, nil, Common.error("Invalid URL", reason: "The provided URL is invalid", code: 0))
            return
        }
        
        var request = URLRequest(url: nsUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: TimeInterval(Default.timeout))
        
        request.httpMethod = "DELETE"
        
        // add the http headers
        if let httpHeaders = httpHeaders {
            for (index, value) in httpHeaders {
                request.addValue(value, forHTTPHeaderField: index)
            }
        }
        
        // get the session and make the request
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            completionHandler(data, response, error)
        }
        
        task.resume()
    }
    
    func put(_ url: String, body requestBody: String, headers httpHeaders: [String: String]!,
             _ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        guard let nsUrl = URL(string: url) else {
            completionHandler(nil, nil, Common.error("Invalid URL", reason: "The provided URL is invalid", code: 0))
            return
        }
        
        var request = URLRequest(url: nsUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: TimeInterval(Default.timeout))
        
        request.httpMethod = "PUT"
        
        // add the http headers
        if let httpHeaders = httpHeaders {
            for (index, value) in httpHeaders {
                request.addValue(value, forHTTPHeaderField: index)
            }
        }
        
        request.httpBody = requestBody.data(using: .utf8)
        
        // get the session and make the request
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            completionHandler(data, response, error)
        }
        
        task.resume()
    }
}

