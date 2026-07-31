import SwiftUI

enum EvanJoCharacterDefinition {
    static let character: PetCharacterDefinition = {
        let normalPanelSize = CGSize(width: 125, height: 132)
        let idlePanelSize = EvanJoIdleLayout.panelSize
        let loadingPanelSize = EvanJoLoadingLayout.panelSize
        let thinkingPanelSize = EvanJoThinkingLayout.panelSize
        let sleepyPanelSize = EvanJoSleepyLayout.panelSize
        let accessibilityLabel = "Evan Jo"

        func appearance(
            id: PetPoseID,
            menuTitle: String,
            assetName: String,
            imageScale: CGFloat,
            horizontalInset: CGFloat,
            alignment: Alignment,
            panelSize: CGSize,
            customRenderer: (() -> AnyView)? = nil
        ) -> PetPoseAppearance {
            PetPoseAppearance(
                id: id,
                menuTitle: menuTitle,
                assetName: assetName,
                logicalCanvasSize: normalPanelSize,
                imageScale: imageScale,
                horizontalInset: horizontalInset,
                imageOffset: .zero,
                alignment: alignment,
                panelSize: panelSize,
                accessibilityLabel: accessibilityLabel,
                customRenderer: customRenderer
            )
        }

        let idle = appearance(
            id: .idle,
            menuTitle: "Idle",
            assetName: "EvanJoIdle",
            imageScale: 1,
            horizontalInset: 0,
            alignment: .center,
            panelSize: idlePanelSize,
            customRenderer: { AnyView(EvanJoIdleAnimatedView()) }
        )
        let happy = appearance(
            id: .happy,
            menuTitle: "Happy",
            assetName: "EvanJoHappy",
            imageScale: 1.18,
            horizontalInset: 0,
            alignment: .bottom,
            panelSize: CGSize(width: 190, height: 166),
            customRenderer: { AnyView(EvanJoHappyAnimatedView()) }
        )
        let loading = appearance(
            id: .loading,
            menuTitle: "Loading",
            assetName: "EvanJoLoading",
            imageScale: 1,
            horizontalInset: 0,
            alignment: .center,
            panelSize: loadingPanelSize,
            customRenderer: { AnyView(EvanJoLoadingAnimatedView()) }
        )
        let thinking = appearance(
            id: .thinking,
            menuTitle: "Speechless",
            assetName: "EvanJoThinking",
            imageScale: 1,
            horizontalInset: 0,
            alignment: .center,
            panelSize: thinkingPanelSize,
            customRenderer: { AnyView(EvanJoThinkingAnimatedView()) }
        )
        let sleepy = appearance(
            id: .sleepy,
            menuTitle: "Brainwave",
            assetName: "EvanJoSleepy",
            imageScale: 1.16,
            horizontalInset: 7,
            alignment: .center,
            panelSize: sleepyPanelSize,
            customRenderer: { AnyView(EvanJoSleepyAnimatedView()) }
        )
        let happyReaction = PetTemporaryPose(
            poseID: .happy,
            duration: 1.8
        )
        let thinkingExpression = PetTemporaryPose(
            poseID: .thinking,
            duration: 5
        )
        let sleepyExpression = PetTemporaryPose(
            poseID: .sleepy,
            duration: 8
        )

        return PetCharacterDefinition(
            id: "evan_jo",
            displayName: "Evan Jo",
            accessibilityLabel: accessibilityLabel,
            defaultPoseID: .idle,
            fallbackAppearance: idle,
            menuPoseIDs: [.idle, .happy, .loading, .thinking, .sleepy],
            additionalAppearances: [happy, loading, thinking, sleepy],
            clickReaction: happyReaction,
            automaticPoseConfiguration: PetAutomaticPoseConfiguration(
                initialIdleDelay: 6...10,
                recoveryIdleDelay: 4...7,
                weightedPoses: [
                    PetWeightedTemporaryPose(
                        temporaryPose: thinkingExpression,
                        weight: 40
                    ),
                    PetWeightedTemporaryPose(
                        temporaryPose: happyReaction,
                        weight: 35
                    ),
                    PetWeightedTemporaryPose(
                        temporaryPose: sleepyExpression,
                        weight: 25
                    )
                ],
                cooldownSelections: [.sleepy: 2]
            )
        )
    }()
}
