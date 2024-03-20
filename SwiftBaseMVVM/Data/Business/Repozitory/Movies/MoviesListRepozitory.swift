//
//  MoviesListRepozitory.swift
//  iiiiii
//
//  Created by Nik on 13/03/2024.
//

import Foundation

class MoviesListRepozitory {
    
    let db: SQLiteDatabase
    init() {
        db = AppDIContainer.shared.DB
    }
    func insert(_ from: [MovieModel]) throws -> Bool {
        // insert
        var res = false
        do {
            try db.insertTable(from: from)
            res = true
        } catch {
          print(db.errorMessage)
        }
        return res
    }
    
    func query(_ from: MovieModel, id: Int32) -> [MovieModel] {
        
        let resArr = db.select(from, id: id) as! [MovieModel]
        resArr.forEach({ item in
            #if DEBUG
                print("iii qr: \(item.id) \(item.name) \(item.idNum)")
            #endif
        })
        return resArr
    }
    
    func update(_ from: MovieModel, conditionDic: [String: Any] ) throws -> Bool {
        var res = false
        do {
            try db.update(from, conditionDic: conditionDic)
            res = true
        } catch  {
            print("*** update err: ")
        }
        return res
    }
    
    func delete(_ from: MovieModel, id: Int32) throws -> Bool {
        var res = false
        do {
            try db.delete(from, id: id)
            res = true
        } catch  {
            print("*** del err: ")
        }
        return res
    }
}
