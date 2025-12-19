import Foundation

@available(iOS 13.0, macOS 10.15, *)
public final class ImageGenerationService {
    private let client: ImageGenerationClient

    public init(client: ImageGenerationClient) {
        self.client = client
    }

    public func generate(request: ImageJobRequest) async throws -> ImageGenerationResponse {
        try await client.generate(request)
    }
}
