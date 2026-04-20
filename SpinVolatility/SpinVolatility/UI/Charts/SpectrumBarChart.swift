import UIKit

final class SpectrumBarChart: UIView {

    private var buckets: [(range: String, count: Int)] = []
    private var barLayers: [CALayer] = []
    private let scrollView = UIScrollView()
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

    func renderBuckets(_ data: [(range: String, count: Int)]) {
        self.buckets = data
        contentView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        contentView.subviews.forEach { $0.removeFromSuperview() }
        barLayers.removeAll()
        setNeedsLayout()
        layoutIfNeeded()
        drawBars(animated: true)
    }

    private func drawBars(animated: Bool) {
        guard !buckets.isEmpty else { return }
        let maxCount = buckets.map { $0.count }.max() ?? 1
        let barW: CGFloat = 44
        let gap: CGFloat  = 10
        let totalW = CGFloat(buckets.count) * (barW + gap) + gap
        let chartH = bounds.height - 36

        contentView.frame = CGRect(x: 0, y: 0, width: max(totalW, bounds.width), height: bounds.height)
        scrollView.contentSize = contentView.frame.size

        let gradColors = NexusTheme.Gradient.accentPulse

        for (i, bucket) in buckets.enumerated() {
            let ratio  = CGFloat(bucket.count) / CGFloat(maxCount)
            let barH   = max(4, ratio * chartH)
            let x      = gap + CGFloat(i) * (barW + gap)
            let y      = chartH - barH

            let grad = CAGradientLayer()
            grad.colors     = gradColors
            grad.startPoint = CGPoint(x: 0.5, y: 1)
            grad.endPoint   = CGPoint(x: 0.5, y: 0)
            grad.cornerRadius = 6

            if animated {
                grad.frame = CGRect(x: x, y: chartH, width: barW, height: 0)
            } else {
                grad.frame = CGRect(x: x, y: y, width: barW, height: barH)
            }
            contentView.layer.addSublayer(grad)
            barLayers.append(grad)

            let lbl = UILabel()
            lbl.text          = bucket.range
            lbl.font          = NexusTheme.Typeface.body(9)
            lbl.textColor     = NexusTheme.Pigment.mist
            lbl.textAlignment = .center
            lbl.frame         = CGRect(x: x, y: chartH + 4, width: barW, height: 28)
            lbl.numberOfLines = 2
            contentView.addSubview(lbl)

            if animated {
                let anim = CABasicAnimation(keyPath: "bounds.size.height")
                anim.fromValue = 0
                anim.toValue   = barH
                anim.duration  = 0.5
                anim.beginTime = CACurrentMediaTime() + Double(i) * 0.04
                anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
                anim.fillMode  = .forwards
                anim.isRemovedOnCompletion = false
                grad.add(anim, forKey: "barGrow")

                CATransaction.begin()
                CATransaction.setDisableActions(true)
                grad.frame = CGRect(x: x, y: y, width: barW, height: barH)
                CATransaction.commit()
            }
        }
    }
}
