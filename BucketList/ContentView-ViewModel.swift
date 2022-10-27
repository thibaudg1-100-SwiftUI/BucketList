//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by RqwerKnot on 23/03/2022.
//

import Foundation
import MapKit
import LocalAuthentication

// this is not just a view model for everyone to use, but dedicated to the ContentView, hence the extension:
extension ContentView {
    // @MainActor for run everything inside on the main Actor, place where the UI updates happen as well
    // We didn't use this '@MainActor' in our previous projects because SwiftUI knows that when we use @StateObject, @ObservedObject in our views it silently run those objects on the Main Actor
    // In this case the @MainActor attribute is to force running on the main actor in case the class is used/called from another class or place in the program
    // When using a class conforming to ObservableObject, you should use @MainActor attribute:
    @MainActor class ViewModel: ObservableObject {
        
        @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
        
        // to prevent this published property to be writeable from outside, declare it as 'private(set)', and write a function inside the class to work on this property:
        @Published private(set) var locations: [Location] // don't need empty collection initialization as default-value since the class init take care of that
        
        @Published var selectedPlace: Location? // is nil at first and then contains the tapped location
        
        // the path to the document that store persistently locations:
        // declare it once as a constant so that we're sure the load and save functions use the same path...
        let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedPlaces")
        
        // new state in our view model that tracks whether the app is unlocked or not:
        @Published var isUnlocked = false
        
        // State property that tracks if the alert for failed auth is shown:
        @Published var showFailedAuthAlert = false
        @Published var authErrorMessage = ""
        
        // State property to track if a list of all pinned locations is shown:
        @Published var showAllLocations = false
        
        // init the view model with persistently stored Locations
        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                print("Couldn't retrieve SavedPlaces. We'll use an empty collection")
                locations = []
            }
        }
        
        // a dedicated authenticate() method that handles all the biometric work:
        func authenticate() {
            let context = LAContext()
            var error: NSError?
            
            // from here, we are calling iOS system process that handle biometrics authentication on our behalf
            // this process is done outside our app, and so it's not done on the Main Actor
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate yourself to unlock your places."
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    // When iOS is done doing the biometrics auth, it calls our completion closure that happens in the background thread where iOS process was being executed
                    // but changing a State property should be done on the Main Actor so that SwiftUI refresh the views properly:
                    if success {
                        // you could do that to force using the MainActor, which means:
                        // "start a new background task, then immediately use that background task to queue up some work on the main actor"
                        //                        Task {
                        //                                await MainActor.run {
                        //                                    self.isUnlocked = true
                        //                                }
                        //                            }
                        // but we can do better: rather than bouncing to a background task then back to the main actor, the new task will immediately start running on the main actor
                        Task { @MainActor in
                            self.isUnlocked = true
                        }
                        //self.isUnlocked = true // will throw runtime error because change shouldn't be published form a background thread
                    } else {
                        // error: handle gracefully retrying authentication
                        Task { @MainActor in
                            self.authErrorMessage = authenticationError?.localizedDescription ?? ""
                            self.showFailedAuthAlert = true
                        }
                    }
                }
            } else {
                // no biometrics: fallback to default authentication with PIN code for example:
                print(error?.localizedDescription ?? "No error localized description available")
                authenticateWithPIN()
            }
        }
        
        func authenticateWithPIN() {
            let context = LAContext()
            var error: NSError?
            
            // '.deviceOwnerAuthentication' will check for any kind of authentication method, falling back on device passcode as a last resort:
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                let reason = "Please authenticate yourself to unlock your places."
                
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authError in
                    if success {
                        Task { @MainActor in
                            self.isUnlocked = true
                        }
                    } else {
                        Task { @MainActor in
                            self.authErrorMessage = authError?.localizedDescription ?? ""
                            self.showFailedAuthAlert = true
                        }
                    }
                }
            }
            else {
                print("Authentication failed big time:")
                print(error?.localizedDescription ?? "No error localized description available")
            }
            
        }
        
        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                // Writing data atomically means that iOS writes to a temporary file then performs a rename.
                // This stops another piece of code from reading the file part-way through a write.
                try data.write(to: savePath, options: [.atomic, .completeFileProtection]) // with encryption
            } catch {
                print("Unable to save data")
            }
        }
        
        func addLocation() {
            let newLocation = Location(id: UUID(), name: "New location", description: "", latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude)
            
            locations.append(newLocation)
            save()
        }
        
        func updateLocation(location: Location) {
            guard let selectedPlace = selectedPlace else {
                return
            }
            
            
            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = location
            }
            
            save()
        }
        
        func deleteLocations(at offsets: IndexSet) {
            locations.remove(atOffsets: offsets)
            
            save()
        }
        
    }
}
