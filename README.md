# Find 9: A Recursive Math Puzzle

** Download on the iOS app store. [
](https://apps.apple.com/us/app/find-9/id6756576900)

Find 9 is a native iOS puzzle game built with **SwiftUI** and **SwiftData**. The goal is simple: start with a random number, then find 9 in the fewest amount of operations. Levels are procedurally generated using reverse walk algorithms to guarantee solvability for every level.

## Tech Stack
* **SwiftUI:** Declarative UI with complex transitions.
* **SwiftData:** Local first persistence and relational object modeling.
* **Algorithms:** Procedural generation via recursive backtracking.
* **Optimization:** Custom LinkedHashSet data structure and haptic engine pre warming for 0ms latency.

## Architecture
The app follows a strict **MVVM** pattern with a factory based level generator.
* **Models:** `Puzzle` and `Attempt` (Managed by SwiftData).
* **ViewModels:** `GameViewModel` (Logic Controller).
* **Views:** `GameView` and `LevelGridView`.

## Motivation
I wanted to create an infinitely playable game where each level brought a degree of freshness. Find 9 is a deterministic, procedurally generated game loop system that offers users millions of different combinations to solve number puzzles.

## Contact
**Developer:** Garrett Woodside
**Email:** garrettmichael07@icloud.com

© 2025 Garrett Woodside
