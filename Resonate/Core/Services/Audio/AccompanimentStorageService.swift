import Foundation
import FirebaseStorage

/// Handles resolving Firebase Storage references and download URLs
/// for hymn accompaniment audio files stored in Firebase Storage.
final class AccompanimentStorageService {

    private let storage = Storage.storage()

    /// Returns the zero-padded filename used in Firebase Storage.
    /// Example: hymnID 1 -> "001.m4a"
    private func filename(for hymnID: Int) -> String {
        String(format: "%03d.m4a", hymnID)
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
}
