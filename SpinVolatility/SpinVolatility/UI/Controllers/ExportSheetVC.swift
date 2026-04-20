import UIKit

final class ExportSheetVC: UIViewController {

    private let result: PulsarResult
    private let config: VortexConfig
    private let presetTag: String

    private let bgGradLayer  = CAGradientLayer()
    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()

    init(result: PulsarResult, config: VortexConfig, presetTag: String) {
        self.result    = result
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
        buildPreview()
        buildActions()
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
        title = "Export Report"
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

    // MARK: - Preview
    private func buildPreview() {
        contentStack.addArrangedSubview(makeSectionTitle("REPORT PREVIEW"))

        let previewPanel = NebulaPanelView(accentColor: NexusTheme.Pigment.prism)
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable   = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.font         = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        textView.textColor    = NexusTheme.Pigment.platinum
        textView.text         = buildReportText()
        previewPanel.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: previewPanel.topAnchor, constant: 14),
            textView.bottomAnchor.constraint(equalTo: previewPanel.bottomAnchor, constant: -14),
            textView.leadingAnchor.constraint(equalTo: previewPanel.leadingAnchor, constant: 14),
            textView.trailingAnchor.constraint(equalTo: previewPanel.trailingAnchor, constant: -14)
        ])
        contentStack.addArrangedSubview(previewPanel)
    }

    // MARK: - Actions
    private func buildActions() {
        contentStack.addArrangedSubview(makeSectionTitle("EXPORT OPTIONS"))

        let copyBtn  = makeActionButton(title: "Copy to Clipboard", icon: "doc.on.doc",
                                        color: NexusTheme.Pigment.prism)
        let shareBtn = makeActionButton(title: "Share as Text File", icon: "square.and.arrow.up",
                                        color: NexusTheme.Pigment.aurora)
        copyBtn.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
        shareBtn.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(copyBtn)
        contentStack.addArrangedSubview(shareBtn)
    }

    private func makeActionButton(title: String, icon: String, color: UIColor) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 52).isActive = true
        btn.layer.cornerRadius = NexusTheme.Radius.md
        btn.layer.borderColor  = color.withAlphaComponent(0.4).cgColor
        btn.layer.borderWidth  = 1
        btn.backgroundColor    = color.withAlphaComponent(0.12)

        let img = UIImageView(image: UIImage(systemName: icon))
        img.tintColor = color
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        img.widthAnchor.constraint(equalToConstant: 20).isActive = true
        img.heightAnchor.constraint(equalToConstant: 20).isActive = true

        let lbl = UILabel()
        lbl.text      = title
        lbl.font      = NexusTheme.Typeface.subhead(15)
        lbl.textColor = color

        let row = UIStackView(arrangedSubviews: [img, lbl])
        row.axis      = .horizontal
        row.spacing   = 8
        row.alignment = .center
        row.isUserInteractionEnabled = false
        row.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(row)
        NSLayoutConstraint.activate([
            row.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
            row.centerYAnchor.constraint(equalTo: btn.centerYAnchor)
        ])
        return btn
    }

    // MARK: - Report text
    private func buildReportText() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let r = result
        let c = config
        return """
SpinVolatility — Simulation Report
Generated: \(df.string(from: Date()))
Preset: \(presetTag)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CONFIGURATION
  Win Rate          : \(String(format: "%.1f%%", c.winRate * 100))
  Big Win Rate      : \(String(format: "%.2f%%", c.bigWinRate * 100))
  Avg Win Multiplier: \(String(format: "%.2fx", c.avgWinMultiplier))
  Max Win Multiplier: \(String(format: "%.0fx", c.maxWinMultiplier))
  Spin Count        : \(c.spinCount)
  Initial Bankroll  : \(String(format: "%.0f", c.initialBankroll))

RESULTS
  Simulated RTP     : \(String(format: "%.2f%%", r.simulatedRTP * 100))
  Actual Hit Rate   : \(String(format: "%.2f%%", r.actualHitRate * 100))
  Fun Score         : \(String(format: "%.1f / 100", r.funScore))
  Peak Balance      : \(String(format: "%.2f", r.peakBalance))
  Trough Balance    : \(String(format: "%.2f", r.troughBalance))
  Max Lose Streak   : \(r.maxLoseStreak)
  Avg Lose Streak   : \(String(format: "%.1f", r.avgLoseStreak))
  Big Win Events    : \(r.bigWinEvents.count)

WIN DISTRIBUTION
\(r.winBuckets.map { "  \($0.range.padding(toLength: 12, withPad: " ", startingAt: 0)): \($0.count)" }.joined(separator: "\n"))
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
This report is for statistical analysis purposes only.
"""
    }

    // MARK: - Actions
    @objc private func copyTapped() {
        UIPasteboard.general.string = buildReportText()
        CometAlertView.present(on: view, style: .success, icon: "✅",
                               title: "Copied",
                               body: "Report copied to clipboard.",
                               actions: [("OK", true, {})])
    }

    @objc private func shareTapped() {
        let text = buildReportText()
        let tmpURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("SpinVolatility_Report.txt")
        try? text.write(to: tmpURL, atomically: true, encoding: .utf8)
        let vc = UIActivityViewController(activityItems: [tmpURL], applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = view
        present(vc, animated: true)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    private func makeSectionTitle(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text      = text
        lbl.font      = NexusTheme.Typeface.subhead(11)
        lbl.textColor = NexusTheme.Pigment.mist
        return lbl
    }
}
