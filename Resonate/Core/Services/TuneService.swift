import Foundation

final class TuneService {

    func tuneURL(for id: Int) -> URL? {
        let filename = String(format: "%03d", id)
        return Bundle.main.url(forResource: filename, withExtension: "mp3")
    }


    func tuneExists(for id: Int) -> Bool {
        tuneURL(for: id) != nil
    }
}
