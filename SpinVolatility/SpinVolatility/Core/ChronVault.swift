import Foundation

struct ChronEntry: Codable {
    let id: UUID
    let timestamp: Date
    let label: String          // user-editable name
    let presetTag: String      // "LOW" / "MED" / "HIGH" / "CUSTOM"
    let config: ChronConfig
    let summary: ChronSummary
}

struct ChronConfig: Codable {
    let winRate: Double
    let bigWinRate: Double
    let avgWinMultiplier: Double
    let maxWinMultiplier: Double
    let spinCount: Int
    let initialBankroll: Double
}

struct ChronSummary: Codable {
    let simulatedRTP: Double
    let actualHitRate: Double
    let maxLoseStreak: Int
    let avgLoseStreak: Double
    let peakBalance: Double
    let troughBalance: Double
    let funScore: Double
    let bigWinCount: Int
}

extension VortexConfig {
    var chronConfig: ChronConfig {
        ChronConfig(winRate: winRate, bigWinRate: bigWinRate,
                    avgWinMultiplier: avgWinMultiplier,
                    maxWinMultiplier: maxWinMultiplier,
                    spinCount: spinCount,
                    initialBankroll: initialBankroll)
    }
}

extension PulsarResult {
    var chronSummary: ChronSummary {
        ChronSummary(simulatedRTP: simulatedRTP,
                     actualHitRate: actualHitRate,
                     maxLoseStreak: maxLoseStreak,
                     avgLoseStreak: avgLoseStreak,
                     peakBalance: peakBalance,
                     troughBalance: troughBalance,
                     funScore: funScore,
                     bigWinCount: bigWinEvents.count)
    }
}

final class ChronVault {

    static let shared = ChronVault()
    private init() { load() }

    private(set) var entries: [ChronEntry] = []
    private let key = "chronVaultEntries"

    func save(result: PulsarResult, config: VortexConfig, presetTag: String, label: String? = nil) {
        let name = label ?? autoLabel(presetTag: presetTag, config: config)
        let entry = ChronEntry(id: UUID(),
                               timestamp: Date(),
                               label: name,
                               presetTag: presetTag,
                               config: config.chronConfig,
                               summary: result.chronSummary)
        entries.insert(entry, at: 0)
        if entries.count > 50 { entries = Array(entries.prefix(50)) }
        persist()
    }

    func delete(id: UUID) {
        entries.removeAll { $0.id == id }
        persist()
    }

    func rename(id: UUID, label: String) {
        guard let idx = entries.firstIndex(where: { $0.id == id }) else { return }
        let old = entries[idx]
        entries[idx] = ChronEntry(id: old.id, timestamp: old.timestamp,
                                  label: label, presetTag: old.presetTag,
                                  config: old.config, summary: old.summary)
        persist()
    }

    func clearAll() {
        entries = []
        persist()
    }

    // MARK: - Persistence
    private func persist() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([ChronEntry].self, from: data)
        else { return }
        entries = decoded
    }

    private func autoLabel(presetTag: String, config: VortexConfig) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return "\(presetTag) · \(formatter.string(from: Date()))"
    }
}
