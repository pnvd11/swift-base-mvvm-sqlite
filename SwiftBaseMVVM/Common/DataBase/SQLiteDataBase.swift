//
//  SQLiteDataBase.swift
//  iiiiii
//
//  Created by Nik on 03/03/2024.
//

import Foundation
import SQLite3

enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

// sqlite conn.
class SQLiteDatabase {
    private let dbPointer: OpaquePointer?
    private init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    
    var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(dbPointer) {
            let errorMessage = String(cString: errorPointer)
            return errorMessage
        } else {
            return "No error message provided from sqlite."
        }
    }
    
    deinit {
        sqlite3_close(dbPointer)
    }
    
    static func open(path: String) throws -> SQLiteDatabase {
        var db: OpaquePointer?
        // 1
        if sqlite3_open(path, &db) == SQLITE_OK {
            // 2
            return SQLiteDatabase(dbPointer: db)
        } else {
            // 3
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String(cString: errorPointer)
                throw SQLiteError.OpenDatabase(message: message)
            } else {
                throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }
}

// preparing statements
extension SQLiteDatabase {
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        return statement
    }
}

//: ## Create Table
extension SQLiteDatabase {
    func createTable(from: BasicModel) throws {
        let model = from
        let tmp = model
        // 1
        let table = SQLTable(model)
        let createTableStatement = try prepareStatement(sql: table.operatingTbl(QueryType.create, model: tmp))
        // 2
        defer {
            sqlite3_finalize(createTableStatement)
        }
        // 3
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        print("\(table) table created.")
    }
}

//: ## Insert
extension SQLiteDatabase {
    func insertTable(from: [BasicModel]) throws {
        let modelArr = from
        
        let table = SQLTable(modelArr.first!)
        let insertSql = table.statementStringWith(QueryType.insert, model: modelArr.first!)
        
        let insertStatement = try prepareStatement(sql: insertSql)
        
        for model in modelArr {
            var i = 1
            let tmp = model.dictionary?.sorted(by: { $0.0 < $1.0 })
            try tmp?.compactMap { (key: String, value: Any) in
#if DEBUG
                print("*** insert: \(i)")
#endif
                try table.bindingTblColVal(insertStatement, valType: type(of: value), idxCol: i, val: value)
                i += 1
            }
            
            
            guard sqlite3_step(insertStatement) == SQLITE_DONE else {
                throw SQLiteError.Step(message: errorMessage)
            }
            
            sqlite3_reset(insertStatement)
        }
        sqlite3_finalize(insertStatement)
        
        print("Successfully inserted row.")
    }
}

//: ## Read
extension SQLiteDatabase {
    func select(_ from: BasicModel, id: Int32) -> [BasicModel]? {
        
        let model = from
        let table = SQLTable(model)
        let querySql = table.statementStringWith(QueryType.select, model: model, conditionDic: ["id": id])
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return nil
        }
        
        var i = 0
        let tmp = model.dictionary?.sorted(by: { $0.0 < $1.0 })
        try! tmp?.compactMap { (key: String, value: Any) in
#if DEBUG
            print("*** qr: \(i)")
#endif
            if (key == "id")
            {
                try table.bindingTblColVal(queryStatement, valType: type(of: id), idxCol: i, val: id)
            }
            i += 1
        }
        
        var resArr = [BasicModel]()//[MovieModel]()
        while sqlite3_step(queryStatement) == SQLITE_ROW  {
            var j = 0
            var res : Dictionary<String, Any> = [:]
            let tmpR = model.dictionary?.sorted(by: { $0.0 < $1.0 })
            try! tmpR?.compactMap { (key: String, value: Any) in
#if DEBUG
                print("*** qr01: \(j)")
#endif
                let qrColVal = try table.queryColVal(queryStatement, valType: type(of: value), idxCol: j)
                res.updateValue(qrColVal, forKey: key)
                j += 1
            }
            var modelResult = type(of: from).init(res)
            resArr.append(modelResult)
        }
        
        sqlite3_finalize(queryStatement)
        
        return resArr
    }
}

// delete ???
// update
extension SQLiteDatabase {
    func update(_ from: BasicModel, conditionDic: [String: Any]) throws {
        
        let model = from
        let table = SQLTable(model)
        let updateSql = table.statementStringWith(QueryType.update, model: model, conditionDic: conditionDic)
        guard let updateStatement = try? prepareStatement(sql: updateSql) else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        var i = 1
        let tmp = model.dictionary?.sorted(by: { $0.0 < $1.0 })
        try tmp?.compactMap { (key: String, value: Any) in
#if DEBUG
            print("*** ud 01: \(key) -- \(value): \(i)")
#endif
            // binding set condition 4 col
            if !"\(value)".contains(Constants.nilString)
            {
                try table.bindingTblColVal(updateStatement, valType: type(of: value), idxCol: i, val: value)
                i += 1
            }
            
        }
        
        try tmp?.compactMap { (key: String, value: Any) in
#if DEBUG
            print("*** ud 02: \(key) -- \(value): \(i)")
#endif
            // binding whr condiction 4 col
            if conditionDic.keys.contains(key) {
                try table.bindingTblColVal(updateStatement, valType: type(of: value), idxCol: i, val: conditionDic[key]) //as! Int32)
                i += 1
            }
        }
        
        
        
        guard sqlite3_step(updateStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        sqlite3_finalize(updateStatement)
        
    }
}

// close
