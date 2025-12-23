//
//  PuzzleFactory.swift
//  9
//
//  Created by GarrettWoodside on 12/14/25.
//

import SwiftData
import Foundation

//servuce resonsible for retrieving or generating puzzles.

@MainActor
final class PuzzleFactory {
//db connection used to query and save puzzles
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }
//PUBLIC API
    //retrieves a specific puzzle or will generate the puzzle if it currently does not exist
    func getOrCreate(pageIndex: Int, cellIndex: Int) -> Puzzle {
        if let existing = fetch(pageIndex: pageIndex, cellIndex: cellIndex) {
            return existing
        }
        
        //cache miss, generate a new level

        //pick random operations
        let operations = OperationRandomizer.generate(startNumber: 9)
        //generates the start num based on the chosen operations
        let startNumber = StartNumberGenerator.generate(
            using: operations,
            sequenceIndex: cellIndex   // or global level index
        )
//create the model
        let puzzle = Puzzle(
            pageIndex: pageIndex,
            cellIndex: cellIndex,
            startNumber: startNumber,
            allowedOperationIDs: operations
        )
//persist to swift data
        context.insert(puzzle)
        return puzzle
    }


//performs a swift data query to find a specific puzzle
    func fetch(pageIndex: Int, cellIndex: Int) -> Puzzle? {
        let descriptor = FetchDescriptor<Puzzle>(
            predicate: #Predicate { p in
                p.pageIndex == pageIndex &&
                p.cellIndex == cellIndex
            }
        )
        return try? context.fetch(descriptor).first
    }
//batch generates entire page of puzzles , avoid latency issues
    func seedPageIfNeeded(pageIndex: Int) {
        for cell in 0..<50 {
            _ = getOrCreate(pageIndex: pageIndex, cellIndex: cell)
        }
    }
}

