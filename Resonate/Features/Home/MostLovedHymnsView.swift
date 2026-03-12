import SwiftUI
import Foundation

struct MostLovedHymnsView: View {

    let environment: AppEnvironment

    private let featuredIDs: [Int] = [
        1, 10, 12, 21, 27, 39, 44, 52, 61, 75,
        88, 99, 108, 120, 134, 152, 176, 194, 205, 224,
        245, 267, 290, 312, 333, 355, 401, 450, 501, 601
    ]

    var hymns: [HymnIndex] {
        let featuredSet = Set(featuredIDs)

        let featured = environment.hymnService.index
            .filter { featuredSet.contains($0.id) }
            .sorted(by: { lhs, rhs in
                guard let leftIndex = featuredIDs.firstIndex(of: lhs.id),
                      let rightIndex = featuredIDs.firstIndex(of: rhs.id) else {
                    return lhs.id < rhs.id
                }
                return leftIndex < rightIndex
            })

        if featured.isEmpty {
            return Array(environment.hymnService.index.prefix(30))
        }

        return featured
    }

    var body: some View {
        HymnListView(
            title: "Most Loved Hymns",
            hymns: hymns,
            environment: environment
        )
    }
}
