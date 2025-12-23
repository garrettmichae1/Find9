//  9
//
//  Created by GarrettWoodside
//


import SwiftUI
import SwiftData

//The primary screen where the user plays the puzzle.

struct GameView: View {
    //access to the database for saving attempts and generating new levels.
    @Environment(\.modelContext) private var modelContext


//fetches all available puzzles and determines page count
    @Query
    private var puzzles: [Puzzle]
//fetches all attempts and calculates best scores
    @Query
    private var attempts: [Attempt]

//handles the current math puzzles's logic
    @State private var viewModel: GameViewModel
    //controls the visibility of heat map
    @State private var isProgressExpanded = false
    //tracks curr page in the level selector
    @State private var currentPageIndex: Int
    //controls the tutorial
    @State private var showHowToPlay = false
    //manages the toast when a level is completed
    @State private var completionFeedback: CompletionFeedback?

  
//Initializes the game with a puzzle
    init(puzzle: Puzzle) {
        //initialize the view model with the specific puzzle configuration
        _viewModel = State(initialValue: GameViewModel(puzzle: puzzle))
        //sync the level selector with the curr puzzle
        _currentPageIndex = State(initialValue: puzzle.pageIndex)
    }
    //highest page index available in the database
    private var maxPageIndex: Int {
        puzzles.map(\.pageIndex).max() ?? 0
    }
    //navigation controls inside the heat map calendar
    private var pageIndicator: some View {
        HStack {
            Button {
                goToPreviousPage()
            } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(currentPageIndex == 0)

            Spacer()

            Text("Page \(currentPageIndex + 1) of \(maxPageIndex + 1)")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                goToNextPage()
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(currentPageIndex >= maxPageIndex)
        }
        .padding(.horizontal)
    }

   
//number of times the specific puzzle has been solved
    private var completionCount: Int {
        attempts.filter { $0.puzzleID == viewModel.puzzle.id }.count
    }
//determines if the user is replaying
    private var isOptimizationMode: Bool {
        viewModel.isComplete && completionCount >= 1
    }


    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 16) {
//target indicator, the main glowing 9
                goalMarker
//main game card and resizes depending if the level selector is open or not
                gameCard
                    .frame(
                        maxHeight: isProgressExpanded
                            ? geo.size.height * 0.55
                            : geo.size.height * 0.88
                    )
                    .animation(.easeInOut(duration: 0.25), value: isProgressExpanded)

                Spacer()
                Spacer()
                //the expandable heat map / level selector
                progressSection
//win state handler
               
            }
            .onChange(of: viewModel.isComplete) { _, isComplete in
                guard isComplete else { return }
                
                Haptics.success()
                
                withAnimation(.easeInOut){
                    isProgressExpanded = false
                }

                let attempt = Attempt(
                    puzzleID: viewModel.puzzle.id,
                    movesUsed: viewModel.movesUsed
                )
                modelContext.insert(attempt)

                computeCompletionFeedback()
            }
            //displays the new record toast
            .overlay(alignment: .top) {
                if let feedback = completionFeedback {
                    CompletionToast(feedback: feedback)
                        .padding(.top, 90)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
        }
        //tool bar for the app
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showHowToPlay = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("How to Play")
            }
        }
        .sheet(isPresented: $showHowToPlay) {
            NavigationStack {
                HowToPlayView()
            }
        }
    }

            
        
    

    //the visual target the user is actually aiming for

    private var goalMarker: some View {
        ZStack {
            //outer glow around the number
            Circle()
                .fill(goalGlowColor)
                .frame(width: 64, height: 64)
                .blur(radius: 20)
                .opacity(0.6)
//Inner badge
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 40, height: 40)
                .overlay(
                    Text("9")
                        .font(.headline)
                        .fontWeight(.semibold)
                )
                .overlay(
                    Circle()
                        .strokeBorder(goalStrokeColor, lineWidth: 1)
                )
        }
        .padding(.top, 8)
    }

   
//banner shown when replaying a completed level
    private var optimizationBanner: some View {
        VStack(spacing: 6) {
            Text("Optimization Mode")
                .font(.headline)
                .fontWeight(.semibold)

            Text("Beat your best solution.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(radius: 6)
    }

    
//the main container for the current number, operations, and controls
    private var gameCard: some View {
        VStack(spacing: 28) {
            header
            operationsGrid
            controls
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal)
        .layoutPriority(1)
    }


    private var header: some View {
        VStack(spacing: 10) {
//the big number display
            Text("\(viewModel.currentNumber)")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(numberColor)

            if isOptimizationMode {
                optimizationBanner
            }
//stats row, moves / best/ total att.
            VStack(spacing: 4) {
                HStack(spacing: 12) {
                    Label("Moves \(viewModel.movesUsed)", systemImage: "arrow.right")

                    if let bestScore {
                        Label("Best \(bestScore)", systemImage: "star.fill")
                            .foregroundStyle(.blue)
                    }
                }

                Text("Attempts \(attemptCount)")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }


//renders the 2 column grid foor the operations buttons
    private var operationsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            ForEach(viewModel.allowedOperationIDs, id: \.self) { opID in
                operationButton(opID)
            }
        }
    }

    
//bottom action buttons . reset, next level, etc
    private var controls: some View {
        VStack(spacing: 12) {

            if viewModel.isComplete {
                Text(isNewRecord ? "New Record" : "Level Complete")
                    .font(.headline)
                    .foregroundStyle(isNewRecord ? .green : .primary)

                Button("Next Level") {
                    advanceToNextLevel()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button("Retry") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)
            } else {
                Button("Reset") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)
            }
        }
    }

   
//expandable drawer that holds the heat map/ level selector grid
    private var progressSection: some View {
        VStack(spacing: 12) {
            
           
//toggle the heat map
            Button {
                guard !viewModel.isComplete else { return }

                withAnimation(.easeInOut) {
                    isProgressExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Progress")
                        .font(.headline)

                

                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isProgressExpanded ? 180 : 0))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isComplete)
            .opacity(viewModel.isComplete ? 0.4 : 1)
            //content is expanded
            if isProgressExpanded {
                VStack(spacing: 8) {

                   //page controls
                    HStack {
                        

                        Spacer()

                        Text("Page \(currentPageIndex + 1) of \(maxPageIndex + 1)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Spacer()

                        
                    }
                    .padding(.horizontal)

                  //make the heat map scrollable
                    ScrollView {
                        LevelGridView(
                            puzzles: puzzles.filter {
                                $0.pageIndex == currentPageIndex
                            },
                            attempts: attempts,
                            onSelect: selectPuzzle
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                    //swipe gestures for map navigation
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width < -50 {
                                    Haptics.impact(.light)
                                    goToNextPage()
                                } else if value.translation.width > 50 {
                                    Haptics.impact(.light)
                                    goToPreviousPage()
                                }
                            }
                    )
                }
            }
        }
    }

   // some ui helpers

    private var bestScore: Int? {
        attempts
            .filter { $0.puzzleID == viewModel.puzzle.id }
            .map(\.movesUsed)
            .min()
    }

    private var attemptCount: Int {
        attempts.filter { $0.puzzleID == viewModel.puzzle.id }.count
    }

    private var isNewRecord: Bool {
        guard let best = bestScore else { return true }
        return viewModel.movesUsed < best
    }

    private var numberColor: Color {
        if viewModel.currentNumber == 9 { return .green }
        if let best = bestScore, viewModel.movesUsed < best { return .blue }
        return .primary
    }

    private var goalGlowColor: Color {
        viewModel.currentNumber == 9 ? .green : .blue.opacity(0.6)
    }

    private var goalStrokeColor: Color {
        viewModel.currentNumber == 9 ? .green : .secondary
    }

    //some logic helpers
    
    private func isOperationDisabled(_ opID: OperationID) -> Bool {
        if viewModel.isComplete { return true }
        //enforces the single use rule for +9
        if opID == .add9Once && viewModel.plus9Used { return true }
        return false
    }

   //navigation logic
    //documentation is boring

    //switches the active game to a selected puzzle
    private func selectPuzzle(_ puzzle: Puzzle) {
        viewModel = GameViewModel(puzzle: puzzle)
        currentPageIndex = puzzle.pageIndex
        isProgressExpanded = false
    }

   
//calculates the next level index and loads / creates it
    private func advanceToNextLevel() {
        let factory = PuzzleFactory(context: modelContext)

        let current = viewModel.puzzle
        var nextPage = current.pageIndex
        var nextCell = current.cellIndex + 1

        if nextCell >= 50 {
            nextPage += 1
            nextCell = 0
        }
//get the specific next puzzle
        let nextPuzzle = factory.getOrCreate(
            pageIndex: nextPage,
            cellIndex: nextCell
        )

        selectPuzzle(nextPuzzle)

        // Opportunistically seed the rest of the page
        if nextCell == 0 {
            factory.seedPageIfNeeded(pageIndex: nextPage)
        }
    }

 
//helper to fetch a specific puzzle from the database
    private func fetchPuzzle(pageIndex: Int, cellIndex: Int) -> Puzzle? {
        let descriptor = FetchDescriptor<Puzzle>(
            predicate: #Predicate { p in
                p.pageIndex == pageIndex && p.cellIndex == cellIndex
            }
        )
        return (try? modelContext.fetch(descriptor))?.first
    }
//generates 50 levels for a specific page in a background task
    //ensure the user does not hit a loading screen EVER
    private func seedPageInBackground(_ pageIndex: Int) {
        Task { @MainActor in
            for cellIndex in 0..<50 {
                // Skip if already exists (prevents duplicates even if user advances fast)
                if fetchPuzzle(pageIndex: pageIndex, cellIndex: cellIndex) != nil {
                    continue
                }
//generate random constrains
                let operations = OperationRandomizer.generate(startNumber: 9)
                //genearte a start number that can be solved using the operations
                let startNumber =
                StartNumberGenerator.generate(
                    using: operations,
                    sequenceIndex: cellIndex   // or global level index
                )
                //save to the database
                let puzzle = Puzzle(
                    pageIndex: pageIndex,
                    cellIndex: cellIndex,
                    startNumber: startNumber,
                    allowedOperationIDs: operations
                )

                modelContext.insert(puzzle)
            }
        }
    }

   
//renders a single operation button
    @ViewBuilder
    private func operationButton(_ opID: OperationID) -> some View {
        let op = Operations.baseline[opID]!

        Button {
            viewModel.apply(op)
        } label: {
            Text(op.name)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.bordered)
        //highlights the +9 button ' tis special '
        .tint(opID == .add9Once ? .blue : .primary)
        .controlSize(.large)
        .disabled(isOperationDisabled(opID))
        .opacity(isOperationDisabled(opID) ? 0.4 : 1)
    }
    //navigaton actions // next and prev page functions
    private func goToNextPage() {
        let maxPage = puzzles.map(\.pageIndex).max() ?? 0
        guard currentPageIndex < maxPage else { return }
        currentPageIndex += 1
    }

    private func goToPreviousPage() {
        guard currentPageIndex > 0 else { return }
        currentPageIndex -= 1
    }
    
    //determines the correct feedback toast to show
    private func computeCompletionFeedback() {
        guard let best = bestScore else {
            showFeedback(.newBest)
            return
        }

        if viewModel.movesUsed < best {
            showFeedback(.newBest)
        } else if viewModel.movesUsed == best {
            showFeedback(.matchedBest)
        } else {
            showFeedback(.offBy(viewModel.movesUsed - best))
        }
    }
//triggers the feedback operation and haptics
    private func showFeedback(_ feedback: CompletionFeedback) {

        //haptics vary by level of success
        switch feedback {
        case .newBest:
            Haptics.impact(.heavy)

        case .matchedBest:
            Haptics.impact(.medium)

        case .offBy:
            Haptics.impact(.light)
        }
//actually show the toast
        withAnimation(.easeOut) {
            completionFeedback = feedback
        }
//hide the toast after a very short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeIn) {
                completionFeedback = nil
            }
        }
    }

    
}
