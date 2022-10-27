//
//  UsingLocalBiometrics.swift
//  BucketList
//
//  Created by RqwerKnot on 22/03/2022.
//

import SwiftUI
import LocalAuthentication

struct UsingLocalBiometrics: View {
    
    @State private var isUnlocked = false
    
    var body: some View {
        VStack {
            if isUnlocked {
                Text("Unlocked")
            } else {
                Text("Locked")
            }
        }
        .onAppear(perform: authenticate)
    }
    
    func authenticate() {
        // Create instance of LAContext, which allows us to query biometric status and perform the authentication check
        let context = LAContext()
        //  Objective-C uses a special class called NSError. We need to be able to pass that into the function and have it changed inside the function rather than returning a new value
        var error: NSError?
        
        // Ask that context whether it’s capable of performing biometric authentication – this is important because iPod touch has neither Touch ID nor Face ID
        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it:
            let reason = "We need to unlock your data." // required for TouchID, for FAceID it's managed in the info.plist options directly
            // If biometrics are possible, then we kick off the actual request for authentication, passing in a closure to run when authentication completes
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                // When the user has either been authenticated or not, our completion closure will be called and tell us whether it worked or not, and if not what the error was
                // authentication has now completed
                if success {
                    // authenticated successfully:
                    isUnlocked = true
                } else {
                    // there was a problem (user hit Cancel, failed ID because of face mask or glove or ...)
                    print("Biometrics available on device, but authentication failed")
                    print(error?.localizedDescription ?? "")
                }
            }
        } else {
            // no biometrics on this device, or user has not enrolled on FaceID nor TouchID
            print("No biometrics on this device, or user hasn't enrolled in any of them")
            print(error?.localizedDescription ?? "")
        }
        
    }
}

struct UsingLocalBiometrics_Previews: PreviewProvider {
    static var previews: some View {
        UsingLocalBiometrics()
            
    }
}
