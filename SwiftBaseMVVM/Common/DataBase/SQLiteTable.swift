//
//  SQLiteTable.swift
//  iiiiii
//
//  Created by Nik on 11/03/2024.
//

import Foundation
import SQLite3

// refactor
protocol SQLStatement {
    var createStatement: String { get }
}

struct SQLTable: SQLStatement {
    
    let SQLITE_DATE = SQLITE_NULL + 1
    private let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var tableName: String?
    
    init(_ model: BasicModel) {
        var tmp = "\(model.self)"
        var arr = tmp.components(separatedBy: ".")
        tableName = arr[1].replacingOccurrences(of: Constants.model, with: Constants.emptyString)
    }
    
    var createStatement: String {
        return """
               """
    }
    
    func operatingTbl(_ typeQuery: QueryType, model: BasicModel) -> String {
        var stm = ""
        
        if let typeC = statementType(typeQuery, model: model), typeC != nil {
            stm += typeC
            stm += " \(tableName!)("//model.self
            let tmp = model.dictionary?.sorted(by: { $0.0 < $1.0 })
            //            model.dictionary?.compactMap { (key: String, value: Any) in
            tmp?.compactMap { (key: String, value: Any) in
                var primaryKey = (key == "id") ? Constants.priKey : Constants.emptyString
                stm += "\(key) \(sqliteType(type(of:value))) \(primaryKey), "
            }
            let endIdx = stm.index(stm.startIndex, offsetBy: stm.count - 2)
            stm = String(stm[stm.startIndex ..< endIdx])
            stm += ");"
        }
        else
        {
            return stm
        }
        
#if DEBUG
        print("*** crt stm: \(stm)")
#endif
        return stm
    }
    func statementStringWith(_ typeQuery: QueryType, model: BasicModel, conditionDic: Dictionary<String, Any> = [:]) -> String {
        var stm = ""
        
        if let typeC = statementType(typeQuery, model: model, conditionDic: conditionDic), typeC != nil {
            stm = typeC
        }
        else
        {
            return stm
        }
        
#if DEBUG
        print("*** stm with: \(stm)")
#endif
        return stm
    }
    
    func bindingTblColVal(_ stm: OpaquePointer?, valType: Any, idxCol: Int, val: Any ) throws {
        
        let typeC = valType
        
        switch "\(typeC)" {
        case "\(NSString.self)", "\(NSString?.self)":
            let txt: NSString = val as! NSString
            guard
                sqlite3_bind_text(stm, Int32(idxCol), txt.utf8String, -1, nil) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: "errorMessage")
            }
        case  "\(String.self)", "\(String?.self)":
            let iii = String(describing: val)
            let txt = NSString(string:iii)
            //            let txt = NSString(string: "\((val as? String)!)")
            //            let txt = "\(val!)" as NSString
            
            guard
                sqlite3_bind_text(stm, Int32(idxCol), txt.utf8String , -1, SQLITE_TRANSIENT) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: "errorMessage")
            }
        case  "\(Int.self)", "\(Int?.self)", "\(Int32.self)", "\(Int32?.self)":
            var int32Val: Int32
            let isInt = ("\(typeC)" == "\(Int.self)" || "\(typeC)" == "\(Int?.self)")
            if isInt {
                int32Val = Int32(val as! Int)
            }
            else
            {
                //                let tmp = Int32(Int(val))
                let tmp = val as! Int32
                int32Val = tmp
            }
            guard
                sqlite3_bind_int(stm, Int32(idxCol), int32Val) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: "errorMessage")
            }
        case "\(Double.self)", "\(Double?.self)", "\(Float.self)", "\(Float?.self)":
            let douVal: Double = val as! Double
            guard
                sqlite3_bind_double(stm, Int32(idxCol), douVal) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: "errorMessage")
            }
        case "\(Bool.self)", "\(Bool?.self)":
            let booVal: Bool = val as! Bool
            guard
                sqlite3_bind_int(stm, Int32(idxCol), booVal ? 1 : 0) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: "errorMessage")
            }
        case "\(Date.self)", "\(Date?.self)":
            let fmt = DateFormatter()
            let txt: NSString = fmt.string(from: val as! Date) as! NSString
            guard
                sqlite3_bind_text(stm, Int32(idxCol), txt.utf8String, -1, SQLITE_TRANSIENT) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: "errorMessage")
            }
        default:
            throw SQLiteError.Step(message: "errorMessage")
        }
    }
    
    func queryColVal(_ stm: OpaquePointer?, valType: Any, idxCol: Int) throws -> Any {
        
        let typeC = valType
        
        switch "\(typeC)" {
        case "\(NSString.self)", "\(NSString?.self)":
            let txt = sqlite3_column_text(stm, Int32(idxCol))
            let res = String(cString: txt!) as NSString
            return res
        case  "\(String.self)", "\(String?.self)":
            let txt = sqlite3_column_text(stm, Int32(idxCol))
            let res = String(cString: txt!) as NSString
            return res
        case  "\(Int.self)", "\(Int?.self)", "\(Int32.self)", "\(Int32?.self)":
            let id = sqlite3_column_int(stm, Int32(idxCol))
            return id
        case "\(Double.self)", "\(Double?.self)",
            "\(Float.self)", "\(Float?.self)":
            let id = sqlite3_column_double(stm, Int32(idxCol))
            return id
        case "\(Bool.self)", "\(Bool?.self)":
            let id = sqlite3_column_int(stm, Int32(idxCol))
            return id
        case "\(Date.self)", "\(Date?.self)":
            let id = sqlite3_column_text(stm, Int32(idxCol))
            return id
        default:
            throw SQLiteError.Step(message: "errorMessage")
        }
    }
    
    func statementType(_ typeQuery: QueryType, model: BasicModel, conditionDic: Dictionary<String, Any> = [:]) -> String? {
        var queryType = ""
        switch typeQuery {
        case QueryType.create:
            queryType = Constants.crt
        case QueryType.insert:
            queryType = Constants.insrt
            var stm = ""
            stm += queryType
            stm += " \(tableName!)("//model.self
            var stmCol = Constants.emptyString
            var stmVal = Constants.stmVal
            let tmp = model.dictionary?.sorted(by: { $0.0 < $1.0 })
            tmp?.compactMap { (key: String, value: Any) in
                stmCol += "\(key),\(Constants.spaceWhite)"
            }
            
            let valArr = Array(repeating: "?", count: model.dictionary?.count ?? 0)
            stmVal += "\(valArr.joined(separator: ","))\(Constants.closeBracket)\(Constants.semiColon)"
            
            let endIdx = stmCol.index(stmCol.startIndex, offsetBy: stmCol.count - 2)
            stmCol = String(stmCol[stmCol.startIndex ..< endIdx])
            stmCol += Constants.closeBracket
            
            stm += stmCol + stmVal
            queryType  = stm
        case QueryType.update:
            queryType = Constants.udt
            var stm = ""
            stm += queryType
            stm += "\(Constants.spaceWhite)\(tableName!)\(Constants.spaceWhite)"
            if conditionDic == nil || conditionDic.keys.count == 0 {
                return Constants.emptyString
            }
            
            stm += "\(Constants.set)\(Constants.spaceWhite)"
            
            var setConditionString = Constants.emptyString
            let tmp = model.dictionary?.sorted(by: { $0.0 < $1.0 })
            try! tmp?.compactMap { (key: String, value: Any) in
                
                if !"\(value)".contains(Constants.nilString) {
#if DEBUG
                    print("*** update: \(key): \(value)")
#endif
                    
                    setConditionString += "\(key)\(Constants.spaceWhite)\(Constants.equal)\(Constants.spaceWhite)\(Constants.questionMark)\(Constants.colon)\(Constants.spaceWhite)"
                }
            }
            
            let endIdx = setConditionString.index(setConditionString.startIndex, offsetBy: setConditionString.count - 2)
            setConditionString = setConditionString.substring(to: endIdx)
            stm += setConditionString
            
            
            stm += "\(Constants.spaceWhite)\(Constants.conditionKey)\(Constants.spaceWhite)"
            var whereString = Constants.emptyString
            conditionDic.compactMap { (key: String, value: Any) in
                whereString += "\(key) \(Constants.equal) \(Constants.questionMark) \(Constants.andOperator)\(Constants.spaceWhite)"
            }
            let endIx = whereString.index(whereString.startIndex, offsetBy: whereString.count - 4)
            whereString = whereString.substring(to: endIx)
            stm += whereString
            queryType  = stm
            
        case QueryType.select:
            queryType = Constants.qr
            var stm = ""
            stm += queryType
            stm += "\(Constants.spaceWhite)\(tableName!)"
            if conditionDic == nil || conditionDic.keys.count == 0 {
                return stm + Constants.semiColon
            }
            else
            {
                stm += "\(Constants.spaceWhite)\(Constants.conditionKey)\(Constants.spaceWhite)"
            }
            var whereString = Constants.emptyString
            conditionDic.compactMap { (key: String, value: Any) in
                whereString += "\(key) \(Constants.equal) \(Constants.questionMark) \(Constants.andOperator)\(Constants.spaceWhite)"
            }
            
            let endIdx = whereString.index(whereString.startIndex, offsetBy: whereString.count - 4)
            whereString = whereString.substring(to: endIdx)
            stm += whereString
            queryType  = stm
        case QueryType.delete:
            queryType = Constants.dlt
            queryType += "\(Constants.spaceWhite)\(tableName!)"
            queryType += "\(Constants.spaceWhite)\(Constants.conditionKey)\(Constants.spaceWhite)"
            
            var whereString = Constants.emptyString
            if conditionDic == nil || conditionDic.keys.count == 0 {
                return queryType + Constants.semiColon
            }
            else
            {
                conditionDic.compactMap { (key: String, value: Any) in
                    whereString += "\(key) \(Constants.equal) \(Constants.questionMark) \(Constants.andOperator)\(Constants.spaceWhite)"
                }
            }
            
            let endIdx = whereString.index(whereString.startIndex, offsetBy: whereString.count - 4)
            whereString = whereString.substring(to: endIdx)
            queryType += whereString                        
            queryType += Constants.semiColon
            return queryType
        default:
            queryType = Constants.emptyString
        }
        return queryType
    }
    
    // Fahim Farook on 20/3/18.
    private func getColumnType(index: CInt, stmt: OpaquePointer) -> CInt {
        var type: CInt = 0
        // Column types - http://www.sqlite.org/datatype3.html (section 2.2 table column 1)
        let blobTypes = ["BINARY", "BLOB", "VARBINARY"]
        let charTypes = ["CHAR", "CHARACTER", "CLOB", "NATIONAL VARYING CHARACTER", "NATIVE CHARACTER", "NCHAR", "NVARCHAR", "TEXT", "VARCHAR", "VARIANT", "VARYING CHARACTER"]
        let dateTypes = ["DATE", "DATETIME", "TIME", "TIMESTAMP"]
        let intTypes = ["BIGINT", "BIT", "BOOL", "BOOLEAN", "INT", "INT2", "INT8", "INTEGER", "MEDIUMINT", "SMALLINT", "TINYINT"]
        let nullTypes = ["NULL"]
        let realTypes = ["DECIMAL", "DOUBLE", "DOUBLE PRECISION", "FLOAT", "NUMERIC", "REAL"]
        // Determine type of column - http://www.sqlite.org/c3ref/c_blob.html
        let buf = sqlite3_column_decltype(stmt, index)
        //        NSLog("SQLiteDB - Got column type: \(buf)")
        if buf != nil {
            var tmp = String(validatingUTF8: buf!)!.uppercased()
            // Remove bracketed section
            if let pos = tmp.range(of: "(") {
                tmp = String(tmp[..<pos.lowerBound])
            }
            // Remove unsigned?
            // Remove spaces
            // Is the data type in any of the pre-set values?
            //            NSLog("SQLiteDB - Cleaned up column type: \(tmp)")
            if intTypes.contains(tmp) {
                return SQLITE_INTEGER
            }
            if realTypes.contains(tmp) {
                return SQLITE_FLOAT
            }
            if charTypes.contains(tmp) {
                return SQLITE_TEXT
            }
            if blobTypes.contains(tmp) {
                return SQLITE_BLOB
            }
            if nullTypes.contains(tmp) {
                return SQLITE_NULL
            }
            if dateTypes.contains(tmp) {
                return SQLITE_DATE
            }
            return SQLITE_TEXT
        } else {
            // For expressions and sub-queries
            type = sqlite3_column_type(stmt, index)
        }
        return type
    }
    
    //
    private func sqliteType(_ from: Any) -> String {
        var res = ""
        let typeC = from
        
        switch "\(typeC)" {
        case  "\(String.self)", "\(String?.self)", "\(NSString.self)", "\(String?.self)":
            res = "CHAR(255)" // TEXT
        case  "\(Int.self)", "\(Int?.self)", "\(Int32.self)", "\(Int32?.self)":
            res = "INTEGER"
        case "\(Double.self)", "\(Double?.self)", "\(Float.self)", "\(Float?.self)":
            res = "REAL"
        case "\(Bool.self)", "\(Bool?.self)":
            res = "BOOLEAN"
        case "\(Date.self)", "\(Date?.self)":
            res = "DATE"
        default:
            res = ""
        }
        return res
    }
}
