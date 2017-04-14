//
//  ApiManager.swift
//  VideoSharing1
//
//  Created by 1 on 12.04.17.
//  Copyright © 2017 1. All rights reserved.
//


import Alamofire
import RealmSwift
import AlamofireObjectMapper

fileprivate let kBaseAPIURLString = "https://api.vid.me/"
fileprivate let kAppKey = "Basic 9EKjzx3YIVCxsC2vZgXC3AL5FTPzUOeK"
fileprivate let kAuthorizationKey = "Authorization"

class APIManager {
    
    class func getFeauturedVideoList(limit: Int, offset: Int, completionHandler: @escaping (Error?, [Video]?) -> Void) {
        
        getVideoList(url: "\(kBaseAPIURLString)videos/featured?limit=\(limit)&offset=\(offset)", completionHandler: completionHandler)
    }
    
    class func getNewVideoList(limit: Int, offset: Int, completionHandler: @escaping (Error?, [Video]?) -> Void) {
        
        getVideoList(url: "\(kBaseAPIURLString)videos/new?limit=\(limit)&offset=\(offset)", completionHandler: completionHandler)
    }
    
    class func getThumbnailForVideo(_ video: Video, completionHandler: @escaping () -> Void) {
        Alamofire.request(video.thumbnailURL!).responseData { response in
                if let data = response.result.value {
                    video.thumbnail = data
                    completionHandler()
                }
            
        }
    }
    
    class func getVideoFeedForCurrentUser(limit: Int, completionHandler: @escaping (Error?, [Video]?) -> Void) {
        
        func getVideos(currentUser: User?) {
            if let user = currentUser, let auth = user.auth {
                let headers: HTTPHeaders = [
                    "AccessToken": "\(auth.token!)"
                ]
                
                Alamofire.request("\(kBaseAPIURLString)videos/following?limit=\(limit)", headers: headers).responseObject { (response: DataResponse<ResponseVideos>) in
                    
                    switch response.result {
                    case .success:
                        if let responseVideos = response.result.value {
                            completionHandler(nil, responseVideos.videos)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            
        }
        
        let completion: (Error?, User?) -> Void = { error, currentUser in
            getVideos(currentUser: currentUser)
        }
        
        
        
        let realm = try! Realm()
        if let user = realm.objects(User.self).first {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            if let dateString = user.auth?.expires {
                if let dateObj = dateFormatter.date(from: dateString), Date().compare(dateObj) == .orderedDescending {
                    //refresh token
                    loginUser(with: user.login, password: user.password, completionHandler: completion)
                    
                } else {
                    getVideos(currentUser: user)
                }
                
            }
        }
    }
    
    class func loginUser(with username: String, password: String, completionHandler: @escaping (Error?, User?) -> Void) {
        
        let headers: HTTPHeaders = [
            "\(kAuthorizationKey)": "\(kAppKey)"
        ]
        let parameters: Parameters = ["username": username, "password": password]
        
        Alamofire.request("\(kBaseAPIURLString)auth/create", method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).validate(statusCode: 200..<300).responseObject { (response: DataResponse<User>) in
            
            switch response.result {
            case .success:
                if let user = response.result.value {
                    print(user)
                    user.login = username
                    user.password = password
                    
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(user, update: true)
                    }
                    
                    completionHandler(nil, user)
                }
            case .failure(let error):
                print(error.localizedDescription)
                completionHandler(error, nil)
            }
            
        }
    }
    
    class func isUserLoggedIn() -> Bool {
        let realm = try! Realm()
        if realm.objects(User.self).first != nil {
            return true
        } else {
            return false
        }
    }
    
    class func logoutUser(_ completionHandler: @escaping (Error?) -> Void) {
        
        let realm = try! Realm()
        if let user = realm.objects(User.self).first {
            let headers: HTTPHeaders = [
                "AccessToken": "\(user.auth!.token!)"
            ]
            Alamofire.request("\(kBaseAPIURLString)auth/delete", headers: headers).responseJSON(completionHandler: { response in
                switch response.result {
                case .success:
                    try! realm.write {
                        realm.delete(user)
                    }
                    completionHandler(nil)
                case .failure(let error):
                    print(error)
                    completionHandler(error)
                }
            })
        }
    }
    
    fileprivate class func getVideoList(url: String, completionHandler: @escaping (Error?, [Video]?) -> Void) {
        
        Alamofire.request(url).responseObject { (response: DataResponse<ResponseVideos>) in
            
            switch response.result {
            case .success:
                if let responseVideos = response.result.value {
                    completionHandler(nil, responseVideos.videos)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
