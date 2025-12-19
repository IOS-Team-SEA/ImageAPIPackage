import Foundation

public protocol ImageGenerationClient {
    func generate(_ request: ImageJobRequest) async throws -> ImageGenerationResponse
}

@available(iOS 13.0, macOS 10.15, *)
public final class URLSessionImageGenerationClient: ImageGenerationClient {
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        session: URLSession = .shared,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.encoder = encoder
        self.decoder = decoder
    }

    public func generate(_ request: ImageJobRequest) async throws -> ImageGenerationResponse {
        var urlRequest = URLRequest(url: request.endpoint, timeoutInterval: request.timeout)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try encoder.encode(request.payload)

        let defaultHeaders: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        for (key, value) in defaultHeaders.merging(request.headers, uniquingKeysWith: { _, new in new }) {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        do {
            let (data, response) = try await performRequest(urlRequest)
            guard let http = response as? HTTPURLResponse else {
                throw ImageGenerationError.invalidRequest
            }
            guard (200..<300).contains(http.statusCode) else {
                throw ImageGenerationError.serverError(
                    statusCode: http.statusCode,
                    body: String(data: data, encoding: .utf8)
                )
            }
            do {
                return try decoder.decode(ImageGenerationResponse.self, from: data)
            } catch {
                throw ImageGenerationError.decodingFailed
            }
        } catch {
            if let genError = error as? ImageGenerationError {
                throw genError
            }
            throw ImageGenerationError.transport(error)
        }
    }

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        if #available(iOS 15.0, macOS 12.0, *) {
            return try await session.data(for: request)
        }

        return try await withCheckedThrowingContinuation { continuation in
            let task = session.dataTask(with: request) { data, response, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let data, let response else {
                    continuation.resume(throwing: ImageGenerationError.invalidRequest)
                    return
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }
}
