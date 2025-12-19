import Foundation
import CoreImage
import ImagePipelineCore
import VisionCapabilities
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 13.0, macOS 10.15, *)
public final class RemoteAPIStep: RemoteStep {
    public let id: String
    private let composer: PromptComposer
    private let service: ImageGenerationService
    private let endpoint: URL
    private let headers: [String: String]
    private let parameters: ImageGenerationParameters
    private let timeout: TimeInterval

    public init(
        id: String,
        composer: PromptComposer,
        service: ImageGenerationService,
        endpoint: URL,
        headers: [String: String] = [:],
        parameters: ImageGenerationParameters = .init(),
        timeout: TimeInterval = 60
    ) {
        self.id = id
        self.composer = composer
        self.service = service
        self.endpoint = endpoint
        self.headers = headers
        self.parameters = parameters
        self.timeout = timeout
    }

    public func apply(to context: AIContext) async -> PipelineStepResult {
        let start = Date()
        let prompts = composer.compose(stepId: id, context: context)

        var imagesBase64: [String] = []
        let primary = context.primaryImage.ensureBase64()
        if let base = primary.base64 { imagesBase64.append(base) }
        for img in context.secondaryImages {
            if let base = img.ensureBase64().base64 {
                imagesBase64.append(base)
            }
        }

        var nextContext = context
        var errorDescription: String?
        var cacheHit = false

        if imagesBase64.isEmpty {
            errorDescription = "No base64 images available"
        } else {
            let payload = ImageGenerationPayload(
                imagesBase64: imagesBase64,
                prompt: prompts.prompt,
                negativePrompt: prompts.negative,
                parameters: parameters
            )
            let request = ImageJobRequest(
                endpoint: endpoint,
                headers: headers,
                payload: payload,
                timeout: timeout
            )
            do {
                let response = try await service.generate(request: request)
                if let base64 = response.imageBase64 {
                    let asset = AIImageAsset(base64: base64, format: .png, hasAlpha: true, metadata: ["source": id])
                    nextContext.primaryImage = asset
                    cacheHit = false
                } else {
                    errorDescription = response.error ?? "Empty response"
                }
            } catch let ImageGenerationError.serverError(statusCode, body) {
                errorDescription = "Server \(statusCode): \(body ?? "no body")"
            } catch {
                errorDescription = error.localizedDescription
            }
        }

        let end = Date()
        let log = StepExecutionLog(
            stepId: id,
            start: start,
            end: end,
            prompt: prompts.prompt,
            negativePrompt: prompts.negative,
            cacheHit: cacheHit,
            errorDescription: errorDescription
        )
        return PipelineStepResult(context: nextContext, log: log)
    }
}

@available(iOS 13.0, macOS 10.15, *)
public final class LocalTransformStep: LocalStep {
    public let id: String
    private let transform: (AIContext) -> AIContext

    public init(id: String, transform: @escaping (AIContext) -> AIContext) {
        self.id = id
        self.transform = transform
    }

    public func apply(to context: AIContext) async -> PipelineStepResult {
        let start = Date()
        let next = transform(context)
        let end = Date()
        let log = StepExecutionLog(
            stepId: id,
            start: start,
            end: end,
            prompt: context.composedPrompt,
            negativePrompt: context.composedNegativePrompt,
            cacheHit: false,
            errorDescription: nil
        )
        return PipelineStepResult(context: next, log: log)
    }
}

#if canImport(UIKit)
@available(iOS 14.0, *)
public final class ForegroundMaskStep: LocalStep {
    public let id: String = "VISION_MASK"
    private let detector: ForegroundMaskDetecting
    private let ciContext = CIContext()

    public init(detector: ForegroundMaskDetecting) {
        self.detector = detector
    }

    public func apply(to context: AIContext) async -> PipelineStepResult {
        let start = Date()
        var next = context
        var errorDescription: String?

        if let image = context.primaryImage.uiImage {
            do {
                if let maskCI = try await detector.generateMask(for: image) {
                    if let maskedImage = MaskExtraction.subjectOnly(from: image, mask: maskCI),
                       let data = maskedImage.pngData() {
                        let asset = AIImageAsset(
                            data: data,
                            base64: data.base64EncodedString(),
                            format: .png,
                            hasAlpha: true,
                            metadata: ["source": "vision-mask"]
                        )
                        next.primaryImage = asset
                    }
                    if let cgMask = ciContext.createCGImage(maskCI, from: maskCI.extent),
                       let maskData = UIImage(cgImage: cgMask).pngData() {
                        next.artifacts["foregroundMask"] = AIImageAsset(
                            data: maskData,
                            base64: maskData.base64EncodedString(),
                            format: .png,
                            hasAlpha: true,
                            metadata: ["type": "mask"]
                        )
                    }
                } else {
                    errorDescription = "No mask generated"
                }
            } catch {
                errorDescription = error.localizedDescription
            }
        } else {
            errorDescription = "No primary image"
        }

        let end = Date()
        let log = StepExecutionLog(
            stepId: id,
            start: start,
            end: end,
            prompt: context.composedPrompt,
            negativePrompt: context.composedNegativePrompt,
            cacheHit: false,
            errorDescription: errorDescription
        )
        return PipelineStepResult(context: next, log: log)
    }
}

@available(iOS 13.0, *)
public final class BlackWhiteFilterStep: LocalStep {
    public let id: String = "BW_FILTER"

    public init() {}

    public func apply(to context: AIContext) async -> PipelineStepResult {
        let start = Date()
        var next = context
        var errorDescription: String?
        if let image = context.primaryImage.uiImage,
           let filtered = ImageFilters.blackAndWhite(image),
           let data = filtered.pngData() {
            next.primaryImage = AIImageAsset(
                data: data,
                base64: data.base64EncodedString(),
                format: .png,
                hasAlpha: true,
                metadata: ["source": "bw-filter"]
            )
        } else {
            errorDescription = "BW filter failed"
        }
        let end = Date()
        let log = StepExecutionLog(
            stepId: id,
            start: start,
            end: end,
            prompt: context.composedPrompt,
            negativePrompt: context.composedNegativePrompt,
            cacheHit: false,
            errorDescription: errorDescription
        )
        return PipelineStepResult(context: next, log: log)
    }
}

@available(iOS 14.0, *)
public final class BlurBackgroundWithMaskStep: LocalStep {
    public let id: String = "BLUR_BACKGROUND"
    private let radius: Double
    private let detector: ForegroundMaskDetecting?

    public init(radius: Double = 12, detector: ForegroundMaskDetecting? = nil) {
        self.radius = radius
        self.detector = detector
    }

    public func apply(to context: AIContext) async -> PipelineStepResult {
        let start = Date()
        var next = context
        var errorDescription: String?

        guard let image = context.primaryImage.uiImage else {
            errorDescription = "No primary image"
            let log = StepExecutionLog(stepId: id, start: start, end: Date(), prompt: context.composedPrompt, negativePrompt: context.composedNegativePrompt, cacheHit: false, errorDescription: errorDescription)
            return PipelineStepResult(context: next, log: log)
        }

        var maskCI: CIImage?
        if let maskAsset = context.artifacts["foregroundMask"] as? AIImageAsset,
           let maskImage = maskAsset.uiImage?.cgImage {
            maskCI = CIImage(cgImage: maskImage)
        } else if let detector = detector {
            maskCI = try? await detector.generateMask(for: image)
        }

        if let maskCI,
           let blurred = ImageFilters.blurBackground(image: image, mask: maskCI, radius: radius),
           let data = blurred.pngData() {
            next.primaryImage = AIImageAsset(
                data: data,
                base64: data.base64EncodedString(),
                format: .png,
                hasAlpha: true,
                metadata: ["source": "blur-bg"]
            )
        } else {
            errorDescription = "Blur failed"
        }

        let end = Date()
        let log = StepExecutionLog(
            stepId: id,
            start: start,
            end: end,
            prompt: context.composedPrompt,
            negativePrompt: context.composedNegativePrompt,
            cacheHit: false,
            errorDescription: errorDescription
        )
        return PipelineStepResult(context: next, log: log)
    }
}
#endif
