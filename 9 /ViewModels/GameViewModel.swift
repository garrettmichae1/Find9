//  9
//
//  Created by GarrettWoodside
//


import Foundation
import Observation

//The logic controller for a single game session
//this class follows the MVVM pattern
//maintains the current game state, validating and applying operations, enforcing the rules of the game, checking for the win condition
//observable allows swift ui to auto update properties like currentNumber etc
@Observable
final class GameViewModel {

   
//the immutable configuration for this level
    let puzzle: Puzzle

   
//num currently displayed on the screen
    var currentNumber: Int
    //counter tracking the effeciency of the user's solution
    var movesUsed: Int = 0
    // bool flag for when target 9 is reached
    var isComplete: Bool = false


    /// Tracks whether the +9 escape has been used
    var plus9Used: Bool = false

 
    /// Operations available for this level.
    /// −1 and +9 are always included.
    let allowedOperationIDs: [OperationID]


    init(puzzle: Puzzle) {
        self.puzzle = puzzle
        self.currentNumber = puzzle.startNumber

        // Force core operations into every level
        let fixedOps: [OperationID] = [
            .subtract1,
            .add9Once
        ]

        //fetch random operations for this puzzle
        let puzzleOps = puzzle.allowedOperationIDs

        // Deduplicate while preserving order
        //we use a linked hash set to remove the duplicates ( we do not want puzzles with the same buttons )
        //strictly preserve the visual order of these buttons
        self.allowedOperationIDs =
            LinkedHashSet(fixedOps + puzzleOps).elements
    }

    
//attempts to apply a mathematical operation to the current number.
    //this method also heandles icrementing the move counter and checking for victory.
    //TODO possible break this down into a couple different methods.
    func apply(_ operation: Operation) {

        // Prevent reuse of +9
        if operation.id == .add9Once && plus9Used {
            return
        }
//validate the math
        guard let next = operation.apply(currentNumber) else {
            return
        }
//state update
        currentNumber = next
        movesUsed += 1

        if operation.id == .add9Once {
            plus9Used = true
        }
//check for the win condition
        if currentNumber == 9 {
            isComplete = true
        }
    }

//resets the game to it's initial state
    func reset() {
        currentNumber = puzzle.startNumber
        movesUsed = 0
        isComplete = false
        plus9Used = false
    }
}

//helpers that ensure uniqueness while preserving insertion order
//standard set is unordered, and an array allows duplicates
//combination of both!
//insertion O(1) , Iteration O(n)

struct LinkedHashSet<Element: Hashable> {
    //used for O(1) uniqueness checks
    private var seen = Set<Element>()
    //used to maintain the order of the elements
    private(set) var elements: [Element] = []

    init(_ items: [Element]) {
        for item in items {
            //if inserted returns true , it means the item was not previously in the set.
            if seen.insert(item).inserted {
                elements.append(item)
            }
        }
    }
}
