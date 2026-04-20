import Foundation

struct VortexConfig {
    var winRate: Double       // 0.0 – 1.0
    var bigWinRate: Double    // 0.0 – 1.0  (fraction of wins that are big)
    var avgWinMultiplier: Double
    var maxWinMultiplier: Double
    var spinCount: Int
    var initialBankroll: Double

    static let fallback = VortexConfig(
        winRate: 0.25,
        bigWinRate: 0.02,
        avgWinMultiplier: 1.2,
        maxWinMultiplier: 50,
        spinCount: 10_000,
        initialBankroll: 100
    )
}

enum SpinTally: Int, CaseIterable {
    case kilo    = 1_000
    case tenKilo = 10_000
    case centKilo = 100_000

    var label: String {
        switch self {
        case .kilo:     return "1K"
        case .tenKilo:  return "10K"
        case .centKilo: return "100K"
        }
    }
}
