import Foundation
import SwiftUI

struct PetPoseID: RawRepresentable, Hashable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    static let idle = PetPoseID(rawValue: "idle")
    static let happy = PetPoseID(rawValue: "happy")
    static let loading = PetPoseID(rawValue: "loading")
    static let thinking = PetPoseID(rawValue: "thinking")
    static let sleepy = PetPoseID(rawValue: "sleepy")
}

struct PetPoseAppearance {
    let id: PetPoseID
    let menuTitle: String
    let assetName: String
    let logicalCanvasSize: CGSize
    let imageScale: CGFloat
    let horizontalInset: CGFloat
    let imageOffset: CGSize
    let alignment: Alignment
    let panelSize: CGSize
    let accessibilityLabel: String
    let customRenderer: (() -> AnyView)?
}

struct PetTemporaryPose {
    let poseID: PetPoseID
    let duration: TimeInterval
}

struct PetWeightedTemporaryPose {
    let temporaryPose: PetTemporaryPose
    let weight: Int
}

struct PetAutomaticPoseConfiguration {
    let initialIdleDelay: ClosedRange<TimeInterval>
    let recoveryIdleDelay: ClosedRange<TimeInterval>
    let weightedPoses: [PetWeightedTemporaryPose]
    let cooldownSelections: [PetPoseID: Int]
}

enum PetAutomaticPoseSelector {
    static func select(
        from weightedPoses: [PetWeightedTemporaryPose],
        excluding lastExpressivePoseID: PetPoseID?,
        cooldowns: [PetPoseID: Int],
        randomUnit: Double
    ) -> PetTemporaryPose? {
        let candidates = weightedPoses.filter { candidate in
            candidate.weight > 0
                && candidate.temporaryPose.poseID != lastExpressivePoseID
                && cooldowns[candidate.temporaryPose.poseID, default: 0] == 0
        }
        let totalWeight = candidates.reduce(0) { $0 + $1.weight }
        guard totalWeight > 0 else { return nil }

        let boundedRandom = min(max(randomUnit, 0), 1)
        let target = min(
            Int(boundedRandom * Double(totalWeight)),
            totalWeight - 1
        )

        var cumulativeWeight = 0
        for candidate in candidates {
            cumulativeWeight += candidate.weight
            if target < cumulativeWeight {
                return candidate.temporaryPose
            }
        }
        return candidates.last?.temporaryPose
    }
}

struct PetCharacterDefinition {
    let id: String
    let displayName: String
    let accessibilityLabel: String
    let defaultPoseID: PetPoseID
    let fallbackPoseID: PetPoseID
    let menuPoseIDs: [PetPoseID]
    let automaticPoseConfiguration: PetAutomaticPoseConfiguration?

    private let appearances: [PetPoseID: PetPoseAppearance]
    private let fallbackAppearance: PetPoseAppearance
    private let defaultClickReaction: PetTemporaryPose?
    private let clickReactionOverrides: [PetPoseID: PetTemporaryPose]

    init(
        id: String,
        displayName: String,
        accessibilityLabel: String,
        defaultPoseID: PetPoseID,
        fallbackAppearance: PetPoseAppearance,
        menuPoseIDs: [PetPoseID],
        additionalAppearances: [PetPoseAppearance],
        clickReaction: PetTemporaryPose?,
        clickReactionOverrides: [PetPoseID: PetTemporaryPose],
        automaticPoseConfiguration: PetAutomaticPoseConfiguration?
    ) {
        var appearances = [fallbackAppearance.id: fallbackAppearance]
        for appearance in additionalAppearances {
            appearances[appearance.id] = appearance
        }

        self.id = id
        self.displayName = displayName
        self.accessibilityLabel = accessibilityLabel
        self.defaultPoseID = defaultPoseID
        self.fallbackPoseID = fallbackAppearance.id
        self.menuPoseIDs = menuPoseIDs.filter { appearances[$0] != nil }
        self.defaultClickReaction = clickReaction.flatMap {
            appearances[$0.poseID] == nil ? nil : $0
        }
        self.clickReactionOverrides = clickReactionOverrides.filter {
            appearances[$0.key] != nil
                && appearances[$0.value.poseID] != nil
        }

        if let configuration = automaticPoseConfiguration {
            let weightedPoses = configuration.weightedPoses.filter {
                let poseID = $0.temporaryPose.poseID
                return $0.weight > 0
                    && poseID != defaultPoseID
                    && appearances[poseID] != nil
            }
            let automaticPoseIDs = Set(
                weightedPoses.map(\.temporaryPose.poseID)
            )
            let cooldownSelections = configuration.cooldownSelections.filter {
                automaticPoseIDs.contains($0.key) && $0.value > 0
            }
            self.automaticPoseConfiguration = weightedPoses.isEmpty
                ? nil
                : PetAutomaticPoseConfiguration(
                    initialIdleDelay: configuration.initialIdleDelay,
                    recoveryIdleDelay: configuration.recoveryIdleDelay,
                    weightedPoses: weightedPoses,
                    cooldownSelections: cooldownSelections
                )
        } else {
            self.automaticPoseConfiguration = nil
        }
        self.appearances = appearances
        self.fallbackAppearance = fallbackAppearance
    }

    var menuAppearances: [PetPoseAppearance] {
        menuPoseIDs.compactMap { appearances[$0] }
    }

    func appearance(for poseID: PetPoseID) -> PetPoseAppearance {
        appearances[poseID] ?? fallbackAppearance
    }

    func clickReaction(for poseID: PetPoseID) -> PetTemporaryPose? {
        clickReactionOverrides[poseID] ?? defaultClickReaction
    }
}
