
//  9
//
//  Created by GarrettWoodside
//



import SwiftUI
import SwiftData

//primary container
//data seeding, ensures the database has the first puzzle on launch
//Transitions the user from the intro to the game

struct ContentView: View {
    //access to the swift data model for database operations (seeding)
    @Environment(\.modelContext) private var modelContext
    //fetch all puzzle objects from the datsbase
    //the array updates whenever the database changes
    @Query private var puzzles: [Puzzle]
    //tracks the first seed to prevent duplication
    @State private var didSeed = false
    //controls intro visibility
    @State private var showIntro = true

    var body: some View {
        NavigationStack {
            ZStack {
                if showIntro {
                    //display the intro screen
                    IntroView {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showIntro = false
                        }
                    }
                    .zIndex(1) //intro for transitions
                } else if let puzzle = firstAvailablePuzzle {
                    //once the intro is dismissed show the game view with the first update
                    GameView(puzzle: puzzle)
                        .id(puzzle.id)
                        .transition(.opacity)
                } else {
                  //fallback case
                    Color.clear
                }
            }
        }
        //runs exactly once when the view appears
        .task {
            guard !didSeed else { return }
            didSeed = true
            await seedInitialContentIfNeeded()
        }
    }
 //retrieves the first avaliable puzzle the first cell always to start the game as the goal is to optimize
    private var firstAvailablePuzzle: Puzzle? {
        puzzles.first { $0.pageIndex == 0 && $0.cellIndex == 0 }
    }



//function that will populate the database with puzzles if they do not exist
    //seed the rest of the puzzles for the pages in a background task
    private func seedInitialContentIfNeeded() async {
        let factory = PuzzleFactory(context: modelContext)

        // Ensure first puzzle exists immediately
        _ = factory.getOrCreate(pageIndex: 0, cellIndex: 0)

        // Seed rest of the page opportunistically ( non blocking )
        Task { @MainActor in
            factory.seedPageIfNeeded(pageIndex: 0)
        }
    }
}
