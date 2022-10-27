//
//  EditView-ViewModel.swift
//  BucketList
//
//  Created by RqwerKnot on 24/03/2022.
//

import Foundation

extension EditView2 {
    
    @MainActor class ViewModel: ObservableObject {
        
        // an enum for loading state of wikipedia content:
        enum LoadingState {
            case loading, loaded, failed
        }
        @Published var loadingState = LoadingState.loading
        
        @Published private(set) var pages = [Page]()
        
        var location: Location
        
        var newLocation: Location {
            // create the new location:
            var newLocation = location
            newLocation.id = UUID() // change UUID if you want SwiftUI to recognize that an item in the collection 'locations' has effectively changed and trigger a Map View refresh. This behavior is altered by our custom implementation of Equatable
            // alternatively, we could create a new location instance from scratch and copy only the properties that need being changed from the original location passed to the View
            newLocation.name = name
            newLocation.description = description
            
            return newLocation
        }
        
        
        @Published var name: String
        @Published var description: String
        
        init(location: Location) {
            self.location = location
            
            _name = Published(initialValue: location.name)
            _description = Published(initialValue: location.description)
        }
        
        func fetchNearbyPlaces() async {
            let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.coordinate.latitude)%7C\(location.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
            
            // the URL is using a String using an interpolation, it's safer to not force unwrap
            guard let url = URL(string: urlString) else {
                print("Bad URL: \(urlString)")
                return
            }
            
            // network request:
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                // we got some data back!
                let items = try JSONDecoder().decode(Result.self, from: data)
                
                // success – convert the array values to our pages array
                // can use a custom inline closure for sorting pages:
                //pages = items.query.pages.values.sorted { $0.title < $1.title }
                // or rather use a natural sorting order if the Type conforms to Comparable:
                pages = items.query.pages.values.sorted()
                loadingState = .loaded
            } catch {
                // if we're still here it means the request failed somehow
                loadingState = .failed
            }
        }
    }
}
