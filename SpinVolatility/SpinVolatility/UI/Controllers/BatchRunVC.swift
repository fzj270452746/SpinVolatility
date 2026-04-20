import UIKit

// MARK: - BatchSummary
private struct BatchSummary {
    let rtpValues:       [Double]
    let funScores:       [Double]
    let maxStreaks:       [Int]
    let finalBalances:   [Double]
    let bigWinCounts:    [Int]

    var rtpMean:   Double { rtpValues.mean }
    var rtpMin:    Double { rtpValues.min() ?? 0 }
    var rtpMax:    Double { rtpValues.max() ?? 0 }
    var funMean:   Double { funScores.mean }
    var peakFun:   Double { funScores.max() ?? 0 }
    var avgStreak: Double { Double(maxStreaks.reduce(0, +)) / Double(max(1, maxStreaks.count)) }
    var worstStreak: Int  { maxStreaks.max() ?? 0 }
    var balanceMean: Double { finalBalances.mean }
    var balanceMin:  Double { finalBalances.min() ?? 0 }
    var balanceMax:  Double { finalBalances.max() ?? 0 }
    var profitRate:  Double {
        guard !finalBalances.isEmpty else { return 0 }
        return Double(finalBalances.filter { $0 > 0 }.count) / Double(finalBalances.count)
    }
}

private extension Array where Element == Double {
    var mean: Double {
        isEmpty ? 0 : reduce(0, +) / Double(count)
    }
    var stddev: Double {
        guard count > 1 else { return 0 }
        let m = mean
        let variance = map { ($0 - m) * ($0 - m) }.reduce(0, +) / Double(count - 1)
        return variance.squareRoot()
    }
}

// MARK: - BatchRunVC
final class BatchRunVC: UIViewController {

    private let config:    VortexConfig
    private let presetTag: String
    private let engine   = QuantumEngine()

    private var runCount:  Int = 10
    private var isRunning  = false

    private let bgGradLayer  = CAGradientLayer()
    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()

    private let runCountPanel = NebulaPanelView(accentColor: NexusTheme.Pigment.azure)
    private var runCountBtns  = [UIButton]()

    private let runBtn        = UIButton(type: .custom)
    private let runGradLayer  = CAGradientLayer()
    private let progressBar   = UIProgressView(progressViewStyle: .bar)
    private let progressLbl   = UILabel()

    private var resultsPanel: UIView?
    private var batchSummary: BatchSummary?

    init(config: VortexConfig, presetTag: String) {
        self.config    = config
        self.presetTag = presetTag
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildBackground()
        buildNav()
        buildScrollView()
        buildRunCountPicker()
        buildRunButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradLayer.frame  = view.bounds
        runGradLayer.frame = runBtn.bounds
    }

    // MARK: - Background
    private func buildBackground() {
        bgGradLayer.colors     = NexusTheme.Gradient.heroTop
        bgGradLayer.startPoint = CGPoint(x: 0.5, y: 0)
        bgGradLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(bgGradLayer, at: 0)
    }

    private func buildNav() {
        title = "Batch Simulation"
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
        contentStack.spacing   = 14
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

    // MARK: - Run Count Picker
    private func buildRunCountPicker() {
        contentStack.addArrangedSubview(makeSectionLabel("PRESET: \(presetTag)  —  HOW MANY RUNS?"))

        let counts = [5, 10, 20, 50]
        let btnStack = UIStackView()
        btnStack.axis         = .horizontal
        btnStack.distribution = .fillEqually
        btnStack.spacing      = 8

        for count in counts {
            let btn = UIButton(type: .custom)
            btn.setTitle("\(count)×", for: .normal)
            btn.titleLabel?.font = NexusTheme.Typeface.subhead(15)
            btn.layer.cornerRadius = NexusTheme.Radius.md
            btn.clipsToBounds = true
            btn.tag = count
            btn.heightAnchor.constraint(equalToConstant: 48).isActive = true
            btn.backgroundColor = NexusTheme.Pigment.slate
            btn.setTitleColor(NexusTheme.Pigment.mist, for: .normal)
            btn.addTarget(self, action: #selector(runCountTapped(_:)), for: .touchUpInside)
            btnStack.addArrangedSubview(btn)
            runCountBtns.append(btn)
        }

        let vStack = UIStackView(arrangedSubviews: [btnStack])
        vStack.axis    = .vertical
        vStack.spacing = 12
        vStack.translatesAutoresizingMaskIntoConstraints = false
        runCountPanel.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: runCountPanel.topAnchor, constant: 14),
            vStack.bottomAnchor.constraint(equalTo: runCountPanel.bottomAnchor, constant: -14),
            vStack.leadingAnchor.constraint(equalTo: runCountPanel.leadingAnchor, constant: 14),
            vStack.trailingAnchor.constraint(equalTo: runCountPanel.trailingAnchor, constant: -14)
        ])
        contentStack.addArrangedSubview(runCountPanel)
        selectRunCount(10)
    }

    // MARK: - Run Button
    private func buildRunButton() {
        contentStack.addArrangedSubview(makeSectionLabel("START BATCH"))

        runBtn.translatesAutoresizingMaskIntoConstraints = false
        runBtn.setTitle("RUN BATCH", for: .normal)
        runBtn.titleLabel?.font = NexusTheme.Typeface.headline(15)
        runBtn.setTitleColor(.white, for: .normal)
        runBtn.layer.cornerRadius = NexusTheme.Radius.lg
        runBtn.clipsToBounds = true
        runBtn.heightAnchor.constraint(equalToConstant: 54).isActive = true
        runGradLayer.colors       = NexusTheme.Gradient.accentPulse
        runGradLayer.startPoint   = CGPoint(x: 0, y: 0.5)
        runGradLayer.endPoint     = CGPoint(x: 1, y: 0.5)
        runGradLayer.cornerRadius = NexusTheme.Radius.lg
        runBtn.layer.insertSublayer(runGradLayer, at: 0)
        runBtn.layer.shadowColor   = NexusTheme.Pigment.prism.cgColor
        runBtn.layer.shadowOpacity = 0.5
        runBtn.layer.shadowRadius  = 10
        runBtn.layer.shadowOffset  = .zero
        runBtn.addTarget(self, action: #selector(runBatchTapped), for: .touchUpInside)

        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.progressTintColor = NexusTheme.Pigment.aurora
        progressBar.trackTintColor    = NexusTheme.Pigment.slate
        progressBar.layer.cornerRadius = 2
        progressBar.clipsToBounds = true
        progressBar.isHidden = true

        progressLbl.translatesAutoresizingMaskIntoConstraints = false
        progressLbl.font      = NexusTheme.Typeface.mono(12)
        progressLbl.textColor = NexusTheme.Pigment.mist
        progressLbl.textAlignment = .center
        progressLbl.isHidden = true

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        [runBtn, progressBar, progressLbl].forEach { container.addSubview($0) }
        NSLayoutConstraint.activate([
            runBtn.topAnchor.constraint(equalTo: container.topAnchor),
            runBtn.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            runBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            progressBar.topAnchor.constraint(equalTo: runBtn.bottomAnchor, constant: 8),
            progressBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 4),
            progressLbl.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 4),
            progressLbl.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            progressLbl.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            progressLbl.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        contentStack.addArrangedSubview(container)
    }

    // MARK: - Run Batch
    @objc private func runBatchTapped() {
        guard !isRunning else { return }
        isRunning = true
        runBtn.setTitle("RUNNING...", for: .normal)
        progressBar.isHidden  = false
        progressLbl.isHidden  = false
        progressBar.progress  = 0

        if let old = resultsPanel {
            contentStack.removeArrangedSubview(old)
            old.removeFromSuperview()
            resultsPanel = nil
        }

        let total = runCount
        var results = [PulsarResult]()
        let queue = DispatchQueue(label: "batch", qos: .userInitiated)

        queue.async {
            for i in 0..<total {
                let result = self.engine.runSync(config: self.config)
                results.append(result)
                let pct = Double(i + 1) / Double(total)
                DispatchQueue.main.async {
                    self.progressBar.setProgress(Float(pct), animated: true)
                    self.progressLbl.text = "\(i + 1) / \(total)"
                }
            }
            let summary = BatchSummary(
                rtpValues:     results.map { $0.simulatedRTP },
                funScores:     results.map { $0.funScore },
                maxStreaks:    results.map { $0.maxLoseStreak },
                finalBalances: results.map { $0.balanceLedger.last ?? self.config.initialBankroll },
                bigWinCounts:  results.map { $0.bigWinEvents.count }
            )
            DispatchQueue.main.async {
                self.isRunning = false
                self.runBtn.setTitle("RUN BATCH", for: .normal)
                self.progressBar.isHidden = true
                self.progressLbl.isHidden = true
                self.batchSummary = summary
                self.showResults(summary)
            }
        }
    }

    private func showResults(_ s: BatchSummary) {
        let panel = NebulaPanelView(accentColor: NexusTheme.Pigment.aurora)
        let vStack = UIStackView()
        vStack.axis    = .vertical
        vStack.spacing = 10
        vStack.translatesAutoresizingMaskIntoConstraints = false

        let hdr = makeSectionLabel("BATCH RESULTS (\(runCount) RUNS)")

        let grid = UIStackView()
        grid.axis         = .vertical
        grid.spacing      = 8

        let row1 = makeResultRow(
            left:  ("RTP Mean", String(format: "%.2f%%", s.rtpMean * 100), NexusTheme.Pigment.aurora),
            right: ("RTP Range", String(format: "%.1f–%.1f%%", s.rtpMin * 100, s.rtpMax * 100), NexusTheme.Pigment.mist)
        )
        let row2 = makeResultRow(
            left:  ("Fun Mean", String(format: "%.1f", s.funMean), NexusTheme.Pigment.prism),
            right: ("Peak Fun", String(format: "%.1f", s.peakFun), NexusTheme.Pigment.violet)
        )
        let row3 = makeResultRow(
            left:  ("Avg Max Streak", String(format: "%.1f", s.avgStreak), NexusTheme.Pigment.crimson),
            right: ("Worst Streak", "\(s.worstStreak)", NexusTheme.Pigment.ember)
        )
        let row4 = makeResultRow(
            left:  ("Avg Balance", String(format: "%.1f", s.balanceMean), NexusTheme.Pigment.gold),
            right: ("Profit Rate", String(format: "%.0f%%", s.profitRate * 100), NexusTheme.Pigment.azure)
        )
        let row5 = makeResultRow(
            left:  ("Balance Min", String(format: "%.1f", s.balanceMin), NexusTheme.Pigment.crimson),
            right: ("Balance Max", String(format: "%.1f", s.balanceMax), NexusTheme.Pigment.aurora)
        )

        [row1, row2, row3, row4, row5].forEach { grid.addArrangedSubview($0) }

        let dispersionLbl = UILabel()
        dispersionLbl.text = "RTP std dev: \(String(format: "%.3f%%", s.rtpValues.stddev * 100))  |  Fun std dev: \(String(format: "%.1f", s.funScores.stddev))"
        dispersionLbl.font = NexusTheme.Typeface.mono(11)
        dispersionLbl.textColor = NexusTheme.Pigment.ghost
        dispersionLbl.textAlignment = .center

        vStack.addArrangedSubview(hdr)
        vStack.addArrangedSubview(grid)
        vStack.addArrangedSubview(dispersionLbl)
        panel.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: panel.topAnchor, constant: 14),
            vStack.bottomAnchor.constraint(equalTo: panel.bottomAnchor, constant: -14),
            vStack.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 14),
            vStack.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -14)
        ])

        contentStack.addArrangedSubview(panel)
        resultsPanel = panel

        // Scroll to results
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let bottom = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.height)
            if bottom.y > 0 {
                self.scrollView.setContentOffset(bottom, animated: true)
            }
        }
    }

    private func makeResultRow(left: (String, String, UIColor),
                                right: (String, String, UIColor)) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [
            makeStatCard(label: left.0,  value: left.1,  accent: left.2),
            makeStatCard(label: right.0, value: right.1, accent: right.2)
        ])
        row.axis         = .horizontal
        row.distribution = .fillEqually
        row.spacing      = 8
        return row
    }

    private func makeStatCard(label: String, value: String, accent: UIColor) -> UIView {
        let card = NebulaPanelView(accentColor: accent)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 60).isActive = true
        let valLbl = UILabel()
        valLbl.text      = value
        valLbl.font      = NexusTheme.Typeface.mono(16)
        valLbl.textColor = accent
        valLbl.textAlignment = .center
        let lblLbl = UILabel()
        lblLbl.text      = label
        lblLbl.font      = NexusTheme.Typeface.body(10)
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

    // MARK: - Helpers
    private func selectRunCount(_ count: Int) {
        runCount = count
        for btn in runCountBtns {
            let selected = btn.tag == count
            UIView.animate(withDuration: 0.2) {
                btn.backgroundColor = selected ? NexusTheme.Pigment.azure : NexusTheme.Pigment.slate
                btn.setTitleColor(selected ? .white : NexusTheme.Pigment.mist, for: .normal)
            }
        }
    }

    @objc private func runCountTapped(_ sender: UIButton) {
        selectRunCount(sender.tag)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text      = text
        lbl.font      = NexusTheme.Typeface.subhead(11)
        lbl.textColor = NexusTheme.Pigment.mist
        return lbl
    }
}

// MARK: - QuantumEngine sync helper
extension QuantumEngine {
    func runSync(config: VortexConfig) -> PulsarResult {
        let sema = DispatchSemaphore(value: 0)
        var out: PulsarResult!
        ignite(config: config) { result in
            out = result
            sema.signal()
        }
        sema.wait()
        return out
    }
}
