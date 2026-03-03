import Foundation

enum JSONLoader {
    static func load<T: Decodable>(_ fileName: String) throws -> T {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            throw NSError(domain: "Missing file", code: 404)
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
