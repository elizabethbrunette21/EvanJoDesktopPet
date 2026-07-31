import SwiftUI

enum EvanJoIdleLayout {
    static let panelSize = CGSize(width: 160, height: 148)
    static let bodyImageSize: CGFloat = 123
    static let bodyOffsetY: CGFloat = 41
    static let headImageSize: CGFloat = 139
    static let headRestingOffsetY: CGFloat = -15.5
    static let contentRestingOffsetY: CGFloat = 8

    static var headFrame: CGRect {
        CGRect(
            x: (panelSize.width - headImageSize) / 2,
            y: (panelSize.height - headImageSize) / 2
                + headRestingOffsetY
                + contentRestingOffsetY,
            width: headImageSize,
            height: headImageSize
        )
    }

    static var headPettingRegion: CGRect {
        CGRect(
            x: headFrame.minX + 20,
            y: headFrame.minY + 27,
            width: headFrame.width - 40,
            height: 78
        )
    }
}

private struct PettingGestureDetector {
    private static let minimumMovement: CGFloat = 2
    private static let minimumLegDistance: CGFloat = 7
    private static let minimumTotalDistance: CGFloat = 20
    private static let maximumDuration: TimeInterval = 1.35

    private var startedAt: TimeInterval?
    private var previousX: CGFloat?
    private var legStartX: CGFloat?
    private var direction = 0
    private var reversalCount = 0
    private var totalDistance: CGFloat = 0

    mutating func registerMovement(x: CGFloat, timestamp: TimeInterval) -> Bool {
        guard let startedAt, let previousX, let legStartX else {
            begin(at: x, timestamp: timestamp)
            return false
        }

        guard timestamp - startedAt <= Self.maximumDuration else {
            begin(at: x, timestamp: timestamp)
            return false
        }

        let delta = x - previousX
        guard abs(delta) >= Self.minimumMovement else { return false }

        let newDirection = delta > 0 ? 1 : -1
        totalDistance += abs(delta)

        if direction == 0 {
            direction = newDirection
        } else if newDirection != direction,
                  abs(previousX - legStartX) >= Self.minimumLegDistance {
            reversalCount += 1
            direction = newDirection
            self.legStartX = previousX
        }

        self.previousX = x

        guard reversalCount >= 2, totalDistance >= Self.minimumTotalDistance else {
            return false
        }

        reset()
        return true
    }

    mutating func reset() {
        startedAt = nil
        previousX = nil
        legStartX = nil
        direction = 0
        reversalCount = 0
        totalDistance = 0
    }

    private mutating func begin(at x: CGFloat, timestamp: TimeInterval) {
        startedAt = timestamp
        previousX = x
        legStartX = x
        direction = 0
        reversalCount = 0
        totalDistance = 0
    }
}

struct EvanJoIdleAnimatedView: View {
    private static let sparkleAssets = [
        "EvanJoIdleSparkle01",
        "EvanJoIdleSparkle02",
        "EvanJoIdleSparkle03",
        "EvanJoIdleSparkle04",
        "EvanJoIdleSparkle05",
        "EvanJoIdleSparkleDot"
    ]
    private static let sparkleOutwardOffsets = [
        CGSize(width: 11, height: -4),
        CGSize(width: -6, height: -8),
        CGSize(width: -11, height: -4),
        CGSize(width: 10, height: 9),
        CGSize(width: -10, height: 9),
        CGSize(width: -8, height: 3)
    ]

    @State private var nodTask: Task<Void, Never>?
    @State private var feedbackTask: Task<Void, Never>?
    @State private var isNodding = false
    @State private var pettingDetector = PettingGestureDetector()
    @State private var sparkleCooldownUntil: TimeInterval = 0
    @State private var expandedSparkles = Array(repeating: false, count: 6)
    @State private var sparkleOpacities = Array(repeating: 0.0, count: 6)
    @State private var sparkleTranslations = Array(repeating: CGSize.zero, count: 6)

    var body: some View {
        ZStack {
            Image("EvanJoIdleBody")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(
                    width: EvanJoIdleLayout.bodyImageSize,
                    height: EvanJoIdleLayout.bodyImageSize
                )
                .offset(
                    y: EvanJoIdleLayout.bodyOffsetY
                        + EvanJoIdleLayout.contentRestingOffsetY
                )

            Image("EvanJoIdleHead")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(
                    width: EvanJoIdleLayout.headImageSize,
                    height: EvanJoIdleLayout.headImageSize
                )
                .scaleEffect(x: 1, y: isNodding ? 0.985 : 1, anchor: .bottom)
                .offset(
                    y: EvanJoIdleLayout.headRestingOffsetY
                        + EvanJoIdleLayout.contentRestingOffsetY
                        + (isNodding ? 1.5 : 0)
                )

            ForEach(Self.sparkleAssets.indices, id: \.self) { index in
                Image(Self.sparkleAssets[index])
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(
                        width: EvanJoIdleLayout.headImageSize,
                        height: EvanJoIdleLayout.headImageSize
                    )
                    .scaleEffect(expandedSparkles[index] ? 1.18 : 0.42)
                    .opacity(sparkleOpacities[index])
                    .offset(
                        x: sparkleTranslations[index].width,
                        y: EvanJoIdleLayout.headRestingOffsetY
                            + EvanJoIdleLayout.contentRestingOffsetY
                            + sparkleTranslations[index].height
                    )
            }

            EvanJoIdlePettingTrackingView(
                onPointerEntered: resetPettingGesture,
                onPointerExited: resetPettingGesture,
                onPointerInteraction: resetPettingGesture,
                onPointerDragged: cancelPettingFeedback,
                onPointerMoved: handlePettingMovement
            )
            .frame(
                width: EvanJoIdleLayout.headPettingRegion.width,
                height: EvanJoIdleLayout.headPettingRegion.height
            )
            .position(
                x: EvanJoIdleLayout.headPettingRegion.midX,
                y: EvanJoIdleLayout.headPettingRegion.midY
            )
        }
        .frame(
            width: EvanJoIdleLayout.panelSize.width,
            height: EvanJoIdleLayout.panelSize.height
        )
        .clipped()
        .onAppear(perform: startAnimation)
        .onDisappear(perform: stopAnimation)
    }

    private func startAnimation() {
        stopAnimation()
        startAutomaticNods(after: 2_000_000_000)
    }

    private func startAutomaticNods(after initialDelay: UInt64) {
        guard nodTask == nil else { return }

        nodTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: initialDelay)
                while !Task.isCancelled {
                    guard feedbackTask == nil else {
                        try await Task.sleep(nanoseconds: 250_000_000)
                        continue
                    }

                    try await runNodSequence(withSparkles: false)
                    try await Task.sleep(nanoseconds: 7_260_000_000)
                }
            } catch is CancellationError {
                return
            } catch {
                return
            }
        }
    }

    @MainActor
    private func runNodSequence(withSparkles: Bool) async throws {
        withAnimation(.easeInOut(duration: 0.15)) {
            isNodding = true
        }
        try await Task.sleep(nanoseconds: 150_000_000)

        withAnimation(.easeOut(duration: 0.17)) {
            isNodding = false
        }
        try await Task.sleep(nanoseconds: 170_000_000)
        try await Task.sleep(nanoseconds: 80_000_000)

        withAnimation(.easeInOut(duration: 0.15)) {
            isNodding = true
        }
        try await Task.sleep(nanoseconds: 150_000_000)

        withAnimation(.easeOut(duration: 0.19)) {
            isNodding = false
        }

        if withSparkles {
            try await runSparkleSequence()
        }
    }

    private func handlePettingMovement(x: CGFloat, timestamp: TimeInterval) {
        guard feedbackTask == nil else {
            resetPettingGesture()
            return
        }

        guard timestamp >= sparkleCooldownUntil else {
            resetPettingGesture()
            return
        }

        guard pettingDetector.registerMovement(x: x, timestamp: timestamp) else {
            return
        }

        sparkleCooldownUntil = timestamp + 1.2
        playPettingFeedback()
    }

    private func playPettingFeedback() {
        guard feedbackTask == nil else { return }

        nodTask?.cancel()
        nodTask = nil
        resetNod()

        feedbackTask = Task { @MainActor in
            do {
                try await runNodSequence(withSparkles: true)
                feedbackTask = nil
                startAutomaticNods(after: 7_260_000_000)
            } catch is CancellationError {
                return
            } catch {
                return
            }
        }
    }

    @MainActor
    private func runSparkleSequence() async throws {
        for index in Self.sparkleAssets.indices {
            withAnimation(.easeOut(duration: 0.21)) {
                expandedSparkles[index] = true
                sparkleOpacities[index] = 1
                sparkleTranslations[index] = Self.sparkleOutwardOffsets[index]
            }
            try await Task.sleep(nanoseconds: 80_000_000)
        }

        try await Task.sleep(nanoseconds: 390_000_000)
        withAnimation(.easeOut(duration: 0.22)) {
            sparkleOpacities = Array(repeating: 0, count: Self.sparkleAssets.count)
        }
        try await Task.sleep(nanoseconds: 220_000_000)
        resetSparkles()
    }

    private func cancelPettingFeedback() {
        resetPettingGesture()
        feedbackTask?.cancel()
        feedbackTask = nil
        resetNod()
        resetSparkles()
        startAutomaticNods(after: 7_260_000_000)
    }

    private func stopAnimation() {
        nodTask?.cancel()
        nodTask = nil
        feedbackTask?.cancel()
        feedbackTask = nil
        resetNod()
        sparkleCooldownUntil = 0
        resetPettingGesture()
        resetSparkles()
    }

    private func resetPettingGesture() {
        pettingDetector.reset()
    }

    private func resetNod() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            isNodding = false
        }
    }

    private func resetSparkles() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            expandedSparkles = Array(repeating: false, count: Self.sparkleAssets.count)
            sparkleOpacities = Array(repeating: 0, count: Self.sparkleAssets.count)
            sparkleTranslations = Array(repeating: .zero, count: Self.sparkleAssets.count)
        }
    }
}
