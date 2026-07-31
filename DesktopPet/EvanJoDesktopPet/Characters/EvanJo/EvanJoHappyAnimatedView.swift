import SwiftUI

struct EvanJoHappyAnimatedView: View {
    private struct FlowerPiece {
        let maskRect: CGRect
        let anchor: UnitPoint
        let midpointOffset: CGSize
        let finalOffset: CGSize
    }

    private static let flowerPieces = [
        FlowerPiece(
            maskRect: CGRect(x: 0.13, y: 0.16, width: 0.13, height: 0.13),
            anchor: UnitPoint(x: 0.195, y: 0.225),
            midpointOffset: CGSize(width: -10, height: -15),
            finalOffset: CGSize(width: -21, height: -24)
        ),
        FlowerPiece(
            maskRect: CGRect(x: 0.69, y: 0.12, width: 0.16, height: 0.15),
            anchor: UnitPoint(x: 0.77, y: 0.195),
            midpointOffset: CGSize(width: 9, height: -17),
            finalOffset: CGSize(width: 20, height: -27)
        ),
        FlowerPiece(
            maskRect: CGRect(x: 0.78, y: 0.29, width: 0.09, height: 0.10),
            anchor: UnitPoint(x: 0.825, y: 0.34),
            midpointOffset: CGSize(width: 9, height: -7),
            finalOffset: CGSize(width: 18, height: -15)
        ),
        FlowerPiece(
            maskRect: CGRect(x: 0.82, y: 0.48, width: 0.16, height: 0.17),
            anchor: UnitPoint(x: 0.90, y: 0.565),
            midpointOffset: CGSize(width: 16, height: -8),
            finalOffset: CGSize(width: 27, height: -4)
        ),
        FlowerPiece(
            maskRect: CGRect(x: 0.79, y: 0.69, width: 0.12, height: 0.12),
            anchor: UnitPoint(x: 0.85, y: 0.75),
            midpointOffset: CGSize(width: 13, height: 5),
            finalOffset: CGSize(width: 24, height: 15)
        ),
        FlowerPiece(
            maskRect: CGRect(x: 0.04, y: 0.52, width: 0.18, height: 0.18),
            anchor: UnitPoint(x: 0.13, y: 0.61),
            midpointOffset: CGSize(width: -16, height: -7),
            finalOffset: CGSize(width: -27, height: -10)
        ),
        FlowerPiece(
            maskRect: CGRect(x: 0.07, y: 0.66, width: 0.12, height: 0.12),
            anchor: UnitPoint(x: 0.13, y: 0.72),
            midpointOffset: CGSize(width: -12, height: 4),
            finalOffset: CGSize(width: -22, height: 14)
        )
    ]

    @State private var animationTask: Task<Void, Never>?
    @State private var characterOffsetY: CGFloat = 0
    @State private var expandedFlowers = Array(repeating: false, count: 7)
    @State private var flowerOpacities = Array(repeating: 0.0, count: 7)
    @State private var flowerOffsets = Array(repeating: CGSize.zero, count: 7)
    @State private var jumpLineOpacity = 0.0

    var body: some View {
        ZStack {
            ZStack {
                Image("EvanJoHappyBody")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 145, height: 145)
                    .offset(y: 31)

                Image("EvanJoHappyHead")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 145, height: 145)
                    .offset(y: -18)
            }
            .offset(y: characterOffsetY)

            ForEach(Self.flowerPieces.indices, id: \.self) { index in
                let piece = Self.flowerPieces[index]

                Image("EvanJoHappyFlowers")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 156, height: 156)
                    .mask(
                        GeometryReader { geometry in
                            Rectangle()
                                .frame(
                                    width: piece.maskRect.width * geometry.size.width,
                                    height: piece.maskRect.height * geometry.size.height
                                )
                                .position(
                                    x: piece.maskRect.midX * geometry.size.width,
                                    y: piece.maskRect.midY * geometry.size.height
                                )
                        }
                    )
                    .scaleEffect(
                        expandedFlowers[index] ? 1 : 0.4,
                        anchor: piece.anchor
                    )
                    .offset(
                        x: flowerOffsets[index].width,
                        y: flowerOffsets[index].height
                    )
                    .opacity(flowerOpacities[index])
            }

            Image("EvanJoHappyJumpLines")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 145, height: 145)
                .offset(y: 22)
                .opacity(jumpLineOpacity)
        }
        .offset(y: 8)
        .frame(width: 190, height: 166)
        .clipped()
        .onAppear(perform: startAnimation)
        .onDisappear(perform: stopAnimation)
    }

    private func startAnimation() {
        stopAnimation()
        animationTask = Task { @MainActor in
            do {
                try await runAnimation()
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
        withAnimation(.easeOut(duration: 0.16)) {
            characterOffsetY = -8
        }
        withAnimation(.easeOut(duration: 0.08)) {
            jumpLineOpacity = 1
        }

        animateFlowerAppearance(at: 0)
        try await Task.sleep(nanoseconds: 40_000_000)
        animateFlowerAppearance(at: 1)
        try await Task.sleep(nanoseconds: 40_000_000)
        animateFlowerAppearance(at: 2)
        try await Task.sleep(nanoseconds: 40_000_000)
        animateFlowerAppearance(at: 3)
        animateFlowerFinalPosition(at: 0)
        try await Task.sleep(nanoseconds: 40_000_000)

        withAnimation(.easeIn(duration: 0.18)) {
            characterOffsetY = 0
        }
        withAnimation(.easeOut(duration: 0.18)) {
            jumpLineOpacity = 0
        }
        animateFlowerAppearance(at: 4)
        animateFlowerFinalPosition(at: 1)
        try await Task.sleep(nanoseconds: 40_000_000)
        animateFlowerAppearance(at: 5)
        animateFlowerFinalPosition(at: 2)
        try await Task.sleep(nanoseconds: 40_000_000)
        animateFlowerAppearance(at: 6)
        animateFlowerFinalPosition(at: 3)
        try await Task.sleep(nanoseconds: 40_000_000)
        animateFlowerFinalPosition(at: 4)
        try await Task.sleep(nanoseconds: 40_000_000)
        animateFlowerFinalPosition(at: 5)
        try await Task.sleep(nanoseconds: 20_000_000)
        withAnimation(.easeOut(duration: 0.10)) {
            characterOffsetY = -2
        }
        try await Task.sleep(nanoseconds: 20_000_000)
        animateFlowerFinalPosition(at: 6)
        try await Task.sleep(nanoseconds: 80_000_000)
        withAnimation(.easeIn(duration: 0.10)) {
            characterOffsetY = 0
        }

        try await Task.sleep(nanoseconds: 50_000_000)
        for index in Self.flowerPieces.indices {
            withAnimation(.easeOut(duration: 0.22)) {
                flowerOpacities[index] = 0
            }

            if index < Self.flowerPieces.count - 1 {
                try await Task.sleep(nanoseconds: 40_000_000)
            }
        }

        try await Task.sleep(nanoseconds: 220_000_000)
        resetFlowers()
    }

    private func animateFlowerAppearance(at index: Int) {
        let piece = Self.flowerPieces[index]
        withAnimation(.easeOut(duration: 0.12)) {
            expandedFlowers[index] = true
            flowerOpacities[index] = 1
            flowerOffsets[index] = piece.midpointOffset
        }
    }

    private func animateFlowerFinalPosition(at index: Int) {
        withAnimation(.easeOut(duration: 0.12)) {
            flowerOffsets[index] = Self.flowerPieces[index].finalOffset
        }
    }

    private func stopAnimation() {
        animationTask?.cancel()
        animationTask = nil
        resetAnimation()
    }

    private func resetFlowers() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            expandedFlowers = Array(repeating: false, count: Self.flowerPieces.count)
            flowerOpacities = Array(repeating: 0, count: Self.flowerPieces.count)
            flowerOffsets = Array(repeating: .zero, count: Self.flowerPieces.count)
        }
    }

    private func resetAnimation() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            characterOffsetY = 0
            jumpLineOpacity = 0
            expandedFlowers = Array(repeating: false, count: Self.flowerPieces.count)
            flowerOpacities = Array(repeating: 0, count: Self.flowerPieces.count)
            flowerOffsets = Array(repeating: .zero, count: Self.flowerPieces.count)
        }
    }
}
