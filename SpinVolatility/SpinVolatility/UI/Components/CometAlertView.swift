import UIKit

final class CometAlertView: UIView {

    enum AlertStyle { case info, success, warning, error }

    private let blurHost    = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let cardView    = UIView()
    private let gradLayer   = CAGradientLayer()
    private let iconLabel   = UILabel()
    private let titleLabel  = UILabel()
    private let bodyLabel   = UILabel()
    private let stackView   = UIStackView()
    private var onDismiss: (() -> Void)?

    // MARK: - Factory
    static func present(on parent: UIView,
                        style: AlertStyle = .info,
                        icon: String,
                        title: String,
                        body: String,
                        actions: [(label: String, isPrimary: Bool, handler: () -> Void)]) {
        let alert = CometAlertView(style: style, icon: icon, title: title, body: body, actions: actions)
        parent.addSubview(alert)
        alert.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            alert.topAnchor.constraint(equalTo: parent.topAnchor),
            alert.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            alert.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            alert.trailingAnchor.constraint(equalTo: parent.trailingAnchor)
        ])
        alert.animateIn()
    }

    // MARK: - Init
    private init(style: AlertStyle, icon: String, title: String, body: String,
                 actions: [(label: String, isPrimary: Bool, handler: () -> Void)]) {
        super.init(frame: .zero)
        buildUI(style: style, icon: icon, title: title, body: body, actions: actions)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Build
    private func buildUI(style: AlertStyle, icon: String, title: String, body: String,
                         actions: [(label: String, isPrimary: Bool, handler: () -> Void)]) {
        backgroundColor = UIColor.black.withAlphaComponent(0.6)

        addSubview(blurHost)
        blurHost.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurHost.topAnchor.constraint(equalTo: topAnchor),
            blurHost.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurHost.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurHost.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = NexusTheme.Radius.xl
        cardView.clipsToBounds = true

        gradLayer.colors     = NexusTheme.Gradient.cardSurface
        gradLayer.startPoint = CGPoint(x: 0, y: 0)
        gradLayer.endPoint   = CGPoint(x: 1, y: 1)
        cardView.layer.insertSublayer(gradLayer, at: 0)

        let accent = accentColor(for: style)
        cardView.layer.borderColor = accent.withAlphaComponent(0.4).cgColor
        cardView.layer.borderWidth = 1.5

        iconLabel.text      = icon
        iconLabel.font      = .systemFont(ofSize: 44)
        iconLabel.textAlignment = .center

        titleLabel.text      = title
        titleLabel.font      = NexusTheme.Typeface.headline(20)
        titleLabel.textColor = NexusTheme.Pigment.platinum
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        bodyLabel.text      = body
        bodyLabel.font      = NexusTheme.Typeface.body(14)
        bodyLabel.textColor = NexusTheme.Pigment.mist
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0

        let btnStack = UIStackView()
        btnStack.axis    = .horizontal
        btnStack.spacing = 12
        btnStack.distribution = .fillEqually

        for action in actions {
            let btn = buildButton(label: action.label, isPrimary: action.isPrimary,
                                  accent: accent, handler: action.handler)
            btnStack.addArrangedSubview(btn)
        }

        let content = UIStackView(arrangedSubviews: [iconLabel, titleLabel, bodyLabel, btnStack])
        content.axis      = .vertical
        content.spacing   = 14
        content.alignment = .fill
        content.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(content)

        let pad: CGFloat = 28
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: centerYAnchor),
            cardView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.88),
            cardView.widthAnchor.constraint(greaterThanOrEqualToConstant: 280),

            content.topAnchor.constraint(equalTo: cardView.topAnchor, constant: pad),
            content.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -pad),
            content.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: pad),
            content.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -pad)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(bgTapped))
        blurHost.addGestureRecognizer(tap)
    }

    private func buildButton(label: String, isPrimary: Bool,
                             accent: UIColor, handler: @escaping () -> Void) -> UIButton {
        let btn = GlowButton(type: .custom)
        btn.setTitle(label, for: .normal)
        btn.titleLabel?.font = NexusTheme.Typeface.subhead(15)
        btn.layer.cornerRadius = NexusTheme.Radius.md
        btn.clipsToBounds = true
        btn.heightAnchor.constraint(equalToConstant: 48).isActive = true

        if isPrimary {
            let gl = CAGradientLayer()
            gl.colors     = [accent.cgColor, accent.withAlphaComponent(0.7).cgColor]
            gl.startPoint = CGPoint(x: 0, y: 0)
            gl.endPoint   = CGPoint(x: 1, y: 1)
            gl.cornerRadius = NexusTheme.Radius.md
            btn.layer.insertSublayer(gl, at: 0)
            btn.setTitleColor(.white, for: .normal)
            btn.gradLayer = gl
        } else {
            btn.backgroundColor = NexusTheme.Pigment.slate
            btn.setTitleColor(NexusTheme.Pigment.mist, for: .normal)
            btn.layer.borderColor = NexusTheme.Pigment.ghost.cgColor
            btn.layer.borderWidth = 1
        }

        btn.addAction(UIAction { [weak self] _ in
            self?.animateOut { handler() }
        }, for: .touchUpInside)
        return btn
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer.frame = cardView.bounds
    }

    private func accentColor(for style: AlertStyle) -> UIColor {
        switch style {
        case .info:    return NexusTheme.Pigment.prism
        case .success: return NexusTheme.Pigment.aurora
        case .warning: return NexusTheme.Pigment.gold
        case .error:   return NexusTheme.Pigment.crimson
        }
    }

    // MARK: - Animation
    private func animateIn() {
        cardView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        alpha = 0
        UIView.animate(withDuration: 0.35, delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut) {
            self.alpha = 1
            self.cardView.transform = .identity
        }
    }

    private func animateOut(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.cardView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            self.removeFromSuperview()
            completion()
        }
    }

    @objc private func bgTapped() {
        animateOut {}
    }
}

// MARK: - GlowButton helper
final class GlowButton: UIButton {
    var gradLayer: CAGradientLayer?
    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer?.frame = bounds
    }
}
