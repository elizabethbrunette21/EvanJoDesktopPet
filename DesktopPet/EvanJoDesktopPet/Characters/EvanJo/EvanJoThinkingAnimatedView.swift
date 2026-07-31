import SwiftUI

enum EvanJoThinkingLayout {
    static let panelSize = CGSize(width: 176, height: 154)

    static let bodyImageSize: CGFloat = 177
    static let bodyRestingOffsetY: CGFloat = 17

    static let glassesImageSize = CGSize(width: 101, height: 26)
    static let glassesRestingOffset = CGSize(width: 13, height: -5)

    static let bubbleImageSize: CGFloat = 92
    static let bubbleRestingOffset = CGSize(width: -45, height: -45)
    static let bubbleAnchor = UnitPoint(x: 0.49, y: 0.70)

    struct DotLayout {
        let assetName: String
        let imageSize: CGFloat
        let restingOffset: CGSize
    }

    static let dots = [
        DotLayout(
            assetName: "EvanJoThinkingDot1",
            imageSize: 177,
            restingOffset: CGSize(width: -53, height: -51)
        ),
        DotLayout(
            assetName: "EvanJoThinkingDot2",
            imageSize: 149,
            restingOffset: CGSize(width: -42, height: -51)
        ),
        DotLayout(
            assetName: "EvanJoThinkingDot3",
            imageSize: 168,
            restingOffset: CGSize(width: -31, height: -52)
        )
    ]

    private static let referenceCanvasSize: CGFloat = 1254
    private static let referenceContentBounds = CGRect(
        x: 176,
        y: 31,
        width: 872,
        height: 1163
    )
    private static let referenceLeafCenter = CGPoint(x: 665.5, y: 1048)
    private static let bodySourceContentBounds = CGRect(
        x: 282,
        y: 126,
        width: 772,
        height: 914
    )
    private static let leafSourceContentBounds = CGRect(
        x: 341,
        y: 337,
        width: 575,
        height: 527
    )

    static let bodyVisibleFrame = CGRect(
        x: -bodyImageSize / 2
            + bodySourceContentBounds.minX / referenceCanvasSize * bodyImageSize,
        y: -bodyImageSize / 2 + bodyRestingOffsetY
            + bodySourceContentBounds.minY / referenceCanvasSize * bodyImageSize,
        width: bodySourceContentBounds.width / referenceCanvasSize * bodyImageSize,
        height: bodySourceContentBounds.height / referenceCanvasSize * bodyImageSize
    )
    static let leafVisibleWidth = bodyVisibleFrame.width * 0.115
    static let leafContentAspectRatio = leafSourceContentBounds.height
        / leafSourceContentBounds.width
    static let leafVisibleSize = CGSize(
        width: leafVisibleWidth,
        height: leafVisibleWidth * leafContentAspectRatio
    )
    static let leafSourceScale = leafVisibleWidth / leafSourceContentBounds.width
    static let leafCanvasRenderSize = referenceCanvasSize * leafSourceScale
    static let leafCanvasAlignmentOffset = CGSize(
        width: -(leafSourceContentBounds.midX - referenceCanvasSize / 2)
            * leafSourceScale,
        height: -(leafSourceContentBounds.midY - referenceCanvasSize / 2)
            * leafSourceScale
    )
    private static let referenceScale = min(
        panelSize.width / referenceContentBounds.width,
        panelSize.height / referenceContentBounds.height
    )
    private static let referenceContentFrame = CGRect(
        x: -(referenceContentBounds.width * referenceScale) / 2,
        y: -(referenceContentBounds.height * referenceScale) / 2,
        width: referenceContentBounds.width * referenceScale,
        height: referenceContentBounds.height * referenceScale
    )
    private static let referenceCanvasFrame = CGRect(
        x: referenceContentFrame.minX
            - referenceContentBounds.minX * referenceScale,
        y: referenceContentFrame.minY
            - referenceContentBounds.minY * referenceScale,
        width: referenceCanvasSize * referenceScale,
        height: referenceCanvasSize * referenceScale
    )
    private static let currentPathEnd = CGSize(
        width: (leafSourceContentBounds.midX - referenceCanvasSize / 2)
            / referenceCanvasSize * bodyImageSize,
        height: bodyRestingOffsetY
            + (leafSourceContentBounds.midY - referenceCanvasSize / 2)
                / referenceCanvasSize * bodyImageSize
    )
    private static let expectedLeafEnd: CGSize = {
        let point = resolveReferencePoint(
            referenceLeafCenter,
            in: referenceCanvasFrame
        )
        return CGSize(width: point.x, height: point.y)
    }()
    private static let leafPathTranslation = CGSize(
        width: expectedLeafEnd.width - currentPathEnd.width,
        height: expectedLeafEnd.height - currentPathEnd.height
    )
    static let finalLeafPosition = CGSize(
        width: currentPathEnd.width + leafPathTranslation.width,
        height: currentPathEnd.height + leafPathTranslation.height
    )

    struct LeafPathSample {
        let position: CGSize
        let cumulativeDistance: CGFloat
    }

    static let leafMovementDuration = 1.62
    static let leafPathPixelSamples = [
        CGPoint(x: 361.0, y: 808.0),
        CGPoint(x: 357.1, y: 807.2),
        CGPoint(x: 353.2, y: 806.4),
        CGPoint(x: 349.2, y: 806.1),
        CGPoint(x: 345.3, y: 806.7),
        CGPoint(x: 341.5, y: 807.9),
        CGPoint(x: 338.0, y: 809.8),
        CGPoint(x: 334.8, y: 812.3),
        CGPoint(x: 332.1, y: 815.2),
        CGPoint(x: 329.8, y: 818.4),
        CGPoint(x: 328.0, y: 822.0),
        CGPoint(x: 326.5, y: 825.7),
        CGPoint(x: 325.4, y: 829.6),
        CGPoint(x: 324.9, y: 833.6),
        CGPoint(x: 324.5, y: 837.5),
        CGPoint(x: 324.1, y: 841.5),
        CGPoint(x: 324.0, y: 845.5),
        CGPoint(x: 324.0, y: 849.5),
        CGPoint(x: 324.4, y: 853.5),
        CGPoint(x: 324.8, y: 857.5),
        CGPoint(x: 325.4, y: 861.4),
        CGPoint(x: 326.2, y: 865.3),
        CGPoint(x: 327.2, y: 869.2),
        CGPoint(x: 328.4, y: 873.0),
        CGPoint(x: 329.8, y: 876.7),
        CGPoint(x: 331.2, y: 880.5),
        CGPoint(x: 332.6, y: 884.3),
        CGPoint(x: 334.3, y: 887.9),
        CGPoint(x: 336.3, y: 891.3),
        CGPoint(x: 338.6, y: 894.6),
        CGPoint(x: 341.1, y: 897.7),
        CGPoint(x: 343.6, y: 900.9),
        CGPoint(x: 346.2, y: 903.8),
        CGPoint(x: 349.1, y: 906.6),
        CGPoint(x: 352.2, y: 909.1),
        CGPoint(x: 355.3, y: 911.6),
        CGPoint(x: 358.6, y: 913.9),
        CGPoint(x: 362.0, y: 916.1),
        CGPoint(x: 365.5, y: 918.0),
        CGPoint(x: 369.1, y: 919.7),
        CGPoint(x: 372.8, y: 921.2),
        CGPoint(x: 376.6, y: 922.4),
        CGPoint(x: 380.5, y: 923.3),
        CGPoint(x: 384.4, y: 924.0),
        CGPoint(x: 388.4, y: 924.6),
        CGPoint(x: 392.3, y: 925.0),
        CGPoint(x: 396.3, y: 924.8),
        CGPoint(x: 400.0, y: 923.3),
        CGPoint(x: 403.8, y: 922.2),
        CGPoint(x: 407.2, y: 924.1),
        CGPoint(x: 408.9, y: 927.7),
        CGPoint(x: 410.5, y: 931.4),
        CGPoint(x: 412.5, y: 934.8),
        CGPoint(x: 415.1, y: 937.9),
        CGPoint(x: 417.8, y: 940.8),
        CGPoint(x: 420.8, y: 943.5),
        CGPoint(x: 423.8, y: 946.1),
        CGPoint(x: 426.8, y: 948.8),
        CGPoint(x: 429.7, y: 951.4),
        CGPoint(x: 432.8, y: 954.1),
        CGPoint(x: 435.9, y: 956.5),
        CGPoint(x: 439.1, y: 959.0),
        CGPoint(x: 442.4, y: 961.3),
        CGPoint(x: 445.6, y: 963.6),
        CGPoint(x: 448.9, y: 965.9),
        CGPoint(x: 452.2, y: 968.1),
        CGPoint(x: 455.6, y: 970.2),
        CGPoint(x: 459.0, y: 972.2),
        CGPoint(x: 462.5, y: 974.3),
        CGPoint(x: 466.0, y: 976.2),
        CGPoint(x: 469.6, y: 978.0),
        CGPoint(x: 473.1, y: 979.8),
        CGPoint(x: 476.7, y: 981.6),
        CGPoint(x: 480.3, y: 983.4),
        CGPoint(x: 484.1, y: 984.3),
        CGPoint(x: 488.1, y: 983.9),
        CGPoint(x: 492.0, y: 983.7),
        CGPoint(x: 495.8, y: 984.9),
        CGPoint(x: 499.5, y: 986.5),
        CGPoint(x: 503.2, y: 988.1),
        CGPoint(x: 506.9, y: 989.5),
        CGPoint(x: 510.5, y: 991.1),
        CGPoint(x: 514.2, y: 992.6),
        CGPoint(x: 518.0, y: 994.0),
        CGPoint(x: 521.8, y: 995.2),
        CGPoint(x: 525.7, y: 996.3),
        CGPoint(x: 529.5, y: 997.5),
        CGPoint(x: 533.3, y: 998.8),
        CGPoint(x: 537.1, y: 1000.0),
        CGPoint(x: 540.9, y: 1001.1),
        CGPoint(x: 544.8, y: 1002.2),
        CGPoint(x: 548.6, y: 1003.2),
        CGPoint(x: 552.5, y: 1004.2),
        CGPoint(x: 556.4, y: 1005.1),
        CGPoint(x: 560.3, y: 1005.8),
        CGPoint(x: 564.2, y: 1006.6),
        CGPoint(x: 568.2, y: 1007.4),
        CGPoint(x: 572.1, y: 1007.9),
        CGPoint(x: 576.1, y: 1008.6),
        CGPoint(x: 580.0, y: 1009.0),
        CGPoint(x: 583.9, y: 1009.8),
        CGPoint(x: 586.0, y: 1012.0),
        CGPoint(x: 665.5, y: 1048.0)
    ]
    static let leafPathSamples = makeLeafPathSamples()

    private static func resolveReferencePoint(
        _ pixelPoint: CGPoint,
        in canvasFrame: CGRect
    ) -> CGPoint {
        CGPoint(
            x: canvasFrame.minX
                + pixelPoint.x / referenceCanvasSize * canvasFrame.width,
            y: canvasFrame.minY
                + pixelPoint.y / referenceCanvasSize * canvasFrame.height
        )
    }

    private static func makeLeafPathSamples() -> [LeafPathSample] {
        var positions = leafPathPixelSamples.map { point in
            CGSize(
                width: currentPathEnd.width
                    + (point.x - referenceLeafCenter.x)
                        / referenceCanvasSize * bodyImageSize
                    + leafPathTranslation.width,
                height: currentPathEnd.height
                    + (point.y - referenceLeafCenter.y)
                        / referenceCanvasSize * bodyImageSize
                    + leafPathTranslation.height
            )
        }
        positions[positions.count - 1] = finalLeafPosition

        var cumulativeDistance: CGFloat = 0
        return positions.enumerated().map { index, position in
            if index > 0 {
                let previous = positions[index - 1]
                let deltaX = position.width - previous.width
                let deltaY = position.height - previous.height
                cumulativeDistance += (deltaX * deltaX + deltaY * deltaY).squareRoot()
            }
            return LeafPathSample(
                position: position,
                cumulativeDistance: cumulativeDistance
            )
        }
    }
}

private struct EvanJoThinkingLeafImage: View {
    var body: some View {
        Image("EvanJoThinkingLeaf")
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(
                width: EvanJoThinkingLayout.leafCanvasRenderSize,
                height: EvanJoThinkingLayout.leafCanvasRenderSize
            )
            .offset(
                x: EvanJoThinkingLayout.leafCanvasAlignmentOffset.width,
                y: EvanJoThinkingLayout.leafCanvasAlignmentOffset.height
            )
            .frame(
                width: EvanJoThinkingLayout.leafVisibleSize.width,
                height: EvanJoThinkingLayout.leafVisibleSize.height
            )
            .clipped()
    }
}

private struct EvanJoThinkingLeafPathEffect: AnimatableModifier {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        let progress = min(max(progress, 0), 1)
        let position = position(for: progress)

        return content
            .offset(x: position.width, y: position.height)
    }

    private func position(for progress: CGFloat) -> CGSize {
        let samples = EvanJoThinkingLayout.leafPathSamples
        guard let finalSample = samples.last else {
            return .zero
        }

        let targetDistance = progress * finalSample.cumulativeDistance
        for index in 1..<samples.count {
            let end = samples[index]
            if targetDistance <= end.cumulativeDistance {
                let start = samples[index - 1]
                let segmentDistance = end.cumulativeDistance - start.cumulativeDistance
                let localProgress = segmentDistance > 0
                    ? (targetDistance - start.cumulativeDistance) / segmentDistance
                    : 0
                return CGSize(
                    width: start.position.width
                        + (end.position.width - start.position.width) * localProgress,
                    height: start.position.height
                        + (end.position.height - start.position.height) * localProgress
                )
            }
        }

        return finalSample.position
    }
}

struct EvanJoThinkingAnimatedView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var animationTask: Task<Void, Never>?
    @State private var isGlassesRaised = false
    @State private var bubbleOpacity = 0.0
    @State private var isBubbleExpanded = false
    @State private var dotOpacities = Array(repeating: 0.0, count: EvanJoThinkingLayout.dots.count)
    @State private var visibleDots = Array(repeating: false, count: EvanJoThinkingLayout.dots.count)
    @State private var leafOpacity = 0.0
    @State private var leafProgress: CGFloat = 0

    var body: some View {
        ZStack {
            Image("EvanJoThinkingBody")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(
                    width: EvanJoThinkingLayout.bodyImageSize,
                    height: EvanJoThinkingLayout.bodyImageSize
                )
                .offset(y: EvanJoThinkingLayout.bodyRestingOffsetY)

            Image("EvanJoThinkingGlasses")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(
                    width: EvanJoThinkingLayout.glassesImageSize.width,
                    height: EvanJoThinkingLayout.glassesImageSize.height
                )
                .rotationEffect(.degrees(isGlassesRaised ? -0.75 : 0))
                .offset(
                    x: EvanJoThinkingLayout.glassesRestingOffset.width,
                    y: EvanJoThinkingLayout.glassesRestingOffset.height
                        + (isGlassesRaised ? -3.5 : 0)
                )

            Image("EvanJoThinkingBubble")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(
                    width: EvanJoThinkingLayout.bubbleImageSize,
                    height: EvanJoThinkingLayout.bubbleImageSize
                )
                .scaleEffect(
                    isBubbleExpanded ? 1 : 0.86,
                    anchor: EvanJoThinkingLayout.bubbleAnchor
                )
                .opacity(bubbleOpacity)
                .offset(
                    x: EvanJoThinkingLayout.bubbleRestingOffset.width,
                    y: EvanJoThinkingLayout.bubbleRestingOffset.height
                )

            ForEach(EvanJoThinkingLayout.dots.indices, id: \.self) { index in
                let dot = EvanJoThinkingLayout.dots[index]
                Image(dot.assetName)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: dot.imageSize, height: dot.imageSize)
                    .scaleEffect(visibleDots[index] ? 1 : 0.7)
                    .opacity(dotOpacities[index])
                    .offset(
                        x: dot.restingOffset.width,
                        y: dot.restingOffset.height
                    )
            }

            EvanJoThinkingLeafImage()
                .modifier(EvanJoThinkingLeafPathEffect(progress: leafProgress))
                .opacity(leafOpacity)
        }
        .frame(
            width: EvanJoThinkingLayout.panelSize.width,
            height: EvanJoThinkingLayout.panelSize.height
        )
        .clipped()
        .onAppear(perform: startAnimation)
        .onDisappear(perform: stopAnimation)
    }

    private func startAnimation() {
        stopAnimation()
        animationTask = Task { @MainActor in
            do {
                try await runAnimation(reduceMotion: reduceMotion)
                animationTask = nil
            } catch is CancellationError {
                return
            } catch {
                return
            }
        }
    }

    @MainActor
    private func runAnimation(reduceMotion: Bool) async throws {
        if !reduceMotion {
            withAnimation(.easeInOut(duration: 0.14)) {
                isGlassesRaised = true
            }
            try await Task.sleep(nanoseconds: 140_000_000)
            try await Task.sleep(nanoseconds: 60_000_000)
            withAnimation(.easeInOut(duration: 0.16)) {
                isGlassesRaised = false
            }
            try await Task.sleep(nanoseconds: 140_000_000)
        } else {
            try await Task.sleep(nanoseconds: 340_000_000)
        }

        showBubble()
        try await Task.sleep(nanoseconds: 280_000_000)
        showDot(at: 0)
        try await Task.sleep(nanoseconds: 200_000_000)
        showDot(at: 1)
        try await Task.sleep(nanoseconds: 180_000_000)

        if reduceMotion {
            withAnimation(.linear(duration: 0.12)) {
                leafOpacity = 1
            }
        } else {
            withAnimation(.linear(duration: 0.12)) {
                leafOpacity = 1
            }
            withAnimation(.linear(duration: EvanJoThinkingLayout.leafMovementDuration)) {
                leafProgress = 1
            }
        }

        try await Task.sleep(nanoseconds: 20_000_000)
        showDot(at: 2)

        if reduceMotion {
            try await Task.sleep(nanoseconds: 1_630_000_000)
            withAnimation(.easeOut(duration: 0.25)) {
                leafOpacity = 0
            }
            try await Task.sleep(nanoseconds: 270_000_000)
            resetLeaf()
            try await Task.sleep(nanoseconds: 1_430_000_000)
        } else {
            try await Task.sleep(nanoseconds: 1_760_000_000)
            withAnimation(.easeOut(duration: 0.28)) {
                leafOpacity = 0
            }
            try await Task.sleep(nanoseconds: 300_000_000)
            resetLeaf()
            try await Task.sleep(nanoseconds: 1_270_000_000)
        }
    }

    private func showBubble() {
        withAnimation(.easeOut(duration: 0.22)) {
            bubbleOpacity = 1
            isBubbleExpanded = true
        }
    }

    private func showDot(at index: Int) {
        withAnimation(.easeOut(duration: 0.14)) {
            visibleDots[index] = true
            dotOpacities[index] = 1
        }
    }

    private func stopAnimation() {
        animationTask?.cancel()
        animationTask = nil
        resetAnimation()
    }

    private func resetLeaf() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            leafOpacity = 0
            leafProgress = 0
        }
    }

    private func resetAnimation() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            isGlassesRaised = false
            bubbleOpacity = 0
            isBubbleExpanded = false
            dotOpacities = Array(repeating: 0, count: EvanJoThinkingLayout.dots.count)
            visibleDots = Array(repeating: false, count: EvanJoThinkingLayout.dots.count)
            leafOpacity = 0
            leafProgress = 0
        }
    }
}
