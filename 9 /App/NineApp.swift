//
//  NineApp.swift
//  9
//
//  Created by GarrettWoodside on 12/13/25.
//

import SwiftUI
import SwiftData

//entry point for the application.
//manages the lifecyle of the app and sets up the global enviroment.
@main
struct NineApp: App {
    init() {
        //warm up the haptics engine to prevent latency.
        Haptics.prepare()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        //sets up for the swift data stack
        //this one method auto loads the SQLite db file, perfroms the scheme migrations for 'Puzzle and 'Attempt, and inject the modelContext into SwiftUI.
        .modelContainer(for: [Puzzle.self, Attempt.self])
    }
}
