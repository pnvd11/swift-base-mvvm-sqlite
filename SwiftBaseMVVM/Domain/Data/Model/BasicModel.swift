//
//  BasicModel.swift
//  iiiiii
//
//  Created by Nik on 11/03/2024.
//

import Foundation

class BasicModel {
    var id: Int32?
    var dictionary: [String: Any]?
    required init(_ jsonDict: [String: Any]) {
        id = jsonDict["id"] as? Int32
    }
    
    static func genUUIDSql() -> String {
        return UUID().uuidString
    }
    
    func toDictionary() -> Dictionary<String, Any> {
        // Prieto
        var dic = [String: Any]()
        let mrr = Mirror(reflecting: self)
        
        let spMrr = mrr
            .superclassMirror!
        
        var allItems = [spMrr.children, mrr.children].lazy.joined()
        for (idx, item) in allItems.enumerated() { //mrr.children.enumerated() {            
            let label = (item ).label
            let value = (item ).value
            guard let label = label  else {
                continue
            }
            if label == "dictionary" {
                continue
            }
            
            dic.updateValue(value, forKey: label)
        }
        return dic
    }
}

// Leo Dabus
struct JSON {
    static let encoder = JSONEncoder()
}
