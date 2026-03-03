import Foundation

struct HymnMusic: Codable {
    let tuneName: String?
    let composer: String?
    let composerBirthDeath: String?
    let yearComposed: Int?
    let originalKey: String?
    let mode: String?
    let timeSignature: String?
    let tempoMarking: String?
    let bpm: Int?
    let meterPattern: String?
    let clef: String?

    let range: VocalRange?
    let congregationalDifficulty: Int?
    let choirSuitability: Bool?
    let performanceStyle: String?
    let suggestedInstrumentation: [String]?
}

struct VocalRange: Codable {
    let lowestNote: String?
    let highestNote: String?
}

struct HymnSource: Codable {
    let title: String?
    let url: String?
    let attributionRequired: Bool?
}


extension HymnMusic {
    var hasContent: Bool {
        tuneName != nil ||
        composer != nil ||
        yearComposed != nil ||
        originalKey != nil ||
        tempoMarking != nil ||
        bpm != nil ||
        !(suggestedInstrumentation?.isEmpty ?? true)
    }
}
