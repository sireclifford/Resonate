import Foundation
import Combine

/// Manages local storage for hymn accompaniment audio files.
/// Files are stored in: Application Support / Accompaniments /
final class AccompanimentCacheService: ObservableObject {

    struct ClearResult {
        let deletedFileCount: Int
        let reclaimedBytes: Int64
    }

    @Published private(set) var totalStorageBytes: Int64 = 0

    private let fileManager = FileManager.default

    private lazy var baseDirectory: URL = {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let directory = appSupport.appendingPathComponent("Accompaniments", isDirectory: true)

        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        return directory
    }()

    init() {
        refreshStorageSize()
    }

    /// Returns the expected local file URL for a hymn accompaniment
    func localURL(for hymnID: Int) -> URL {
        let filename = String(format: "%03d.mp3", hymnID)
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
        refreshStorageSize()
        return url
    }

    /// Delete a downloaded accompaniment
    func delete(for hymnID: Int) {
        let url = localURL(for: hymnID)
        try? fileManager.removeItem(at: url)
        refreshStorageSize()
    }

    /// Delete all downloaded accompaniments
    @discardableResult
    func clearAll() -> ClearResult {
        guard let files = try? fileManager.contentsOfDirectory(at: baseDirectory, includingPropertiesForKeys: nil) else {
            return ClearResult(deletedFileCount: 0, reclaimedBytes: 0)
        }
        let reclaimedBytes = totalStorageSize()
        let deletedFileCount = files.count
        for file in files {
            try? fileManager.removeItem(at: file)
        }
        refreshStorageSize()
        return ClearResult(deletedFileCount: deletedFileCount, reclaimedBytes: reclaimedBytes)
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

    private func refreshStorageSize() {
        let newValue = totalStorageSize()
        if Thread.isMainThread {
            totalStorageBytes = newValue
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.totalStorageBytes = newValue
            }
        }
    }
}
