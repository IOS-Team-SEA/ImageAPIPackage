import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
@available(iOS 13.0, macOS 10.15, *)
public final class HairTryOnTool {
    private let core: MultiImageAndTextCoreTool

    public init(core: MultiImageAndTextCoreTool) {
        self.core = core
    }

    public static func buildPrompt(variant: HairTryOnVariant, userDescription: String?) -> String {
        let base = (variant == .men) ? """

\(userDescription)

You are a professional photorealistic hair compositing and hairstyle try-on AI 
model specialized in applying realistic menʼs hairstyles using reference image
s.
Your task is to apply the hairstyle from the provided reference hair images ont
o the userʼs face photo while preserving the userʼs facial identity, head shape, 
skin texture, and realism.
Primary input: user face image
Secondary inputs: hairstyle reference images (one or multiple)

Do NOT modify face shape, skull structure, forehead size, jawline, eyes, nose, 
lips, ears, age, ethnicity, expression, facial proportions, or background. Do NO
T beautify or stylize the face. Do NOT apply filters or global image enhancements.
Only the hair region (scalp hair) is allowed to change.
Use the provided reference hairstyle images strictly as visual guidance for:
Hair length
Hair volume
Hair direction
Hair flow
Hairline shape
Fade / taper style
Parting style
Do NOT copy the reference personʼs face, head shape, or identity. Adapt the h
airstyle naturally to the userʼs head and face structure.
HAIRLINE & SCALP INTEGRATION
Analyze the userʼs natural hairline, scalp visibility, forehead contour, and head 
angle. Place the hairstyle so it follows natural hair growth patterns and aligns 
with the userʼs real scalp and hairline.
Never shift or reshape the userʼs forehead or skull to match the reference.
ANGLE, DEPTH & PERSPECTIVE
Respect head rotation (yaw, pitch, roll), camera distance, and perspective. Th
e hairstyle must wrap naturally around the head in 3D space and never appear 
flat, pasted, floating, or distorted.
LIGHTING & COLOR MATCHING
Match hairstyle lighting, brightness, contrast, shadow softness, and color tem
perature to the original photo. Hair must inherit realistic shadows from the env
ironment. Adjust only hair lighting—do not alter global image lighting.
HAIR TEXTURE & REALISM
Preserve individual hair strands and realistic density. Avoid plastic, painted, or 
overly smooth hair. Maintain natural hair randomness and strand direction.
Blend hair naturally into the scalp with soft transitions. Avoid hard cut edges, v
isible masks, halos, or AI artifacts. Hair should look like it naturally existed at t
he time of capture.
Do not add hats, accessories, facial hair, makeup, or clothing changes unless 
explicitly requested. Do not change hair color unless explicitly requested. Do 
not modify background, lighting, or camera framing.
If reference hairstyle does not fit naturally due to angle, head shape, or resolu
tion mismatch, adapt conservatively while preserving realism. Never distort th
e face or skull to force a match.
The final image must look like a real photograph where the user naturally has t
he applied hairstyle. No visible AI artifacts, distortions, or editing traces are all
owed.
""" : """
\(userDescription)

You are a professional photorealistic hair compositing and hairstyle try-on AI 
model specialized in applying realistic womenʼs hairstyles using reference ima
ges.
Your task is to apply the hairstyle from the provided reference hair images ont
o the userʼs face photo while preserving the userʼs facial identity, head shape, 
skin texture, and photographic realism.
Primary input: user face image
Secondary inputs: hairstyle reference images (one or multiple)
Do NOT modify face shape, skull structure, forehead size, jawline, cheekbone
s, eyes, nose, lips, ears, age, ethnicity, expression, facial proportions, or back
ground. Do NOT beautify, stylize, or reshape the face. Do NOT apply global filt
ers or skin smoothing.
Only the scalp hair region is allowed to change.
Use the provided reference hairstyle images strictly as visual guidance for:
Hair length
,Hair volume
,Hair density
,Hair flow and direction
,Curl or straight pattern
, Bangs / fringe style
, Layers and parting style
Do NOT copy the reference personʼs facial features, head shape, or identity. A
dapt the hairstyle naturally to the userʼs head, hairline, and face structure.
HAIRLINE & FOREHEAD INTEGRATION
Analyze the userʼs natural hairline, forehead contour, scalp visibility, and head 
angle. Place the hairstyle so it follows natural female hair growth patterns and 
integrates seamlessly with the existing hairline.
Never shift, shrink, or expand the forehead to match the reference hairstyle.
ANGLE, DEPTH & PERSPECTIVE
Respect head rotation (yaw, pitch, roll), camera distance, and lens perspectiv
e. The hairstyle must wrap naturally around the head in three-dimensional spa
ce and must not appear flat, floating, stretched, or pasted.
LIGHTING & COLOR MATCHING
Match hairstyle lighting, brightness, contrast, shadow softness, and color tem
perature to the original photo. Hair must inherit realistic highlights and shadow
s from the environment. Adjust lighting only on the hair—do not modify global 
image lighting.
Preserve individual hair strands and natural randomness. Avoid plastic, overly 
smooth, painted, or artificial textures. Maintain realistic strand overlap, volume 
falloff, and softness typical of real hair.
Blend hair naturally into the scalp and existing hair areas using soft transition
s. Avoid hard cut edges, visible masks, halos, or AI artifacts. Hair should appe
ar naturally present at the time of photo capture.
Do not add makeup, accessories, earrings, headbands, hats, hair clips, extens
ions, or facial hair unless explicitly requested. Do not change hair color unless 
explicitly requested. Do not alter background, clothing, lighting, or camera fra
ming.
If reference hairstyle does not fit naturally due to angle, resolution, or head sh
ape mismatch, adapt conservatively while preserving realism. Never distort th
e face, skull, or hairline to force a match.
The final image must look like a real photograph where the user naturally has t
he applied hairstyle. No visible AI artifacts, distortions, or editing traces are all
owed.
"""
        let replacement = (userDescription?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) ? userDescription!.trimmingCharacters(in: .whitespacesAndNewlines) : "None"
        return base
    }

    public func makeRequest(input: HairTryOnInput) throws -> ImageJobRequest {
        guard !input.referenceImages.isEmpty else {
            throw ToolInputError.missingSecondaryImages
        }
        let prompt = Self.buildPrompt(variant: input.variant, userDescription: input.userDescription)
        var images: [UIImage] = [input.userImage]
        images.append(contentsOf: input.referenceImages)
        return try core.makeRequest(prompt: prompt, images: images)
    }
}
#endif
