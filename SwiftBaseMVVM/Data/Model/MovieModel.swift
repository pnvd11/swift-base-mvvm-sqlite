//
//  MovieModel.swift
//  iiiiii
//
//  Created by Nik on 04/03/2024.
//

import Foundation

//  MovieModel tbl entity
class MovieModel: BasicModel {
    var name: String?
    var addr: String?
    var idNum: Int?
    required init(_ jsonDict: [String: Any]) {
        super.init(jsonDict)
        name = jsonDict["name"] as? String
        addr = jsonDict["addr"] as? String
        idNum = jsonDict["idNum"] is Int32 ? Int(jsonDict["idNum"] as! Int32) : jsonDict["idNum"] as? Int
        let tmp = jsonDict["id"] as? Int
        if (tmp != nil)
        {
            self.id = Int32(tmp!)
        }
        
        dictionary = toDictionary()
    }    
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}
