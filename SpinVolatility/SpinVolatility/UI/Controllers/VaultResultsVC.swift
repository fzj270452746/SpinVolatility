import UIKit

final class VaultResultsVC: UIViewController {

    private let result: PulsarResult
    private let config: VortexConfig
    private let presetTag: String

    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()
    private let bgGradLayer  = CAGradientLayer()

    // Header
    private let headerPanel  = NebulaPanelView(accentColor: NexusTheme.Pigment.fuchsia)
    private let funScoreLbl  = UILabel()
    private let funRingLayer = CAShapeLayer()
    private let funFillLayer = CAShapeLayer()

    // Stats grid
    private let statsPanel   = NebulaPanelView(accentColor: NexusTheme.Pigment.azure)

    // Charts
    private let bankrollPanel = NebulaPanelView(accentColor: NexusTheme.Pigment.aurora)
    private let bankrollChart = OrbitalLineChart()

    private let histPanel    = NebulaPanelView(accentColor: NexusTheme.Pigment.prism)
    private let histChart    = SpectrumBarChart()

    private let streakPanel  = NebulaPanelView(accentColor: NexusTheme.Pigment.crimson)
    private let streakChart  = CascadeStreakChart()

    private let timelinePanel = NebulaPanelView(accentColor: NexusTheme.Pigment.gold)
    private let timelineView  = NovaTimelineView()

    private let closeBtn     = UIButton(type: .custom)

    // MARK: - Init
    init(result: PulsarResult, config: VortexConfig, presetTag: String = "CUSTOM") {
        self.result    = result
        self.config    = config
        self.presetTag = presetTag
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buildBackground()
        buildScrollView()
        buildCloseButton()
        buildFunScoreHeader()
        buildStatsGrid()
        buildBankrollChart()
        buildHistogram()
        buildStreakChart()
        buildTimeline()
        buildActionBar()
        populateData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradLayer.frame = view.bounds
        animateFunRing()
    }

    // MARK: - Background
    private func buildBackground() {
        bgGradLayer.colors     = [
            UIColor(hex: "#0A0E1A").cgColor,
            UIColor(hex: "#0D1220").cgColor
        ]
        bgGradLayer.startPoint = CGPoint(x: 0.5, y: 0)
        bgGradLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(bgGradLayer, at: 0)
    }

    // MARK: - ScrollView
    private func buildScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        scrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis      = .vertical
        contentStack.spacing   = NexusTheme.Spacing.md
        contentStack.alignment = .fill
        let pad = NexusTheme.Spacing.md
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: pad),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -pad),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: pad),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -pad),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -pad * 2)
        ])
    }

    // MARK: - Close Button
    private func buildCloseButton() {
        view.addSubview(closeBtn)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeBtn.tintColor = NexusTheme.Pigment.mist
        closeBtn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            closeBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeBtn.widthAnchor.constraint(equalToConstant: 36),
            closeBtn.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    // MARK: - Fun Score Header
    private func buildFunScoreHeader() {
        headerPanel.translatesAutoresizingMaskIntoConstraints = false

        let titleLbl = UILabel()
        titleLbl.text      = "SIMULATION RESULTS"
        titleLbl.font      = NexusTheme.Typeface.subhead(11)
        titleLbl.textColor = NexusTheme.Pigment.mist
        titleLbl.textAlignment = .center

        let ringContainer = UIView()
        ringContainer.translatesAutoresizingMaskIntoConstraints = false
        ringContainer.heightAnchor.constraint(equalToConstant: 120).isActive = true

        let ringRadius: CGFloat = 46
        let center = CGPoint(x: 60, y: 60)
        let bgRing = CAShapeLayer()
        bgRing.path        = UIBezierPath(arcCenter: center, radius: ringRadius,
                                          startAngle: -.pi / 2, endAngle: .pi * 1.5,
                                          clockwise: true).cgPath
        bgRing.strokeColor = NexusTheme.Pigment.slate.cgColor
        bgRing.fillColor   = UIColor.clear.cgColor
        bgRing.lineWidth   = 10
        ringContainer.layer.addSublayer(bgRing)

        funFillLayer.path        = UIBezierPath(arcCenter: center, radius: ringRadius,
                                                startAngle: -.pi / 2, endAngle: .pi * 1.5,
                                                clockwise: true).cgPath
        funFillLayer.fillColor   = UIColor.clear.cgColor
        funFillLayer.lineWidth   = 10
        funFillLayer.lineCap     = .round
        funFillLayer.strokeEnd   = 0

        let ringGrad = CAGradientLayer()
        ringGrad.colors     = NexusTheme.Gradient.accentPulse
        ringGrad.startPoint = CGPoint(x: 0, y: 0)
        ringGrad.endPoint   = CGPoint(x: 1, y: 1)
        ringGrad.frame      = CGRect(x: 0, y: 0, width: 120, height: 120)
        ringGrad.mask       = funFillLayer
        ringContainer.layer.addSublayer(ringGrad)

        funScoreLbl.font          = NexusTheme.Typeface.display(26)
        funScoreLbl.textColor     = NexusTheme.Pigment.platinum
        funScoreLbl.textAlignment = .center
        funScoreLbl.translatesAutoresizingMaskIntoConstraints = false
        ringContainer.addSubview(funScoreLbl)
        NSLayoutConstraint.activate([
            funScoreLbl.centerXAnchor.constraint(equalTo: ringContainer.leadingAnchor, constant: 60),
            funScoreLbl.centerYAnchor.constraint(equalTo: ringContainer.topAnchor, constant: 60)
        ])

        let funTagLbl = UILabel()
        funTagLbl.text      = "FUN SCORE"
        funTagLbl.font      = NexusTheme.Typeface.subhead(10)
        funTagLbl.textColor = NexusTheme.Pigment.fuchsia
        funTagLbl.textAlignment = .center

        let vStack = UIStackView(arrangedSubviews: [titleLbl, ringContainer, funTagLbl])
        vStack.axis      = .vertical
        vStack.spacing   = 8
        vStack.alignment = .center
        vStack.translatesAutoresizingMaskIntoConstraints = false
        headerPanel.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: headerPanel.topAnchor, constant: 20),
            vStack.bottomAnchor.constraint(equalTo: headerPanel.bottomAnchor, constant: -20),
            vStack.leadingAnchor.constraint(equalTo: headerPanel.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: headerPanel.trailingAnchor, constant: -16)
        ])
        contentStack.addArrangedSubview(headerPanel)
    }

    // MARK: - Stats Grid
    private func buildStatsGrid() {
        statsPanel.translatesAutoresizingMaskIntoConstraints = false
        let titleLbl = makeSectionTitle("Key Metrics")

        let grid = UIStackView()
        grid.axis         = .vertical
        grid.spacing      = 10
        grid.distribution = .fillEqually

        let row1 = makeStatRow([
            ("RTP", String(format: "%.1f%%", result.simulatedRTP * 100), NexusTheme.Pigment.aurora),
            ("Hit Rate", String(format: "%.1f%%", result.actualHitRate * 100), NexusTheme.Pigment.azure)
        ])
        let row2 = makeStatRow([
            ("Max Streak", "\(result.maxLoseStreak)", NexusTheme.Pigment.crimson),
            ("Avg Streak", String(format: "%.1f", result.avgLoseStreak), NexusTheme.Pigment.ember)
        ])
        let row3 = makeStatRow([
            ("Peak", String(format: "+%.0f", result.peakBalance - config.initialBankroll), NexusTheme.Pigment.aurora),
            ("Trough", String(format: "%.0f", result.troughBalance - config.initialBankroll), NexusTheme.Pigment.crimson)
        ])
        let row4 = makeStatRow([
            ("Big Wins", "\(result.bigWinEvents.count)", NexusTheme.Pigment.gold),
            ("Spins", "\(config.spinCount)", NexusTheme.Pigment.prism)
        ])

        [row1, row2, row3, row4].forEach { grid.addArrangedSubview($0) }

        let vStack = UIStackView(arrangedSubviews: [titleLbl, grid])
        vStack.axis    = .vertical
        vStack.spacing = 12
        vStack.translatesAutoresizingMaskIntoConstraints = false
        statsPanel.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: statsPanel.topAnchor, constant: 16),
            vStack.bottomAnchor.constraint(equalTo: statsPanel.bottomAnchor, constant: -16),
            vStack.leadingAnchor.constraint(equalTo: statsPanel.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: statsPanel.trailingAnchor, constant: -16)
        ])
        contentStack.addArrangedSubview(statsPanel)
    }

    private func makeStatRow(_ items: [(String, String, UIColor)]) -> UIStackView {
        let row = UIStackView()
        row.axis         = .horizontal
        row.distribution = .fillEqually
        row.spacing      = 10
        for item in items {
            let card = makeStatCard(label: item.0, value: item.1, accent: item.2)
            row.addArrangedSubview(card)
        }
        return row
    }

    private func makeStatCard(label: String, value: String, accent: UIColor) -> UIView {
        let card = NebulaPanelView(accentColor: accent)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 64).isActive = true

        let valLbl = UILabel()
        valLbl.text      = value
        valLbl.font      = NexusTheme.Typeface.mono(20)
        valLbl.textColor = accent
        valLbl.textAlignment = .center

        let lblLbl = UILabel()
        lblLbl.text      = label
        lblLbl.font      = NexusTheme.Typeface.body(11)
        lblLbl.textColor = NexusTheme.Pigment.mist
        lblLbl.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [valLbl, lblLbl])
        stack.axis      = .vertical
        stack.spacing   = 2
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        return card
    }

    // MARK: - Bankroll Chart
    private func buildBankrollChart() {
        bankrollPanel.translatesAutoresizingMaskIntoConstraints = false
        let titleLbl = makeSectionTitle("Bankroll Curve")
        bankrollChart.translatesAutoresizingMaskIntoConstraints = false
        bankrollChart.heightAnchor.constraint(equalToConstant: 180).isActive = true

        let vStack = UIStackView(arrangedSubviews: [titleLbl, bankrollChart])
        vStack.axis    = .vertical
        vStack.spacing = 12
        vStack.translatesAutoresizingMaskIntoConstraints = false
        bankrollPanel.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: bankrollPanel.topAnchor, constant: 16),
            vStack.bottomAnchor.constraint(equalTo: bankrollPanel.bottomAnchor, constant: -16),
            vStack.leadingAnchor.constraint(equalTo: bankrollPanel.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: bankrollPanel.trailingAnchor, constant: -16)
        ])
        contentStack.addArrangedSubview(bankrollPanel)
    }

    // MARK: - Histogram
    private func buildHistogram() {
        histPanel.translatesAutoresizingMaskIntoConstraints = false
        let titleLbl = makeSectionTitle("Win Distribution")
        histChart.translatesAutoresizingMaskIntoConstraints = false
        histChart.heightAnchor.constraint(equalToConstant: 160).isActive = true

        let vStack = UIStackView(arrangedSubviews: [titleLbl, histChart])
        vStack.axis    = .vertical
        vStack.spacing = 12
        vStack.translatesAutoresizingMaskIntoConstraints = false
        histPanel.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: histPanel.topAnchor, constant: 16),
            vStack.bottomAnchor.constraint(equalTo: histPanel.bottomAnchor, constant: -16),
            vStack.leadingAnchor.constraint(equalTo: histPanel.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: histPanel.trailingAnchor, constant: -16)
        ])
        contentStack.addArrangedSubview(histPanel)
    }

    // MARK: - Streak Chart
    private func buildStreakChart() {
        streakPanel.translatesAutoresizingMaskIntoConstraints = false
        let titleLbl = makeSectionTitle("Lose Streak Distribution")
        streakChart.translatesAutoresizingMaskIntoConstraints = false
        streakChart.heightAnchor.constraint(equalToConstant: 150).isActive = true

        let vStack = UIStackView(arrangedSubviews: [titleLbl, streakChart])
        vStack.axis    = .vertical
        vStack.spacing = 12
        vStack.translatesAutoresizingMaskIntoConstraints = false
        streakPanel.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: streakPanel.topAnchor, constant: 16),
            vStack.bottomAnchor.constraint(equalTo: streakPanel.bottomAnchor, constant: -16),
            vStack.leadingAnchor.constraint(equalTo: streakPanel.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: streakPanel.trailingAnchor, constant: -16)
        ])
        contentStack.addArrangedSubview(streakPanel)
    }

    // MARK: - Timeline
    private func buildTimeline() {
        timelinePanel.translatesAutoresizingMaskIntoConstraints = false
        let titleLbl = makeSectionTitle("Big Win Timeline")
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        timelineView.heightAnchor.constraint(equalToConstant: 120).isActive = true

        let vStack = UIStackView(arrangedSubviews: [titleLbl, timelineView])
        vStack.axis    = .vertical
        vStack.spacing = 12
        vStack.translatesAutoresizingMaskIntoConstraints = false
        timelinePanel.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: timelinePanel.topAnchor, constant: 16),
            vStack.bottomAnchor.constraint(equalTo: timelinePanel.bottomAnchor, constant: -16),
            vStack.leadingAnchor.constraint(equalTo: timelinePanel.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: timelinePanel.trailingAnchor, constant: -16)
        ])
        contentStack.addArrangedSubview(timelinePanel)
    }

    // MARK: - Action Bar
    private func buildActionBar() {
        let panel = NebulaPanelView(accentColor: NexusTheme.Pigment.prism)
        let stack = UIStackView()
        stack.axis         = .horizontal
        stack.distribution = .fillEqually
        stack.spacing      = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: panel.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: panel.bottomAnchor, constant: -14),
            stack.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -14)
        ])

        let exportBtn  = makeIconBtn(icon: "square.and.arrow.up", label: "Export",
                                     color: NexusTheme.Pigment.aurora, action: #selector(exportTapped))
        let compareBtn = makeIconBtn(icon: "arrow.left.arrow.right", label: "Compare",
                                     color: NexusTheme.Pigment.prism, action: #selector(compareTapped))
        stack.addArrangedSubview(exportBtn)
        stack.addArrangedSubview(compareBtn)
        contentStack.addArrangedSubview(panel)
    }

    private func makeIconBtn(icon: String, label: String, color: UIColor, action: Selector) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.heightAnchor.constraint(equalToConstant: 52).isActive = true
        btn.layer.cornerRadius = NexusTheme.Radius.md
        btn.backgroundColor    = color.withAlphaComponent(0.12)
        btn.layer.borderColor  = color.withAlphaComponent(0.35).cgColor
        btn.layer.borderWidth  = 1

        let img = UIImageView(image: UIImage(systemName: icon))
        img.tintColor = color
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        img.widthAnchor.constraint(equalToConstant: 18).isActive = true
        img.heightAnchor.constraint(equalToConstant: 18).isActive = true

        let lbl = UILabel()
        lbl.text      = label
        lbl.font      = NexusTheme.Typeface.subhead(13)
        lbl.textColor = color

        let row = UIStackView(arrangedSubviews: [img, lbl])
        row.axis      = .horizontal
        row.spacing   = 6
        row.alignment = .center
        row.isUserInteractionEnabled = false
        row.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(row)
        NSLayoutConstraint.activate([
            row.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
            row.centerYAnchor.constraint(equalTo: btn.centerYAnchor)
        ])
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }

    @objc private func exportTapped() {
        let vc = ExportSheetVC(result: result, config: config, presetTag: presetTag)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    @objc private func compareTapped() {
        let history = ChronVault.shared.entries
        guard !history.isEmpty else {
            CometAlertView.present(on: view, style: .info, icon: "📂",
                                   title: "No History",
                                   body: "Run more simulations to compare results.",
                                   actions: [("OK", true, {})])
            return
        }
        let picker = HistoryListVC()
        picker.onLoadConfig = { [weak self] cfg, tag in
            guard let self = self else { return }
            // find the matching entry to build a ChronEntry for comparison
            if let entry = ChronVault.shared.entries.first(where: {
                $0.config.winRate == cfg.winRate && $0.presetTag == tag
            }) {
                let currentEntry = ChronEntry(
                    id: UUID(), timestamp: Date(),
                    label: "Current (\(self.presetTag))",
                    presetTag: self.presetTag,
                    config: self.config.chronConfig,
                    summary: self.result.chronSummary
                )
                let dualVC = DualPrismVC(entryA: currentEntry, entryB: entry)
                let nav = UINavigationController(rootViewController: dualVC)
                nav.modalPresentationStyle = .pageSheet
                self.present(nav, animated: true)
            }
        }
        let nav = UINavigationController(rootViewController: picker)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    // MARK: - Populate
    private func populateData() {
        funScoreLbl.text = String(format: "%.0f", result.funScore)
        bankrollChart.renderLedger(result.balanceLedger, initial: config.initialBankroll)
        histChart.renderBuckets(result.winBuckets)
        streakChart.renderStreaks(distribution: result.streakDistribution,
                                  maxStreak: result.maxLoseStreak,
                                  avgStreak: result.avgLoseStreak)
        timelineView.renderEvents(result.bigWinEvents, totalSpins: config.spinCount)
    }

    private func animateFunRing() {
        let target = CGFloat(result.funScore / 100)
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue = 0
        anim.toValue   = target
        anim.duration  = 1.2
        anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        anim.fillMode  = .forwards
        anim.isRemovedOnCompletion = false
        funFillLayer.add(anim, forKey: "ring")
        funFillLayer.strokeEnd = target
    }

    // MARK: - Helpers
    private func makeSectionTitle(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text      = text.uppercased()
        lbl.font      = NexusTheme.Typeface.subhead(11)
        lbl.textColor = NexusTheme.Pigment.mist
        return lbl
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
