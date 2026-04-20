import UIKit

final class CascadeStreakChart: UIView {

    private var distribution: [Int: Int] = [:]
    private var maxStreak: Int = 0
    private var avgStreak: Double = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError() }

    func renderStreaks(distribution: [Int: Int], maxStreak: Int, avgStreak: Double) {
        self.distribution = distribution
        self.maxStreak    = maxStreak
        self.avgStreak    = avgStreak
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard !distribution.isEmpty else { return }
        let ctx = UIGraphicsGetCurrentContext()!

        let sorted  = distribution.sorted { $0.key < $1.key }
        let maxCnt  = sorted.map { $0.value }.max() ?? 1
        let count   = sorted.count
        let padL: CGFloat = 8
        let padR: CGFloat = 8
        let padT: CGFloat = 8
        let padB: CGFloat = 28
        let chartW  = rect.width - padL - padR
        let chartH  = rect.height - padT - padB
        let barW    = max(6, chartW / CGFloat(count) - 3)
        let gap     = chartW / CGFloat(count)

        for (i, pair) in sorted.enumerated() {
            let ratio  = CGFloat(pair.value) / CGFloat(maxCnt)
            let barH   = max(3, ratio * chartH)
            let x      = padL + CGFloat(i) * gap
            let y      = padT + chartH - barH

            let intensity = CGFloat(pair.key) / CGFloat(max(1, maxStreak))
            let color = interpolateColor(from: NexusTheme.Pigment.aurora,
                                         to: NexusTheme.Pigment.crimson,
                                         t: intensity)
            ctx.setFillColor(color.cgColor)
            let barRect = CGRect(x: x, y: y, width: barW, height: barH)
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: 3)
            ctx.addPath(path.cgPath)
            ctx.fillPath()

            if i % max(1, count / 5) == 0 {
                let lbl = "\(pair.key)"
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: NexusTheme.Typeface.body(9),
                    .foregroundColor: NexusTheme.Pigment.ghost
                ]
                let sz = (lbl as NSString).size(withAttributes: attrs)
                (lbl as NSString).draw(at: CGPoint(x: x + barW / 2 - sz.width / 2,
                                                   y: rect.height - padB + 4),
                                       withAttributes: attrs)
            }
        }

        // avg line
        if avgStreak > 0 && maxStreak > 0 {
            let avgX = padL + CGFloat(avgStreak / Double(maxStreak)) * chartW
            ctx.setStrokeColor(NexusTheme.Pigment.gold.cgColor)
            ctx.setLineWidth(1.5)
            ctx.setLineDash(phase: 0, lengths: [4, 3])
            ctx.move(to: CGPoint(x: avgX, y: padT))
            ctx.addLine(to: CGPoint(x: avgX, y: padT + chartH))
            ctx.strokePath()
        }
    }

    private func interpolateColor(from: UIColor, to: UIColor, t: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0
        from.getRed(&r1, green: &g1, blue: &b1, alpha: nil)
        to.getRed(&r2, green: &g2, blue: &b2, alpha: nil)
        return UIColor(red: r1 + (r2 - r1) * t,
                       green: g1 + (g2 - g1) * t,
                       blue: b1 + (b2 - b1) * t,
                       alpha: 1)
    }
}
