//
//  Attempt.swift
//  9
//
//  Created by GarrettWoodside

//This class represents a user's attempt to solve a puzzle.
//

import Foundation
import SwiftData
//the model annotation allows swift data to manage its chema and persistence in the database
@Model
final class Attempt {
    //unique identifier for the specific attempt
    var id: UUID
    //The id of the puzzle that is attempted
    var puzzleID: UUID
    //total number of moves used to complete the puzzle
    var movesUsed: Int
    // the time stamp of when the puzzle is finished
    var completedAt: Date
// creates a new puzzle attempt record
    init(puzzleID: UUID, movesUsed: Int) {
        self.id = UUID()
        self.puzzleID = puzzleID
        self.movesUsed = movesUsed
        self.completedAt = Date()
    }
}
