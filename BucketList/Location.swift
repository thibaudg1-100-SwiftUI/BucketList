//
//  Location.swift
//  BucketList
//
//  Created by RqwerKnot on 23/03/2022.
//

import Foundation
import CoreLocation

struct Location: Identifiable, Codable, Equatable {
    // every property below conforms to Codable and Equatable by design, so the new Struct 'Location' conforms as well "for free":
    
    var id: UUID // must be a variable if we intend to change the UUID of an existing Location
    var name: String
    var description: String
    let latitude: Double // this will actually be a CLLocationDegress which is typealias for Double, but using Double will alow "free" Codable conformance
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    // When possible, add a static example to your custom Struct, so that previewing is your layout is easier:
    static let example = Location(id: UUID(), name: "Buckingham Palace", description: "Where Queen Elizabeth lives with her dorgis.", latitude: 51.501, longitude: -0.141)
    
    // Custom implementation of Equatable (this is not mandatory if all stored properties already conform to Equatable):
    //  Behind the scenes, Swift will write this function for us by comparing every property against every other property, which is rather wasteful – all our locations already have a unique identifier, so if two locations have the same identifier then we can be sure they are the same without also checking the other properties.
    // So, we can save a bunch of work by writing our own == function to Location, which compares two identifiers and nothing else:
    static func ==(lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}
