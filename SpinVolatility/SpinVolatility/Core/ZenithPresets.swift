import Foundation

struct ZenithPreset {
    let tag: String
    let label: String
    let subtitle: String
    let config: VortexConfig
    let accentHex: String
}

enum ZenithPresets {
    static let catalogue: [ZenithPreset] = [
        ZenithPreset(
            tag: "LOW",
            label: "Low",
            subtitle: "Steady & Safe",
            config: VortexConfig(winRate: 0.40, bigWinRate: 0.005,
                                 avgWinMultiplier: 1.1, maxWinMultiplier: 20,
                                 spinCount: 10_000, initialBankroll: 100),
            accentHex: "#10B981"
        ),
        ZenithPreset(
            tag: "MED",
            label: "Medium",
            subtitle: "Balanced Play",
            config: VortexConfig(winRate: 0.25, bigWinRate: 0.02,
                                 avgWinMultiplier: 1.2, maxWinMultiplier: 50,
                                 spinCount: 10_000, initialBankroll: 100),
            accentHex: "#6366F1"
        ),
        ZenithPreset(
            tag: "HIGH",
            label: "High",
            subtitle: "Boom or Bust",
            config: VortexConfig(winRate: 0.15, bigWinRate: 0.05,
                                 avgWinMultiplier: 1.5, maxWinMultiplier: 100,
                                 spinCount: 10_000, initialBankroll: 100),
            accentHex: "#EF4444"
        ),
        ZenithPreset(
            tag: "MEGA",
            label: "Mega",
            subtitle: "Jackpot Hunter",
            config: VortexConfig(winRate: 0.10, bigWinRate: 0.08,
                                 avgWinMultiplier: 2.0, maxWinMultiplier: 500,
                                 spinCount: 10_000, initialBankroll: 100),
            accentHex: "#F59E0B"
        ),
        ZenithPreset(
            tag: "GRIND",
            label: "Grind",
            subtitle: "High Frequency",
            config: VortexConfig(winRate: 0.55, bigWinRate: 0.002,
                                 avgWinMultiplier: 0.9, maxWinMultiplier: 10,
                                 spinCount: 10_000, initialBankroll: 100),
            accentHex: "#2563EB"
        ),
        ZenithPreset(
            tag: "CHAOS",
            label: "Chaos",
            subtitle: "Extreme Swings",
            config: VortexConfig(winRate: 0.08, bigWinRate: 0.12,
                                 avgWinMultiplier: 3.0, maxWinMultiplier: 1000,
                                 spinCount: 10_000, initialBankroll: 100),
            accentHex: "#D946EF"
        )
    ]
}
