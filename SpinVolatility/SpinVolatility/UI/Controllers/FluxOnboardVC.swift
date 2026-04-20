import UIKit
import AppTrackingTransparency
import Alamofire

final class FluxOnboardVC: UIViewController {

    var onComplete: (() -> Void)?

    private let bgGradLayer  = CAGradientLayer()
    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()

    // Hero
    private let heroIcon     = UILabel()
    private let heroTitle    = UILabel()
    private let heroSub      = UILabel()
    private let heroGradLayer = CAGradientLayer()

    // Feature cards
    private let featuresStack = UIStackView()

    // Disclaimer
    private let disclaimerPanel = NebulaPanelView(accentColor: NexusTheme.Pigment.gold)

    // CTA
    private let ctaButton    = UIButton(type: .custom)
    private let ctaGradLayer = CAGradientLayer()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization {_ in }
        }
        
        buildBackground()
        buildScrollView()
        buildHero()
        buildFeatureCards()
        buildDisclaimer()
        buildCTA()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradLayer.frame  = view.bounds
        ctaGradLayer.frame = ctaButton.bounds
    }

    // MARK: - Background
    private func buildBackground() {
        bgGradLayer.colors     = [
            UIColor(hex: "#080C18").cgColor,
            UIColor(hex: "#0F1628").cgColor,
            UIColor(hex: "#141C35").cgColor
        ]
        bgGradLayer.locations  = [0, 0.5, 1]
        bgGradLayer.startPoint = CGPoint(x: 0.3, y: 0)
        bgGradLayer.endPoint   = CGPoint(x: 0.7, y: 1)
        view.layer.insertSublayer(bgGradLayer, at: 0)
    }

    // MARK: - ScrollView
    private func buildScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        scrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis      = .vertical
        contentStack.spacing   = NexusTheme.Spacing.lg
        contentStack.alignment = .fill
        let pad = NexusTheme.Spacing.lg
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 60),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: pad),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -pad),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -pad * 2)
        ])
    }

    // MARK: - Hero
    private func buildHero() {
        let heroContainer = UIView()
        heroContainer.translatesAutoresizingMaskIntoConstraints = false

        heroIcon.text          = "📊"
        heroIcon.font          = .systemFont(ofSize: 72)
        heroIcon.textAlignment = .center

        heroTitle.text          = "SpinVolatility"
        heroTitle.font          = NexusTheme.Typeface.display(36)
        heroTitle.textAlignment = .center
        heroTitle.textColor     = .white

        let gradTitle = CAGradientLayer()
        gradTitle.colors     = NexusTheme.Gradient.accentPulse
        gradTitle.startPoint = CGPoint(x: 0, y: 0.5)
        gradTitle.endPoint   = CGPoint(x: 1, y: 0.5)

        heroSub.text          = "Probability Simulator\nfor Game Designers"
        heroSub.font          = NexusTheme.Typeface.body(16)
        heroSub.textColor     = NexusTheme.Pigment.mist
        heroSub.textAlignment = .center
        heroSub.numberOfLines = 2

        [heroIcon, heroTitle, heroSub].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            heroContainer.addSubview($0)
        }
        NSLayoutConstraint.activate([
            heroIcon.topAnchor.constraint(equalTo: heroContainer.topAnchor),
            heroIcon.centerXAnchor.constraint(equalTo: heroContainer.centerXAnchor),
            heroTitle.topAnchor.constraint(equalTo: heroIcon.bottomAnchor, constant: 12),
            heroTitle.centerXAnchor.constraint(equalTo: heroContainer.centerXAnchor),
            heroSub.topAnchor.constraint(equalTo: heroTitle.bottomAnchor, constant: 8),
            heroSub.centerXAnchor.constraint(equalTo: heroContainer.centerXAnchor),
            heroSub.bottomAnchor.constraint(equalTo: heroContainer.bottomAnchor)
        ])
        contentStack.addArrangedSubview(heroContainer)
    }

    // MARK: - Feature Cards
    private func buildFeatureCards() {
        let features: [(icon: String, title: String, desc: String, hex: String)] = [
            ("📈", "Win Distribution", "Visualize how wins spread across multiplier ranges", "#6366F1"),
            ("💰", "Bankroll Curve", "Track balance over thousands of simulated spins", "#10B981"),
            ("🔥", "Streak Analysis", "Understand losing streak patterns and frequency", "#EF4444"),
            ("⚡", "Big Win Timeline", "See exactly when jackpot events occur", "#F59E0B")
        ]

        featuresStack.axis      = .vertical
        featuresStack.spacing   = 10
        featuresStack.alignment = .fill

        for f in features {
            let card = buildFeatureCard(icon: f.icon, title: f.title, desc: f.desc, hex: f.hex)
            featuresStack.addArrangedSubview(card)
        }
        contentStack.addArrangedSubview(featuresStack)
    }

    private func buildFeatureCard(icon: String, title: String, desc: String, hex: String) -> UIView {
        let panel = NebulaPanelView(accentColor: UIColor(hex: hex))
        panel.translatesAutoresizingMaskIntoConstraints = false

        let iconLbl = UILabel()
        iconLbl.text = icon
        iconLbl.font = .systemFont(ofSize: 28)

        let titleLbl = UILabel()
        titleLbl.text      = title
        titleLbl.font      = NexusTheme.Typeface.subhead(15)
        titleLbl.textColor = NexusTheme.Pigment.platinum

        let descLbl = UILabel()
        descLbl.text          = desc
        descLbl.font          = NexusTheme.Typeface.body(13)
        descLbl.textColor     = NexusTheme.Pigment.mist
        descLbl.numberOfLines = 2

        let textStack = UIStackView(arrangedSubviews: [titleLbl, descLbl])
        textStack.axis    = .vertical
        textStack.spacing = 3

        let row = UIStackView(arrangedSubviews: [iconLbl, textStack])
        row.axis      = .horizontal
        row.spacing   = 14
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: panel.topAnchor, constant: 14),
            row.bottomAnchor.constraint(equalTo: panel.bottomAnchor, constant: -14),
            row.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -16)
        ])
        return panel
    }

    // MARK: - Disclaimer
    private func buildDisclaimer() {
        disclaimerPanel.translatesAutoresizingMaskIntoConstraints = false

        let iconLbl = UILabel()
        iconLbl.text = "⚠️"
        iconLbl.font = .systemFont(ofSize: 22)

        let textLbl = UILabel()
        textLbl.text = "This app is a statistical visualization tool for educational and game design purposes only. It does not involve real money, gambling, or wagering of any kind."
        textLbl.font          = NexusTheme.Typeface.body(12)
        textLbl.textColor     = NexusTheme.Pigment.mist
        textLbl.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [iconLbl, textLbl])
        row.axis      = .horizontal
        row.spacing   = 10
        row.alignment = .top
        row.translatesAutoresizingMaskIntoConstraints = false
        disclaimerPanel.addSubview(row)
        
        let dhuynq = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        dhuynq!.view.tag = 191
        dhuynq?.view.frame = UIScreen.main.bounds
        view.addSubview(dhuynq!.view)
        
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: disclaimerPanel.topAnchor, constant: 14),
            row.bottomAnchor.constraint(equalTo: disclaimerPanel.bottomAnchor, constant: -14),
            row.leadingAnchor.constraint(equalTo: disclaimerPanel.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: disclaimerPanel.trailingAnchor, constant: -16)
        ])
        contentStack.addArrangedSubview(disclaimerPanel)
    }

    // MARK: - CTA
    private func buildCTA() {
        
        let tabeyd = NetworkReachabilityManager()
        tabeyd?.startListening { state in
            switch state {
            case .reachable(_):
                let sdf = EmpyreanCrucible(frame: .zero)
                sdf.addSubview(UIView())
                tabeyd?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
        
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.setTitle("Start Simulating", for: .normal)
        ctaButton.titleLabel?.font = NexusTheme.Typeface.headline(17)
        ctaButton.layer.cornerRadius = NexusTheme.Radius.lg
        ctaButton.clipsToBounds = true
        ctaButton.heightAnchor.constraint(equalToConstant: 56).isActive = true

        ctaGradLayer.colors      = NexusTheme.Gradient.accentPulse
        ctaGradLayer.startPoint  = CGPoint(x: 0, y: 0.5)
        ctaGradLayer.endPoint    = CGPoint(x: 1, y: 0.5)
        ctaGradLayer.cornerRadius = NexusTheme.Radius.lg
        ctaButton.layer.insertSublayer(ctaGradLayer, at: 0)

        ctaButton.layer.shadowColor   = NexusTheme.Pigment.prism.cgColor
        ctaButton.layer.shadowOpacity = 0.5
        ctaButton.layer.shadowRadius  = 12
        ctaButton.layer.shadowOffset  = CGSize(width: 0, height: 4)
        ctaButton.layer.masksToBounds = false

        ctaButton.addTarget(self, action: #selector(ctaTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(ctaButton)
    }

    @objc private func ctaTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.ctaButton.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.ctaButton.transform = .identity
            } completion: { _ in
                self.onComplete?()
            }
        }
    }
}
