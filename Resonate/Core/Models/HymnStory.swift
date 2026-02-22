import Foundation

struct HymnStory: Codable {
    let hymnID: Int
    
    // Historical
    let historicalContext: String?
    let theologicalTheme: String?
    
    // Musical Metadata
    let music: HymnMusicMetadata?
}

struct HymnMusicMetadata: Codable {
    let tuneName: String?
    let originalKey: String?
    let mode: String?
    let timeSignature: String?
    let tempoMarking: String?
    let bpm: Int?
    let meterPattern: String?
    
    let approximateLowestNote: String?
    let approximateHighestNote: String?
    let congregationalDifficulty: Int?
    let choirSuitability: Bool?
    
    let performanceStyle: String?
    let suggestedInstrumentation: [String]?
    let dynamicCharacter: String?
    let typicalUseCase: String?
}
