import Foundation
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 13.0, macOS 10.15, *)
public enum ImageJobRequestBuilder {
    #if canImport(UIKit)
    public static func makeRequest(
        prompt: String,
        images: [UIImage],
        endpoint: URL,
        headers: [String: String] = [:],
        negativePrompt: String = " ",
        params: ImageGenerationParameters = .init(),
        maxDimension: CGFloat = 768,
        format: ImageEncodingFormat = .png,
        timeout: TimeInterval = 60,
        requireImages: Bool = true
    ) throws -> ImageJobRequest {
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ImageGenerationError.missingPrompt
        }
        guard !images.isEmpty || !requireImages else {
            throw ImageGenerationError.missingImages
        }

        let encoded = try images.map {
            try ImageBase64Builder.base64String(from: $0, format: format, maxDimension: maxDimension)
        }

        let payload = ImageGenerationPayload(
            imagesBase64: encoded,
            prompt: prompt,
            negativePrompt: negativePrompt,
            parameters: params
        )

        return ImageJobRequest(
            endpoint: endpoint,
            headers: headers,
            payload: payload,
            timeout: timeout
        )
    }
    #endif
}
