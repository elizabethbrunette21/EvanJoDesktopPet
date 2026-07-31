import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var petWindowController: PetWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let controller = PetWindowController(character: EvanJoCharacterDefinition.character)
        petWindowController = controller
        controller.show()
    }
}
