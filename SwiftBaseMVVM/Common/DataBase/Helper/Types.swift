//
//  Types.swift
//  iiiiii
//
//  Created by Nik on 04/03/2024.
//

import Foundation
import SQLite3

public enum QueryType {
    case create
    case insert
    case update
    case delete
    case select
    
    fileprivate init(rawValue: Int32) {
        switch rawValue {
        case SQLITE_CREATE_TABLE:
            self = .create
        case SQLITE_INSERT:
            self = .insert
        case SQLITE_UPDATE:
            self = .update
        case SQLITE_DELETE:
            self = .delete
        case SQLITE_SELECT:
            self = .select
        default:
            fatalError("unhandled operation code: \(rawValue)")
        }
    }
}
