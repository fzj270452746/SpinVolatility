import UIKit

final class GlossaryVC: UIViewController {

    struct Term {
        let icon: String
        let title: String
        let subtitle: String
        let body: String
        let accentHex: String
    }

    private let terms: [Term] = [
        Term(icon: "percent", title: "RTP (Return to Player)",
             subtitle: "Theoretical Return Rate",
             body: "RTP represents the percentage of total wagered money that a slot returns to players over time. For example, an RTP of 96% means for every 100 units wagered, 96 units are theoretically returned. A higher RTP means smaller long-term losses, but does not predict the outcome of a single session.",
             accentHex: "#10B981"),
        Term(icon: "waveform.path.ecg", title: "Volatility",
             subtitle: "Risk Level",
             body: "Volatility describes how spread out the reward distribution is. Low volatility: frequent small wins with a stable balance curve. High volatility: long dry spells with occasional large payouts. High-volatility games require a larger bankroll to survive the losing streaks.",
             accentHex: "#6366F1"),
        Term(icon: "target", title: "Hit Rate",
             subtitle: "Trigger Frequency",
             body: "Hit rate is the probability that any spin triggers a win. A hit rate of 25% means on average 1 in every 4 spins pays out. Note: a high hit rate does not equal a high RTP — frequent small wins can still result in a net loss.",
             accentHex: "#2563EB"),
        Term(icon: "bolt.fill", title: "Big Win",
             subtitle: "High-Multiplier Event",
             body: "A big win is defined as a single payout exceeding 5× the average win multiplier. The big win rate determines how explosive a game feels. Too high a big win rate lowers RTP; too low makes the game feel unrewarding.",
             accentHex: "#F59E0B"),
        Term(icon: "chart.line.downtrend.xyaxis", title: "Lose Streak",
             subtitle: "Consecutive Non-Winning Spins",
             body: "A lose streak is the number of consecutive spins that trigger no reward. Max Streak reflects the worst-case scenario; Avg Streak reflects the typical experience. High-volatility games tend to produce longer losing streaks.",
             accentHex: "#EF4444"),
        Term(icon: "mountain.2.fill", title: "Peak / Trough",
             subtitle: "Highest / Lowest Balance Point",
             body: "Peak is the all-time high balance recorded during the simulation; Trough is the lowest. A larger peak-to-trough gap indicates more dramatic swings and a more emotionally intense player experience.",
             accentHex: "#D946EF"),
        Term(icon: "face.smiling", title: "Fun Score",
             subtitle: "Overall Experience Rating",
             body: "Fun Score is a proprietary SpinVolatility metric calculated from big win frequency, average reward intensity, and losing streak length (0–100). A high Fun Score means the game strikes a good balance between excitement and playability.",
             accentHex: "#8B5CF6"),
        Term(icon: "arrow.triangle.2.circlepath", title: "Monte Carlo Simulation",
             subtitle: "Random Sampling Method",
             body: "Monte Carlo simulation estimates probability distributions through a large number of random samples. SpinVolatility runs up to 100,000 spins per session and uses the statistical distribution of results to predict long-term game behavior — without relying on analytical formulas.",
             accentHex: "#F97316"),
        Term(icon: "scalemass.fill", title: "Bankroll Management",
             subtitle: "Key to Sustainable Play",
             body: "Bankroll management means sizing each bet appropriately relative to volatility. It is generally recommended to bet no more than 1–2% of your total bankroll per spin. High-volatility games require a larger buffer to avoid running out of funds before a big win arrives.",
             accentHex: "#06B6D4"),
    ]

    private let bgGradLayer  = CAGradientLayer()
    private let tableView    = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        buildBackground()
        buildNav()
        buildTable()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradLayer.frame = view.bounds
    }

    private func buildBackground() {
        bgGradLayer.colors     = NexusTheme.Gradient.heroTop
        bgGradLayer.startPoint = CGPoint(x: 0.5, y: 0)
        bgGradLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(bgGradLayer, at: 0)
    }

    private func buildNav() {
        title = "Glossary"
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

    private func buildTable() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle  = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.register(GlossaryCell.self, forCellReuseIdentifier: GlossaryCell.reuseID)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    @objc private func closeTapped() { dismiss(animated: true) }
}

// MARK: - UITableViewDataSource / Delegate
extension GlossaryVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        terms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GlossaryCell.reuseID,
                                                  for: indexPath) as! GlossaryCell
        cell.configure(with: terms[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? GlossaryCell else { return }
        cell.toggleExpanded()
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

// MARK: - GlossaryCell
private final class GlossaryCell: UITableViewCell {

    static let reuseID = "GlossaryCell"

    private let panel       = NebulaPanelView(accentColor: NexusTheme.Pigment.prism)
    private let iconView    = UIView()
    private let iconLbl     = UILabel()
    private let titleLbl    = UILabel()
    private let subtitleLbl = UILabel()
    private let chevron     = UIImageView(image: UIImage(systemName: "chevron.down"))
    private let bodyLbl     = UILabel()
    private var isExpanded  = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none
        buildLayout()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func buildLayout() {
        contentView.addSubview(panel)
        panel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            panel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            panel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            panel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            panel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        // Icon circle
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.layer.cornerRadius = 20
        iconLbl.translatesAutoresizingMaskIntoConstraints = false
        iconLbl.font      = UIFont.systemFont(ofSize: 16, weight: .semibold)
        iconLbl.textAlignment = .center
        iconView.addSubview(iconLbl)
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            iconLbl.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconLbl.centerYAnchor.constraint(equalTo: iconView.centerYAnchor)
        ])

        titleLbl.font      = NexusTheme.Typeface.subhead(15)
        titleLbl.textColor = NexusTheme.Pigment.platinum
        titleLbl.numberOfLines = 1

        subtitleLbl.font      = NexusTheme.Typeface.body(12)
        subtitleLbl.textColor = NexusTheme.Pigment.mist

        chevron.tintColor    = NexusTheme.Pigment.ghost
        chevron.contentMode  = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.widthAnchor.constraint(equalToConstant: 14).isActive = true
        chevron.heightAnchor.constraint(equalToConstant: 14).isActive = true

        let textStack = UIStackView(arrangedSubviews: [titleLbl, subtitleLbl])
        textStack.axis    = .vertical
        textStack.spacing = 2

        let headerRow = UIStackView(arrangedSubviews: [iconView, textStack, chevron])
        headerRow.axis      = .horizontal
        headerRow.spacing   = 12
        headerRow.alignment = .center

        bodyLbl.font          = NexusTheme.Typeface.body(13)
        bodyLbl.textColor     = NexusTheme.Pigment.mist
        bodyLbl.numberOfLines = 0
        bodyLbl.isHidden      = true

        let mainStack = UIStackView(arrangedSubviews: [headerRow, bodyLbl])
        mainStack.axis    = .vertical
        mainStack.spacing = 10
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: panel.topAnchor, constant: 14),
            mainStack.bottomAnchor.constraint(equalTo: panel.bottomAnchor, constant: -14),
            mainStack.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 14),
            mainStack.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -14)
        ])
    }

    func configure(with term: GlossaryVC.Term) {
        let accent = UIColor(hex: term.accentHex)
        iconView.backgroundColor = accent.withAlphaComponent(0.15)
        iconView.layer.borderColor = accent.withAlphaComponent(0.4).cgColor
        iconView.layer.borderWidth = 1

        let img = UIImage(systemName: term.icon)
        if let img = img {
            let iv = UIImageView(image: img)
            iv.tintColor = accent
            iv.contentMode = UIView.ContentMode.scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            iconView.subviews.forEach { $0.removeFromSuperview() }
            iconView.addSubview(iv)
            NSLayoutConstraint.activate([
                iv.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
                iv.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
                iv.widthAnchor.constraint(equalToConstant: 18),
                iv.heightAnchor.constraint(equalToConstant: 18)
            ])
        }

        titleLbl.text    = term.title
        subtitleLbl.text = term.subtitle
        bodyLbl.text     = term.body
        layer.borderColor = accent.withAlphaComponent(0.25).cgColor
    }

    func toggleExpanded() {
        isExpanded.toggle()
        bodyLbl.isHidden = !isExpanded
        UIView.animate(withDuration: 0.25) {
            self.chevron.transform = self.isExpanded
                ? CGAffineTransform(rotationAngle: .pi)
                : .identity
        }
    }
}

