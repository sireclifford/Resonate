import Foundation
import Combine
import CryptoKit
final class HymnService: ObservableObject {
    
    private(set) var index: [HymnIndex] = []
    @Published private(set) var currentHymnOfTheDay: HymnIndex?
    private var detailStorage: [Int: HymnDetail] = [:]
    
    init() {
        loadHymns()
        refreshHymnOfTheDay()
    }
    
    private struct HymnDTO: Codable {
        let id: Int
        let title: String
        let verses: [[String]]
        let chorus: [String]?
        let category: HymnCategory
        let language: Language
    }
    
    private func loadHymns() {
        do {
            let fullHymns: [HymnDTO] = try JSONLoader.load("hymns_en.json")
            
            // Transform into index + detail storage
            for dto in fullHymns {
                
                let detail = HymnDetail(
                    id: dto.id,
                    verses: dto.verses,
                    chorus: dto.chorus,
                    scriptureRef: nil,
                    highlight: nil,
                    storyHint: nil,
                    reflection: nil
                )
                detailStorage[dto.id] = detail
                
                let item = HymnIndex(
                    id: dto.id,
                    title: dto.title,
                    category: dto.category,
                    language: dto.language,
                    verseCount: dto.verses.count
                )
                index.append(item)
            }
            
            // Keep sorted by id
            index.sort { $0.id < $1.id }
            
        } catch {
            assertionFailure("Failed to load hymns: \(error)")
        }
    }
    
    func hymnIndex(by id: Int) -> HymnIndex? {
        index.first { $0.id == id }
    }
    
    func detail(for id: Int) -> HymnDetail? {
        detailStorage[id]
    }
    
    func hymns(in category: HymnCategory) -> [HymnIndex] {
        index.filter { $0.category == category }
    }
    
    func hymn(after id: Int) -> HymnIndex? {
        guard let currentIndex = index.firstIndex(where: { $0.id == id }) else { return nil }
        let nextIndex = currentIndex + 1
        return index.indices.contains(nextIndex) ? index[nextIndex] : nil
    }
    
    func hymn(before id: Int) -> HymnIndex? {
        guard let currentIndex = index.firstIndex(where: { $0.id == id }) else { return nil }
        let previousIndex = currentIndex - 1
        return index.indices.contains(previousIndex) ? index[previousIndex] : nil
    }
    
    func refreshHymnOfTheDay(on date: Date = Date()) {
        currentHymnOfTheDay = hymnOfTheDay(on: date)
    }

    func onAppBecameActive() {
        refreshHymnOfTheDay()
    }

    func hymnOfTheDay(on date: Date = Date()) -> HymnIndex? {
        let hymns = index
        guard !hymns.isEmpty else { return nil }
//        #if DEBUG
//        return hymnIndex(by: 264)
//        #endif

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        let dateKey = formatter.string(from: date)

        let hash = SHA256.hash(data: Data(dateKey.utf8))

        // Convert first 8 bytes of the hash into a UInt64
        let value = hash.prefix(8).reduce(UInt64(0)) { partial, byte in
            (partial << 8) | UInt64(byte)
        }

        let indexPosition = Int(value % UInt64(hymns.count))

        return hymns[indexPosition]
    }
}
