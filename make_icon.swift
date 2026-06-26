import Cocoa

let size: CGFloat = 1024

let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
                           pixelsWide: Int(size), pixelsHigh: Int(size),
                           bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                           isPlanar: false, colorSpaceName: .deviceRGB,
                           bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)!

// MARK: - Squircle, dégradé bleu (style maison)
let inset = size * 0.06
let bgRect = NSRect(x: 0, y: 0, width: size, height: size).insetBy(dx: inset, dy: inset)
let radius = bgRect.width * 0.2237
let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: radius, yRadius: radius)
let grad = NSGradient(colorsAndLocations:
    (NSColor(srgbRed: 0.26, green: 0.62, blue: 1.00, alpha: 1), 0.0),
    (NSColor(srgbRed: 0.13, green: 0.45, blue: 0.98, alpha: 1), 0.55),
    (NSColor(srgbRed: 0.07, green: 0.30, blue: 0.86, alpha: 1), 1.0)
)!
grad.draw(in: bgPath, angle: -90)

// MARK: - La marque DroppTimer : fine ligne verticale + bille arrondie (flat, blanche)
let cx = size / 2
let h = bgRect.height
let billeR = size * 0.092
let billeCY = bgRect.minY + h * 0.30          // bille dans la partie basse
let lineTopY = bgRect.minY + h * 0.80         // sommet de la ligne
let lineW = size * 0.044

NSColor.white.set()

// Ligne (capsule à bouts ronds), depuis le centre de la bille jusqu'en haut
let line = NSBezierPath()
line.lineWidth = lineW
line.lineCapStyle = .round
line.move(to: NSPoint(x: cx, y: billeCY))
line.line(to: NSPoint(x: cx, y: lineTopY))
line.stroke()

// Bille pleine
NSBezierPath(ovalIn: NSRect(x: cx - billeR, y: billeCY - billeR,
                            width: billeR * 2, height: billeR * 2)).fill()

NSGraphicsContext.restoreGraphicsState()

let png = rep.representation(using: .png, properties: [:])!
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon_1024.png"
try! png.write(to: URL(fileURLWithPath: out))
print("→ écrit \(out)")
