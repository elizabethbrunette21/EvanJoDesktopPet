import SwiftUI

enum EvanJoSleepyLayout {
    struct Layer {
        let imageSize: CGSize
        let restingOffset: CGSize
    }

    static let panelSize = CGSize(width: 176, height: 154)

    private static let referenceCanvasSize = CGSize(width: 419, height: 418)
    private static let staticLogicalCanvasSize = CGSize(width: 125, height: 132)
    private static let staticHorizontalInset: CGFloat = 7
    private static let staticImageScale: CGFloat = 1.16
    private static let legacyBodySourceSize = CGSize(width: 887, height: 961)
    private static let legacyBodyContentBounds = CGRect(
        x: 19,
        y: 19,
        width: 849,
        height: 923
    )
    private static let splitLayerSourceSize = CGSize(width: 1024, height: 1024)
    private static let splitBodyContentBounds = CGRect(
        x: 107,
        y: 10,
        width: 805,
        height: 930
    )
    private static let splitHandContentBounds = CGRect(
        x: 472,
        y: 338,
        width: 331,
        height: 456
    )
    private static let handScale: CGFloat = 0.92
    private static let legacyHandReferencePosition = CGPoint(
        x: 539.5,
        y: 665
    )
    private static let legacyHandContactAnchor = CGPoint(
        x: 500,
        y: 498
    )
    private static let legacyHandTargetVisibleBounds: CGRect = {
        let height: CGFloat = 334
        let width = height
            * splitHandContentBounds.width / splitHandContentBounds.height
        let referenceBounds = CGRect(
            x: legacyHandReferencePosition.x - width / 2,
            y: legacyHandReferencePosition.y - height / 2,
            width: width,
            height: height
        )
        return scaled(
            referenceBounds,
            around: legacyHandContactAnchor,
            by: handScale
        )
    }()
    private static let impactSourceSize = CGSize(
        width: 1187,
        height: 180
    )
    private static let idleVisualHeight: CGFloat = 130.7
    private static let idleBottomGap: CGFloat = 0.15
    private static let baseReferenceCanvasFrame: CGRect = {
        let availableWidth = staticLogicalCanvasSize.width
            - staticHorizontalInset * 2
        let imageAspectRatio = referenceCanvasSize.width
            / referenceCanvasSize.height
        let renderedWidth = availableWidth * staticImageScale
        let renderedHeight = availableWidth / imageAspectRatio
            * staticImageScale
        let originalBottomGap = staticLogicalCanvasSize.height
            - (staticLogicalCanvasSize.height / 2 + renderedHeight / 2)

        return CGRect(
            x: (panelSize.width - renderedWidth) / 2,
            y: panelSize.height - originalBottomGap - renderedHeight,
            width: renderedWidth,
            height: renderedHeight
        )
    }()

    private static let mistReferenceFrame = CGRect(
        x: -3,
        y: 0,
        width: 864 * 0.488,
        height: 744 * 0.488
    )
    private static let bodyReferenceFrame = CGRect(
        x: 37,
        y: 39.6,
        width: 887 * 0.4,
        height: 961 * 0.4
    )
    private static let glassesReferenceFrame = CGRect(
        x: 140,
        y: 222,
        width: 1013 * 0.194,
        height: 358 * 0.194
    )
    private static let sparkleReferenceFrame = CGRect(
        x: 96.8,
        y: 172.8,
        width: 231 * 0.2,
        height: 261 * 0.2
    )

    private static let baseLegacyBodyVisibleFrame = visibleContentFrame(
        contentBounds: legacyBodyContentBounds,
        sourceSize: legacyBodySourceSize,
        destinationFrame: resolveFrame(
            bodyReferenceFrame,
            in: baseReferenceCanvasFrame
        )
    )
    private static let sleepySceneScale: CGFloat = 1.198
    private static let sceneSourceAnchor = CGPoint(
        x: baseLegacyBodyVisibleFrame.midX,
        y: baseLegacyBodyVisibleFrame.maxY
    )
    private static let sceneTargetAnchor = CGPoint(
        x: panelSize.width / 2,
        y: panelSize.height - idleBottomGap
    )
    private static let sceneTranslation = CGSize(
        width: sceneTargetAnchor.x
            - sceneSourceAnchor.x * sleepySceneScale,
        height: sceneTargetAnchor.y
            - sceneSourceAnchor.y * sleepySceneScale
    )
    private static let referenceCanvasFrame = applySceneTransform(
        to: baseReferenceCanvasFrame
    )
    private static let targetBodyVisibleFrame: CGRect = {
        let height = baseLegacyBodyVisibleFrame.height * sleepySceneScale
        let width = height
            * splitBodyContentBounds.width / splitBodyContentBounds.height
        return CGRect(
            x: sceneTargetAnchor.x - width / 2,
            y: sceneTargetAnchor.y - height,
            width: width,
            height: height
        )
    }()
    private static let handReferenceVisibleFrame = visibleContentFrame(
        contentBounds: legacyHandTargetVisibleBounds,
        sourceSize: legacyBodySourceSize,
        destinationFrame: bodyReferenceFrame
    )

    static let mist = resolve(mistReferenceFrame)
    static let glasses = resolve(glassesReferenceFrame)
    static let sparkle = resolve(sparkleReferenceFrame)
    static let bodyBack = layer(
        aligning: splitBodyContentBounds,
        in: splitLayerSourceSize,
        to: targetBodyVisibleFrame
    )
    static let handFront = layer(
        aligning: splitHandContentBounds,
        in: splitLayerSourceSize,
        to: resolveFrame(handReferenceVisibleFrame)
    )

    static let finalGlassesPushOffset = CGSize(
        width: 0.75,
        height: -3.5
    )
    static let finalGlassesPushRotation = -0.65
    static let baseGlassesFrame = frame(for: glasses)
    static let finalGlassesFrame = baseGlassesFrame.offsetBy(
        dx: finalGlassesPushOffset.width,
        dy: finalGlassesPushOffset.height
    )

    static let primaryMistSettledScale: CGFloat = 1.035
    static let primaryMistInitialOffset = CGSize(width: -3, height: 1)
    static let primaryMistSettledOffset = CGSize(width: 3, height: -1)
    static let headVisibleBounds = CGRect(
        x: targetBodyVisibleFrame.minX
            + targetBodyVisibleFrame.width * 0.15,
        y: targetBodyVisibleFrame.minY,
        width: targetBodyVisibleFrame.width * 0.70,
        height: targetBodyVisibleFrame.height * 0.58
    )
    private static let impactBurstHorizontalGap: CGFloat = 14
    private static let impactBurstVerticalOffset: CGFloat = -2
    static let impactBurstCenter = CGPoint(
        x: finalGlassesFrame.minX - impactBurstHorizontalGap,
        y: finalGlassesFrame.midY + impactBurstVerticalOffset
    )
    static let impactBurstSize: CGFloat = 17
    static let impactLineCenter = CGPoint(
        x: headVisibleBounds.midX,
        y: finalGlassesFrame.midY + 1
    )
    static let impactLineWidth = headVisibleBounds.width * 1.12
    static let impactLineHeight: CGFloat = 2.75
    static let impactBurstSourceImageSize = CGSize(
        width: impactBurstSize
            * impactSourceSize.width / impactSourceSize.height,
        height: impactBurstSize
    )

    private static func resolve(_ referenceFrame: CGRect) -> Layer {
        layer(from: resolveFrame(referenceFrame))
    }

    private static func resolveFrame(_ referenceFrame: CGRect) -> CGRect {
        resolveFrame(referenceFrame, in: referenceCanvasFrame)
    }

    private static func resolveFrame(
        _ referenceFrame: CGRect,
        in canvasFrame: CGRect
    ) -> CGRect {
        let scaleX = canvasFrame.width / referenceCanvasSize.width
        let scaleY = canvasFrame.height / referenceCanvasSize.height
        return CGRect(
            x: canvasFrame.minX + referenceFrame.minX * scaleX,
            y: canvasFrame.minY + referenceFrame.minY * scaleY,
            width: referenceFrame.width * scaleX,
            height: referenceFrame.height * scaleY
        )
    }

    private static func layer(from frame: CGRect) -> Layer {
        return Layer(
            imageSize: frame.size,
            restingOffset: CGSize(
                width: frame.midX - panelSize.width / 2,
                height: frame.midY - panelSize.height / 2
            )
        )
    }

    private static func frame(for layer: Layer) -> CGRect {
        CGRect(
            x: panelSize.width / 2
                + layer.restingOffset.width - layer.imageSize.width / 2,
            y: panelSize.height / 2
                + layer.restingOffset.height - layer.imageSize.height / 2,
            width: layer.imageSize.width,
            height: layer.imageSize.height
        )
    }

    private static func visibleContentFrame(
        contentBounds: CGRect,
        sourceSize: CGSize,
        destinationFrame: CGRect
    ) -> CGRect {
        CGRect(
            x: destinationFrame.minX
                + contentBounds.minX / sourceSize.width
                    * destinationFrame.width,
            y: destinationFrame.minY
                + contentBounds.minY / sourceSize.height
                    * destinationFrame.height,
            width: contentBounds.width / sourceSize.width
                * destinationFrame.width,
            height: contentBounds.height / sourceSize.height
                * destinationFrame.height
        )
    }

    private static func layer(
        aligning contentBounds: CGRect,
        in sourceSize: CGSize,
        to visibleFrame: CGRect
    ) -> Layer {
        let frameWidth = visibleFrame.width
            * sourceSize.width / contentBounds.width
        let frameHeight = visibleFrame.height
            * sourceSize.height / contentBounds.height
        let frame = CGRect(
            x: visibleFrame.minX
                - contentBounds.minX / sourceSize.width * frameWidth,
            y: visibleFrame.minY
                - contentBounds.minY / sourceSize.height * frameHeight,
            width: frameWidth,
            height: frameHeight
        )
        return layer(from: frame)
    }

    private static func applySceneTransform(to frame: CGRect) -> CGRect {
        return CGRect(
            x: frame.minX * sleepySceneScale + sceneTranslation.width,
            y: frame.minY * sleepySceneScale + sceneTranslation.height,
            width: frame.width * sleepySceneScale,
            height: frame.height * sleepySceneScale
        )
    }

    private static func scaled(
        _ frame: CGRect,
        around anchor: CGPoint,
        by scale: CGFloat
    ) -> CGRect {
        CGRect(
            x: anchor.x + (frame.minX - anchor.x) * scale,
            y: anchor.y + (frame.minY - anchor.y) * scale,
            width: frame.width * scale,
            height: frame.height * scale
        )
    }
}

struct EvanJoSleepyAnimatedView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var animationTask: Task<Void, Never>?
    @State private var mistASettled = false
    @State private var mistBSettled = false
    @State private var glassesRaised = false
    @State private var reflectionAmount = 0.0
    @State private var backgroundImpactOpacity = 0.0
    @State private var backgroundImpactScale: CGFloat = 0.92
    @State private var sparkleOpacity = 0.0
    @State private var sparkleScale: CGFloat = 0.72

    var body: some View {
        ZStack {
            mistLayerA
            mistLayerB

            impactHorizontalLineLayer
            impactBurstLayer

            bodyBackLayer

            pushingLayers

            Image("EvanJoSleepyYellowSparkle")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(
                    width: EvanJoSleepyLayout.sparkle.imageSize.width,
                    height: EvanJoSleepyLayout.sparkle.imageSize.height
                )
                .scaleEffect(sparkleScale)
                .opacity(sparkleOpacity)
                .offset(
                    x: EvanJoSleepyLayout.sparkle.restingOffset.width,
                    y: EvanJoSleepyLayout.sparkle.restingOffset.height
                )
        }
        .frame(
            width: EvanJoSleepyLayout.panelSize.width,
            height: EvanJoSleepyLayout.panelSize.height
        )
        .clipped()
        .onAppear(perform: startAnimation)
        .onDisappear(perform: stopAnimation)
    }

    private var mistLayerA: some View {
        primaryMistGeometry
            .opacity(0.72)
    }

    private var primaryMistGeometry: some View {
        Image("EvanJoSleepyBlueMist")
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(
                width: EvanJoSleepyLayout.mist.imageSize.width,
                height: EvanJoSleepyLayout.mist.imageSize.height
            )
            .scaleEffect(
                mistASettled
                    ? EvanJoSleepyLayout.primaryMistSettledScale
                    : 1
            )
            .offset(
                x: EvanJoSleepyLayout.mist.restingOffset.width
                    + (
                        mistASettled
                            ? EvanJoSleepyLayout
                                .primaryMistSettledOffset.width
                            : EvanJoSleepyLayout
                                .primaryMistInitialOffset.width
                    ),
                y: EvanJoSleepyLayout.mist.restingOffset.height
                    + (
                        mistASettled
                            ? EvanJoSleepyLayout
                                .primaryMistSettledOffset.height
                            : EvanJoSleepyLayout
                                .primaryMistInitialOffset.height
                    )
            )
    }

    private var mistLayerB: some View {
        Image("EvanJoSleepyBlueMist")
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(
                width: EvanJoSleepyLayout.mist.imageSize.width,
                height: EvanJoSleepyLayout.mist.imageSize.height
            )
            .scaleEffect(mistBSettled ? 1.01 : 1.05)
            .rotationEffect(.degrees(mistBSettled ? 0.4 : -0.4))
            .opacity(0.34)
            .offset(
                x: EvanJoSleepyLayout.mist.restingOffset.width
                    + (mistBSettled ? -2 : 4),
                y: EvanJoSleepyLayout.mist.restingOffset.height
        )
    }

    private var bodyBackLayer: some View {
        Image("EvanJoSleepyBodyBack")
            .resizable()
            .interpolation(.high)
            .frame(
                width: EvanJoSleepyLayout.bodyBack.imageSize.width,
                height: EvanJoSleepyLayout.bodyBack.imageSize.height
            )
            .offset(
                x: EvanJoSleepyLayout.bodyBack.restingOffset.width,
                y: EvanJoSleepyLayout.bodyBack.restingOffset.height
            )
    }

    private var impactHorizontalLineLayer: some View {
        Capsule()
            .fill(Color.white)
            .frame(
                width: EvanJoSleepyLayout.impactLineWidth,
                height: EvanJoSleepyLayout.impactLineHeight
            )
            .opacity(backgroundImpactOpacity)
            .offset(
                x: EvanJoSleepyLayout.impactLineCenter.x
                    - EvanJoSleepyLayout.panelSize.width / 2,
                y: EvanJoSleepyLayout.impactLineCenter.y
                    - EvanJoSleepyLayout.panelSize.height / 2
            )
    }

    private var impactBurstLayer: some View {
        ZStack(alignment: .leading) {
            Image("EvanJoSleepyImpactStreak")
                .resizable()
                .interpolation(.high)
                .frame(
                    width: EvanJoSleepyLayout
                        .impactBurstSourceImageSize.width,
                    height: EvanJoSleepyLayout
                        .impactBurstSourceImageSize.height
                )
        }
        .frame(
            width: EvanJoSleepyLayout.impactBurstSize,
            height: EvanJoSleepyLayout.impactBurstSize,
            alignment: .leading
        )
        .clipped()
        .scaleEffect(backgroundImpactScale)
        .opacity(backgroundImpactOpacity)
        .offset(
            x: EvanJoSleepyLayout.impactBurstCenter.x
                - EvanJoSleepyLayout.panelSize.width / 2,
            y: EvanJoSleepyLayout.impactBurstCenter.y
                - EvanJoSleepyLayout.panelSize.height / 2
        )
    }

    private var pushingLayers: some View {
        ZStack {
            glassesGroup
            handFrontLayer
        }
        .rotationEffect(
            .degrees(
                glassesRaised
                    ? EvanJoSleepyLayout.finalGlassesPushRotation
                    : 0
            )
        )
        .offset(
            x: glassesRaised
                ? EvanJoSleepyLayout.finalGlassesPushOffset.width
                : 0,
            y: glassesRaised
                ? EvanJoSleepyLayout.finalGlassesPushOffset.height
                : 0
        )
    }

    private var glassesGroup: some View {
        ZStack {
            normalGlassesLayer
            reflectionGlassesLayer
        }
    }

    private var normalGlassesLayer: some View {
        glassesImage("EvanJoSleepyGlasses")
            .opacity(1 - reflectionAmount)
    }

    private var reflectionGlassesLayer: some View {
        glassesImage("EvanJoSleepyGlassesReflection")
            .opacity(reflectionAmount)
    }

    private func glassesImage(_ assetName: String) -> some View {
        Image(assetName)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(
                width: EvanJoSleepyLayout.glasses.imageSize.width,
                height: EvanJoSleepyLayout.glasses.imageSize.height
            )
            .offset(
                x: EvanJoSleepyLayout.glasses.restingOffset.width,
                y: EvanJoSleepyLayout.glasses.restingOffset.height
            )
    }

    private var handFrontLayer: some View {
        Image("EvanJoSleepyHandFront")
            .resizable()
            .interpolation(.high)
            .frame(
                width: EvanJoSleepyLayout.handFront.imageSize.width,
                height: EvanJoSleepyLayout.handFront.imageSize.height
            )
            .offset(
                x: EvanJoSleepyLayout.handFront.restingOffset.width,
                y: EvanJoSleepyLayout.handFront.restingOffset.height
            )
    }

    private func startAnimation() {
        stopAnimation()
        animationTask = Task { @MainActor in
            do {
                if reduceMotion {
                    try await runReducedMotionAnimation()
                } else {
                    try await runAnimation()
                }
                animationTask = nil
            } catch is CancellationError {
                return
            } catch {
                return
            }
        }
    }

    @MainActor
    private func runAnimation() async throws {
        withAnimation(.easeInOut(duration: 1.00)) {
            mistASettled = true
        }
        withAnimation(.easeInOut(duration: 1.00)) {
            mistBSettled = true
        }

        try await Task.sleep(nanoseconds: 650_000_000)
        withAnimation(.easeInOut(duration: 0.17)) {
            glassesRaised = true
        }
        try await Task.sleep(nanoseconds: 170_000_000)
        showReflection()

        try await Task.sleep(nanoseconds: 60_000_000)
        showBackgroundImpact()

        try await Task.sleep(nanoseconds: 120_000_000)
        showIdea()

        try await Task.sleep(nanoseconds: 200_000_000)
        fadeBackgroundImpact()

        try await Task.sleep(nanoseconds: 220_000_000)
        resetBackgroundImpactWithoutAnimation()
    }

    @MainActor
    private func runReducedMotionAnimation() async throws {
        settleMistWithoutAnimation()

        try await Task.sleep(nanoseconds: 650_000_000)
        raiseGlassesWithoutAnimation()

        try await Task.sleep(nanoseconds: 170_000_000)
        showReflection()

        try await Task.sleep(nanoseconds: 60_000_000)
        showReducedMotionBackgroundImpact()

        try await Task.sleep(nanoseconds: 120_000_000)
        showIdea()

        try await Task.sleep(nanoseconds: 200_000_000)
        fadeBackgroundImpact()

        try await Task.sleep(nanoseconds: 220_000_000)
        resetBackgroundImpactWithoutAnimation()
    }

    private func showReflection() {
        withAnimation(.easeOut(duration: 0.14)) {
            reflectionAmount = 1
        }
    }

    private func showIdea() {
        withAnimation(.easeOut(duration: 0.16)) {
            sparkleOpacity = 1
            sparkleScale = 1
        }
    }

    private func showBackgroundImpact() {
        withAnimation(.easeOut(duration: 0.10)) {
            backgroundImpactOpacity = 1
            backgroundImpactScale = 1
        }
    }

    private func showReducedMotionBackgroundImpact() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            backgroundImpactScale = 1
        }
        withAnimation(.easeOut(duration: 0.10)) {
            backgroundImpactOpacity = 1
        }
    }

    private func fadeBackgroundImpact() {
        withAnimation(.linear(duration: 0.22)) {
            backgroundImpactOpacity = 0
        }
    }

    private func raiseGlassesWithoutAnimation() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            glassesRaised = true
        }
    }

    private func resetBackgroundImpactWithoutAnimation() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            backgroundImpactOpacity = 0
            backgroundImpactScale = 0.92
        }
    }

    private func settleMistWithoutAnimation() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            mistASettled = true
            mistBSettled = true
        }
    }

    private func stopAnimation() {
        animationTask?.cancel()
        animationTask = nil

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            mistASettled = false
            mistBSettled = false
            glassesRaised = false
            reflectionAmount = 0
            backgroundImpactOpacity = 0
            backgroundImpactScale = 0.92
            sparkleOpacity = 0
            sparkleScale = 0.72
        }
    }
}
