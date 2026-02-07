import Combine

final class AppEnvironment: ObservableObject {
    let hymnService: HymnService
    
    init()
    {
        self.hymnService = HymnService()
    }
}
