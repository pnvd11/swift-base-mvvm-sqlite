//
//  MoviesListVC.swift
//  iiiiii
//
//  Created by Nik on 13/03/2024.
//

import Foundation
import UIKit

class MoviesListVC: UIViewController {
    
    private var vm: MoviesListVM = MoviesListVM()
    override func viewDidLoad() {
        
        // api
        let resAPI = vm.fetchMovies("Superman") { result in
            #if DEBUG
            print("ftch res \(result)")
            #endif
        }
        
        // insert
        do {
            
        let resInsert = try vm.insert([MovieModel(["id": 1, "name": "Ray", "idNum": 35]), MovieModel(["id": 2, "name": "Ray2", "idNum": 45])])
            
        } catch {
            print(error.localizedDescription)
        }
        
        // query
        let resQr = vm.query(MovieModel([:]), id: 1)
        
        // update
        
        do {
            let udRes = try  vm.update(MovieModel(["name":"iiiiii108"]), conditionDic: ["id": 1 as Int32])
        } catch  {
            print(error.localizedDescription)
        }
        
        
    }
    
}
