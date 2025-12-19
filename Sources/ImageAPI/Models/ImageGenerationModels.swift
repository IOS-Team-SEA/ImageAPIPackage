import Foundation
#if canImport(UIKit)
import UIKit
#endif

public struct ImageGenerationParameters: Equatable {
    public let trueCFGScale: Double
    public let numInferenceSteps: Int
    public let guidanceScale: Double
    public let numImages: Int
    public let seed: Int

    public init(
        trueCFGScale: Double = 4.0,
        numInferenceSteps: Int = 20,
        guidanceScale: Double = 1.0,
        numImages: Int = 1,
        seed: Int = 0
    ) {
        self.trueCFGScale = trueCFGScale
        self.numInferenceSteps = numInferenceSteps
        self.guidanceScale = guidanceScale
        self.numImages = numImages
        self.seed = seed
    }
}

public struct ImageGenerationPayload: Codable, Equatable {
    public struct Inputs: Codable, Equatable {
        public let images: [String]
        public let prompt: String
        public let negativePrompt: String
        public let trueCFGScale: Double
        public let numInferenceSteps: Int
        public let guidanceScale: Double
        public let numImagesPerPrompt: Int
        public let seed: Int

        public init(
            images: [String],
            prompt: String,
            negativePrompt: String,
            trueCFGScale: Double,
            numInferenceSteps: Int,
            guidanceScale: Double,
            numImagesPerPrompt: Int,
            seed: Int
        ) {
            self.images = images
            self.prompt = prompt
            self.negativePrompt = negativePrompt
            self.trueCFGScale = trueCFGScale
            self.numInferenceSteps = numInferenceSteps
            self.guidanceScale = guidanceScale
            self.numImagesPerPrompt = numImagesPerPrompt
            self.seed = seed
        }

        enum CodingKeys: String, CodingKey {
            case images
            case prompt
            case negativePrompt = "negative_prompt"
            case trueCFGScale = "true_cfg_scale"
            case numInferenceSteps = "num_inference_steps"
            case guidanceScale = "guidance_scale"
            case numImagesPerPrompt = "num_images_per_prompt"
            case seed
        }
    }

    public let inputs: Inputs

    public init(
        imageBase64: String,
        prompt: String,
        negativePrompt: String = " ",
        parameters: ImageGenerationParameters = .init()
    ) {
        self.init(
            imagesBase64: [imageBase64],
            prompt: prompt,
            negativePrompt: negativePrompt,
            parameters: parameters
        )
    }

    public init(
        imagesBase64: [String],
        prompt: String,
        negativePrompt: String = " ",
        parameters: ImageGenerationParameters = .init()
    ) {
        self.inputs = Inputs(
            images: imagesBase64,
            prompt: prompt,
            negativePrompt: negativePrompt,
            trueCFGScale: parameters.trueCFGScale,
            numInferenceSteps: parameters.numInferenceSteps,
            guidanceScale: parameters.guidanceScale,
            numImagesPerPrompt: parameters.numImages,
            seed: parameters.seed
        )
    }
}

public struct ImageGenerationResponse: Codable, Equatable {
    public let imageBase64: String?
    public let status: String?
    public let error: String?

    public init(
        imageBase64: String? = nil,
        status: String? = nil,
        error: String? = nil
    ) {
        self.imageBase64 = imageBase64
        self.status = status
        self.error = error
    }

    enum CodingKeys: String, CodingKey {
        case imageBase64 = "image_base64"
        case status
        case error
    }
}

public struct ImageJobRequest {
    public let endpoint: URL
    public let headers: [String: String]
    public let payload: ImageGenerationPayload
    public let timeout: TimeInterval

    public init(
        endpoint: URL,
        headers: [String: String] = [:],
        payload: ImageGenerationPayload,
        timeout: TimeInterval = 60
    ) {
        self.endpoint = endpoint
        self.headers = headers
        self.payload = payload
        self.timeout = timeout
    }
}

public enum ImageGenerationError: Error {
    case invalidRequest
    case serverError(statusCode: Int, body: String?)
    case decodingFailed
    case transport(Error)
    case imageEncodingFailed
    case missingPrompt
    case missingImages
}

#if canImport(UIKit)
public enum ImageEncodingFormat {
    case png
    case jpeg(quality: CGFloat)
}

public enum ImageBase64Builder {
    public static func base64String(
        from image: UIImage,
        format: ImageEncodingFormat = .png,
        maxDimension: CGFloat? = nil
    ) throws -> String {
        let resized = resize(image: image, maxDimension: maxDimension)
        guard let data = encode(image: resized, format: format) else {
            throw ImageGenerationError.imageEncodingFailed
        }
        return data.base64EncodedString()
    }

    private static func resize(image: UIImage, maxDimension: CGFloat?) -> UIImage {
        guard let maxDimension, max(image.size.width, image.size.height) > maxDimension else {
            return image
        }
        let ratio = maxDimension / max(image.size.width, image.size.height)
        let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    private static func encode(image: UIImage, format: ImageEncodingFormat) -> Data? {
        switch format {
        case .png:
            return image.pngData()
        case .jpeg(let quality):
            return image.jpegData(compressionQuality: quality)
        }
    }
}
#endif
