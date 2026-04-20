import UIKit

final class NebulaPanelView: UIView {

    private let gradLayer = CAGradientLayer()
    private let glowLayer = CAGradientLayer()

    init(accentColor: UIColor = NexusTheme.Pigment.prism) {
        super.init(frame: .zero)
        setupLayers(accent: accentColor)
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupLayers(accent: UIColor) {
        layer.cornerRadius = NexusTheme.Radius.lg
        layer.masksToBounds = false
        clipsToBounds = false

        gradLayer.colors     = NexusTheme.Gradient.cardSurface
        gradLayer.startPoint = CGPoint(x: 0, y: 0)
        gradLayer.endPoint   = CGPoint(x: 1, y: 1)
        gradLayer.cornerRadius = NexusTheme.Radius.lg
        layer.insertSublayer(gradLayer, at: 0)

        layer.borderColor = accent.withAlphaComponent(0.25).cgColor
        layer.borderWidth = 1

        layer.shadowColor   = accent.cgColor
        layer.shadowOpacity = 0.18
        layer.shadowRadius  = 16
        layer.shadowOffset  = CGSize(width: 0, height: 4)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer.frame = bounds
    }
}
