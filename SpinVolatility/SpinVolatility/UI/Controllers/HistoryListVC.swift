import UIKit

final class HistoryListVC: UIViewController {

    var onLoadConfig: ((VortexConfig, String) -> Void)?

    private let bgGradLayer  = CAGradientLayer()
    private let tableView    = UITableView(frame: .zero, style: .plain)
    private let emptyLabel   = UILabel()
    private var entries: [ChronEntry] { ChronVault.shared.entries }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buildBackground()
        buildNavBar()
        buildTable()
        buildEmptyState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        updateEmptyState()
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

    // MARK: - Nav
    private func buildNavBar() {
        title = "Simulation History"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: NexusTheme.Pigment.platinum,
            .font: NexusTheme.Typeface.headline(17)
        ]
        navigationController?.navigationBar.barTintColor = UIColor(hex: "#0A0E1A")
        navigationController?.navigationBar.isTranslucent = false

        let clearBtn = UIBarButtonItem(title: "Clear All", style: .plain,
                                       target: self, action: #selector(clearAll))
        clearBtn.tintColor = NexusTheme.Pigment.crimson
        navigationItem.rightBarButtonItem = clearBtn
    }

    // MARK: - Table
    private func buildTable() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        tableView.backgroundColor = .clear
        tableView.separatorStyle  = .none
        tableView.register(ChronEntryCell.self, forCellReuseIdentifier: ChronEntryCell.reuseID)
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 40, right: 0)
    }

    // MARK: - Empty state
    private func buildEmptyState() {
        view.addSubview(emptyLabel)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text          = "No simulations yet.\nRun one from the dashboard."
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.font          = NexusTheme.Typeface.body(15)
        emptyLabel.textColor     = NexusTheme.Pigment.ghost
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func updateEmptyState() {
        emptyLabel.isHidden = !entries.isEmpty
        tableView.isHidden  = entries.isEmpty
    }

    // MARK: - Actions
    @objc private func clearAll() {
        guard !entries.isEmpty else { return }
        CometAlertView.present(on: view, style: .warning, icon: "🗑️",
                               title: "Clear History",
                               body: "Delete all \(entries.count) saved simulations?",
                               actions: [
                                ("Delete All", true, {
                                    ChronVault.shared.clearAll()
                                    self.tableView.reloadData()
                                    self.updateEmptyState()
                                }),
                                ("Cancel", false, {})
                               ])
    }
}

// MARK: - UITableViewDataSource
extension HistoryListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChronEntryCell.reuseID,
                                                  for: indexPath) as! ChronEntryCell
        cell.configure(with: entries[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let id = entries[indexPath.row].id
        ChronVault.shared.delete(id: id)
        tableView.deleteRows(at: [indexPath], with: .fade)
        updateEmptyState()
    }
}

// MARK: - UITableViewDelegate
extension HistoryListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 110 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let entry = entries[indexPath.row]
        let cfg = VortexConfig(winRate: entry.config.winRate,
                               bigWinRate: entry.config.bigWinRate,
                               avgWinMultiplier: entry.config.avgWinMultiplier,
                               maxWinMultiplier: entry.config.maxWinMultiplier,
                               spinCount: entry.config.spinCount,
                               initialBankroll: entry.config.initialBankroll)
        CometAlertView.present(on: view, style: .info, icon: "📂",
                               title: "Load Config",
                               body: "Load \"\(entry.label)\" settings into the dashboard?",
                               actions: [
                                ("Load", true, {
                                    self.onLoadConfig?(cfg, entry.presetTag)
                                    self.navigationController?.popViewController(animated: true)
                                }),
                                ("Cancel", false, {})
                               ])
    }
}

// MARK: - Cell
private final class ChronEntryCell: UITableViewCell {
    static let reuseID = "ChronEntryCell"

    private let panel      = NebulaPanelView(accentColor: NexusTheme.Pigment.prism)
    private let tagBadge   = UILabel()
    private let titleLbl   = UILabel()
    private let dateLbl    = UILabel()
    private let rtpLbl     = UILabel()
    private let funLbl     = UILabel()
    private let streakLbl  = UILabel()

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

        [tagBadge, titleLbl, dateLbl, rtpLbl, funLbl, streakLbl].forEach {
            panel.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        tagBadge.font            = NexusTheme.Typeface.subhead(10)
        tagBadge.textColor       = .white
        tagBadge.layer.cornerRadius = 6
        tagBadge.clipsToBounds   = true
        tagBadge.textAlignment   = .center

        titleLbl.font      = NexusTheme.Typeface.headline(14)
        titleLbl.textColor = NexusTheme.Pigment.platinum

        dateLbl.font       = NexusTheme.Typeface.body(11)
        dateLbl.textColor  = NexusTheme.Pigment.ghost

        for lbl in [rtpLbl, funLbl, streakLbl] {
            lbl.font      = NexusTheme.Typeface.mono(12)
            lbl.textColor = NexusTheme.Pigment.mist
        }

        NSLayoutConstraint.activate([
            tagBadge.topAnchor.constraint(equalTo: panel.topAnchor, constant: 14),
            tagBadge.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 14),
            tagBadge.widthAnchor.constraint(equalToConstant: 46),
            tagBadge.heightAnchor.constraint(equalToConstant: 20),

            titleLbl.centerYAnchor.constraint(equalTo: tagBadge.centerYAnchor),
            titleLbl.leadingAnchor.constraint(equalTo: tagBadge.trailingAnchor, constant: 8),
            titleLbl.trailingAnchor.constraint(equalTo: dateLbl.leadingAnchor, constant: -8),

            dateLbl.centerYAnchor.constraint(equalTo: tagBadge.centerYAnchor),
            dateLbl.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -14),

            rtpLbl.topAnchor.constraint(equalTo: tagBadge.bottomAnchor, constant: 10),
            rtpLbl.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 14),

            funLbl.centerYAnchor.constraint(equalTo: rtpLbl.centerYAnchor),
            funLbl.leadingAnchor.constraint(equalTo: rtpLbl.trailingAnchor, constant: 16),

            streakLbl.centerYAnchor.constraint(equalTo: rtpLbl.centerYAnchor),
            streakLbl.leadingAnchor.constraint(equalTo: funLbl.trailingAnchor, constant: 16)
        ])
    }

    func configure(with entry: ChronEntry) {
        titleLbl.text = entry.label

        let df = DateFormatter()
        df.dateFormat = "MM/dd HH:mm"
        dateLbl.text = df.string(from: entry.timestamp)

        let s = entry.summary
        rtpLbl.text    = String(format: "RTP %.1f%%", s.simulatedRTP * 100)
        funLbl.text    = String(format: "Fun %.0f", s.funScore)
        streakLbl.text = String(format: "Streak %d", s.maxLoseStreak)

        let color: UIColor
        switch entry.presetTag {
        case "LOW":    color = NexusTheme.Pigment.aurora
        case "HIGH":   color = NexusTheme.Pigment.crimson
        case "CUSTOM": color = NexusTheme.Pigment.gold
        default:       color = NexusTheme.Pigment.prism
        }
        tagBadge.backgroundColor = color.withAlphaComponent(0.85)
        tagBadge.text = entry.presetTag
    }
}
