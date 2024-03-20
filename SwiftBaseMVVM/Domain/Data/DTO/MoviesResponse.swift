//
//  MoviesResponse.swift
//  iiiiii
//
//  Created by Nik on 12/03/2024.
//

import Foundation

struct MoviesResponseDTO: Decodable {
    struct Movie: Decodable{
        private enum CodingKeys: String, CodingKey {
            case title
            case overview
            case posterPath = "poster_path"
        }
        let title: String
        let overview: String
        let posterPath: String
    }
    private enum CodingKeys: String, CodingKey {
        case movies = "results"
    }
    
    let movies: [Movie]
    
    func toModel() -> [MovieModel] {
        let result = (movies.count > 0) ?
            movies.map { item -> MovieModel in
            var model = MovieModel([:])
            model.id = Int32(arc4random())
            model.name = item.title
            model.addr = item.overview
            model.idNum = Int(arc4random())
            return model
            }
            : [MovieModel([:])]
        return [MovieModel([:])]
    }
}
