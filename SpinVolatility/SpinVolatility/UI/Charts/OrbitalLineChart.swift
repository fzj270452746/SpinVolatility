import UIKit

final class OrbitalLineChart: UIView {

    private var ledger: [Double] = []
    private var initialBalance: Double = 100
    private let lineLayer  = CAShapeLayer()
    private let fillLayer  = CAShapeLayer()
    private let gradFill   = CAGradientLayer()
    private let zeroLine   = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = .clear
        layer.addSublayer(gradFill)
        layer.addSublayer(fillLayer)
        layer.addSublayer(zeroLine)
        layer.addSublayer(lineLayer)

        lineLayer.fillColor   = UIColor.clear.cgColor
        lineLayer.lineWidth   = 2.5
        lineLayer.lineCap     = .round
        lineLayer.lineJoin    = .round

        fillLayer.fillColor   = UIColor.clear.cgColor
        fillLayer.strokeColor = UIColor.clear.cgColor

        gradFill.startPoint = CGPoint(x: 0.5, y: 0)
        gradFill.endPoint   = CGPoint(x: 0.5, y: 1)

        zeroLine.strokeColor = NexusTheme.Pigment.ghost.cgColor
        zeroLine.lineWidth   = 1
        zeroLine.lineDashPattern = [4, 4]
    }

    func renderLedger(_ data: [Double], initial: Double) {
        self.ledger         = data
        self.initialBalance = initial
        setNeedsLayout()
        layoutIfNeeded()
        drawChart(animated: true)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !ledger.isEmpty { drawChart(animated: false) }
    }

    private func drawChart(animated: Bool) {
        guard ledger.count > 1, bounds.width > 0 else { return }

        let w = bounds.width
        let h = bounds.height - 20
        let minV = min(ledger.min() ?? 0, initialBalance) - 5
        let maxV = max(ledger.max() ?? 0, initialBalance) + 5
        let range = maxV - minV

        func xFor(_ i: Int) -> CGFloat {
            CGFloat(i) / CGFloat(ledger.count - 1) * w
        }
        func yFor(_ v: Double) -> CGFloat {
            CGFloat(1 - (v - minV) / range) * h + 10
        }

        let path = UIBezierPath()
        path.move(to: CGPoint(x: xFor(0), y: yFor(ledger[0])))
        for i in 1..<ledger.count {
            path.addLine(to: CGPoint(x: xFor(i), y: yFor(ledger[i])))
        }

        let fillPath = path.copy() as! UIBezierPath
        fillPath.addLine(to: CGPoint(x: w, y: h + 10))
        fillPath.addLine(to: CGPoint(x: 0, y: h + 10))
        fillPath.close()

        let isProfit = (ledger.last ?? initialBalance) >= initialBalance
        let lineColors = isProfit ? NexusTheme.Gradient.winGlow : NexusTheme.Gradient.loseGlow

        let gradStroke = CAGradientLayer()
        gradStroke.colors     = lineColors
        gradStroke.startPoint = CGPoint(x: 0, y: 0.5)
        gradStroke.endPoint   = CGPoint(x: 1, y: 0.5)
        gradStroke.frame      = bounds

        let maskShape = CAShapeLayer()
        maskShape.path        = path.cgPath
        maskShape.fillColor   = UIColor.clear.cgColor
        maskShape.strokeColor = UIColor.white.cgColor
        maskShape.lineWidth   = 2.5
        maskShape.lineCap     = .round
        gradStroke.mask       = maskShape

        layer.sublayers?.filter { $0 is CAGradientLayer && $0 !== gradFill }.forEach { $0.removeFromSuperlayer() }
        layer.insertSublayer(gradStroke, above: gradFill)

        gradFill.colors = [
            (isProfit ? NexusTheme.Pigment.aurora : NexusTheme.Pigment.crimson).withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        gradFill.frame = bounds
        gradFill.mask  = { let m = CAShapeLayer(); m.path = fillPath.cgPath; return m }()

        let zeroY = yFor(initialBalance)
        let zp = UIBezierPath()
        zp.move(to: CGPoint(x: 0, y: zeroY))
        zp.addLine(to: CGPoint(x: w, y: zeroY))
        zeroLine.path  = zp.cgPath
        zeroLine.frame = bounds

        if animated {
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = 0
            anim.toValue   = 1
            anim.duration  = 1.0
            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            maskShape.add(anim, forKey: "draw")
        }
    }
}
