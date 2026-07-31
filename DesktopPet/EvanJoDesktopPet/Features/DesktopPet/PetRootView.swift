import SwiftUI

struct PetRootView: View {
    let appearance: PetPoseAppearance

    var body: some View {
        content
            .accessibilityLabel(appearance.accessibilityLabel)
    }

    @ViewBuilder
    private var content: some View {
        if let customRenderer = appearance.customRenderer {
            customRenderer()
        } else {
            Image(appearance.assetName)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .padding(.horizontal, appearance.horizontalInset)
                .frame(
                    width: appearance.logicalCanvasSize.width,
                    height: appearance.logicalCanvasSize.height
                )
                .scaleEffect(appearance.imageScale)
                .offset(appearance.imageOffset)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: appearance.alignment
                )
        }
    }
}
