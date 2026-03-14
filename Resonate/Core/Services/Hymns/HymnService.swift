import Foundation
import Combine

final class HymnService: ObservableObject {

    private(set) var index: [HymnIndex] = []
    @Published private(set) var currentHymnOfTheDay: HymnIndex?
    private var detailStorage: [Int: HymnDetail] = [:]

    private let hotdEngine = HymnOfTheDayEngine()
    private var hotdOverrides: [HOTDOverride] = []

    init() {
        loadHymns()
        loadHOTDOverrides()
        refreshHymnOfTheDay()
    }

    private struct HymnDTO: Codable {
        let id: Int
        let title: String
        let verses: [[String]]
        let chorus: [String]?
        let category: HymnCategory
        let language: Language
        let occasions: [HymnOccasion]?
    }

    private func loadHymns() {
        index.removeAll()
        detailStorage.removeAll()

        do {
            let fullHymns: [HymnDTO] = try JSONLoader.load("hymns_en.json")

            for dto in fullHymns {
                let detail = HymnDetail(
                    id: dto.id,
                    verses: dto.verses,
                    chorus: dto.chorus,
                    scriptureRef: nil,
                    highlight: nil,
                    storyHint: nil,
                    occasions: dto.occasions,
                    reflection: nil
                )
                detailStorage[dto.id] = detail

                let item = HymnIndex(
                    id: dto.id,
                    title: dto.title,
                    category: dto.category,
                    language: dto.language,
                    verseCount: dto.verses.count,
                    occasions: dto.occasions
                )
                index.append(item)
            }

            index.sort { $0.id < $1.id }
        } catch {
            assertionFailure("Failed to load hymns: \(error)")
        }
    }

    private func loadHOTDOverrides() {
        do {
            hotdOverrides = try JSONLoader.load("hotd_overrides.json")
        } catch {
            hotdOverrides = []
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
        guard let hymnID = hotdEngine.hymnID(
            for: date,
            hymns: index,
            overrides: hotdOverrides
        ) else {
            return nil
        }

        return hymnIndex(by: hymnID)
    }
}
