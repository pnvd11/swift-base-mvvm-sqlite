//
//  MoviesListVM.swift
//  iiiiii
//
//  Created by Nik on 13/03/2024.
//

import Foundation

final class MoviesListVM {
    let mvRepo: MoviesListRepozitory
    let mvSerVice: MovieListService
    init() {
        mvRepo = MoviesListRepozitory()
        mvSerVice = MovieListService()
    }
    
    func fetchMovies(_ query: String, completion: @escaping  (Result<[MoviesResponseDTO.Movie], DataTransferError>) -> Void) -> Bool {
        var resBool = false
        let mvService = MovieListService()
        let res = mvService.getMovies("Superman", completion: { result in
            // handle result
            switch result {
            case .success(let movies):
                let res = movies
                completion(.success(res))
                resBool = true
            case .failure( let err):
//                let err = err.localizedDescription
                completion(.failure(err))
                resBool = false
            }
        })
        
        return resBool
    }
    func insert(_ from: [MovieModel]) throws -> Bool {
        // insert
        var res = false
        do {
             res = try mvRepo.insert(from)            
        } catch {
            print(error.localizedDescription)
        }
        return res
    }
    
    func query(_ from: MovieModel, id: Int32) -> [MovieModel] {
        
    let resArr = mvRepo.query(from, id: id)
        resArr.forEach({ item in
            #if DEBUG
                print("iii qr: \(item.id) \(item.name) \(item.idNum)")
            #endif
        })
        return resArr
    }
    
    func update(_ from: MovieModel, conditionDic: [String: Any] ) throws -> Bool  {
        var res = false
        do {
            res = try mvRepo.update(from, conditionDic: conditionDic)
            
        } catch  {
            print("*** update err: ")
        }
        return res
    }
    
    func delete(_ from: MovieModel, id: Int32) throws -> Bool  {
        var res = false
        do {
            res = try mvRepo.delete(from, id: id)
            
        } catch  {
            print("*** del err: ")
        }
        return res
    }
}
