//
//  MoviesRequest.swift
//  iiiiii
//
//  Created by Nik on 12/03/2024.
//

import Foundation
struct MoviesRequestDTO: Encodable {
    let query: String
    let page: Int
}
