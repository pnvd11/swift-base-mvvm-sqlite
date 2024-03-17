//
//  constants.swift
//  iiiiii
//
//  Created by Nik on 11/03/2024.
//

import Foundation

struct Constants{
    static var crt = "CREATE \(tbl)"
    static var insrt = "INSERT \(into)"
    static var udt = "UPDATE"
    static var qr = "SELECT * FROM"
    static var dlt = "DELETE"
    static var tbl = "TABLE"
    static var priKey = "PRIMARY KEY NOT NULL"
    static _const let into = "INTO"
    static _const let set = "SET"
    static _const let conditionKey = "WHERE"
    static _const let stmVal = " VALUES ("
    static _const let emptyString = ""
    static _const let spaceWhite = " "
    static _const let openBracket = "("
    static _const let closeBracket = ")"
    static _const let semiColon = ";"
    static _const let colon = ","
    static _const let dot = "."
    static _const let questionMark = "?"
    static _const let equal = "="
    static _const let andOperator = "AND"
    static _const let model = "Model"
    static _const let nilString = "nil"
}
