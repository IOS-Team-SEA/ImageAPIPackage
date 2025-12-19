import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
@available(iOS 13.0, macOS 10.15, *)
public final class TextToImageCoreTool {
    public let endpoint: URL
    public let headers: [String: String]
    public let defaultParams: ImageGenerationParameters
    public let timeout: TimeInterval

    public init(
        endpoint: URL,
        headers: [String: String] = [:],
        defaultParams: ImageGenerationParameters = .init(),
        timeout: TimeInterval = 60
    ) {
        self.endpoint = endpoint
        self.headers = headers
        self.defaultParams = defaultParams
        self.timeout = timeout
    }

    public func makeRequest(
        prompt: String,
        negativePrompt: String = " ",
        params: ImageGenerationParameters? = nil
    ) throws -> ImageJobRequest {
        try ImageJobRequestBuilder.makeRequest(
            prompt: prompt,
            images: [],
            endpoint: endpoint,
            headers: headers,
            negativePrompt: negativePrompt,
            params: params ?? defaultParams,
            timeout: timeout, requireImages: false
        )
    }
}

@available(iOS 13.0, macOS 10.15, *)
public final class ImageAndTextToImageCoreTool {
    public let endpoint: URL
    public let headers: [String: String]
    public let defaultParams: ImageGenerationParameters
    public let maxDimension: CGFloat
    public let format: ImageEncodingFormat
    public let timeout: TimeInterval

    public init(
        endpoint: URL,
        headers: [String: String] = [:],
        defaultParams: ImageGenerationParameters = .init(),
        maxDimension: CGFloat = 768,
        format: ImageEncodingFormat = .png,
        timeout: TimeInterval = 60
    ) {
        self.endpoint = endpoint
        self.headers = headers
        self.defaultParams = defaultParams
        self.maxDimension = maxDimension
        self.format = format
        self.timeout = timeout
    }

    public func makeRequest(
        prompt: String,
        image: UIImage,
        secondaryImage: UIImage? = nil,
        negativePrompt: String = " ",
        params: ImageGenerationParameters? = nil
    ) throws -> ImageJobRequest {
        var images: [UIImage] = [image]
        if let secondaryImage { images.append(secondaryImage) }
        return try ImageJobRequestBuilder.makeRequest(
            prompt: prompt,
            images: images,
            endpoint: endpoint,
            headers: headers,
            negativePrompt: negativePrompt,
            params: params ?? defaultParams,
            maxDimension: maxDimension,
            format: format,
            timeout: timeout
        )
    }
}

@available(iOS 13.0, macOS 10.15, *)
public final class MultiImageAndTextCoreTool {
    public let endpoint: URL
    public let headers: [String: String]
    public let defaultParams: ImageGenerationParameters
    public let maxDimension: CGFloat
    public let format: ImageEncodingFormat
    public let timeout: TimeInterval

    public init(
        endpoint: URL,
        headers: [String: String] = [:],
        defaultParams: ImageGenerationParameters = .init(),
        maxDimension: CGFloat = 768,
        format: ImageEncodingFormat = .png,
        timeout: TimeInterval = 60
    ) {
        self.endpoint = endpoint
        self.headers = headers
        self.defaultParams = defaultParams
        self.maxDimension = maxDimension
        self.format = format
        self.timeout = timeout
    }

    public func makeRequest(
        prompt: String,
        images: [UIImage],
        negativePrompt: String = " ",
        params: ImageGenerationParameters? = nil
    ) throws -> ImageJobRequest {
        try ImageJobRequestBuilder.makeRequest(
            prompt: prompt,
            images: images,
            endpoint: endpoint,
            headers: headers,
            negativePrompt: negativePrompt,
            params: params ?? defaultParams,
            maxDimension: maxDimension,
            format: format,
            timeout: timeout
        )
    }
}
#endif
