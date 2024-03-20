//
//  searchMoviesService.swift
//  iiiiii
//
//  Created by Nik on 12/03/2024.
//

import Foundation

extension APIEndPoints {
    static func getMovies(_ movieRequest: MoviesRequestDTO) -> Endpoint<MoviesResponseDTO> {
        return Endpoint(path: "search/movie", method: .get, headerParameters: ["Content-Type": "application/json"], queryParametersEncodable: movieRequest)
    }
}

class MovieListService {
    func getMovies(_ query: String, completion: @escaping  (Result<[MoviesResponseDTO.Movie], DataTransferError>) -> Void)  {
//        var res = [MoviesResponseDTO.Movie(title: Constants.emptyString, overview: Constants.emptyString, posterPath: Constants.emptyString)]
        let endpoint = APIEndPoints.getMovies(MoviesRequestDTO(query: query, page: 1))
        AppDIContainer.shared.apiDataTransferService.request(with: endpoint) { result in
                        switch result {
                        case .success(let responseDTO):
                            completion(.success(responseDTO.movies))
                        case .failure(let error):
                            completion(.failure(error))
                            #if DEBUG
                            print("** get mv err: \(error.localizedDescription) ")
                            #endif
                        }
                    }        

    }
}
