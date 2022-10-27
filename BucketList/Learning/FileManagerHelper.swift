//
//  FileManagerHelper.swift
//  BucketList
//
//  Created by RqwerKnot on 21/03/2022.
//

import Foundation

extension FileManager {
    
    func decode<T: Codable>(document: String) -> T {
        
        // find all possible documents directories for this user (and for this app)
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let path = paths[0]
        let url = path.appendingPathComponent(document)
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(document) from FileManager")
        }
        
        let decoder = JSONDecoder()
        
        guard let decoded = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(document) from FileManager")
        }
        
        return decoded
    }
}
