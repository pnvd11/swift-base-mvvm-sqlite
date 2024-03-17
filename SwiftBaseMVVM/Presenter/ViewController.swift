//
//  ViewController.swift
//  iiiiii
//
//  Created by Nik on 03/03/2024.
//

import UIKit
import SQLite3

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // db
        let sqliteVersion = sqlite3_libversion()
        print("sqliteVersion: \(String(describing: sqliteVersion))")
        let sqliteVersionString = NSString(utf8String: sqliteVersion! )
        print("sqliteVersionString: \(String(describing: sqliteVersionString))")        
        // rm db.
//        destroyPart2Database()
        let mvVC = MoviesListVC().viewDidLoad()
    }


}

