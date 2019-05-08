import Cocoa
import Carbon.HIToolbox // For key constants


class RulerController: NSCoder, NSWindowDelegate, PreferenceSubscriber {
    let ruler: Ruler
    let rulerWindow: RulerWindow
    var otherWindow: RulerWindow?
    var keyListener: Any?

    var opacity: Int {
        didSet {
            rulerWindow.alphaValue = windowAlphaValue(opacity)
        }
    }

    init(ruler: Ruler) {
        self.ruler = ruler
        self.rulerWindow = RulerWindow(ruler: ruler)
        self.opacity = Prefs.foregroundOpacity.value

        super.init()

        subscribeToPrefs()
        rulerWindow.delegate = self
    }

    convenience init(_ ruler: Ruler) {
        self.init(ruler: ruler)
    }

    func showWindow() {
        rulerWindow.orderFront(nil)
    }

    func windowWillStartLiveResize(_ notification: Notification) {
        // print(self.type, "windowWillStartLiveResize")
    }

    func windowDidEndLiveResize(_ notification: Notification) {
        // print(self.type, "windowDidEndLiveResize")
    }

    func windowWillMove(_ notification: Notification) {
        // print(self.type, "windowWillMove")
    }

    func windowDidMove(_ notification: Notification) {
        // print(self.type, "windowDidMove")
        rulerWindow.invalidateShadow()
    }

    func windowDidBecomeKey(_ notification: Notification) {
        // print(self.type, "windowDidBecomeKey")
        updateChildWindow()
        startKeyListener()
    }

    func windowDidResignKey(_ notification: Notification) {
        // print(self.type, "windowDidResignKey")
        updateChildWindow()
        stopKeyListener()
    }

    func onChangeGrouped() {
        updateChildWindow()
    }

    func updateChildWindow() {
        guard let other = otherWindow else { return }

        if Prefs.groupRulers.value && rulerWindow.isKeyWindow {
            self.rulerWindow.addChildWindow(other, ordered: .below)
        } else {
            self.rulerWindow.removeChildWindow(other)
        }
    }

    func foreground() {
        opacity = Prefs.foregroundOpacity.value
    }
    func background() {
        opacity = Prefs.backgroundOpacity.value
    }

    func subscribeToPrefs() {
        Prefs.groupRulers.subscribe(self)
    }

    func onChangePreference(_ name: String) {
        switch(name) {
        case Prefs.groupRulers.name:
            updateChildWindow()
        default:
            print("Unknown preference changed: \(name)")
        }
    }

}

// MARK: KeyListener

extension RulerController {

    func startKeyListener() {
        self.keyListener = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] in
            guard let self = self else { return $0 }
            return self.onKeyDown(with: $0)
        }
    }

    func stopKeyListener() {
        if let keyListener = self.keyListener {
            NSEvent.removeMonitor(keyListener)
            self.keyListener = nil
        }
    }

    // Return nil if the event was handled here.
    func onKeyDown(with event: NSEvent) -> NSEvent? {
        // print(ruler.orientation, "onKeyDown")

        let shift = event.modifierFlags.contains(.shift)

        switch Int(event.keyCode) {
        case kVK_LeftArrow:
            rulerWindow.nudgeLeft(withShift: shift)
            return nil
        case kVK_RightArrow:
            rulerWindow.nudgeRight(withShift: shift)
            return nil
        case kVK_UpArrow:
            rulerWindow.nudgeUp(withShift: shift)
            return nil
        case kVK_DownArrow:
            rulerWindow.nudgeDown(withShift: shift)
            return nil
        default:
            return event
        }
    }

}
