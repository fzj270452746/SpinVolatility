import UIKit

protocol AuroraSliderDelegate: AnyObject {
    func auroraSlider(_ cell: AuroraSliderCell, didChange value: Double)
}

final class AuroraSliderCell: UIView {

    weak var delegate: AuroraSliderDelegate?

    private let titleLabel   = UILabel()
    private let valueLabel   = UILabel()
    private let trackBg      = UIView()
    private let trackFill    = UIView()
    private let thumbView    = UIView()
    private let gradLayer    = CAGradientLayer()

    private var minVal: Double = 0
    private var maxVal: Double = 1
    private(set) var currentVal: Double = 0.5

    private var thumbCenterX: NSLayoutConstraint?
    private var isDragging = false
    private var formatter: (Double) -> String = { String(format: "%.0f%%", $0 * 100) }

    // MARK: - Init
    init(title: String, min: Double, max: Double, value: Double,
         format: @escaping (Double) -> String) {
        super.init(frame: .zero)
        self.minVal     = min
        self.maxVal     = max
        self.currentVal = value
        self.formatter  = format
        titleLabel.text = title
        buildLayout()
        styleViews()
        addGesture()
        refresh(animated: false)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout
    private func buildLayout() {
        [titleLabel, valueLabel, trackBg, thumbView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        trackBg.addSubview(trackFill)
        trackFill.translatesAutoresizingMaskIntoConstraints = false

        let thumbSize: CGFloat = 26
        thumbCenterX = thumbView.centerXAnchor.constraint(equalTo: trackBg.leadingAnchor)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),

            valueLabel.topAnchor.constraint(equalTo: topAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            trackBg.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            trackBg.leadingAnchor.constraint(equalTo: leadingAnchor, constant: thumbSize / 2),
            trackBg.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -thumbSize / 2),
            trackBg.heightAnchor.constraint(equalToConstant: 6),
            trackBg.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -thumbSize / 2),

            trackFill.leadingAnchor.constraint(equalTo: trackBg.leadingAnchor),
            trackFill.topAnchor.constraint(equalTo: trackBg.topAnchor),
            trackFill.bottomAnchor.constraint(equalTo: trackBg.bottomAnchor),

            thumbView.centerYAnchor.constraint(equalTo: trackBg.centerYAnchor),
            thumbView.widthAnchor.constraint(equalToConstant: thumbSize),
            thumbView.heightAnchor.constraint(equalToConstant: thumbSize),
            thumbCenterX!
        ])
    }

    private func styleViews() {
        titleLabel.font      = NexusTheme.Typeface.subhead(13)
        titleLabel.textColor = NexusTheme.Pigment.mist

        valueLabel.font      = NexusTheme.Typeface.mono(14)
        valueLabel.textColor = NexusTheme.Pigment.platinum

        trackBg.backgroundColor   = NexusTheme.Pigment.slate
        trackBg.layer.cornerRadius = 3
        trackBg.clipsToBounds      = true

        gradLayer.colors     = NexusTheme.Gradient.accentPulse
        gradLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        trackFill.layer.insertSublayer(gradLayer, at: 0)

        thumbView.backgroundColor  = .white
        thumbView.layer.cornerRadius = 13
        thumbView.layer.shadowColor  = NexusTheme.Pigment.prism.cgColor
        thumbView.layer.shadowOpacity = 0.7
        thumbView.layer.shadowRadius  = 6
        thumbView.layer.shadowOffset  = .zero
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer.frame = trackFill.bounds
        refresh(animated: false)
    }

    // MARK: - Gesture
    private func addGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }

    @objc private func handlePan(_ g: UIPanGestureRecognizer) {
        let x = g.location(in: trackBg).x
        updateFromX(x, animated: false)
        if g.state == .began { animateThumbScale(1.2) }
        if g.state == .ended || g.state == .cancelled { animateThumbScale(1.0) }
    }

    @objc private func handleTap(_ g: UITapGestureRecognizer) {
        let x = g.location(in: trackBg).x
        updateFromX(x, animated: true)
    }

    private func updateFromX(_ x: CGFloat, animated: Bool) {
        let w = trackBg.bounds.width
        guard w > 0 else { return }
        let ratio = max(0, min(1, x / w))
        currentVal = minVal + (maxVal - minVal) * Double(ratio)
        refresh(animated: animated)
        delegate?.auroraSlider(self, didChange: currentVal)
    }

    // MARK: - Refresh
    func setValue(_ v: Double, animated: Bool = true) {
        currentVal = max(minVal, min(maxVal, v))
        refresh(animated: animated)
    }

    private func refresh(animated: Bool) {
        let w = trackBg.bounds.width
        let ratio = w > 0 ? CGFloat((currentVal - minVal) / (maxVal - minVal)) : 0
        let cx = ratio * w
        valueLabel.text = formatter(currentVal)

        let block = {
            self.thumbCenterX?.constant = cx
            self.trackFill.frame = CGRect(x: 0, y: 0,
                                          width: cx,
                                          height: self.trackBg.bounds.height)
            self.gradLayer.frame = self.trackFill.bounds
        }
        if animated {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: block)
        } else {
            block()
        }
    }

    private func animateThumbScale(_ s: CGFloat) {
        UIView.animate(withDuration: 0.15) {
            self.thumbView.transform = CGAffineTransform(scaleX: s, y: s)
        }
    }
}
