import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
/// BaseTool 01 — TextImageGenerator (prompt only)
@available(iOS 13.0, macOS 10.15, *)
public final class TextImageGenerator {
    private let core: TextToImageCoreTool

    public init(core: TextToImageCoreTool) {
        self.core = core
    }

    public func makeRequest(
        prompt: String,
        negativePrompt: String? = nil,
        styleHints: [String]? = nil,
        params: ImageGenerationParameters? = nil
    ) throws -> ImageJobRequest {
        let combinedPrompt: String
        if let hints = styleHints, !hints.isEmpty {
            combinedPrompt = ([prompt] + hints).joined(separator: ", ")
        } else {
            combinedPrompt = prompt
        }
        return try core.makeRequest(
            prompt: combinedPrompt,
            negativePrompt: negativePrompt ?? " ",
            params: params
        )
    }
}

/// BaseTool 02 — ImageTransformer (one image + prompt)
@available(iOS 13.0, macOS 10.15, *)
public final class ImageTransformer {
    private let core: ImageAndTextToImageCoreTool

    public init(core: ImageAndTextToImageCoreTool) {
        self.core = core
    }

    public func makeRequest(
        image: UIImage,
        secondaryImage: UIImage? = nil,
        prompt: String,
        negativePrompt: String? = nil,
        strength: Float? = nil,
        params: ImageGenerationParameters? = nil
    ) throws -> ImageJobRequest {
        // strength can be mapped to guidance/steps later; for now pass-through
        let mergedParams = params ?? ImageGenerationParameters()
        return try core.makeRequest(
            prompt: prompt,
            image: image,
            secondaryImage: secondaryImage,
            negativePrompt: negativePrompt ?? " ",
            params: mergedParams
        )
    }
}

/// BaseTool 03 — ImageInpaintingTool (requires backend support for mask)
@available(iOS 13.0, macOS 10.15, *)
public final class ImageInpaintingTool {
    private let core: ImageAndTextToImageCoreTool

    public init(core: ImageAndTextToImageCoreTool) {
        self.core = core
    }

    public func makeRequest(
        image: UIImage,
        secondaryImage: UIImage? = nil,
        mask: UIImage,
        prompt: String?,
        negativePrompt: String? = nil,
        params: ImageGenerationParameters? = nil
    ) throws -> ImageJobRequest {
        // Note: mask handling depends on backend schema; for now we attach both images in order [image, mask]
        return try ImageJobRequestBuilder.makeRequest(
            prompt: prompt ?? "",
            images: [image, secondaryImage, mask].compactMap { $0 },
            endpoint: coreEndpoint,
            headers: coreHeaders,
            negativePrompt: negativePrompt ?? " ",
            params: params ?? ImageGenerationParameters(),
            maxDimension: coreMaxDimension,
            format: coreFormat,
            timeout: coreTimeout
        )
    }

    // Core accessors
    private var coreEndpoint: URL { core.endpoint }
    private var coreHeaders: [String: String] { core.headers }
    private var coreMaxDimension: CGFloat { core.maxDimension }
    private var coreFormat: ImageEncodingFormat { core.format }
    private var coreTimeout: TimeInterval { core.timeout }
}

/// BaseTool 04 — ImageOutpaintingTool (extend image)
@available(iOS 13.0, macOS 10.15, *)
public final class ImageOutpaintingTool {
    private let core: ImageAndTextToImageCoreTool

    public init(core: ImageAndTextToImageCoreTool) {
        self.core = core
    }

    public func makeRequest(
        image: UIImage,
        targetAspectRatio: String,
        prompt: String?,
        negativePrompt: String? = nil,
        params: ImageGenerationParameters? = nil
    ) throws -> ImageJobRequest {
        let aspectHint = "Target aspect: \(targetAspectRatio)"
        let fullPrompt = [prompt, aspectHint].compactMap { $0 }.joined(separator: ", ")
        return try core.makeRequest(
            prompt: fullPrompt.isEmpty ? " " : fullPrompt,
            image: image,
            negativePrompt: negativePrompt ?? " ",
            params: params ?? ImageGenerationParameters()
        )
    }
}

/// BaseTool 05 — ImageEnhancementTool (quality without structure change)
@available(iOS 13.0, macOS 10.15, *)
public final class ImageEnhancementTool {
    public enum Enhancement {
        case upscale
        case denoise
        case sharpen
    }

    private let core: ImageAndTextToImageCoreTool

    public init(core: ImageAndTextToImageCoreTool) {
        self.core = core
    }

    public func makeRequest(
        image: UIImage,
        enhancementType: [Enhancement],
        negativePrompt: String? = nil,
        params: ImageGenerationParameters? = nil
    ) throws -> ImageJobRequest {
        let prompt = enhancementType.map { "\($0)" }.joined(separator: ", ")
        return try core.makeRequest(
            prompt: prompt.isEmpty ? "enhance quality" : prompt,
            image: image,
            negativePrompt: negativePrompt ?? " ",
            params: params ?? ImageGenerationParameters()
        )
    }
}

/// BaseTool 06 — MultiImageComposer (compose multiple images)
@available(iOS 13.0, macOS 10.15, *)
public final class MultiImageComposer {
    public enum LayoutType {
        case grid
        case collage
        case stacked
    }

    private let core: MultiImageAndTextCoreTool

    public init(core: MultiImageAndTextCoreTool) {
        self.core = core
    }

    public func makeRequest(
        images: [UIImage],
        layoutHint: LayoutType? = nil,
        prompt: String? = nil,
        negativePrompt: String? = nil,
        params: ImageGenerationParameters? = nil
    ) throws -> ImageJobRequest {
        var combinedPrompt = prompt ?? ""
        if let layoutHint {
            combinedPrompt = [combinedPrompt, "layout: \(layoutHint)"].filter { !$0.isEmpty }.joined(separator: ", ")
        }
        return try core.makeRequest(
            prompt: combinedPrompt.isEmpty ? "compose" : combinedPrompt,
            images: images,
            negativePrompt: negativePrompt ?? " ",
            params: params ?? ImageGenerationParameters()
        )
    }
}

/// BaseTool 07 — ImageToVideoGenerator (animates image into video) — placeholder for video endpoint
@available(iOS 13.0, macOS 10.15, *)
public final class ImageToVideoGenerator {
    public enum MotionPreset {
        case pan
        case zoom
        case parallax
    }

    private let core: ImageAndTextToImageCoreTool

    public init(core: ImageAndTextToImageCoreTool) {
        self.core = core
    }

    public func makeRequest(
        image: UIImage,
        motionStyle: MotionPreset,
        duration: TimeInterval,
        prompt: String? = nil,
        negativePrompt: String? = nil,
        params: ImageGenerationParameters? = nil
    ) throws -> ImageJobRequest {
        let hint = "motion: \(motionStyle), duration: \(Int(duration))s"
        let combinedPrompt = [prompt, hint].compactMap { $0 }.joined(separator: ", ")
        return try core.makeRequest(
            prompt: combinedPrompt.isEmpty ? "animate image" : combinedPrompt,
            image: image,
            negativePrompt: negativePrompt ?? " ",
            params: params ?? ImageGenerationParameters()
        )
    }
}
#endif
