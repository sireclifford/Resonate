import Foundation

final class TuneService {
    func tuneExists(for hymn: Hymn) -> Bool {
        Bundle.main.url(forResource: hymn.tuneFileName, withExtension: nil,
                        subdirectory: "Tunes") != nil
    }
    
    func tuneURL(for hymn: Hymn) -> URL? {
        Bundle.main.url(
            forResource: hymn.tuneFileName, withExtension: nil, subdirectory: "Tunes"
        )
    }
}
