
//  9
//
//  Created by GarrettWoodside
//


import SwiftUI
import SwiftData

//displays a collection of puzzles for a specific page
//handles layout of level cell
//determines which levels are locked or unlocked based on user progress

struct LevelGridView: View {
    //the list of puzzles to display on the page
    let puzzles: [Puzzle]
    //full history of the users attempts that is used to compute the lock status of levels
    let attempts: [Attempt]
    //callback closure when a user taps an unlocked puzzle
    let onSelect: (Puzzle) -> Void
//creates a 7 column grid with a flexible layout width
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 6),
        count: 7
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            // sort the puzzles by index to ensure visual order
            ForEach(sortedPuzzles) { puzzle in
                LevelCell(
                    puzzle: puzzle,
                    attempts: attempts,
                    isUnlocked: isUnlocked(puzzle)
                )
                .onTapGesture {
                    guard isUnlocked(puzzle) else { return }
                    onSelect(puzzle)
                }
            }
        }
        .padding(.horizontal)
    }

//returns a sorted copy of the puzzles based on teir grid position
    private var sortedPuzzles: [Puzzle] {
        puzzles.sorted { $0.cellIndex < $1.cellIndex }
    }
//base case = the first cell index 0 is always unlocked
    //recursive case: any cell is unlocked IF and only if the immediatly preceding cell (i - 1) exists AND has exists in 'attempts' meaning it has been solved.
    private func isUnlocked(_ puzzle: Puzzle) -> Bool {
        // First cell in a page is always unlocked
        if puzzle.cellIndex == 0 {
            return true
        }

        let previousCellIndex = puzzle.cellIndex - 1
//find the puzzle object that is associated with the prev index
        return puzzles
            .first(where: { $0.cellIndex == previousCellIndex })
            .map { prevPuzzle in
                //check if the user has already completed the puzzle
                attempts.contains { $0.puzzleID == prevPuzzle.id }
            } ?? false
    }
}
