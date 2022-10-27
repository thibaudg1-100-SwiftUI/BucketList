//
//  OperatorOverloading.swift
//  BucketList
//
//  Created by RqwerKnot on 28/03/2022.
//

import SwiftUI

// This is called operator overloading, and it’s what allows us to add two integers or join two strings using the same + operator. You can define your own operators if you want, but it’s also easy to extend existing operators to do new things.

// As an example, we could add some extensions to Int that lets us multiply an Int and a Double – something that Swift doesn’t allow by default, which can be annoying:
extension Int {
    static func *(lhs: Int, rhs: Double) -> Double {
        return Double(lhs) * rhs
    }
    
    // Pay particular attention to the parameters: it uses an Int as the left-hand operand and a Double as the right-hand operand, which means it won’t work if you swap those two around. So, if you want to be complete – if you want either order to work – you need to define the method twice.
}

// However, if you want to be really complete then extending Int is the wrong choice: we should go up to a protocol that wraps Int as well as other integer types such as the Int16 we used with Core Data.

extension BinaryInteger {
    static func *(lhs: Self, rhs: Double) -> Double {
        return Double(lhs) * rhs
    }
    
    static func *(lhs: Double, rhs: Self) -> Double {
        return lhs * Double(rhs)
    }
}

// If you were wondering, there is a reason Swift doesn’t enable these operators for us: it’s not guaranteed to be as accurate as you might hope. As a simple example, try this:

struct OperatorOverloading: View {
    
    let exampleInt: Int64 = 50_000_000_000_000_001
    
    var result : Double { exampleInt * 1.0 }
    
    var body: some View {
        VStack {
            Text("\(exampleInt)")
            
            // String(format:_:) call asks for the number to be printed with no decimal places:
            Text(String(format: "%.0f", result))
            
            Text("\(result)")
        }
        
    }
}

struct OperatorOverloading_Previews: PreviewProvider {
    static var previews: some View {
        OperatorOverloading()
    }
}
