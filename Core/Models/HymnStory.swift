import Foundation

struct HymnStory: Codable, Identifiable {
    
    let hymnID: Int
    var id: Int { hymnID }
    
    let title: String
    
    let author: String?
    let authorBirthDeath: String?
    let yearWritten: Int?
    let copyright: String?
    let historicalContext: String?
    let theologicalTheme: String?
    
    let scriptureReferences: [ScriptureReference]?
    let music: HymnMusic?
    
    let liturgicalUse: [String]?
    let keywords: [String]?
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
