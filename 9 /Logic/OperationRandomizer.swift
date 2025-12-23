//  9
//
//  Created by GarrettWoodside
//




import Foundation


// a utility class to generate a balanced set of operations for a new puzzle
//instead of purely random selection each set of operations must include a raiser and a reducer operator
struct OperationRandomizer {

    //generates valid and non trivial set of operations for a starting number.
    static func generate(startNumber: Int) -> [OperationID] {

        let raisers: [OperationID] = [
            .add1,
            .multiplyBy2
        ]

        let reducers: [OperationID] = [
            .digitSum,
            .digitSquareSum,
            .digitDifference,
            .mod10,
            .mod9,
            .dropLastDigit,
            .divideBy2,
            .divideBy3
        ]

        let wildcards: [OperationID] = [
            .reverseDigits,
            .rotateDigits,
            .subtract1
        ]
//loop into a valid config is found that passes all safety checks
        while true {
            var selected = Set<OperationID>()

            // 1. Pick one raiser
            if let raiser = raisers.randomElement() {
                selected.insert(raiser)
            }

            // 2. Pick one reducer
            if let reducer = reducers.randomElement() {
                selected.insert(reducer)
            }

            // 3. Fill remaining slots
            let remainingPool =
                (raisers + reducers + wildcards)
                    .filter { !selected.contains($0) }

            let needed = 4 - selected.count
            selected.formUnion(remainingPool.shuffled().prefix(needed))

          

            // Avoid trivial mod 10 win
            if selected.contains(.mod10), startNumber % 10 == 9 {
                continue
            }

          

            // Ensure exactly 4 unique operations
            guard selected.count == 4 else { continue }

            return Array(selected)
        }
    }
}
