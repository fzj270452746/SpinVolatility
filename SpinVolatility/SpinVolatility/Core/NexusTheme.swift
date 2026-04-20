import UIKit

enum NexusTheme {

    // MARK: - Palette
    enum Pigment {
        static let obsidian     = UIColor(hex: "#0A0E1A")
        static let abyss        = UIColor(hex: "#0F1628")
        static let midnight     = UIColor(hex: "#141C35")
        static let slate        = UIColor(hex: "#1E2A4A")
        static let cobalt       = UIColor(hex: "#1A3A6B")
        static let azure        = UIColor(hex: "#2563EB")
        static let prism        = UIColor(hex: "#6366F1")
        static let violet       = UIColor(hex: "#8B5CF6")
        static let fuchsia      = UIColor(hex: "#D946EF")
        static let ember        = UIColor(hex: "#F97316")
        static let aurora       = UIColor(hex: "#10B981")
        static let crimson      = UIColor(hex: "#EF4444")
        static let gold         = UIColor(hex: "#F59E0B")
        static let platinum     = UIColor(hex: "#E2E8F0")
        static let mist         = UIColor(hex: "#94A3B8")
        static let ghost        = UIColor(hex: "#475569")
    }

    // MARK: - Gradients
    enum Gradient {
        static let heroTop: [CGColor] = [
            UIColor(hex: "#0A0E1A").cgColor,
            UIColor(hex: "#0F1628").cgColor
        ]
        static let accentPulse: [CGColor] = [
            UIColor(hex: "#6366F1").cgColor,
            UIColor(hex: "#8B5CF6").cgColor,
            UIColor(hex: "#D946EF").cgColor
        ]
        static let winGlow: [CGColor] = [
            UIColor(hex: "#10B981").cgColor,
            UIColor(hex: "#2563EB").cgColor
        ]
        static let loseGlow: [CGColor] = [
            UIColor(hex: "#EF4444").cgColor,
            UIColor(hex: "#F97316").cgColor
        ]
        static let goldBurst: [CGColor] = [
            UIColor(hex: "#F59E0B").cgColor,
            UIColor(hex: "#F97316").cgColor
        ]
        static let cardSurface: [CGColor] = [
            UIColor(hex: "#141C35").cgColor,
            UIColor(hex: "#1E2A4A").cgColor
        ]
        static let buttonPrimary: [CGColor] = [
            UIColor(hex: "#6366F1").cgColor,
            UIColor(hex: "#8B5CF6").cgColor
        ]
    }

    // MARK: - Typography
    enum Typeface {
        static func display(_ size: CGFloat) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: .black)
        }
        static func headline(_ size: CGFloat) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: .bold)
        }
        static func subhead(_ size: CGFloat) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: .semibold)
        }
        static func body(_ size: CGFloat) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: .regular)
        }
        static func mono(_ size: CGFloat) -> UIFont {
            UIFont.monospacedDigitSystemFont(ofSize: size, weight: .medium)
        }
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat  = 4
        static let sm: CGFloat  = 8
        static let md: CGFloat  = 16
        static let lg: CGFloat  = 24
        static let xl: CGFloat  = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Radius
    enum Radius {
        static let sm: CGFloat  = 8
        static let md: CGFloat  = 14
        static let lg: CGFloat  = 20
        static let xl: CGFloat  = 28
        static let pill: CGFloat = 999
    }
}

// MARK: - UIColor hex init
extension UIColor {
    convenience init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = CGFloat((rgb >> 16) & 0xFF) / 255
        let g = CGFloat((rgb >> 8)  & 0xFF) / 255
        let b = CGFloat(rgb & 0xFF)          / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

// MARK: - CAGradientLayer helper
extension CAGradientLayer {
    static func nexusMake(colors: [CGColor],
                          start: CGPoint = CGPoint(x: 0, y: 0),
                          end: CGPoint   = CGPoint(x: 1, y: 1)) -> CAGradientLayer {
        let l = CAGradientLayer()
        l.colors = colors
        l.startPoint = start
        l.endPoint   = end
        return l
    }
}
