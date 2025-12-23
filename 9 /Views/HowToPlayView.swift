//
//  HowToPlayView.swift
//  9
//
//  Created by GarrettWoodside on 12/14/25.
//

import SwiftUI

//A scrollable tutorial screen that explains the game mechanics.

struct HowToPlayView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

               //objective
                SectionHeader("Objective")
                Text("Reach 9 using the fewest moves possible. Each tap applies an operation to the current number.")

                //rules
                SectionHeader("Rules")
                Bullet("Each operation transforms the current number")
                Bullet("Some operations may be unavailable depending on the number")
                Bullet("Levels are always solvable")
                Bullet("Fewer moves = better optimization score")

            //operations
                SectionHeader("Operations")

                OperationRow("+1", "Increase the number by 1")
                OperationRow("−1", "Decrease the number by 1 (precision control)")
                OperationRow("+9", "Add 9 once per level (single-use escape)")
                OperationRow("×2", "Double the number")

                Divider().padding(.vertical, 8)

                OperationRow("÷2", "Divide by 2 if divisible")
                OperationRow("÷3", "Divide by 3 if divisible")

                Divider().padding(.vertical, 8)

                OperationRow("Digit Sum", "Sum of all digits")
                OperationRow("Digit² Sum", "Sum of squared digits")
                OperationRow("Digit Diff", "Absolute difference across digits")
                OperationRow("Mod 9", "Remainder mod 9 (0 becomes 9)")
                OperationRow("Drop Digit", "Remove the last digit")
                OperationRow("Reverse", "Reverse digit order")
                OperationRow("Rotate Digits", "Move first digit to the end")

            }
            .padding()
        }
        .navigationTitle("How to Play")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//helpers
//standard header for content sections

private struct SectionHeader: View {
    let title: String
    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title)
            .font(.headline)
            .padding(.top, 8)
    }
}
//bullet point for list items
private struct Bullet: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text("• \(text)")
    }
}
//row that displays an operation name and it's definition/
private struct OperationRow: View {
    let name: String
    let description: String

    init(_ name: String, _ description: String) {
        self.name = name
        self.description = description
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name).bold()
            Text(description)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
