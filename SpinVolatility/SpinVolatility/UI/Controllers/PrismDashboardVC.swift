import UIKit


final class PrismDashboardVC: UIViewController {

    // MARK: - State
    private var vortexConfig = VortexConfig.fallback
    private let engine       = QuantumEngine()
    private var isRunning    = false
    private var selectedPresetIndex: Int = 1
    private var currentPresetTag: String = "MED"

    // MARK: - UI
    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()
    private let bgGradLayer  = CAGradientLayer()
    private let particleHost = UIView()

    // Header
    private let headerView   = UIView()
    private let appTitleLbl  = UILabel()
    private let subtitleLbl  = UILabel()
    private let infoBtn      = UIButton(type: .custom)
    private let historyBtn   = UIButton(type: .custom)
    private let glossaryBtn  = UIButton(type: .custom)

    // Preset bar
    private let presetPanel  = NebulaPanelView(accentColor: NexusTheme.Pigment.prism)
    private let presetStack  = UIStackView()
    private var presetBtns   = [UIButton]()

    // Spin count
    private let spinPanel    = NebulaPanelView(accentColor: NexusTheme.Pigment.azure)
    private let spinStack    = UIStackView()
    private var spinBtns     = [UIButton]()

    // Sliders
    private let sliderPanel  = NebulaPanelView(accentColor: NexusTheme.Pigment.violet)
    private let winRateSlider    = AuroraSliderCell(title: "Win Rate", min: 0.05, max: 0.60,
                                                    value: 0.25,
                                                    format: { String(format: "%.0f%%", $0 * 100) })
    private let bigWinSlider     = AuroraSliderCell(title: "Big Win Rate", min: 0.001, max: 0.10,
                                                    value: 0.02,
                                                    format: { String(format: "%.1f%%", $0 * 100) })
    private let avgWinSlider     = AuroraSliderCell(title: "Avg Win", min: 0.5, max: 5.0,
                                                    value: 1.2,
                                                    format: { String(format: "%.1fx", $0) })
    private let maxWinSlider     = AuroraSliderCell(title: "Max Win Cap", min: 10, max: 500,
                                                    value: 50,
                                                    format: { String(format: "%.0fx", $0) })

    // Run button
    private let runButton    = UIButton(type: .custom)
    private let runGradLayer = CAGradientLayer()
    private let progressBar  = UIProgressView(progressViewStyle: .bar)
    private let progressLbl  = UILabel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buildBackground()
        buildScrollView()
        buildHeader()
        buildPresetBar()
        buildSpinCountBar()
        buildSliderPanel()
        buildRunButton()
        buildSecondaryActions()
        wireSliders()
        selectPreset(index: 1, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradLayer.frame = view.bounds
        runGradLayer.frame = runButton.bounds
    }

    // MARK: - Background
    private func buildBackground() {

        
        bgGradLayer.colors     = NexusTheme.Gradient.heroTop
        bgGradLayer.startPoint = CGPoint(x: 0.5, y: 0)
        bgGradLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(bgGradLayer, at: 0)
        addParticles()
    }

    private func addParticles() {
        view.addSubview(particleHost)
        particleHost.frame = view.bounds
        particleHost.isUserInteractionEnabled = false
        for _ in 0..<30 {
            let dot = UIView()
            let size = CGFloat.random(in: 1.5...4)
            dot.frame = CGRect(x: CGFloat.random(in: 0...view.bounds.width),
                               y: CGFloat.random(in: 0...view.bounds.height),
                               width: size, height: size)
            dot.layer.cornerRadius = size / 2
            dot.backgroundColor = [NexusTheme.Pigment.prism,
                                    NexusTheme.Pigment.violet,
                                    NexusTheme.Pigment.fuchsia].randomElement()!
                .withAlphaComponent(CGFloat.random(in: 0.3...0.7))
            particleHost.addSubview(dot)
            animateParticle(dot)
        }
    }

    private func animateParticle(_ v: UIView) {
        let dur = Double.random(in: 3...8)
        UIView.animate(withDuration: dur, delay: Double.random(in: 0...3),
                       options: [.autoreverse, .repeat, .curveEaseInOut]) {
            v.alpha = CGFloat.random(in: 0.05...0.5)
            v.transform = CGAffineTransform(translationX: CGFloat.random(in: -20...20),
                                            y: CGFloat.random(in: -20...20))
        }
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

    // MARK: - Header
    private func buildHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: 80).isActive = true

        appTitleLbl.text      = "SpinVolatility"
        appTitleLbl.font      = NexusTheme.Typeface.display(28)
        appTitleLbl.textColor = NexusTheme.Pigment.platinum

        let gradTitle = CAGradientLayer()
        gradTitle.colors     = NexusTheme.Gradient.accentPulse
        gradTitle.startPoint = CGPoint(x: 0, y: 0.5)
        gradTitle.endPoint   = CGPoint(x: 1, y: 0.5)

        subtitleLbl.text      = "Probability Simulator"
        subtitleLbl.font      = NexusTheme.Typeface.body(13)
        subtitleLbl.textColor = NexusTheme.Pigment.mist

        infoBtn.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
        infoBtn.tintColor = NexusTheme.Pigment.prism
        infoBtn.addTarget(self, action: #selector(showInfo), for: .touchUpInside)

        historyBtn.setImage(UIImage(systemName: "clock.fill"), for: .normal)
        historyBtn.tintColor = NexusTheme.Pigment.gold
        historyBtn.addTarget(self, action: #selector(showHistory), for: .touchUpInside)

        glossaryBtn.setImage(UIImage(systemName: "book.fill"), for: .normal)
        glossaryBtn.tintColor = NexusTheme.Pigment.aurora
        glossaryBtn.addTarget(self, action: #selector(showGlossary), for: .touchUpInside)

        [appTitleLbl, subtitleLbl, infoBtn, historyBtn, glossaryBtn].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            appTitleLbl.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            appTitleLbl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            subtitleLbl.topAnchor.constraint(equalTo: appTitleLbl.bottomAnchor, constant: 2),
            subtitleLbl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            infoBtn.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            infoBtn.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            infoBtn.widthAnchor.constraint(equalToConstant: 36),
            infoBtn.heightAnchor.constraint(equalToConstant: 36),
            historyBtn.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            historyBtn.trailingAnchor.constraint(equalTo: infoBtn.leadingAnchor, constant: -4),
            historyBtn.widthAnchor.constraint(equalToConstant: 36),
            historyBtn.heightAnchor.constraint(equalToConstant: 36),
            glossaryBtn.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            glossaryBtn.trailingAnchor.constraint(equalTo: historyBtn.leadingAnchor, constant: -4),
            glossaryBtn.widthAnchor.constraint(equalToConstant: 36),
            glossaryBtn.heightAnchor.constraint(equalToConstant: 36)
        ])
        contentStack.addArrangedSubview(headerView)
    }

    // MARK: - Preset Bar
    private func buildPresetBar() {
        presetPanel.translatesAutoresizingMaskIntoConstraints = false
        let titleLbl = makeSectionTitle("Volatility Preset")
        presetStack.axis         = .horizontal
        presetStack.distribution = .fillEqually
        presetStack.spacing      = 8

        for (i, preset) in ZenithPresets.catalogue.enumerated() {
            let btn = buildPresetButton(preset: preset, index: i)
            presetStack.addArrangedSubview(btn)
            presetBtns.append(btn)
        }

        let vStack = UIStackView(arrangedSubviews: [titleLbl, presetStack])
        vStack.axis    = .vertical
        vStack.spacing = 12
        vStack.translatesAutoresizingMaskIntoConstraints = false
        presetPanel.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: presetPanel.topAnchor, constant: 16),
            vStack.bottomAnchor.constraint(equalTo: presetPanel.bottomAnchor, constant: -16),
            vStack.leadingAnchor.constraint(equalTo: presetPanel.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: presetPanel.trailingAnchor, constant: -16)
        ])
        contentStack.addArrangedSubview(presetPanel)
    }

    private func buildPresetButton(preset: ZenithPreset, index: Int) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.tag = index
        btn.layer.cornerRadius = NexusTheme.Radius.md
        btn.clipsToBounds = true

        let stack = UIStackView()
        stack.axis      = .vertical
        stack.alignment = .center
        stack.spacing   = 2
        stack.isUserInteractionEnabled = false

        let tagLbl = UILabel()
        tagLbl.text      = preset.tag
        tagLbl.font      = NexusTheme.Typeface.headline(12)
        tagLbl.textColor = .white

        let nameLbl = UILabel()
        nameLbl.text      = preset.label
        nameLbl.font      = NexusTheme.Typeface.body(10)
        nameLbl.textColor = UIColor.white.withAlphaComponent(0.8)
        nameLbl.numberOfLines = 2
        nameLbl.textAlignment = .center

        stack.addArrangedSubview(tagLbl)
        stack.addArrangedSubview(nameLbl)
        stack.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: btn.leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: btn.trailingAnchor, constant: -4),
            btn.heightAnchor.constraint(equalToConstant: 64)
        ])

        btn.backgroundColor = NexusTheme.Pigment.slate
        btn.addTarget(self, action: #selector(presetTapped(_:)), for: .touchUpInside)
        return btn
    }

    // MARK: - Spin Count Bar
    private func buildSpinCountBar() {
        spinPanel.translatesAutoresizingMaskIntoConstraints = false
        let titleLbl = makeSectionTitle("Spin Count")
        spinStack.axis         = .horizontal
        spinStack.distribution = .fillEqually
        spinStack.spacing      = 8

        for tally in SpinTally.allCases {
            let btn = UIButton(type: .custom)
            btn.setTitle(tally.label, for: .normal)
            btn.titleLabel?.font = NexusTheme.Typeface.subhead(14)
            btn.layer.cornerRadius = NexusTheme.Radius.md
            btn.clipsToBounds = true
            btn.tag = tally.rawValue
            btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
            btn.backgroundColor = NexusTheme.Pigment.slate
            btn.setTitleColor(NexusTheme.Pigment.mist, for: .normal)
            btn.addTarget(self, action: #selector(spinCountTapped(_:)), for: .touchUpInside)
            spinStack.addArrangedSubview(btn)
            spinBtns.append(btn)
        }

        let vStack = UIStackView(arrangedSubviews: [titleLbl, spinStack])
        vStack.axis    = .vertical
        vStack.spacing = 12
        vStack.translatesAutoresizingMaskIntoConstraints = false
        spinPanel.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: spinPanel.topAnchor, constant: 16),
            vStack.bottomAnchor.constraint(equalTo: spinPanel.bottomAnchor, constant: -16),
            vStack.leadingAnchor.constraint(equalTo: spinPanel.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: spinPanel.trailingAnchor, constant: -16)
        ])
        contentStack.addArrangedSubview(spinPanel)
        selectSpinCount(rawValue: SpinTally.tenKilo.rawValue)
    }

    // MARK: - Slider Panel
    private func buildSliderPanel() {
        sliderPanel.translatesAutoresizingMaskIntoConstraints = false
        let titleLbl = makeSectionTitle("Parameters")

        [winRateSlider, bigWinSlider, avgWinSlider].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let vStack = UIStackView(arrangedSubviews: [titleLbl, winRateSlider, bigWinSlider, avgWinSlider, maxWinSlider])
        vStack.axis    = .vertical
        vStack.spacing = 20
        vStack.translatesAutoresizingMaskIntoConstraints = false
        sliderPanel.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: sliderPanel.topAnchor, constant: 16),
            vStack.bottomAnchor.constraint(equalTo: sliderPanel.bottomAnchor, constant: -16),
            vStack.leadingAnchor.constraint(equalTo: sliderPanel.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: sliderPanel.trailingAnchor, constant: -16)
        ])
        contentStack.addArrangedSubview(sliderPanel)
    }

    // MARK: - Run Button
    private func buildRunButton() {
        runButton.translatesAutoresizingMaskIntoConstraints = false
        runButton.setTitle("RUN SIMULATION", for: .normal)
        runButton.titleLabel?.font = NexusTheme.Typeface.headline(16)
        runButton.setTitleColor(.white, for: .normal)
        runButton.layer.cornerRadius = NexusTheme.Radius.lg
        runButton.clipsToBounds = true
        runButton.heightAnchor.constraint(equalToConstant: 58).isActive = true

        runGradLayer.colors     = NexusTheme.Gradient.accentPulse
        runGradLayer.startPoint = CGPoint(x: 0, y: 0.5)
        runGradLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        runGradLayer.cornerRadius = NexusTheme.Radius.lg
        runButton.layer.insertSublayer(runGradLayer, at: 0)

        runButton.layer.shadowColor   = NexusTheme.Pigment.prism.cgColor
        runButton.layer.shadowOpacity = 0.6
        runButton.layer.shadowRadius  = 12
        runButton.layer.shadowOffset  = CGSize(width: 0, height: 4)
        runButton.addTarget(self, action: #selector(runTapped), for: .touchUpInside)

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

        let btnContainer = UIView()
        btnContainer.translatesAutoresizingMaskIntoConstraints = false
        [runButton, progressBar, progressLbl].forEach { btnContainer.addSubview($0) }
        NSLayoutConstraint.activate([
            runButton.topAnchor.constraint(equalTo: btnContainer.topAnchor),
            runButton.leadingAnchor.constraint(equalTo: btnContainer.leadingAnchor),
            runButton.trailingAnchor.constraint(equalTo: btnContainer.trailingAnchor),
            progressBar.topAnchor.constraint(equalTo: runButton.bottomAnchor, constant: 8),
            progressBar.leadingAnchor.constraint(equalTo: btnContainer.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: btnContainer.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 4),
            progressLbl.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 4),
            progressLbl.leadingAnchor.constraint(equalTo: btnContainer.leadingAnchor),
            progressLbl.trailingAnchor.constraint(equalTo: btnContainer.trailingAnchor),
            progressLbl.bottomAnchor.constraint(equalTo: btnContainer.bottomAnchor)
        ])
        contentStack.addArrangedSubview(btnContainer)
    }

    // MARK: - Secondary Actions (Save Preset + Batch Run)
    private func buildSecondaryActions() {
        let row = UIStackView()
        row.axis         = .horizontal
        row.distribution = .fillEqually
        row.spacing      = 10

        let saveBtn  = makeSmallBtn(title: "Save Preset", icon: "star.fill",
                                    color: NexusTheme.Pigment.gold, action: #selector(savePresetTapped))
        let batchBtn = makeSmallBtn(title: "Batch Run", icon: "arrow.triangle.2.circlepath",
                                    color: NexusTheme.Pigment.prism, action: #selector(batchRunTapped))
        row.addArrangedSubview(saveBtn)
        row.addArrangedSubview(batchBtn)
        contentStack.addArrangedSubview(row)
    }

    private func makeSmallBtn(title: String, icon: String,
                               color: UIColor, action: Selector) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 46).isActive = true
        btn.layer.cornerRadius = NexusTheme.Radius.md
        btn.backgroundColor    = color.withAlphaComponent(0.10)
        btn.layer.borderColor  = color.withAlphaComponent(0.35).cgColor
        btn.layer.borderWidth  = 1

        let img = UIImageView(image: UIImage(systemName: icon))
        img.tintColor = color
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        img.widthAnchor.constraint(equalToConstant: 16).isActive = true
        img.heightAnchor.constraint(equalToConstant: 16).isActive = true

        let lbl = UILabel()
        lbl.text      = title
        lbl.font      = NexusTheme.Typeface.subhead(13)
        lbl.textColor = color

        let stack = UIStackView(arrangedSubviews: [img, lbl])
        stack.axis      = .horizontal
        stack.spacing   = 6
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: btn.centerYAnchor)
        ])
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }
    private func wireSliders() {
        winRateSlider.delegate  = self
        bigWinSlider.delegate   = self
        avgWinSlider.delegate   = self
        maxWinSlider.delegate   = self
    }

    // MARK: - Helpers
    private func makeSectionTitle(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text      = text.uppercased()
        lbl.font      = NexusTheme.Typeface.subhead(11)
        lbl.textColor = NexusTheme.Pigment.mist
        lbl.letterSpacing(1.5)
        return lbl
    }

    private func selectPreset(index: Int, animated: Bool) {
        selectedPresetIndex = index
        let preset = ZenithPresets.catalogue[index]
        currentPresetTag = preset.tag
        vortexConfig = preset.config
        winRateSlider.setValue(preset.config.winRate, animated: animated)
        bigWinSlider.setValue(preset.config.bigWinRate, animated: animated)
        avgWinSlider.setValue(preset.config.avgWinMultiplier, animated: animated)
        maxWinSlider.setValue(preset.config.maxWinMultiplier, animated: animated)

        for (i, btn) in presetBtns.enumerated() {
            let isSelected = i == index
            let accent = UIColor(hex: ZenithPresets.catalogue[i].accentHex)
            UIView.animate(withDuration: 0.25) {
                if isSelected {
                    let gl = CAGradientLayer()
                    gl.colors = [accent.cgColor, accent.withAlphaComponent(0.6).cgColor]
                    gl.startPoint = CGPoint(x: 0, y: 0)
                    gl.endPoint   = CGPoint(x: 1, y: 1)
                    gl.frame      = btn.bounds
                    gl.cornerRadius = NexusTheme.Radius.md
                    btn.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
                    btn.layer.insertSublayer(gl, at: 0)
                    btn.layer.borderColor = accent.cgColor
                    btn.layer.borderWidth = 1.5
                } else {
                    btn.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
                    btn.backgroundColor = NexusTheme.Pigment.slate
                    btn.layer.borderWidth = 0
                }
            }
        }
    }

    private func selectSpinCount(rawValue: Int) {
        vortexConfig.spinCount = rawValue
        for btn in spinBtns {
            let isSelected = btn.tag == rawValue
            UIView.animate(withDuration: 0.2) {
                btn.backgroundColor = isSelected ? NexusTheme.Pigment.azure : NexusTheme.Pigment.slate
                btn.setTitleColor(isSelected ? .white : NexusTheme.Pigment.mist, for: .normal)
            }
        }
    }

    // MARK: - Actions
    @objc private func presetTapped(_ sender: UIButton) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        selectPreset(index: sender.tag, animated: true)
    }

    @objc private func spinCountTapped(_ sender: UIButton) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        selectSpinCount(rawValue: sender.tag)
    }

    @objc private func runTapped() {
        guard !isRunning else { return }
        isRunning = true
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()

        runButton.setTitle("SIMULATING...", for: .normal)
        progressBar.isHidden  = false
        progressLbl.isHidden  = false
        progressBar.progress  = 0

        engine.ignite(config: vortexConfig, progress: { [weak self] pct in
            DispatchQueue.main.async {
                self?.progressBar.setProgress(Float(pct), animated: true)
                self?.progressLbl.text = String(format: "%.0f%%", pct * 100)
            }
        }) { [weak self] result in
            guard let self = self else { return }
            self.isRunning = false
            self.runButton.setTitle("RUN SIMULATION", for: .normal)
            self.progressBar.isHidden = true
            self.progressLbl.isHidden = true
            self.progressBar.progress = 0
            ChronVault.shared.save(result: result, config: self.vortexConfig,
                                   presetTag: self.currentPresetTag)
            let vc = VaultResultsVC(result: result, config: self.vortexConfig,
                                    presetTag: self.currentPresetTag)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }

    @objc private func showHistory() {
        let vc = HistoryListVC()
        vc.onLoadConfig = { [weak self] cfg, tag in
            guard let self = self else { return }
            self.currentPresetTag = tag
            self.vortexConfig = cfg
            self.winRateSlider.setValue(cfg.winRate, animated: true)
            self.bigWinSlider.setValue(cfg.bigWinRate, animated: true)
            self.avgWinSlider.setValue(cfg.avgWinMultiplier, animated: true)
            self.maxWinSlider.setValue(cfg.maxWinMultiplier, animated: true)
            // deselect all preset buttons
            for btn in self.presetBtns {
                btn.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
                btn.backgroundColor = NexusTheme.Pigment.slate
                btn.layer.borderWidth = 0
            }
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    @objc private func showInfo() {
        CometAlertView.present(
            on: view,
            style: .info,
            icon: "📊",
            title: "About SpinVolatility",
            body: "A statistical visualization tool for game designers and probability enthusiasts. Simulate spin outcomes and analyze volatility patterns.",
            actions: [("Got it", true, {})]
        )
    }

    @objc private func showGlossary() {
        let vc = GlossaryVC()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    @objc private func savePresetTapped() {
        let alert = UIAlertController(title: "Save Preset",
                                      message: "Enter a name for this configuration",
                                      preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "e.g. My High Volatility"
            tf.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            guard let self = self,
                  let name = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespaces),
                  !name.isEmpty else { return }
            CustomPresetVault.shared.save(name: name, config: self.vortexConfig)
            CometAlertView.present(on: self.view, style: .success, icon: "⭐️",
                                   title: "Saved",
                                   body: "Preset \"\(name)\" saved.",
                                   actions: [("OK", true, {})])
        })
        present(alert, animated: true)
    }

    @objc private func batchRunTapped() {
        let vc = BatchRunVC(config: vortexConfig, presetTag: currentPresetTag)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }
}

// MARK: - AuroraSliderDelegate
extension PrismDashboardVC: AuroraSliderDelegate {
    func auroraSlider(_ cell: AuroraSliderCell, didChange value: Double) {
        if cell === winRateSlider  { vortexConfig.winRate = value }
        if cell === bigWinSlider   { vortexConfig.bigWinRate = value }
        if cell === avgWinSlider   { vortexConfig.avgWinMultiplier = value }
        if cell === maxWinSlider   { vortexConfig.maxWinMultiplier = value }
        // mark as custom when user manually adjusts
        if cell === winRateSlider || cell === bigWinSlider ||
           cell === avgWinSlider  || cell === maxWinSlider {
            currentPresetTag = "CUSTOM"
        }
    }
}

// MARK: - UILabel letter spacing
private extension UILabel {
    func letterSpacing(_ spacing: CGFloat) {
        guard let text = text else { return }
        let attr = NSMutableAttributedString(string: text)
        attr.addAttribute(.kern, value: spacing, range: NSRange(location: 0, length: text.count))
        attributedText = attr
    }
}
