import Foundation

final class TuneService {

    func tuneURL(for hymn: Hymn) -> URL? {
        let filename = String(format: "%03d.mid", hymn.id)
        return Bundle.main.url(forResource: filename, withExtension: nil)
    }

    func tuneExists(for hymn: Hymn) -> Bool {
        tuneURL(for: hymn) != nil
    }
}
