import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
@available(iOS 13.0, macOS 10.15, *)
public final class PresetTool {
    private let core: MultiImageAndTextCoreTool

    public init(core: MultiImageAndTextCoreTool) {
        self.core = core
    }

    public static func buildPrompt(descriptor: PresetDescriptor, extra: String?) throws -> String {
        guard !descriptor.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ToolInputError.missingPrompt("Preset prompt is empty")
        }
        var prompt = """
\(extra)

You are generic but smart image editor. follow above instruction and generate new image.
whatever asked keep it exact samed.
"""
        
        return prompt
    }

    public func makeRequest(input: PresetInput) throws -> ImageJobRequest {
        if let expected = input.descriptor.requiredSecondaryCount {
            if input.secondaryImages.count != expected {
                throw ToolInputError.secondaryCountMismatch(expected: expected, actual: input.secondaryImages.count)
            }
        }
        let prompt = try Self.buildPrompt(descriptor: input.descriptor, extra: input.userExtraDescription)
        var images: [UIImage] = [input.userImage]
        images.append(contentsOf: input.secondaryImages)
        return try core.makeRequest(prompt: prompt, images: images)
    }
}
#endif
