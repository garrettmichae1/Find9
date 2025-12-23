
//  9
//
//  Created by GarrettWoodside
//


import Foundation

//procedural generation utility that creates the startingn nums for levels.
struct StartNumberGenerator {

    //generation pipeline
    //1) walk wasy from the target number of 9
    //scale that seed into a specific class  large, small, etc
    //then ensure the result is not trivial or way too easy

    static func generate(
        using operations: [OperationID],
        sequenceIndex: Int,          // drives cycling
        minSteps: Int = 4,
        maxSteps: Int = 7,
        target: Int = 9
    ) -> Int {
        precondition(!operations.isEmpty, "Operations list must not be empty")

        // 1. Reverse walk from target
        //prduces a num specific to the operation set
        var value = target
        let steps = Int.random(in: minSteps...maxSteps)

        for _ in 0..<steps {
            //only apply operations valid for the current num
            guard let opID = operations.randomElement(),
                  let op = Operations.baseline[opID],
                  let next = op.apply(value) else {
                continue
            }
            value = next
        }

        // 2. Apply deterministic magnitude + sign case
        //to prevent every level from looking the same, we froce the number into specfic classes based on the level index
        //big pos, small pos, small neg, big neg ( Always )
        let magnitudeCase = magnitudeCycle[sequenceIndex % magnitudeCycle.count]
        value = applyMagnitudeCase(magnitudeCase, to: value)

        // 3. Enforce non trivial start (never 0 or 9)
        //ensures the game is not too boring
        value = normalize(value, target: target)
//clamp to keep the UI at a max of 5 digits ( order )
        return clamp(value)
    }
//defines the class of the starting num
    private enum MagnitudeCase {
        case bigPositive
        case smallPositive
        case smallNegative
        case bigNegative
    }

    //fixed cycle pattern
    //prevents the same puzzles back anf forth
    private static let magnitudeCycle: [MagnitudeCase] = [
        .bigPositive,
        .smallPositive,
        .smallNegative,
        .bigNegative
    ]

    // projects the seed value into the target magnitude.

    private static func applyMagnitudeCase(
        _ kind: MagnitudeCase,
        to value: Int
    ) -> Int {

        switch kind {
//10k to 99k
        case .bigPositive:
            let scale = Int.random(in: 10_000...99_999)
            return abs(value) * scale / max(abs(value), 1)
//under 1k
        case .smallPositive:
            return abs(value) % 1_000
//under - 1k
        case .smallNegative:
            return -(abs(value) % 1_000)
//-10k to -99k
        case .bigNegative:
            let scale = Int.random(in: 10_000...99_999)
            return -(abs(value) * scale / max(abs(value), 1))
        }
    }

 //final safety check to ensure the puzzle is playable and non trivial
    private static func normalize(_ value: Int, target: Int) -> Int {
        let absValue = abs(value)
        let sign = value >= 0 ? 1 : -1

        // Never allow zero
        if absValue == 0 {
            return sign * Int.random(in: 21...99)
        }

        // Never allow target itself
        if absValue == target {
            return sign * (target + Int.random(in: 12...25))
        }

        // avoid trivial ranges
        if absValue <= 20 {
            return sign * Int.random(in: 21...99)
        }

        return value
    }


//caps UI at -99.999k to 99.999k to prevent overflow
    private static func clamp(_ n: Int) -> Int {
        max(min(n, 99_999), -99_999)
    }
}
