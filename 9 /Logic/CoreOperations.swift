
//  9
//
//  Created by GarrettWoodside
//



import Foundation


//All operations that are available to use in the game
// serlialize enums into swift data as Strings to pass them around the UI
enum OperationID: String, CaseIterable, Hashable {

   //reducers
    case digitSum
    case digitSquareSum 
    case digitDifference
    case mod10
    case mod9
    case dropLastDigit

 //arithmetic and control
    case add1
    case subtract1
    case add9Once
    case multiplyBy2

    //divide
    case divideBy2
    case divideBy3

//tranform
    case reverseDigits
    case rotateDigits
}

//pairs the identifier with the actual logic
//returning nil from apply tells us that the move is illegal
struct Operation {
    //the identifier for storage
    let id: OperationID
    //the name that is actually displayed on the button
    let name: String
    // the current number and returns either the new number or nil if an operation is invalid
    let apply: (Int) -> Int?
}


// Central registry for all supported operations.
// Digit-based operations always operate on `abs value'
//Operations never clamp magnitude
//Operations never enforce usage limits
enum Operations {

    static let baseline: [OperationID: Operation] = [

        
        .mod9: Operation(
            id: .mod9,
            name: "Mod 9",
            apply: { n in
                let v = abs(n)
                let r = v % 9
                return r == 0 ? 9 : r
            }
        ),

        .digitSum: Operation(
            id: .digitSum,
            name: "Digit Sum",
            apply: { n in
                String(abs(n))
                    .compactMap { $0.wholeNumberValue }
                    .reduce(0, +)
            }
        ),

        .digitSquareSum: Operation(
            id: .digitSquareSum,
            name: "Digit² Sum",
            apply: { n in
                String(abs(n))
                    .compactMap { $0.wholeNumberValue }
                    .map { $0 * $0 }
                    .reduce(0, +)
            }
        ),

        .digitDifference: Operation(
            id: .digitDifference,
            name: "Digit Diff",
            apply: { n in
                let digits = String(abs(n)).compactMap { $0.wholeNumberValue }
                guard let first = digits.first else { return nil }
                return digits.dropFirst().reduce(first) { abs($0 - $1) }
            }
        ),

        .mod10: Operation(
            id: .mod10,
            name: "Mod 10",
            apply: { n in abs(n) % 10 }
        ),

        .dropLastDigit: Operation(
            id: .dropLastDigit,
            name: "Drop Digit",
            apply: { n in
                let v = abs(n)
                return v >= 10 ? v / 10 : nil
            }
        ),

        .add1: Operation(
            id: .add1,
            name: "+1",
            apply: { n in n + 1 }
        ),

        .subtract1: Operation(
            id: .subtract1,
            name: "−1",
            apply: { n in n - 1 }
        ),

        .add9Once: Operation(
            id: .add9Once,
            name: "+9",
            apply: { n in n + 9 }
        ),

        .multiplyBy2: Operation(
            id: .multiplyBy2,
            name: "×2",
            apply: { n in n * 2 }
        ),


        .divideBy2: Operation(
            id: .divideBy2,
            name: "÷2",
            apply: { n in n % 2 == 0 ? n / 2 : nil }
        ),

        .divideBy3: Operation(
            id: .divideBy3,
            name: "÷3",
            apply: { n in n % 3 == 0 ? n / 3 : nil }
        ),
        
        
        .rotateDigits: Operation(
                id: .rotateDigits,
                name: "Rotate Digits",
                apply: { n in
                    let v = abs(n)
                    let digits = String(v)
                    guard digits.count > 1 else { return nil }

                    let rotated = digits.dropFirst() + digits.prefix(1)
                    return Int(rotated)
                }
            ),


        .reverseDigits: Operation(
            id: .reverseDigits,
            name: "Reverse",
            apply: { n in
                let reversed = String(abs(n)).reversed()
                return Int(reversed.map(String.init).joined())
            }
        )
    ]
}

//operation classifications

extension OperationID {

//helps the puzzle generator 'balance levels'
    enum Kind {
        case reducer        // collapses magnitude / information
        case amplifier     // increases magnitude
        case transformer   // restructures digits
        case precision     // fine-grained control
    }
//determines the category for the operation
    var kind: Kind {
        switch self {

        // Reducers
        case .digitSum,
             .digitSquareSum,
             .digitDifference,
             .mod10,
             .mod9,
             .dropLastDigit,
             .divideBy2,
             .divideBy3:
            return .reducer

        // Amplifiers
        case .add1,
             .multiplyBy2,
             .add9Once:
            return .amplifier

        // Precision
        case .subtract1:
            return .precision

        // Structural transforms
        case .reverseDigits,
                .rotateDigits:
            return .transformer
        }
    }
}
