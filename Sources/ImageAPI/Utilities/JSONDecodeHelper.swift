import Foundation

func decodeJSONDictionary<T: Decodable>(_ dict: [String: Any], as type: T.Type, using decoder: JSONDecoder) -> T? {
    do {
        let data = try JSONSerialization.data(withJSONObject: dict, options: [])
        return try decoder.decode(T.self, from: data)
    } catch {
        return nil
    }
}
