import Foundation

struct PulsarResult {
    let balanceLedger: [Double]      // bankroll per spin
    let winMultipliers: [Double]     // all non-zero win multiples
    let bigWinEvents: [(spin: Int, multiplier: Double)]
    let maxLoseStreak: Int
    let avgLoseStreak: Double
    let streakDistribution: [Int: Int]  // streak length -> count
    let simulatedRTP: Double
    let actualHitRate: Double
    let peakBalance: Double
    let troughBalance: Double
    let funScore: Double             // burst freq × reward intensity / lose streak

    // histogram buckets: multiplier range -> count
    let winBuckets: [(range: String, count: Int)]
}
