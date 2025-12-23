//  9
//
//  Created by GarrettWoodside
//

import SwiftUI

//The splash screen that is displayed when the app is launched.

//plays a branded 9 animation

struct IntroView: View {
    //callback closure for when the animation sequence finishes
    let onFinished: () -> Void
//controls the size of the floating 9
    @State private var scale: CGFloat = 0.85
    //controls visibility of the green glow behind the 9
    @State private var glowOpacity: Double = 0.0

    var body: some View {
        ZStack {
            //adapt to light / dark mode
            Color(.systemBackground)
                .ignoresSafeArea()

            ZStack {
                // Glow layer
                Text("9")
                    .font(.system(size: 88, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
                    .opacity(glowOpacity)
                    .blur(radius: 16)

                // Core number
                //num sitting at the top
                Text("9")
                    .font(.system(size: 88, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .scaleEffect(scale) //applies the zoom animation
        }
        .onAppear {
            runAnimation()
        }
    }
//animation logic
    //this is the start up timeline
    private func runAnimation() {
        // Step 1: gentle scale-in
        withAnimation(.easeOut(duration: 0.5)) {
            scale = 1.0
        }

        // Step 2: glow pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.4)) {
                glowOpacity = 1.0
            }
        }

        // Step 3: exit
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            onFinished()
        }
    }
}
