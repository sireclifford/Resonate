import Foundation
import FirebaseStorage

/// Handles resolving Firebase Storage references and download URLs
/// for hymn accompaniment audio files stored in Firebase Storage.
final class AccompanimentStorageService {

    private let storage = Storage.storage()
    private var availabilityCache: [Int: Bool] = [:]
    private var inFlightChecks: [Int: Task<Bool, Never>] = [:]

    /// Returns the zero-padded filename used in Firebase Storage.
    /// Example: hymnID 1 -> "001.mp3"
    private func filename(for hymnID: Int) -> String {
        String(format: "%03d.mp3", hymnID)
    }

    /// Returns the Firebase Storage path for a hymn accompaniment file.
    func path(for hymnID: Int) -> String {
        "midi/hymns/\(filename(for: hymnID))"
    }

    /// Returns the Firebase Storage reference for a hymn accompaniment file.
    func reference(for hymnID: Int) -> StorageReference {
        storage.reference(withPath: path(for: hymnID))
    }

    /// Fetches the public download URL for a hymn accompaniment file.
    func fetchDownloadURL(for hymnID: Int) async throws -> URL {
        try await reference(for: hymnID).downloadURL()
    }

    /// Checks if an accompaniment file exists in Firebase Storage.
    /// Uses metadata lookup and caches the result to avoid repeated requests.
    @MainActor
    func accompanimentExists(for hymnID: Int) async -> Bool {
        if let cached = availabilityCache[hymnID] {
            return cached
        }

        if let existingTask = inFlightChecks[hymnID] {
            return await existingTask.value
        }

        let task = Task<Bool, Never> {
            do {
                _ = try await self.reference(for: hymnID).getMetadata()
                return true
            } catch {
                return false
            }
        }

        inFlightChecks[hymnID] = task
        let exists = await task.value
        availabilityCache[hymnID] = exists
        inFlightChecks[hymnID] = nil
        return exists
    }

    @MainActor
    func prefetchAvailability(for hymnIDs: [Int]) async {
        for hymnID in hymnIDs {
            _ = await accompanimentExists(for: hymnID)
        }
    }

    @MainActor
    func cachedAvailability(for hymnID: Int) -> Bool? {
        availabilityCache[hymnID]
    }

    @MainActor
    func invalidateAvailability(for hymnID: Int) {
        availabilityCache[hymnID] = nil
        inFlightChecks[hymnID] = nil
    }

    @MainActor
    func clearAvailabilityCache() {
        availabilityCache.removeAll()
        inFlightChecks.removeAll()
    }
}
