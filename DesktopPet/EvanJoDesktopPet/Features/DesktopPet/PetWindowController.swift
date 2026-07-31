import AppKit
import ColorSync
import SwiftUI

@MainActor
final class PetWindowController: NSObject {
    private static let screenMargin: CGFloat = 24

    private enum BehaviorMode {
        case automatic
        case fixed(PetPoseID)
    }

    private enum PositionStorage {
        static let defaultsKey = "desktopPet.panelPosition"
        static let formatVersion = 1
        static let versionKey = "version"
        static let originXKey = "originX"
        static let originYKey = "originY"
        static let screenIdentifierKey = "screenIdentifier"
    }

    private struct SavedPosition {
        let origin: NSPoint
        let screenIdentifier: String?
    }

    private let character: PetCharacterDefinition
    private let panel: PetPanel
    private let interactionView: PetInteractionView
    private let hostingView: NSHostingView<PetRootView>
    private let defaults = UserDefaults.standard
    private var behaviorMode = BehaviorMode.automatic
    private var currentPoseID: PetPoseID
    private var automaticPoseItem: NSMenuItem?
    private var poseItems: [PetPoseID: NSMenuItem] = [:]
    private var autoCycleTask: Task<Void, Never>?
    private var autoCycleGeneration = 0
    private var lastExpressivePoseID: PetPoseID?
    private var remainingPoseCooldowns: [PetPoseID: Int] = [:]
    private var isInteractionSequenceActive = false
    private var isLoadingOverrideActive = false
    private var screenParametersObserver: NSObjectProtocol?

    init(character: PetCharacterDefinition) {
        let initialAppearance = character.appearance(for: character.defaultPoseID)
        let contentRect = NSRect(origin: .zero, size: initialAppearance.panelSize)
        let panel = PetPanel(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.isMovable = false
        panel.isMovableByWindowBackground = false
        panel.ignoresMouseEvents = false
        panel.acceptsMouseMovedEvents = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let interactionView = PetInteractionView(frame: contentRect)
        interactionView.autoresizingMask = [.width, .height]
        interactionView.wantsLayer = true
        interactionView.layer?.backgroundColor = NSColor.clear.cgColor

        let hostingView = NSHostingView(rootView: PetRootView(appearance: initialAppearance))
        hostingView.frame = interactionView.bounds
        hostingView.autoresizingMask = [.width, .height]
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor
        interactionView.addSubview(hostingView)
        panel.contentView = interactionView

        self.character = character
        self.panel = panel
        self.interactionView = interactionView
        self.hostingView = hostingView
        self.currentPoseID = initialAppearance.id

        super.init()

        interactionView.onClick = { [weak self] in
            self?.handleClick()
        }
        interactionView.onDragBegan = { [weak self] in
            self?.beginDragging()
        }
        interactionView.onDrag = { [weak self] proposedOrigin, pointerLocation in
            self?.movePanel(to: proposedOrigin, pointerLocation: pointerLocation)
        }
        interactionView.onDragEnded = { [weak self] pointerLocation in
            self?.finishDragging(pointerLocation: pointerLocation)
        }

        let menu = NSMenu()
        let poseMenu = NSMenu(title: "Pose")
        let automaticItem = NSMenuItem(
            title: "Auto",
            action: #selector(selectAutomaticBehavior),
            keyEquivalent: ""
        )
        automaticItem.target = self
        automaticItem.state = .on
        poseMenu.addItem(automaticItem)
        poseMenu.addItem(.separator())
        automaticPoseItem = automaticItem

        for appearance in character.menuAppearances {
            let item = NSMenuItem(
                title: appearance.menuTitle,
                action: #selector(selectPose(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = appearance.id.rawValue
            item.state = .off
            poseMenu.addItem(item)
            poseItems[appearance.id] = item
        }

        let poseItem = NSMenuItem(title: "Pose", action: nil, keyEquivalent: "")
        poseItem.submenu = poseMenu
        menu.addItem(poseItem)

        let resetItem = NSMenuItem(
            title: "Reset Position",
            action: #selector(resetPosition),
            keyEquivalent: ""
        )
        resetItem.target = self
        menu.addItem(resetItem)
        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit EvanJoDesktopPet",
            action: #selector(quitApplication),
            keyEquivalent: ""
        )
        quitItem.target = self
        menu.addItem(quitItem)
        interactionView.menu = menu
    }

    deinit {
        autoCycleTask?.cancel()
        if let screenParametersObserver = screenParametersObserver {
            NotificationCenter.default.removeObserver(screenParametersObserver)
        }
    }

    func show() {
        if !restoreSavedPosition() {
            placeAtDefault(on: NSScreen.main)
        }
        panel.orderFrontRegardless()
        startObservingScreenChanges()
        enableAutomaticBehavior()
    }

    @discardableResult
    private func placeAtDefault(on screen: NSScreen?) -> NSScreen? {
        guard let screen = screen else { return nil }
        let visibleFrame = screen.visibleFrame

        let proposedX = visibleFrame.maxX - panel.frame.width - Self.screenMargin
        let proposedY = visibleFrame.minY + Self.screenMargin
        panel.setFrameOrigin(
            clampedOrigin(
                NSPoint(x: proposedX, y: proposedY),
                to: visibleFrame
            )
        )
        return screen
    }

    private func restoreSavedPosition() -> Bool {
        guard let savedPosition = loadSavedPosition() else { return false }

        let screen = screen(matching: savedPosition.screenIdentifier)
            ?? screen(containingWindowAt: savedPosition.origin)
            ?? NSScreen.main
        guard let screen = screen else { return false }

        panel.setFrameOrigin(clampedOrigin(savedPosition.origin, to: screen.visibleFrame))
        return true
    }

    @discardableResult
    private func movePanel(to proposedOrigin: NSPoint, pointerLocation: NSPoint) -> NSScreen? {
        let screen = NSScreen.screens.first { $0.frame.contains(pointerLocation) }
            ?? panel.screen
            ?? NSScreen.main
        guard let screen = screen else { return nil }

        panel.setFrameOrigin(clampedOrigin(proposedOrigin, to: screen.visibleFrame))
        return screen
    }

    private func finishDragging(pointerLocation: NSPoint) {
        let screen = movePanel(
            to: panel.frame.origin,
            pointerLocation: pointerLocation
        )

        if case .automatic = behaviorMode, !isLoadingOverrideActive {
            startAutomaticCycle(resetHistory: false)
        }

        if let screen = screen {
            panel.setFrameOrigin(clampedOrigin(panel.frame.origin, to: screen.visibleFrame))
            savePosition(on: screen)
        }
    }

    private func clampedOrigin(_ proposedOrigin: NSPoint, to visibleFrame: NSRect) -> NSPoint {
        let maximumX = max(visibleFrame.minX, visibleFrame.maxX - panel.frame.width)
        let maximumY = max(visibleFrame.minY, visibleFrame.maxY - panel.frame.height)
        return NSPoint(
            x: min(max(proposedOrigin.x, visibleFrame.minX), maximumX),
            y: min(max(proposedOrigin.y, visibleFrame.minY), maximumY)
        )
    }

    private func resizePanel(for appearance: PetPoseAppearance) {
        let currentFrame = panel.frame
        let size = appearance.panelSize
        guard currentFrame.size != size else { return }

        let screen = panel.screen ?? NSScreen.main
        let resizedFrame = NSRect(
            x: currentFrame.midX - size.width / 2,
            y: currentFrame.minY,
            width: size.width,
            height: size.height
        )
        panel.setFrame(resizedFrame, display: true)

        if let screen = screen {
            panel.setFrameOrigin(clampedOrigin(panel.frame.origin, to: screen.visibleFrame))
        }
    }

    private func handleClick() {
        guard case .automatic = behaviorMode else { return }
        guard !isLoadingOverrideActive else { return }
        guard !isInteractionSequenceActive else { return }
        guard let clickReaction = character.clickReaction else { return }
        startInteractionSequence(clickReaction)
    }

    private func beginDragging() {
        cancelAutoCycle()
    }

    private func enableAutomaticBehavior() {
        behaviorMode = .automatic
        updatePoseMenuState()
        startAutomaticCycle(resetHistory: true)
    }

    private func startAutomaticCycle(resetHistory: Bool) {
        cancelAutoCycle()
        if resetHistory {
            clearAutomaticHistory()
        }

        guard
            case .automatic = behaviorMode,
            !isLoadingOverrideActive
        else {
            return
        }

        showPose(character.defaultPoseID, restartIfCurrent: true)
        guard let configuration = character.automaticPoseConfiguration else {
            return
        }
        installAutoCycleTask(
            configuration: configuration,
            firstIdleDelay: configuration.initialIdleDelay
        )
    }

    private func startInteractionSequence(
        _ temporaryPose: PetTemporaryPose
    ) {
        guard
            case .automatic = behaviorMode,
            !isLoadingOverrideActive,
            let configuration = character.automaticPoseConfiguration
        else {
            return
        }

        cancelAutoCycle()
        isInteractionSequenceActive = true
        showPose(temporaryPose.poseID, restartIfCurrent: true)
        installAutoCycleTask(
            configuration: configuration,
            firstIdleDelay: configuration.recoveryIdleDelay,
            interactionDuration: temporaryPose.duration
        )
    }

    private func installAutoCycleTask(
        configuration: PetAutomaticPoseConfiguration,
        firstIdleDelay: ClosedRange<TimeInterval>,
        interactionDuration: TimeInterval? = nil
    ) {
        let generation = autoCycleGeneration

        autoCycleTask = Task { @MainActor [weak self] in
            defer {
                if self?.autoCycleGeneration == generation {
                    self?.autoCycleTask = nil
                    self?.isInteractionSequenceActive = false
                }
            }

            do {
                if let interactionDuration = interactionDuration {
                    try await Self.sleep(for: interactionDuration)
                    guard self?.finishInteractionSequence(
                        generation: generation
                    ) == true else {
                        return
                    }
                }

                var idleDelay = firstIdleDelay
                while true {
                    try await Self.sleep(
                        for: TimeInterval.random(in: idleDelay)
                    )
                    guard let temporaryPose = self?.beginAutomaticExpression(
                        configuration: configuration,
                        generation: generation
                    ) else {
                        return
                    }

                    try await Self.sleep(for: temporaryPose.duration)
                    guard self?.finishAutomaticExpression(
                        generation: generation
                    ) == true else {
                        return
                    }
                    idleDelay = configuration.recoveryIdleDelay
                }
            } catch is CancellationError {
                // Cancellation is the expected exit for mode and lifecycle changes.
            } catch {
                // Task.sleep currently only throws for cancellation.
            }
        }
    }

    private func beginAutomaticExpression(
        configuration: PetAutomaticPoseConfiguration,
        generation: Int
    ) -> PetTemporaryPose? {
        guard isAutoCycleActive(generation: generation) else { return nil }

        guard let temporaryPose = PetAutomaticPoseSelector.select(
            from: configuration.weightedPoses,
            excluding: lastExpressivePoseID,
            cooldowns: remainingPoseCooldowns,
            randomUnit: Double.random(in: 0..<1)
        ) else {
            return nil
        }

        recordAutomaticSelection(
            temporaryPose.poseID,
            configuration: configuration
        )
        showPose(temporaryPose.poseID, restartIfCurrent: true)
        return temporaryPose
    }

    private func finishAutomaticExpression(generation: Int) -> Bool {
        guard isAutoCycleActive(generation: generation) else { return false }
        showPose(character.defaultPoseID)
        return true
    }

    private func finishInteractionSequence(generation: Int) -> Bool {
        guard isAutoCycleActive(generation: generation) else { return false }
        isInteractionSequenceActive = false
        showPose(character.defaultPoseID)
        return true
    }

    private func isAutoCycleActive(generation: Int) -> Bool {
        guard generation == autoCycleGeneration else { return false }
        guard !Task.isCancelled, !isLoadingOverrideActive else { return false }
        guard case .automatic = behaviorMode else { return false }
        return true
    }

    private func recordAutomaticSelection(
        _ poseID: PetPoseID,
        configuration: PetAutomaticPoseConfiguration
    ) {
        for cooldownPoseID in Array(remainingPoseCooldowns.keys) {
            let remainingSelections =
                remainingPoseCooldowns[cooldownPoseID, default: 0]
            let updatedValue = max(0, remainingSelections - 1)
            if updatedValue == 0 {
                remainingPoseCooldowns.removeValue(forKey: cooldownPoseID)
            } else {
                remainingPoseCooldowns[cooldownPoseID] = updatedValue
            }
        }

        if let cooldown = configuration.cooldownSelections[poseID] {
            remainingPoseCooldowns[poseID] = cooldown
        }
        lastExpressivePoseID = poseID
    }

    private func clearAutomaticHistory() {
        lastExpressivePoseID = nil
        remainingPoseCooldowns.removeAll()
    }

    private func cancelAutoCycle() {
        autoCycleGeneration &+= 1
        autoCycleTask?.cancel()
        autoCycleTask = nil
        isInteractionSequenceActive = false
    }

    private static func sleep(for duration: TimeInterval) async throws {
        try Task.checkCancellation()
        let clampedDuration = max(0, duration)
        let nanoseconds = UInt64(clampedDuration * 1_000_000_000)
        try await Task.sleep(nanoseconds: nanoseconds)
        try Task.checkCancellation()
    }

    func setLoadingOverrideActive(_ isActive: Bool) {
        guard isActive != isLoadingOverrideActive else { return }
        isLoadingOverrideActive = isActive

        if isActive {
            cancelAutoCycle()
            showPose(.loading, restartIfCurrent: true)
            return
        }

        switch behaviorMode {
        case .automatic:
            startAutomaticCycle(resetHistory: false)
        case .fixed(let poseID):
            showPose(poseID, restartIfCurrent: true)
        }
    }

    private func showPose(
        _ poseID: PetPoseID,
        restartIfCurrent: Bool = false
    ) {
        let appearance = character.appearance(for: poseID)
        guard restartIfCurrent || appearance.id != currentPoseID else {
            return
        }

        resizePanel(for: appearance)
        currentPoseID = appearance.id
        hostingView.rootView = PetRootView(appearance: appearance)
    }

    private func updatePoseMenuState() {
        let fixedPoseID: PetPoseID?
        switch behaviorMode {
        case .automatic:
            automaticPoseItem?.state = .on
            fixedPoseID = nil
        case .fixed(let poseID):
            automaticPoseItem?.state = .off
            fixedPoseID = poseID
        }

        for (poseID, item) in poseItems {
            item.state = poseID == fixedPoseID ? .on : .off
        }
    }

    private func loadSavedPosition() -> SavedPosition? {
        guard
            let value = defaults.dictionary(forKey: PositionStorage.defaultsKey),
            let version = value[PositionStorage.versionKey] as? NSNumber,
            version.intValue == PositionStorage.formatVersion,
            let storedX = value[PositionStorage.originXKey] as? NSNumber,
            let storedY = value[PositionStorage.originYKey] as? NSNumber
        else {
            return nil
        }

        let x = storedX.doubleValue
        let y = storedY.doubleValue
        guard x.isFinite, y.isFinite else { return nil }

        let screenIdentifier: String?
        if let storedIdentifier = value[PositionStorage.screenIdentifierKey] {
            guard let identifier = storedIdentifier as? String, !identifier.isEmpty else {
                return nil
            }
            screenIdentifier = identifier
        } else {
            screenIdentifier = nil
        }

        return SavedPosition(
            origin: NSPoint(x: CGFloat(x), y: CGFloat(y)),
            screenIdentifier: screenIdentifier
        )
    }

    private func savePosition(on screen: NSScreen) {
        let origin = panel.frame.origin
        guard origin.x.isFinite, origin.y.isFinite else { return }

        var value: [String: Any] = [
            PositionStorage.versionKey: PositionStorage.formatVersion,
            PositionStorage.originXKey: Double(origin.x),
            PositionStorage.originYKey: Double(origin.y)
        ]
        if let screenIdentifier = screenIdentifier(for: screen) {
            value[PositionStorage.screenIdentifierKey] = screenIdentifier
        }

        defaults.set(value, forKey: PositionStorage.defaultsKey)
    }

    private func screen(matching identifier: String?) -> NSScreen? {
        guard let identifier = identifier else { return nil }
        return NSScreen.screens.first { screenIdentifier(for: $0) == identifier }
    }

    private func screen(containingWindowAt origin: NSPoint) -> NSScreen? {
        let windowCenter = NSPoint(
            x: origin.x + panel.frame.width / 2,
            y: origin.y + panel.frame.height / 2
        )
        return NSScreen.screens.first { $0.frame.contains(windowCenter) }
    }

    private func screenIdentifier(for screen: NSScreen) -> String? {
        let screenNumberKey = NSDeviceDescriptionKey("NSScreenNumber")
        guard let screenNumber = screen.deviceDescription[screenNumberKey] as? NSNumber else {
            return nil
        }

        let displayUUID = CGDisplayCreateUUIDFromDisplayID(screenNumber.uint32Value).takeRetainedValue()
        return CFUUIDCreateString(nil, displayUUID) as String
    }

    private func startObservingScreenChanges() {
        guard screenParametersObserver == nil else { return }

        screenParametersObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleScreenConfigurationChange()
        }
    }

    private func handleScreenConfigurationChange() {
        let originalOrigin = panel.frame.origin
        let savedScreenIdentifier = loadSavedPosition()?.screenIdentifier
        let screen = screen(matching: savedScreenIdentifier)
            ?? screen(containingWindowAt: originalOrigin)
            ?? NSScreen.main
        guard let screen = screen else { return }

        let adjustedOrigin = clampedOrigin(originalOrigin, to: screen.visibleFrame)
        panel.setFrameOrigin(adjustedOrigin)

        if abs(adjustedOrigin.x - originalOrigin.x) > 0.5
            || abs(adjustedOrigin.y - originalOrigin.y) > 0.5 {
            savePosition(on: screen)
        }
    }

    @objc private func resetPosition() {
        guard let screen = placeAtDefault(on: panel.screen ?? NSScreen.main) else { return }
        savePosition(on: screen)
    }

    @objc private func selectAutomaticBehavior() {
        enableAutomaticBehavior()
    }

    @objc private func selectPose(_ sender: NSMenuItem) {
        guard let rawPoseID = sender.representedObject as? String else { return }
        let poseID = PetPoseID(rawValue: rawPoseID)

        behaviorMode = .fixed(poseID)
        cancelAutoCycle()
        if !isLoadingOverrideActive {
            showPose(poseID, restartIfCurrent: true)
        }
        updatePoseMenuState()
    }

    @objc private func quitApplication() {
        cancelAutoCycle()
        NSApplication.shared.terminate(nil)
    }
}
