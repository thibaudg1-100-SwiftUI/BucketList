//
//  ContentView.swift
//  BucketList
//
//  Created by RqwerKnot on 21/03/2022.
//

import SwiftUI
import MapKit

struct ContentView: View {
    // extracted to the view model:
    //    @State private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
    //
    //    @State private var locations = [Location]()
    //
    //    @State private var selectedPlace: Location? // is nil at first and then contains the tapped location
    
    // added to use the view model:
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        
        ZStack {
            if viewModel.isUnlocked {
                Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.locations, annotationContent: { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        VStack {
                            Image(systemName: "star.circle")
                                .resizable() // mandatory to use '.frame()' on Image
                            // alternatively use '.font()' for a SF Symbol Image
                                .frame(width: 44, height: 44)
                            // 44 is kind of a magic number for minimum size of interactive objects that fit the different sizes of iOS devices
                                .foregroundColor(.mint)
                                .background(.white)
                                .clipShape(Circle())
                            
                            Text(location.name)
                                .fixedSize()
                        }
                        .onTapGesture {
                            viewModel.selectedPlace = location
                        }
                    }
                })
                .ignoresSafeArea()
                
                Circle()
                    .fill(.blue)
                    .opacity(0.3)
                    .frame(width: 32, height: 32)
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Button {
                            viewModel.showAllLocations = true
                        } label: {
                            Image(systemName: "list.star")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(.black.opacity(0.75))
                                .clipShape(Circle())
                                .padding(.leading)
                        }
                        
                        Spacer()
                        
                        Button {
                            viewModel.addLocation()
                        } label: {
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(.black.opacity(0.75))
                                .clipShape(Circle())
                                .padding(.trailing)
                        }
                    }
                }
                
            } else {
                Button("Unlock your places") {
                    viewModel.authenticate()
                }
                .padding()
                .background(.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
        }
        .sheet(item: $viewModel.selectedPlace) { place in
            // no need to unwrap the optional 'selectedPlace', because Swift gives us a non-optional 'place':
            //Text(place.name)
            
            // using the onSave trailing closure allows us to bring in the new location from EditView along with properties and functionnality of the parent view (here ContentView):
            EditView2(location: place) { newLocation in
                viewModel.updateLocation(location: newLocation)
            }
        }
        .sheet(isPresented: $viewModel.showAllLocations, content: {
            List {
                ForEach(viewModel.locations) { location in
                    Text(location.name)
                }
                .onDelete { indexSet in
                    viewModel.deleteLocations(at: indexSet)
                }
            }
            
        })
        .alert("Authentication failed", isPresented: $viewModel.showFailedAuthAlert) {
            Button("Retry") {
                // retry authentication
                viewModel.authenticateWithPIN()
            }
            Button("Cancel", role: .cancel){}
        } message: {
            Text(viewModel.authErrorMessage)
        }
        
    }
    
    // initializer required to avoid Swift 6 error where it's not possible to assign a default value using global main actor because init does not run async:
    //    init() {
    //        _viewModel = StateObject(wrappedValue: ViewModel())
    //    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 13")
    }
}
