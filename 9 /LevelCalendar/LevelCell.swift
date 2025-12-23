//
//  LevelCell.swift
//  9
//
//  Created by GarrettWoodside 
//

import SwiftUI

//This cell displats the level num and changes colors based on the users completion status and their high score

struct LevelCell: View {
    // the puzzle data for this cell
    let puzzle: Puzzle
    //a list of all the attempts passed down from the parent view
    //finds attempts relevant to this puzzle
    let attempts: [Attempt]
    //determines if a level is grayed out or not
    let isUnlocked: Bool
// this finction computes the lowest number of moves to solve a puzzle
    //returns the min movesUsed from attempt history or nil if never solved
    private var bestScore: Int? {
        attempts
            .filter { $0.puzzleID == puzzle.id }
            .map(\.movesUsed)
            .min()
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(cellColor)
            .frame(height: 28)
            .overlay(
                Text("\(puzzle.cellIndex + 1)")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(isUnlocked ? 1 : 0.4))
            )
        // cell is dimmed if the level has not been played
            .opacity(isUnlocked ? 1 : 0.25)
    }
// dertimines the background color of the cell depending on how good the user perfromed on the specific level
    private var cellColor: Color {
        guard isUnlocked else { return .gray }

        if let score = bestScore {
            // darker = better score
            return score <= 5 ? .green : .green.opacity(0.6)
        } else {
            return .secondary.opacity(0.3)
        }
    }
}
