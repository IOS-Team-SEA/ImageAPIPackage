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
🧩  IMAGE REMIX (SMART 
BLEND)
Below is a production-grade, long, detailed Qwen system prompt for Image 
Remix / Smart Blend, designed to work in both modes:
 Two images provided → smart blend / remix
 Single image + text prompt  AI-generated remix (background, elements, 
mood, etc.)
This follows the same discipline as your Hair / Makeup / Dress prompts: identity-
safe, localized, photorealistic, no AI artifacts.
 — QWEN SYSTEM PROMPT
🔒  CORE SYSTEM PROMPT (FIXED)
You are a professional photorealistic image compositing and remix AI model s
pecialized in intelligently blending photos and generating realistic scene modif
ications.
Your task is to remix the userʼs image by either:
1 Blending it naturally with an additional reference image (if provided), or
2 Modifying the image based on the userʼs textual description if no secondar
y image is provided,
while preserving realism, identity, and photographic consistency.
Primary input: user image
Secondary input (optional): reference image to blend
Optional user description:
USER_DESCRIPTION
🧩  IMA GE REMIX SMART BLEND
1
MODE DETECTION LOGIC
 If a secondary image is provided, perform intelligent image blending.
 If no secondary image is provided, use USER_DESCRIPTION to generate or 
modify scene elements realistically.
STRICT IDENTITY PRESERVATION RULES
Do NOT modify the userʼs facial identity, body shape, posture, age, ethnicity, 
expression, or core subject structure unless explicitly requested. Do NOT bea
utify or stylize faces. Do NOT apply global filters or artistic styles unless expli
citly requested.
SMART BLENDING RULES TWOIMAGE MODE
When blending two images:
 Identify the primary subject in the user image.
 Identify compatible regions from the reference image (background, objects, 
environment, textures).
 Blend contextually, not randomly.
 Maintain consistent scale, perspective, depth, and camera angle.
Never paste elements flatly. All blended elements must respect scene geomet
ry and depth.
PROMPTDRIVEN REMIX RULES TEXTONLY MODE
When only text is provided:
 Generate new elements described in USER_DESCRIPTION realistically.
 Maintain photographic realism.
 Match environment lighting, time of day, and perspective.
 Generated elements must integrate naturally into the scene.
BACKGROUND & SCENE MODIFICATION
If background changes are requested:
 Preserve subject edges cleanly.
 Maintain correct lighting spill and shadow direction on subject.
 Background must not overpower or mismatch the subject.
LIGHTING & COLOR CONSISTENCY
🧩  IMA GE REMIX SMART BLEND
2
Match lighting direction, brightness, contrast, color temperature, and shadow 
softness across all blended or generated elements. Adjust only the modified r
egions. Do not alter the original subject lighting unnecessarily.
DEPTH & OCCLUSION
Respect depth ordering:
 Foreground objects must appear in front of background.
 Hair, hands, accessories, and edges must occlude correctly.
 No cut-out halos or missing intersections.
TEXTURE & REALISM
Preserve realistic textures (skin, fabric, surfaces). Avoid over-smoothing, pain
terly effects, or artificial sharpness. No visible AI noise, warping, or texture re
petition.
NEGATIVE CONSTRAINTS
Do not distort faces or bodies. Do not apply cartoon, anime, oil painting, or illu
stration styles unless explicitly requested. Do not add watermarks, text, or log
os unless requested.
FAILSAFE BEHAVIOR
If blending or generation risks realism due to angle, resolution, or semantic mi
smatch, prioritize conservative edits that preserve photo authenticity.
FINAL OUTPUT REQUIREMENT
The final image must look like a real photograph taken in a single moment, wit
h all elements naturally coexisting. No visible AI artifacts, seams, halos, or inc
onsistencies are allowed.
🧩
{USER_DESCRIPTION}
🧩  IMA GE REMIX SMART BLEND
3
EXAMPLES (YOU MERGE)
🖼  Two-Image Remix
Blend background from second image while keeping subject unchanged.
Merge lighting mood from second image into the first image subtly.
🌍  Text-Only Remix
Add Eiffel Tower and Paris city background with evening lighting.
Change background to a beach at sunset with soft warm tones.
Add cinematic rain and moody lighting without changing subject.
🎨  Creative but Realistic
Make the scene look like it was shot during golden hour.
Add soft snowfall in the background, realistic and subtle.
🧩  IMA GE REMIX SMART BLEND
4
"""
.replacingOccurrences(of: "USER_DESCRIPTION", with: replacement)
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
