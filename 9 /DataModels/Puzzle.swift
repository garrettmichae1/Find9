//
//  Puzzle.swift
//  9
//
//  Created by GarrettWoodside 
//

import Foundation
import SwiftData

// this class represents a level within the game.

@Model
final class Puzzle {
    //unique identifier for the puzzle instance
    var id: UUID
    // when this puzzle was created or generated/
    var createdAt: Date

    // the page number the level belongs to in the heat map calendar
    var pageIndex: Int
   // the actual cell index on the page
    var cellIndex: Int        // 0–49
    // the starting integer for the puzzle
    var startNumber: Int
    // store the raw string here and access it via the allowedOperationIds computed property
    //swift data cannot persist complex enums easily
    var allowedOperationRawValues: [String]
    //Initializes a new puzzle
    init(
        pageIndex: Int,
        cellIndex: Int,
        startNumber: Int,
        allowedOperationIDs: [OperationID]
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.pageIndex = pageIndex
        self.cellIndex = cellIndex
        self.startNumber = startNumber
        //Converts the enums to Strings
        self.allowedOperationRawValues = allowedOperationIDs.map { $0.rawValue }
    }
//Converts the stores String array 'allowedOperationRawValues' back into OperationID objects to be used in the game logic.
    var allowedOperationIDs: [OperationID] {
        allowedOperationRawValues.compactMap(OperationID.init(rawValue:))
    }
}
