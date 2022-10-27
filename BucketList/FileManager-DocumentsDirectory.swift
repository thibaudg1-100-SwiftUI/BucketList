//
//  FileManager-DocumentsDirectory.swift
//  BucketList
//
//  Created by RqwerKnot on 23/03/2022.
//

import Foundation


// Previously I showed you how to find our app’s documents directory with a reusable function, but here we’re going to package it up as an extension on FileManager for easier access in any project:
extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
