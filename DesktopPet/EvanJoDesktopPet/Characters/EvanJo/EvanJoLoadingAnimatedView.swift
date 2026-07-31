import SwiftUI

enum EvanJoLoadingLayout {
    static let panelSize = CGSize(width: 176, height: 132)
    static let bodyImageSize: CGFloat = 139
    static let bodyRestingOffsetY: CGFloat = 7
    static let textImageSize: CGFloat = 180
    static let textRestingOffsetY: CGFloat = 17
    // EvanJoLoadingText has visible alpha content in source columns 222..<1051.
    static let textAssetCanvasWidth: CGFloat = 1254
    static let textAssetVisibleMinX: CGFloat = 222
    static let textAssetVisibleMaxX: CGFloat = 1051
    static let textEntryMargin: CGFloat = 12
    static let textVisibleWidth = textImageSize
        * (textAssetVisibleMaxX - textAssetVisibleMinX)
        / textAssetCanvasWidth
    static let textVisibleCenterOffsetX = textImageSize
        * (((textAssetVisibleMinX + textAssetVisibleMaxX) / 2)
            / textAssetCanvasWidth - 0.5)
    static let textStartOffsetX = panelSize.width / 2
        + textVisibleWidth / 2
        + textEntryMargin
        - textVisibleCenterOffsetX
    static let textEndOffsetX: CGFloat = -180
    static let spinnerImageSize: CGFloat = 74
    static let spinnerRestingOffsetY: CGFloat = -28
}

struct EvanJoLoadingAnimatedView: View {
    @State private var spinnerRotation = 0.0
    @State private var isBodyRaised = false
    @State private var textOffsetX = EvanJoLoadingLayout.textStartOffsetX
    @State private var textTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            Image("EvanJoLoadingText")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(
                    width: EvanJoLoadingLayout.textImageSize,
                    height: EvanJoLoadingLayout.textImageSize
                )
                .offset(
                    x: textOffsetX,
                    y: EvanJoLoadingLayout.textRestingOffsetY
                )
                .frame(
                    width: EvanJoLoadingLayout.panelSize.width,
                    height: EvanJoLoadingLayout.panelSize.height
                )
                .clipped()

            Image("EvanJoLoadingBody")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(
                    width: EvanJoLoadingLayout.bodyImageSize,
                    height: EvanJoLoadingLayout.bodyImageSize
                )
                .offset(
                    y: EvanJoLoadingLayout.bodyRestingOffsetY
                        + (isBodyRaised ? -1 : 0)
                )

            Image("EvanJoLoadingSpinner")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(
                    width: EvanJoLoadingLayout.spinnerImageSize,
                    height: EvanJoLoadingLayout.spinnerImageSize
                )
                .rotationEffect(.degrees(spinnerRotation))
                .offset(y: EvanJoLoadingLayout.spinnerRestingOffsetY)
        }
        .frame(
            width: EvanJoLoadingLayout.panelSize.width,
            height: EvanJoLoadingLayout.panelSize.height
        )
        .onAppear(perform: startAnimation)
        .onDisappear(perform: stopAnimation)
    }

    private func startAnimation() {
        stopAnimation()

        withAnimation(.linear(duration: 2.8).repeatForever(autoreverses: false)) {
            spinnerRotation = 360
        }
        withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
            isBodyRaised = true
        }
        startTextPasses()
    }

    private func startTextPasses() {
        textTask = Task { @MainActor in
            do {
                while !Task.isCancelled {
                    resetTextPass()
                    try await Task.sleep(nanoseconds: 150_000_000)
                    guard !Task.isCancelled else { return }

                    withAnimation(.linear(duration: 2.8)) {
                        textOffsetX = EvanJoLoadingLayout.textEndOffsetX
                    }

                    try await Task.sleep(nanoseconds: 2_800_000_000)
                    guard !Task.isCancelled else { return }

                    try await Task.sleep(nanoseconds: 400_000_000)
                    guard !Task.isCancelled else { return }
                }
            } catch {
                return
            }
        }
    }

    private func resetTextPass() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            textOffsetX = EvanJoLoadingLayout.textStartOffsetX
        }
    }

    private func stopAnimation() {
        textTask?.cancel()
        textTask = nil

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            spinnerRotation = 0
            isBodyRaised = false
            textOffsetX = EvanJoLoadingLayout.textStartOffsetX
        }
    }
}
