//
//  APICaller.swift
//  Pagination
//
//  Created by meng on 2021/06/21.
//

import Foundation

class APICaller {
    
    var isPagination = false
    
    func fetchData(pagination: Bool = false, completion: @escaping (Result<[String], Error>) -> Void){
        
        if pagination {
            isPagination = true
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + (pagination ? 3 : 2), execute: {
            let originalDate = [
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google"
            ]
            
            let newData = [
                "banana", "oranges", "grapes", "Food"
            ]
            completion(.success( pagination ? newData : originalDate))
            
            if pagination {
                self.isPagination = false
            }
        })
    }
}
