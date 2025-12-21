import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
@available(iOS 13.0, macOS 10.15, *)
public final class LogoGenerationTool {
    private let core: ImageAndTextToImageCoreTool

    public init(core: ImageAndTextToImageCoreTool) {
        self.core = core
    }

    public func makeRequest(input: LogoGenerationInput) throws -> ImageJobRequest {
        // Enforce prompt + at least one image per API contract.
        let prompt = try ToolPromptBuilders.logoPrompt(from: input)
        return try core.makeRequest(
            prompt: prompt,
            image: input.styleReference
        )
    }
}

@available(iOS 13.0, macOS 10.15, *)
public final class HairTryOnTool {
    private let core: MultiImageAndTextCoreTool

    public init(core: MultiImageAndTextCoreTool) {
        self.core = core
    }

    public func makeRequest(input: HairTryOnInput) throws -> ImageJobRequest {
        guard !input.referenceImages.isEmpty else {
            throw ToolInputError.missingSecondaryImages
        }
        let prompt = ToolPromptBuilders.hairPrompt(variant: input.variant, userDescription: input.userDescription)
        var images: [UIImage] = [input.userImage]
        images.append(contentsOf: input.referenceImages)
        return try core.makeRequest(prompt: prompt, images: images)
    }
}

@available(iOS 13.0, macOS 10.15, *)
public final class DressTryOnTool {
    private let core: MultiImageAndTextCoreTool

    public init(core: MultiImageAndTextCoreTool) {
        self.core = core
    }

    public func makeRequest(input: DressTryOnInput) throws -> ImageJobRequest {
        guard !input.referenceImages.isEmpty else {
            throw ToolInputError.missingSecondaryImages
        }
        let prompt = ToolPromptBuilders.dressPrompt(userDescription: input.userDescription)
        var images: [UIImage] = [input.userImage]
        images.append(contentsOf: input.referenceImages)
        return try core.makeRequest(prompt: prompt, images: images)
    }
}

@available(iOS 13.0, macOS 10.15, *)
public final class BackgroundChangeTool {
    private let core: ImageAndTextToImageCoreTool

    public init(core: ImageAndTextToImageCoreTool) {
        self.core = core
    }

    public func makeRequest(input: BackgroundChangeInput) throws -> ImageJobRequest {
        let prompt = try ToolPromptBuilders.backgroundChangePrompt(
            userDescription: input.userDescription,
            hasBackgroundRef: input.backgroundReference != nil
        )
        var secondary: UIImage? = nil
        if let bg = input.backgroundReference {
            secondary = bg
        }
        return try core.makeRequest(
            prompt: prompt,
            image: input.userImage,
            secondaryImage: secondary
        )
    }
}

@available(iOS 13.0, macOS 10.15, *)
public final class ImageRemixTool {
    private let core: ImageAndTextToImageCoreTool

    public init(core: ImageAndTextToImageCoreTool) {
        self.core = core
    }

    public func makeRequest(input: ImageRemixInput) throws -> ImageJobRequest {
        let prompt = try ToolPromptBuilders.remixPrompt(
            userDescription: input.userDescription,
            hasSecondary: input.secondaryImage != nil
        )
        return try core.makeRequest(
            prompt: prompt,
            image: input.userImage,
            secondaryImage: input.secondaryImage
        )
    }
}

@available(iOS 13.0, macOS 10.15, *)
public final class PresetTool {
    private let core: ImageAndTextToImageCoreTool

    public init(core: ImageAndTextToImageCoreTool) {
        self.core = core
    }

    public func makeRequest(input: PresetInput) throws -> ImageJobRequest {
        if let expected = input.descriptor.requiredSecondaryCount {
            if input.secondaryImages.count != expected {
                throw ToolInputError.secondaryCountMismatch(
                    expected: expected,
                    actual: input.secondaryImages.count
                )
            }
        }
        let prompt = try ToolPromptBuilders.presetPrompt(
            descriptor: input.descriptor,
            extra: input.userExtraDescription
        )
        var images: [UIImage] = [input.userImage]
        images.append(contentsOf: input.secondaryImages)
        return try core.makeRequest(prompt: prompt, images: images)
    }
}
#endif
