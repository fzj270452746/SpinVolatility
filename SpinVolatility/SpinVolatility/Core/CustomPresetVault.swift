import Foundation

struct CustomPreset: Codable, Identifiable {
    let id: UUID
    var name: String
    let config: ChronConfig
    let createdAt: Date
}

final class CustomPresetVault {

    static let shared = CustomPresetVault()
    private init() { load() }

    private(set) var presets: [CustomPreset] = []
    private let key = "customPresets"

    func save(name: String, config: VortexConfig) {
        let p = CustomPreset(id: UUID(), name: name,
                             config: config.chronConfig,
                             createdAt: Date())
        presets.insert(p, at: 0)
        if presets.count > 20 { presets = Array(presets.prefix(20)) }
        persist()
    }

    func delete(id: UUID) {
        presets.removeAll { $0.id == id }
        persist()
    }

    func rename(id: UUID, name: String) {
        guard let idx = presets.firstIndex(where: { $0.id == id }) else { return }
        presets[idx].name = name
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([CustomPreset].self, from: data)
        else { return }
        presets = decoded
    }
}

extension ChronConfig {
    var vortexConfig: VortexConfig {
        VortexConfig(winRate: winRate, bigWinRate: bigWinRate,
                     avgWinMultiplier: avgWinMultiplier,
                     maxWinMultiplier: maxWinMultiplier,
                     spinCount: spinCount,
                     initialBankroll: initialBankroll)
    }
}
