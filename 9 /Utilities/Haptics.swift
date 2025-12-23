//
//  Haptics.swift
//  9
//
//  Created by GarrettWoodside on 12/14/25.
//
// Haptics.swift

import UIKit

//class for triggering haptic feedback througout the app.

enum Haptics {

 //held in memory to avoid the initialization cost on every single tap. We would have lag if we recreated on every single tap.

    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)

    private static let notification = UINotificationFeedbackGenerator()
//prewarm the taptic engine to avoid latency
    //called when the app launchs
    static func prepare() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        notification.prepare()
    }

    //PUBLIC API
    
    //triggers the actual physcial feedbacks

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .light:
            lightImpact.impactOccurred()
            //always keep it prepared
            lightImpact.prepare()

        case .medium:
            mediumImpact.impactOccurred()
            mediumImpact.prepare()

        case .heavy:
            heavyImpact.impactOccurred()
            heavyImpact.prepare()

        default:
            mediumImpact.impactOccurred()
            mediumImpact.prepare()
        }
    }
    
    //PUBLIC API

    static func success() {
        notification.notificationOccurred(.success)
        notification.prepare()
    }

    static func warning() {
        notification.notificationOccurred(.warning)
        notification.prepare()
    }

    static func error() {
        notification.notificationOccurred(.error)
        notification.prepare()
    }
}
