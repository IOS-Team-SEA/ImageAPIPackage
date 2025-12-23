import Foundation
#if canImport(UIKit)
import UIKit
#endif
import LoggerKit

#if canImport(UIKit)
@available(iOS 13.0, macOS 10.15, *)
public final class ImageGenerationMultipartService {
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }

    public func generate(
        url: URL,
        payload: ImageMultipartRequestBuilder.Payload
    ) async throws -> ImageAPIEnvelope {
        let request = try ImageMultipartRequestBuilder.makeRequest(url: url, payload: payload)
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw ImageGenerationError.invalidRequest
            }
            guard (200..<300).contains(http.statusCode) else {
                throw ImageGenerationError.serverError(statusCode: http.statusCode, body: String(data: data, encoding: .utf8))
            }
            do {
                return try decoder.decode(ImageAPIEnvelope.self, from: data)
            } catch {
                let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
                await Logger.error("Image multipart response decode failed", metadata: ["error": error.localizedDescription, "body": body, "status": "\(http.statusCode)"])
                throw ImageGenerationError.transport(error)
            }
        } catch {
            if let genError = error as? ImageGenerationError {
                throw genError
            }
            await Logger.error("Image multipart request failed", metadata: ["error": error.localizedDescription])
            throw ImageGenerationError.transport(error)
        }
    }
}
#endif
