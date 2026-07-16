import Foundation
import Combine

final class AccompanimentCacheService: ObservableObject {
    
    enum CacheError: Error {
        case deleteFailed(hymnID: Int, error: Error)
    }
    
    enum ClearResult {
        case cleared(deletedFileCount: Int, reclaimedBytes: Int64)
        case nothingToClear
        case failed(underlying: Error)
    }
    
    @Published private(set) var totalStorageBytes: Int64 = 0
    
    private let fileManager = FileManager.default
    
    private lazy var baseDirectory: URL = {
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError("Crucial system directory 'Application Support' could not be found.")
        }
        
        let directory = appSupport.appendingPathComponent("Accompaniments", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("⚠️ Failed to create base directory: \(error.localizedDescription)")
        }
        
        return directory
    }()
    
    init() {
        refreshStorageSize()
    }
    
    func localURL(for hymnID: Int) -> URL {
        let filename = String(format: "%03d.mp3", hymnID)
        return baseDirectory.appendingPathComponent(filename)
    }
    
    func isDownloaded(for hymnID: Int) -> Bool {
        fileManager.fileExists(atPath: localURL(for: hymnID).path)
    }
    
    func save(data: Data, for hymnID: Int) throws -> URL {
        let url = localURL(for: hymnID)
        try data.write(to: url, options: .atomic)
        refreshStorageSize()
        return url
    }
    
    func delete(for hymnID: Int) throws {
        let url = localURL(for: hymnID)
        
        guard fileManager.fileExists(atPath: url.path) else { return }
        
        do {
            try fileManager.removeItem(at: url)
        } catch {
            throw CacheError.deleteFailed(hymnID: hymnID, error: error)
        }
        refreshStorageSize()
    }
    
    func clearAll() -> ClearResult {
        let files: [URL]
        let reclaimedBytes = totalStorageSize()
        
        do {
            files = try fileManager.contentsOfDirectory(at: baseDirectory, includingPropertiesForKeys: nil)
        } catch {
            return ClearResult.failed(underlying: error)
        }
        
        let deletedFileCount = files.count
        
        guard deletedFileCount > 0 else { return ClearResult.nothingToClear }
        
        do {
            try fileManager.removeItem(at: baseDirectory)
            try fileManager.createDirectory(at: baseDirectory, withIntermediateDirectories: true, attributes: nil)
            refreshStorageSize()
            return ClearResult.cleared(deletedFileCount: deletedFileCount, reclaimedBytes: reclaimedBytes)
            
        } catch {
            print("⚠️ Failed to completely clear directory: \(error.localizedDescription)")
            refreshStorageSize()
            return ClearResult.failed(underlying: error)
        }
    }
    
    func totalStorageSize() -> Int64 {
        let keys: Set<URLResourceKey> = [.fileSizeKey]
        guard let files = try? fileManager.contentsOfDirectory(at: baseDirectory, includingPropertiesForKeys: Array(keys)) else {
            return 0
        }
        
        return files.reduce(0) { total, fileURL in
            guard let values = try? fileURL.resourceValues(forKeys: keys),
                  let size = values.fileSize else {
                return total
            }
            return total + Int64(size)
        }
    }
    
    private func refreshStorageSize() {
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            
            let newValue = self.totalStorageSize()
            
            await MainActor.run {
                self.totalStorageBytes = newValue
            }
        }
    }
}

extension AccompanimentCacheService.CacheError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .deleteFailed:
            return "Couldn't remove the downloaded audio file. Please try again."
        }
    }
}
