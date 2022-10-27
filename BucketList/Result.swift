//
//  Result.swift
//  BucketList
//
//  Created by RqwerKnot on 23/03/2022.
//

import Foundation

// Wikipedia’s API sends back JSON data:
struct Result: Codable {
    let query: Query
}

struct Query: Codable {
    let pages: [Int: Page]
}

struct Page: Codable, Comparable {
    // Adding Comparable conformance let us describle a natural way to compare and sort different instances of Page, and add '.sorted()' functionality to any collection of Page instances:
    static func < (lhs: Page, rhs: Page) -> Bool {
        lhs.title < rhs.title
    }
    
    let pageid: Int
    let title: String
    let terms: [String: [String]]?
    
    
    // Wikipedia’s JSON data does contain a description, but it’s buried: the terms dictionary might not be there, and if it is there it might not have a description key, and if it has a description key it might be an empty array rather than an array with some text inside.
    // We don’t want this mess to plague our SwiftUI code, so again the best thing to do is make a computed property that returns the description if it exists, or a fixed string otherwise:
    var description: String {
        terms?["description"]?.first ?? "No further information"
    }
}

/*
 Wikipedia’s API sends back JSON data in a precise format, so we need to do a little work to define Codable structs capable of storing it all. The structure is this:

     The main result contains the result of our query in a key called “query”.
 
     Inside the query is a “pages” dictionary, with page IDs as the key and the Wikipedia pages themselves as values.
 
     Each page has a lot of information, including its coordinates, title, terms, and more.

 */
