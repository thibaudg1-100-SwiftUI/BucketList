//
//  MapsAnnotations.swift
//  BucketList
//
//  Created by RqwerKnot on 21/03/2022.
//

import SwiftUI
import MapKit

// defining a new data type that contains your location
// Whatever new data type you create to store locations, it must conform to the Identifiable protocol so that SwiftUI can identify each map marker uniquely
struct Location1: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct MapsAnnotations: View {
    // the original Coordinate Region of the map, it will be updated when user interacts with the map
    @State private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.5, longitude: -0.12), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    
    // creating an array of those containing all your locations:
    let locations = [
        Location1(name: "Buckingham Palace", coordinate: CLLocationCoordinate2D(latitude: 51.501, longitude: -0.141)),
        Location1(name: "Tower of London", coordinate: CLLocationCoordinate2D(latitude: 51.508, longitude: -0.076))
    ]
    
    let map = SwitchMap.map4
    
    var body: some View {
        // That has a two-way binding to the region so it can be updated as the user moves around the map, and when the app runs you should see London right there on your map
        NavigationView {
            // different kind of maps from simplest to more advanced:
            switch map {
            case .map1:
                Map(coordinateRegion: $mapRegion, annotationItems: locations) { location in
                    // A simple marker with no interactivity:
                    MapMarker(coordinate: location.coordinate, tint: .mint)
                }
                
            case .map2:
                Map(coordinateRegion: $mapRegion, annotationItems: locations) { location in
                    // An annotation where you can provide a custom View
                    MapAnnotation(coordinate: location.coordinate) {
                        Circle()
                            .stroke(.mint, lineWidth: 3)
                            .frame(width: 44, height: 44)
                    }
                }
                
            case .map3:
                Map(coordinateRegion: $mapRegion, annotationItems: locations) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        // You can add common SwiftUI modifier:
                        Circle()
                            .stroke(.mint, lineWidth: 3)
                            .frame(width: 44, height: 44)
                            .onTapGesture {
                                print("Tapped on \(location.name)")
                            }
                    }
                }
                
            case .map4:
                Map(coordinateRegion: $mapRegion, annotationItems: locations) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        // Integrating a Nav Link within a Nav View:
                        NavigationLink {
                            Text(location.name)
                        } label: {
                            Circle()
                                .stroke(.mint, lineWidth: 3)
                                .frame(width: 44, height: 44)
                        }
                    }
                }
                .navigationTitle("London Explorer")
            }
                
        }
    }
}

enum SwitchMap {
    case map1, map2, map3, map4
}

struct MapsAnnotations_Previews: PreviewProvider {
    static var previews: some View {
        MapsAnnotations()
            .previewDevice("iPhone 13")
    }
}
