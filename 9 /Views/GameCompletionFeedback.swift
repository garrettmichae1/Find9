
//
//  GameCompletionFeedback.swift
//  9
//
//  Created by GarrettWoodside on 12/14/25.
//

import SwiftUI

//represents the success of a completed puzzle
//this enum compares the current attempt's score against the user's historical best
//encapsulates all neccasary UI configuration data
enum CompletionFeedback: Equatable {
    //first completion or the user beat thier high score
    case newBest
    //the user equaled their high score
    case matchedBest
    //user solved puzzles and they were this far off from their best
    case offBy(Int)
//primary headline text for the feedback 'toast'
    var title: String {
        switch self {
        case .newBest:
            return "New Optimal"
        case .matchedBest:
            return "Matched Best"
        case .offBy:
            return "Close"
        }
    }
//seconday text that explains the result
    var subtitle: String {
        switch self {
        case .newBest:
            return "Best solution so far"
        case .matchedBest:
            return "You hit your record"
        case .offBy(let n):
            return "\(n) move\(n == 1 ? "" : "s") away"
        }
    }
//the theme that is associated with the result
    var tint: Color {
        switch self {
        case .newBest:
            return .green
        case .matchedBest:
            return .blue
        case .offBy:
            return .secondary
        }
    }
//the icon used to represent the result
    var icon: String {
        switch self {
        case .newBest:
            return "sparkles"
        case .matchedBest:
            return "star.fill"
        case .offBy:
            return "arrow.up.right"
        }
    }
}



//A floating visual notification that is displayed when a level is complete
//designed to be overlayed on top of the game content
struct CompletionToast: View {
    //feedback state to display
    let feedback: CompletionFeedback

    var body: some View {
        HStack(spacing: 14) {
//icon section
            Image(systemName: feedback.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(feedback.tint)
                .frame(width: 28)
//text section
            VStack(alignment: .leading, spacing: 4) {
                Text(feedback.title)
                    .font(.callout.weight(.semibold))

                Text(feedback.subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
        //add a colored ring matching the feedback tint
        .overlay(
            Capsule()
                .strokeBorder(feedback.tint.opacity(0.45), lineWidth: 1)
        )
        //the shadow adds depth feel to the overlay
        .shadow(color: .black.opacity(0.18), radius: 10, y: 5)
    }
}
