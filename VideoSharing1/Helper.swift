//
//  Helper.swift
//  VideoSharing1
//
//  Created by 1 on 12.04.17.
//  Copyright © 2017 1. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class User: Object, Mappable {
    dynamic var auth: Auth?
    dynamic var login = ""
    dynamic var password = ""
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        return "login"
    }
    
    func mapping(map: Map) {
        auth <- map["auth"]
        
    }
}

class Auth: Object, Mappable {
    
    dynamic var token: String?
    dynamic var expires: String?
    dynamic var userId: String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        token <- map["token"]
        expires <- map["expires"]
        userId <- map["user_id"]
        
    }
}

public struct ListTransform<T: RealmSwift.Object>: TransformType where T: Mappable {
    
    public init() { }
    
    public typealias Object = List<T>
    public typealias JSON = Array<Any>
    
    public func transformFromJSON(_ value: Any?) -> List<T>? {
        if let objects = Mapper<T>().mapArray(JSONObject: value) {
            let list = List<T>()
            list.append(objectsIn: objects)
            return list
        }
        return nil
    }
    
    public func transformToJSON(_ value: Object?) -> JSON? {
        return value?.flatMap { $0.toJSON() }
    }
    
}

class Video: Mappable {
    var dateAdded: String?
    var dateFeatured: String?
    var isNew = 0
    var likesCount = 0
    var title: String?
    var thumbnail: Data?
    var thumbnailURL: String?
    var height = 0.0
    var width = 0.0
    var videoURL: String?
    var userFollowing = 0
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        dateAdded <- map["date_stored"]
        dateFeatured <- map["date_featured"]
        likesCount <- map["likes_count"]
        title <- map["title"]
        thumbnailURL <- map["thumbnail_url"]
        height <- map["height"]
        width <- map["width"]
        videoURL <- map["complete_url"]
    }
}

class ResponseVideos: Mappable {
    var videos: [Video] = []
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        videos <- map["videos"]
    }
}

