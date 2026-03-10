

import Foundation

/// Manages local storage for hymn accompaniment audio files.
/// Files are stored in: Application Support / Accompaniments /
final class AccompanimentCacheService {

    private let fileManager = FileManager.default

    private lazy var baseDirectory: URL = {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let directory = appSupport.appendingPathComponent("Accompaniments", isDirectory: true)

        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        return directory
    }()

    /// Returns the expected local file URL for a hymn accompaniment
    func localURL(for hymnID: Int) -> URL {
        let filename = String(format: "%03d.m4a", hymnID)
        return baseDirectory.appendingPathComponent(filename)
    }

    /// Returns true if the accompaniment is already downloaded
    func isDownloaded(for hymnID: Int) -> Bool {
        fileManager.fileExists(atPath: localURL(for: hymnID).path)
    }

    /// Save downloaded data to local storage
    func save(data: Data, for hymnID: Int) throws -> URL {
        let url = localURL(for: hymnID)
        try data.write(to: url, options: .atomic)
        return url
    }

    /// Delete a downloaded accompaniment
    func delete(for hymnID: Int) {
        let url = localURL(for: hymnID)
        try? fileManager.removeItem(at: url)
    }

    /// Delete all downloaded accompaniments
    func clearAll() {
        guard let files = try? fileManager.contentsOfDirectory(at: baseDirectory, includingPropertiesForKeys: nil) else { return }
        for file in files {
            try? fileManager.removeItem(at: file)
        }
    }

    /// Returns the total storage used by accompaniment files
    func totalStorageSize() -> Int64 {
        guard let files = try? fileManager.contentsOfDirectory(at: baseDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }

        var total: Int64 = 0

        for file in files {
            if let size = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                total += Int64(size)
            }
        }

        return total
    }
}
