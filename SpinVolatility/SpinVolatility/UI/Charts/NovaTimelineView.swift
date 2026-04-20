import UIKit

final class NovaTimelineView: UIView {

    private var events: [(spin: Int, multiplier: Double)] = []
    private var totalSpins: Int = 1
    private let scrollView  = UIScrollView()
    private let contentView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = .clear
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }

    func renderEvents(_ data: [(spin: Int, multiplier: Double)], totalSpins: Int) {
        self.events     = data
        self.totalSpins = max(1, totalSpins)
        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        setNeedsLayout()
        layoutIfNeeded()
        drawTimeline()
    }

    private func drawTimeline() {
        let h = bounds.height
        let minW = bounds.width
        let contentW = max(minW, CGFloat(events.count) * 60 + 40)
        contentView.frame = CGRect(x: 0, y: 0, width: contentW, height: h)
        scrollView.contentSize = contentView.frame.size

        // baseline
        let baseLine = CAShapeLayer()
        let bp = UIBezierPath()
        bp.move(to: CGPoint(x: 0, y: h * 0.65))
        bp.addLine(to: CGPoint(x: contentW, y: h * 0.65))
        baseLine.path        = bp.cgPath
        baseLine.strokeColor = NexusTheme.Pigment.slate.cgColor
        baseLine.lineWidth   = 2
        contentView.layer.addSublayer(baseLine)

        let maxMult = events.map { $0.multiplier }.max() ?? 1

        for (i, event) in events.enumerated() {
            let xRatio = contentW > minW
                ? CGFloat(i) / CGFloat(max(1, events.count - 1)) * (contentW - 40) + 20
                : CGFloat(event.spin) / CGFloat(totalSpins) * contentW

            let intensity = CGFloat(event.multiplier / maxMult)
            let dotR: CGFloat = 6 + intensity * 10

            // glow
            let glow = CALayer()
            glow.frame = CGRect(x: xRatio - dotR * 1.8,
                                y: h * 0.65 - dotR * 1.8,
                                width: dotR * 3.6, height: dotR * 3.6)
            glow.cornerRadius  = dotR * 1.8
            glow.backgroundColor = NexusTheme.Pigment.gold.withAlphaComponent(0.25).cgColor
            contentView.layer.addSublayer(glow)

            // dot
            let dot = CALayer()
            dot.frame = CGRect(x: xRatio - dotR, y: h * 0.65 - dotR,
                               width: dotR * 2, height: dotR * 2)
            dot.cornerRadius  = dotR
            dot.backgroundColor = NexusTheme.Pigment.gold.cgColor
            contentView.layer.addSublayer(dot)

            // label
            let lbl = UILabel()
            lbl.text      = String(format: "%.0fx", event.multiplier)
            lbl.font      = NexusTheme.Typeface.mono(10)
            lbl.textColor = NexusTheme.Pigment.gold
            lbl.sizeToFit()
            lbl.center    = CGPoint(x: xRatio, y: h * 0.65 - dotR - lbl.bounds.height / 2 - 4)
            contentView.addSubview(lbl)

            // spin label
            let spinLbl = UILabel()
            spinLbl.text      = "#\(event.spin)"
            spinLbl.font      = NexusTheme.Typeface.body(9)
            spinLbl.textColor = NexusTheme.Pigment.ghost
            spinLbl.sizeToFit()
            spinLbl.center    = CGPoint(x: xRatio, y: h * 0.65 + dotR + spinLbl.bounds.height / 2 + 4)
            contentView.addSubview(spinLbl)

            // pulse animation
            let pulse = CABasicAnimation(keyPath: "transform.scale")
            pulse.fromValue  = 1.0
            pulse.toValue    = 1.4
            pulse.duration   = 0.8
            pulse.beginTime  = CACurrentMediaTime() + Double(i) * 0.1
            pulse.autoreverses = true
            pulse.repeatCount  = 2
            dot.add(pulse, forKey: "pulse")
        }
    }
}
