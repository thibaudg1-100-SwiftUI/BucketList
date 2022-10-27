//
//  MakeItComparable.swift
//  BucketList
//
//  Created by RqwerKnot on 21/03/2022.
//

import SwiftUI

struct User: Identifiable, Comparable {
    let id = UUID()
    let firstName: String
    let lastName: String
    
    // simply add a '<' function to get '<' and '>' functionality (ie, Comparison) on your type 'User'
    //  the method must be marked as static, which means it’s called on the User struct directly rather than a single instance of the struct
    // the method is just called <, which is the “less than” operator. It’s the job of the method to decide whether one user is “less than” (in a sorting sense) another, so we’re adding functionality to an existing operator. This is called operator overloading, and it can be both a blessing and a curse.
    static func <(lhs: User, rhs: User) -> Bool {
        lhs.lastName < rhs.lastName  //  lhs and rhs are coding conventions short for “left-hand side” and “right-hand side”, and they are used because the < operator has one operand on its left and one on its righ
    }
    // this method must return a Boolean, which means we must decide whether one object should be sorted before another. There is no room for “they are the same” here – that’s handled by another protocol called Equatable.
}

struct MakeItComparable: View {
    // without conformance to 'Comparable', you must pass a particular closure for comparison:
    let users = [
        User(firstName: "Arnold", lastName: "Rimmer"),
        User(firstName: "Kristine", lastName: "Kochanski"),
        User(firstName: "David", lastName: "Lister"),
    ].sorted {
        $0.firstName < $1.firstName
    }
    
    // You should better add conformance on the type, so that you isolate your data model functionality from your view
    let users2 = [
        User(firstName: "Arnold", lastName: "Rimmer"),
        User(firstName: "Kristine", lastName: "Kochanski"),
        User(firstName: "David", lastName: "Lister"),
    ].sorted()
    
    
    var body: some View {
        VStack {
            List(users) { user in
                        Text("\(user.lastName), \(user.firstName)")
                    }
            
            List(users2) { user in
                        Text("\(user.lastName), \(user.firstName)")
                    }
        }
    }
}

struct MakeItComparable_Previews: PreviewProvider {
    static var previews: some View {
        MakeItComparable()
    }
}
