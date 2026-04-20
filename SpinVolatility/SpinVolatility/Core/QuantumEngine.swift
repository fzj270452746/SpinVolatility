import Foundation

final class QuantumEngine {

    // MARK: - Public
    func ignite(config: VortexConfig,
                progress: ((Double) -> Void)? = nil,
                completion: @escaping (PulsarResult) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.runMonteCarlo(config: config, progress: progress)
            DispatchQueue.main.async { completion(result) }
        }
    }

    // MARK: - Core Monte Carlo
    private func runMonteCarlo(config: VortexConfig,
                               progress: ((Double) -> Void)?) -> PulsarResult {
        let n = config.spinCount
        var balance = config.initialBankroll
        var ledger  = [Double]()
        ledger.reserveCapacity(min(n, 10_000))

        var winMultipliers  = [Double]()
        var bigWinEvents    = [(spin: Int, multiplier: Double)]()
        var currentStreak   = 0
        var maxStreak       = 0
        var streakDist      = [Int: Int]()
        var totalWinSum     = 0.0
        var hitCount        = 0
        let sampleStride    = max(1, n / 10_000)

        for i in 0..<n {
            let spinResult = resolveOneSpin(config: config)
            balance += spinResult - 1.0   // cost 1 unit per spin

            if spinResult > 0 {
                hitCount += 1
                totalWinSum += spinResult
                winMultipliers.append(spinResult)
                if spinResult >= config.avgWinMultiplier * 5 {
                    bigWinEvents.append((spin: i, multiplier: spinResult))
                }
                if currentStreak > 0 {
                    streakDist[currentStreak, default: 0] += 1
                    maxStreak = max(maxStreak, currentStreak)
                    currentStreak = 0
                }
            } else {
                currentStreak += 1
            }

            if i % sampleStride == 0 {
                ledger.append(balance)
            }
            if i % 5000 == 0 {
                let pct = Double(i) / Double(n)
                progress?(pct)
            }
        }
        if currentStreak > 0 {
            streakDist[currentStreak, default: 0] += 1
            maxStreak = max(maxStreak, currentStreak)
        }

        let rtp        = n > 0 ? totalWinSum / Double(n) : 0
        let hitRate    = n > 0 ? Double(hitCount) / Double(n) : 0
        let peak       = ledger.max() ?? config.initialBankroll
        let trough     = ledger.min() ?? config.initialBankroll
        let avgStreak  = computeAvgStreak(dist: streakDist)
        let funScore   = computeFunScore(bigWins: bigWinEvents.count,
                                         n: n,
                                         avgMult: totalWinSum / max(1, Double(hitCount)),
                                         avgStreak: avgStreak)
        let buckets    = buildBuckets(multipliers: winMultipliers, max: config.maxWinMultiplier)

        return PulsarResult(
            balanceLedger: ledger,
            winMultipliers: winMultipliers,
            bigWinEvents: bigWinEvents,
            maxLoseStreak: maxStreak,
            avgLoseStreak: avgStreak,
            streakDistribution: streakDist,
            simulatedRTP: rtp,
            actualHitRate: hitRate,
            peakBalance: peak,
            troughBalance: trough,
            funScore: funScore,
            winBuckets: buckets
        )
    }

    // MARK: - Single Spin
    private func resolveOneSpin(config: VortexConfig) -> Double {
        let r = Double.random(in: 0..<1)
        guard r < config.winRate else { return 0 }
        let isBig = Double.random(in: 0..<1) < config.bigWinRate
        if isBig {
            let lo = config.avgWinMultiplier * 5
            let hi = config.maxWinMultiplier
            return Double.random(in: lo...max(lo, hi))
        } else {
            let lo = 0.1
            let hi = config.avgWinMultiplier * 4.9
            return Double.random(in: lo...max(lo, hi))
        }
    }

    // MARK: - Helpers
    private func computeAvgStreak(dist: [Int: Int]) -> Double {
        let total = dist.values.reduce(0, +)
        guard total > 0 else { return 0 }
        let sum = dist.reduce(0) { $0 + $1.key * $1.value }
        return Double(sum) / Double(total)
    }

    private func computeFunScore(bigWins: Int, n: Int,
                                 avgMult: Double, avgStreak: Double) -> Double {
        let burstFreq = n > 0 ? Double(bigWins) / Double(n) * 1000 : 0
        let denom     = max(1, avgStreak)
        let raw       = burstFreq * avgMult / denom
        return min(100, raw * 10)
    }

    private func buildBuckets(multipliers: [Double], max maxMult: Double) -> [(range: String, count: Int)] {
        let boundaries: [Double] = [0, 0.5, 1, 2, 5, 10, 20, 50, 100, maxMult + 1]
        var buckets = [(range: String, count: Int)]()
        for i in 0..<boundaries.count - 1 {
            let lo = boundaries[i]
            let hi = boundaries[i + 1]
            let label = hi > maxMult ? "\(Int(lo))x+" : "\(formatBound(lo))–\(formatBound(hi))x"
            let cnt = multipliers.filter { $0 >= lo && $0 < hi }.count
            buckets.append((range: label, count: cnt))
        }
        return buckets.filter { $0.count > 0 }
    }

    private func formatBound(_ v: Double) -> String {
        v.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(v))" : String(format: "%.1f", v)
    }
}
