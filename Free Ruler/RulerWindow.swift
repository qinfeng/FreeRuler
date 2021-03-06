import Cocoa

class RulerWindow: NSPanel {

    var ruler: Ruler
    var rule: RuleView

    convenience init(_ ruler: Ruler) {
        self.init(ruler: ruler)
    }

    init(ruler: Ruler) {
        self.ruler = ruler
        self.rule = getRulerView(ruler: ruler)

        let styleMask: NSWindow.StyleMask = [
            .borderless,
            .resizable,
            .fullSizeContentView,
        ]

        super.init(
            contentRect: ruler.frame,
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )

        self.alphaValue = windowAlphaValue(prefs.foregroundOpacity)
        self.minSize = getMinSize(ruler: ruler)
        self.maxSize = getMaxSize(ruler: ruler)

        self.isFloatingPanel = prefs.floatRulers
        self.hidesOnDeactivate = false
        self.isMovableByWindowBackground = true
        self.hasShadow = prefs.rulerShadow

        rule.wantsLayer = true
        rule.layer?.borderColor = CGColor(gray: 0, alpha: 0.5)
        rule.layer?.borderWidth = 1.0

        rule.nextResponder = self
        self.contentView = rule
    }

    override var canBecomeKey: Bool {
        return true
    }

    override var acceptsMouseMovedEvents: Bool {
        get { return true }
        set {}
    }

}

extension RulerWindow {
    private enum Distance: CGFloat {
        case aLittle = 1
        case aLot = 10
    }

    func moveHorizontally(by pixels: CGFloat) {
        var position = frame.origin
        position.x = position.x + pixels
        setFrameOrigin(position)
    }

    func moveVertically(by pixels: CGFloat) {
        var position = frame.origin
        position.y = position.y + pixels
        setFrameOrigin(position)
    }

    private func distance(withShift: Bool) -> CGFloat {
        let dist = withShift ? Distance.aLot : Distance.aLittle
        return dist.rawValue
    }

    func nudgeLeft(withShift shiftPressed: Bool) {
        let dist = distance(withShift: shiftPressed)
        moveHorizontally(by: dist * -1)
    }

    func nudgeRight(withShift shiftPressed: Bool) {
        let dist = distance(withShift: shiftPressed)
        moveHorizontally(by: dist)
    }

    func nudgeDown(withShift shiftPressed: Bool) {
        let dist = distance(withShift: shiftPressed)
        moveVertically(by: dist * -1)
    }

    func nudgeUp(withShift shiftPressed: Bool) {
        let dist = distance(withShift: shiftPressed)
        moveVertically(by: dist)
    }

}
