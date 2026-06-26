import Cocoa

func pinPath(top T: CGPoint, bottom B: CGPoint, stemHalf sw: CGFloat, bulbR R: CGFloat) -> NSBezierPath {
    let cx = T.x
    let C = CGPoint(x: cx, y: B.y + R)
    let eqY = C.y
    let flareY = eqY + R
    let p = NSBezierPath()
    p.move(to: CGPoint(x: cx - sw, y: T.y))
    p.line(to: CGPoint(x: cx - sw, y: flareY))
    p.curve(to: CGPoint(x: cx - R, y: eqY),
            controlPoint1: CGPoint(x: cx - sw, y: eqY + R * 0.45),
            controlPoint2: CGPoint(x: cx - R,  y: eqY + R * 0.55))
    p.appendArc(withCenter: C, radius: R, startAngle: 180, endAngle: 360, clockwise: false)
    p.curve(to: CGPoint(x: cx + sw, y: flareY),
            controlPoint1: CGPoint(x: cx + R,  y: eqY + R * 0.55),
            controlPoint2: CGPoint(x: cx + sw, y: eqY + R * 0.45))
    p.line(to: CGPoint(x: cx + sw, y: T.y))
    p.close()
    return p
}

let accentTop = NSColor(srgbRed: 0.78, green: 0.90, blue: 1.0, alpha: 1)
let accentBot = NSColor(srgbRed: 0.40, green: 0.66, blue: 0.99, alpha: 1)
func clamp(_ v: CGFloat, _ lo: CGFloat, _ hi: CGFloat) -> CGFloat { min(hi, max(lo, v)) }

func savePNG(_ img: NSImage, _ path: String) {
    guard let tiff = img.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else { return }
    try? png.write(to: URL(fileURLWithPath: path))
}

func drawPin(top: CGPoint, bot: CGPoint, sw: CGFloat, R: CGFloat, alpha: CGFloat) {
    // Flat design : aplat de couleur unie
    let path = pinPath(top: top, bottom: bot, stemHalf: sw, bulbR: R)
    NSColor.systemBlue.withAlphaComponent(alpha).setFill()   // tient lieu de controlAccentColor
    path.fill()
}

// Calcule sw/R comme dans l'app
func swR(_ L: CGFloat) -> (CGFloat, CGFloat) {
    let sw = clamp(3.2 - L*0.0075, 0.9, 3.2)
    let R = clamp(min(sw*2.3, L*0.34), 2.2, 11)
    return (sw, R)
}

func sequence(file: String) {
    let lens: [(CGFloat, String)] = [(40, "départ"), (110, "ligne"), (200, "on tire"),
                                     (300, "plus fin"), (380, "très tiré")]
    let cw: CGFloat = 150, H: CGFloat = 440, W = cw*CGFloat(lens.count)
    let img = NSImage(size: NSSize(width: W, height: H)); img.lockFocus()
    NSColor(calibratedWhite: 0.11, alpha: 1).setFill(); NSRect(x: 0, y: 0, width: W, height: H).fill()
    for (i, item) in lens.enumerated() {
        let cx = cw*CGFloat(i) + cw/2
        let top = CGPoint(x: cx, y: H - 24), bot = CGPoint(x: cx, y: top.y - item.0)
        let (sw, R) = swR(item.0)
        drawPin(top: top, bot: bot, sw: sw, R: R, alpha: 1)
        let s = NSAttributedString(string: item.1, attributes: [.font: NSFont.systemFont(ofSize: 13), .foregroundColor: NSColor.white])
        s.draw(at: NSPoint(x: cx - s.size().width/2, y: 14))
    }
    img.unlockFocus(); savePNG(img, file)
}

func scene(minutes: Int, len: CGFloat, file: String) {
    let W: CGFloat = 360, H: CGFloat = 440
    let img = NSImage(size: NSSize(width: W, height: H)); img.lockFocus()
    NSColor(calibratedWhite: 0.11, alpha: 1).setFill(); NSRect(x: 0, y: 0, width: W, height: H).fill()
    let top = CGPoint(x: 150, y: H - 24), bot = CGPoint(x: 150, y: top.y - len)
    let (sw, R) = swR(len)
    drawPin(top: top, bot: bot, sw: sw, R: R, alpha: 1)
    let c = CGPoint(x: bot.x, y: bot.y + R)
    let main = NSMutableAttributedString(string: "\(minutes)", attributes: [
        .font: NSFont.systemFont(ofSize: 30, weight: .ultraLight), .foregroundColor: NSColor.white])
    main.append(NSAttributedString(string: " min", attributes: [
        .font: NSFont.systemFont(ofSize: 15, weight: .light), .foregroundColor: NSColor.white.withAlphaComponent(0.7)]))
    main.draw(at: NSPoint(x: c.x + R + 22, y: c.y - main.size().height/2))
    img.unlockFocus(); savePNG(img, file)
}

func iconStrip(file: String) {
    let scale: CGFloat = 10, cell: CGFloat = 18*scale
    let fracs: [CGFloat?] = [nil, 1.0, 0.66, 0.33, 0.05]
    let img = NSImage(size: NSSize(width: cell*CGFloat(fracs.count), height: cell)); img.lockFocus()
    NSColor(calibratedWhite: 0.93, alpha: 1).setFill(); NSRect(x: 0, y: 0, width: cell*CGFloat(fracs.count), height: cell).fill()
    for (i, f) in fracs.enumerated() {
        NSGraphicsContext.saveGraphicsState()
        let t = NSAffineTransform(); t.translateX(by: CGFloat(i)*cell, yBy: 0); t.scale(by: scale); t.concat()
        let s: CGFloat = 18, r: CGFloat = 4.6
        let path = NSBezierPath(ovalIn: NSRect(x: s/2 - r, y: s/2 - r, width: r*2, height: r*2))
        let active = (f != nil)
        if let f = f, f > 0 {
            NSGraphicsContext.saveGraphicsState(); path.addClip()
            accentBot.setFill(); NSBezierPath(rect: NSRect(x: 0, y: 0, width: s, height: (s/2 - r) + 2*r*f)).fill()
            NSGraphicsContext.restoreGraphicsState()
        }
        path.lineWidth = 1.4; (active ? accentBot : NSColor.black).setStroke(); path.stroke()
        NSGraphicsContext.restoreGraphicsState()
    }
    img.unlockFocus(); savePNG(img, file)
}

iconStrip(file: "/tmp/dropp_icons.png")
sequence(file: "/tmp/dropp_seq.png")
scene(minutes: 25, len: 240, file: "/tmp/dropp_scene.png")
print("done")
