import Foundation

final class TuneService {

    func tuneURL(for hymn: Hymn) -> URL? {
        let filename = String(format: "%03d", hymn.id)
        return Bundle.main.url(forResource: filename, withExtension: "m4a")
    }


    func tuneExists(for hymn: Hymn) -> Bool {
        tuneURL(for: hymn) != nil
    }
}
