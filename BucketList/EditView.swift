//
//  EditView.swift
//  BucketList
//
//  Created by RqwerKnot on 23/03/2022.
//

import SwiftUI

// modified EditView with MVVM software architectural design:
struct EditView2: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel: ViewModel
    
    
    var onSave: (Location) -> Void // this is a completion handler:
    // a closure that are called once we are done editing the location
    
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Place name", text: $viewModel.name)
                    TextField("Description", text: $viewModel.description)
                }
                
                Section("Nearby…") {
                    switch viewModel.loadingState {
                    case .loaded:
                        ForEach(viewModel.pages, id: \.pageid) { page in
                            // Notice how we can use + to add text views together? This lets us create larger text views that mix and match different kinds of formatting:
                            Text(page.title)
                                .font(.headline)
                            + Text(": ") +
                            Text(page.description)
                                .italic()
                        }
                    case .loading:
                        Text("Loading…")
                    case .failed:
                        Text("Please try again later.")
                    }
                }
            }
            .navigationTitle("Place details")
            .toolbar {
                Button("Save") {
                    // call the completion handler with the new location
                    onSave(viewModel.newLocation)
                    // dismiss the sheet:
                    dismiss()
                }
            }
            .task {
                await viewModel.fetchNearbyPlaces()
            }
        }
    }
    
    init(location: Location, onSave: @escaping (Location) -> Void) {

        _viewModel = StateObject(wrappedValue: ViewModel(location: location))
        
        self.onSave = onSave
    }
    
   
}

// original EditView without MVVM changes:
struct EditView: View {
    // an enum for loading state of wikipedia content:
    enum LoadingState {
        case loading, loaded, failed
    }
    @State private var loadingState = LoadingState.loading
    @State private var pages = [Page]()
    
    @Environment(\.dismiss) var dismiss
    var location: Location
    var onSave: (Location) -> Void // this is a completion handler:
    // a closure that are called once we are done editing the location
    
    @State private var name: String
    @State private var description: String
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Place name", text: $name)
                    TextField("Description", text: $description)
                }
                
                Section("Nearby…") {
                    switch loadingState {
                    case .loaded:
                        ForEach(pages, id: \.pageid) { page in
                            // Notice how we can use + to add text views together? This lets us create larger text views that mix and match different kinds of formatting:
                            Text(page.title)
                                .font(.headline)
                            + Text(": ") +
                            Text(page.description)
                                .italic()
                        }
                    case .loading:
                        Text("Loading…")
                    case .failed:
                        Text("Please try again later.")
                    }
                }
            }
            .navigationTitle("Place details")
            .toolbar {
                Button("Save") {
                    // create the new location:
                    var newLocation = location
                    newLocation.id = UUID() // change UUID if you want SwiftUI to recognize that an item in the collection 'locations' has effectively changed and trigger a Map View refresh. This behavior is altered by our custom implementation of Equatable
                    // alternatively, we could create a new location instance from scratch and copy only the properties that need being changed from the original location passed to the View
                    newLocation.name = name
                    newLocation.description = description
                    
                    // call the completion handler with the new location
                    onSave(newLocation)
                    // dismiss the sheet:
                    dismiss()
                }
            }
            .task {
                await fetchNearbyPlaces()
            }
        }
    }
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        // Remember, @escaping means the function is being stashed away for user later on, rather than being called immediately, and it’s needed here because the onSave function will get called only when the user presses Save.
        self.location = location
        self.onSave = onSave
        
        // This uses the same underscore approach we used when creating a fetch request inside an initializer, which allows us to create an instance of the property wrapper not the data inside the wrapper:
        _name = State(initialValue: location.name)
        _description = State(initialValue: location.description)
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

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView2(location: .example, onSave: {_ in })
        // passes a minimal empty closure for 'onSave' because it's irrelevant for Previews
    }
}
