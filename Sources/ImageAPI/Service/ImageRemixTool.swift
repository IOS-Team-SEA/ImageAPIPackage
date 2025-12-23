import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
@available(iOS 13.0, macOS 10.15, *)
public final class ImageRemixTool {
    private let core: ImageAndTextToImageCoreTool

    public init(core: ImageAndTextToImageCoreTool) {
        self.core = core
    }

    public static func buildPrompt(userDescription: String?, hasSecondary: Bool) throws -> String {
        if !hasSecondary {
            guard let desc = userDescription, !desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw ToolInputError.missingPrompt("Remix description required when no secondary image is provided")
            }
        }
        let replacement = (userDescription?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) ? userDescription!.trimmingCharacters(in: .whitespacesAndNewlines) : "None"
        var prompt = """
\(userDescription)

You are a professional photorealistic image compositing and remix AI model s
pecialized in intelligently blending photos and generating realistic scene modif
ications.
Your task is to remix the userʼs image with :
1 Blending it naturally with an additional reference image (if provided),
2 Modifying the image based on the userʼs textual description at top 
while preserving realism, identity, and photographic consistency.

If a secondary image is provided, perform intelligent image blending.

Do NOT modify the userʼs facial identity, body shape, posture, age, ethnicity, 
expression, or core subject structure unless explicitly requested. Do NOT bea
utify or stylize faces. Do NOT apply global filters or artistic styles unless expli
citly requested.
When blending two images:
 Identify the primary subject in the user image.
Identify compatible regions from the reference image (background, objects, 
environment, textures).
Blend contextually, not randomly.
Maintain consistent scale, perspective, depth, and camera angle.
Never paste elements flatly. All blended elements must respect scene geomet
ry and depth.

When only text is provided:
 Generate new elements described in \(userDescription) realistically.
 Maintain photographic realism.
 Match environment lighting, time of day, and perspective.
 Generated elements must integrate naturally into the scene.
If background changes are requested:
 Preserve subject edges cleanly.
 Maintain correct lighting spill and shadow direction on subject.
 Background must not overpower or mismatch the subject.

Match lighting direction, brightness, contrast, color temperature, and shadow 
softness across all blended or generated elements. Adjust only the modified r
egions. Do not alter the original subject lighting unnecessarily.

Respect depth ordering:
 Foreground objects must appear in front of background.
 Hair, hands, accessories, and edges must occlude correctly.
 No cut-out halos or missing intersections.
Preserve realistic textures (skin, fabric, surfaces). Avoid over-smoothing, pain
terly effects, or artificial sharpness. No visible AI noise, warping, or texture re
petition.
Do not distort faces or bodies. Do not apply cartoon, anime, oil painting, or illu
stration styles unless explicitly requested. Do not add watermarks, text, or log
os unless requested.
If blending or generation risks realism due to angle, resolution, or semantic mi
smatch, prioritize conservative edits that preserve photo authenticity.
The final image must look like a real photograph taken in a single moment, wit
h all elements naturally coexisting. No visible AI artifacts, seams, halos, or inc
onsistencies are allowed.

"""

        if hasSecondary {
            prompt += "Secondary image provided for blending."
        }
        return prompt
    }

    public func makeRequest(input: ImageRemixInput) throws -> ImageJobRequest {
        let prompt = try Self.buildPrompt(userDescription: input.userDescription, hasSecondary: input.secondaryImage != nil)
        return try core.makeRequest(prompt: prompt, image: input.userImage, secondaryImage: input.secondaryImage)
    }
}
#endif
