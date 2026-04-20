import UIKit

final class DualPrismVC: UIViewController {

    private let entryA: ChronEntry
    private let entryB: ChronEntry

    private let bgGradLayer  = CAGradientLayer()
    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()

    init(entryA: ChronEntry, entryB: ChronEntry) {
        self.entryA = entryA
        self.entryB = entryB
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildBackground()
        buildNav()
        buildScrollView()
        buildHeader()
        buildMetricRows()
        buildConfigSection()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradLayer.frame = view.bounds
    }

    // MARK: - Background
    private func buildBackground() {
        bgGradLayer.colors     = NexusTheme.Gradient.heroTop
        bgGradLayer.startPoint = CGPoint(x: 0.5, y: 0)
        bgGradLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(bgGradLayer, at: 0)
    }

    private func buildNav() {
        title = "Compare"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: NexusTheme.Pigment.platinum,
            .font: NexusTheme.Typeface.headline(17)
        ]
        navigationController?.navigationBar.barTintColor = UIColor(hex: "#0A0E1A")
        navigationController?.navigationBar.isTranslucent = false
        let closeBtn = UIBarButtonItem(title: "Done", style: .done,
                                       target: self, action: #selector(closeTapped))
        closeBtn.tintColor = NexusTheme.Pigment.prism
        navigationItem.rightBarButtonItem = closeBtn
    }

    // MARK: - ScrollView
    private func buildScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        scrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis      = .vertical
        contentStack.spacing   = 12
        contentStack.alignment = .fill
        let pad: CGFloat = 16
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: pad),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -pad),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -pad * 2)
        ])
    }

    // MARK: - Header
    private func buildHeader() {
        let row = UIStackView()
        row.axis         = .horizontal
        row.distribution = .fillEqually
        row.spacing      = 10

        row.addArrangedSubview(makeNameCard(entry: entryA, side: .left))
        row.addArrangedSubview(makeVsLabel())
        row.addArrangedSubview(makeNameCard(entry: entryB, side: .right))
        contentStack.addArrangedSubview(row)
        row.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }

    private func makeNameCard(entry: ChronEntry, side: Side) -> UIView {
        let panel = NebulaPanelView(accentColor: side == .left ? NexusTheme.Pigment.prism : NexusTheme.Pigment.fuchsia)
        let stack = UIStackView()
        stack.axis      = .vertical
        stack.spacing   = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: panel.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: panel.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: panel.trailingAnchor, constant: -8)
        ])
        let badge = UILabel()
        badge.text            = entry.presetTag
        badge.font            = NexusTheme.Typeface.subhead(10)
        badge.textColor       = .white
        badge.backgroundColor = (side == .left ? NexusTheme.Pigment.prism : NexusTheme.Pigment.fuchsia).withAlphaComponent(0.8)
        badge.layer.cornerRadius = 5
        badge.clipsToBounds   = true
        badge.textAlignment   = .center
        badge.widthAnchor.constraint(equalToConstant: 46).isActive = true
        badge.heightAnchor.constraint(equalToConstant: 18).isActive = true

        let nameLbl = UILabel()
        nameLbl.text          = entry.label
        nameLbl.font          = NexusTheme.Typeface.subhead(11)
        nameLbl.textColor     = NexusTheme.Pigment.platinum
        nameLbl.textAlignment = .center
        nameLbl.numberOfLines = 2

        stack.addArrangedSubview(badge)
        stack.addArrangedSubview(nameLbl)
        return panel
    }

    private func makeVsLabel() -> UIView {
        let lbl = UILabel()
        lbl.text          = "VS"
        lbl.font          = NexusTheme.Typeface.display(18)
        lbl.textColor     = NexusTheme.Pigment.gold
        lbl.textAlignment = .center
        lbl.widthAnchor.constraint(equalToConstant: 36).isActive = true
        return lbl
    }

    // MARK: - Metric Rows
    private func buildMetricRows() {
        let sectionLbl = makeSectionTitle("PERFORMANCE METRICS")
        contentStack.addArrangedSubview(sectionLbl)

        let a = entryA.summary
        let b = entryB.summary

        let metrics: [(String, String, String, Winner)] = [
            ("RTP",
             String(format: "%.2f%%", a.simulatedRTP * 100),
             String(format: "%.2f%%", b.simulatedRTP * 100),
             a.simulatedRTP >= b.simulatedRTP ? .left : .right),

            ("Hit Rate",
             String(format: "%.2f%%", a.actualHitRate * 100),
             String(format: "%.2f%%", b.actualHitRate * 100),
             a.actualHitRate >= b.actualHitRate ? .left : .right),

            ("Fun Score",
             String(format: "%.1f", a.funScore),
             String(format: "%.1f", b.funScore),
             a.funScore >= b.funScore ? .left : .right),

            ("Max Streak",
             "\(a.maxLoseStreak)",
             "\(b.maxLoseStreak)",
             a.maxLoseStreak <= b.maxLoseStreak ? .left : .right),

            ("Avg Streak",
             String(format: "%.1f", a.avgLoseStreak),
             String(format: "%.1f", b.avgLoseStreak),
             a.avgLoseStreak <= b.avgLoseStreak ? .left : .right),

            ("Peak Balance",
             String(format: "%.1f", a.peakBalance),
             String(format: "%.1f", b.peakBalance),
             a.peakBalance >= b.peakBalance ? .left : .right),

            ("Trough",
             String(format: "%.1f", a.troughBalance),
             String(format: "%.1f", b.troughBalance),
             a.troughBalance >= b.troughBalance ? .left : .right),

            ("Big Wins",
             "\(a.bigWinCount)",
             "\(b.bigWinCount)",
             a.bigWinCount >= b.bigWinCount ? .left : .right)
        ]

        for (label, valA, valB, winner) in metrics {
            contentStack.addArrangedSubview(makeMetricRow(label: label, valA: valA, valB: valB, winner: winner))
        }
    }

    private func makeMetricRow(label: String, valA: String, valB: String, winner: Winner) -> UIView {
        let panel = NebulaPanelView(accentColor: NexusTheme.Pigment.slate)
        panel.heightAnchor.constraint(equalToConstant: 52).isActive = true

        let labelLbl = UILabel()
        labelLbl.text      = label
        labelLbl.font      = NexusTheme.Typeface.subhead(12)
        labelLbl.textColor = NexusTheme.Pigment.mist
        labelLbl.textAlignment = .center

        let aLbl = UILabel()
        aLbl.text      = valA
        aLbl.font      = NexusTheme.Typeface.mono(14)
        aLbl.textColor = winner == .left ? NexusTheme.Pigment.aurora : NexusTheme.Pigment.platinum
        aLbl.textAlignment = .center

        let bLbl = UILabel()
        bLbl.text      = valB
        bLbl.font      = NexusTheme.Typeface.mono(14)
        bLbl.textColor = winner == .right ? NexusTheme.Pigment.aurora : NexusTheme.Pigment.platinum
        bLbl.textAlignment = .center

        let winnerDot = UIView()
        winnerDot.backgroundColor = NexusTheme.Pigment.aurora
        winnerDot.layer.cornerRadius = 4
        winnerDot.widthAnchor.constraint(equalToConstant: 8).isActive = true
        winnerDot.heightAnchor.constraint(equalToConstant: 8).isActive = true

        [aLbl, labelLbl, bLbl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            panel.addSubview($0)
        }
        winnerDot.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(winnerDot)

        NSLayoutConstraint.activate([
            aLbl.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 16),
            aLbl.centerYAnchor.constraint(equalTo: panel.centerYAnchor),
            aLbl.widthAnchor.constraint(equalTo: panel.widthAnchor, multiplier: 0.3),

            labelLbl.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
            labelLbl.centerYAnchor.constraint(equalTo: panel.centerYAnchor),

            bLbl.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -16),
            bLbl.centerYAnchor.constraint(equalTo: panel.centerYAnchor),
            bLbl.widthAnchor.constraint(equalTo: panel.widthAnchor, multiplier: 0.3),

            winnerDot.centerYAnchor.constraint(equalTo: panel.centerYAnchor),
            winnerDot.leadingAnchor.constraint(equalTo: winner == .left ? aLbl.trailingAnchor : bLbl.leadingAnchor,
                                               constant: winner == .left ? 4 : -12)
        ])

        return panel
    }

    // MARK: - Config Section
    private func buildConfigSection() {
        let sectionLbl = makeSectionTitle("CONFIGURATION")
        contentStack.addArrangedSubview(sectionLbl)

        let row = UIStackView()
        row.axis         = .horizontal
        row.distribution = .fillEqually
        row.spacing      = 10
        row.addArrangedSubview(makeConfigCard(entry: entryA, side: .left))
        row.addArrangedSubview(makeConfigCard(entry: entryB, side: .right))
        contentStack.addArrangedSubview(row)
    }

    private func makeConfigCard(entry: ChronEntry, side: Side) -> UIView {
        let panel = NebulaPanelView(accentColor: side == .left ? NexusTheme.Pigment.prism : NexusTheme.Pigment.fuchsia)
        let stack = UIStackView()
        stack.axis    = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: panel.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: panel.bottomAnchor, constant: -14),
            stack.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -14)
        ])
        let c = entry.config
        let lines: [(String, String)] = [
            ("Win Rate",   String(format: "%.0f%%", c.winRate * 100)),
            ("Big Win",    String(format: "%.1f%%", c.bigWinRate * 100)),
            ("Avg Win",    String(format: "%.1fx", c.avgWinMultiplier)),
            ("Max Win",    String(format: "%.0fx", c.maxWinMultiplier)),
            ("Spins",      spinLabel(c.spinCount))
        ]
        for (k, v) in lines {
            stack.addArrangedSubview(makeKV(key: k, value: v))
        }
        return panel
    }

    private func makeKV(key: String, value: String) -> UIView {
        let row = UIStackView()
        row.axis         = .horizontal
        row.distribution = .equalSpacing
        let kLbl = UILabel()
        kLbl.text      = key
        kLbl.font      = NexusTheme.Typeface.body(11)
        kLbl.textColor = NexusTheme.Pigment.ghost
        let vLbl = UILabel()
        vLbl.text      = value
        vLbl.font      = NexusTheme.Typeface.mono(11)
        vLbl.textColor = NexusTheme.Pigment.platinum
        row.addArrangedSubview(kLbl)
        row.addArrangedSubview(vLbl)
        return row
    }

    private func spinLabel(_ n: Int) -> String {
        n >= 100_000 ? "100K" : n >= 10_000 ? "10K" : "1K"
    }

    private func makeSectionTitle(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text      = text
        lbl.font      = NexusTheme.Typeface.subhead(11)
        lbl.textColor = NexusTheme.Pigment.mist
        return lbl
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    private enum Side { case left, right }
    private enum Winner { case left, right }
}
