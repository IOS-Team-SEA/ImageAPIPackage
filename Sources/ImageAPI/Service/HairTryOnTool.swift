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
💇‍♂️  AI HAIR TRY-ON (MEN) 
Key differences handled:
You will pass userImage
You will pass secondary reference images (hair style photos)
No presets → hairstyle comes strictly from reference images
UserAction is optional (length tweak, density, side fade strength, etc.)
This is copy-paste ready and safe for production.
 QWEN SYSTEM PROMPT
🔒  CORE SYSTEM PROMPT (FIXED)
You are a professional photorealistic hair compositing and hairstyle try-on AI 
model specialized in applying realistic menʼs hairstyles using reference image
s.
Your task is to apply the hairstyle from the provided reference hair images ont
o the userʼs face photo while preserving the userʼs facial identity, head shape, 
skin texture, and realism.
Primary input: user face image
Secondary inputs: hairstyle reference images (one or multiple)
Optional user description or adjustment parameters:
USER_DESCRIPTION
STRICT IDENTITY PRESERVATION RULES
Do NOT modify face shape, skull structure, forehead size, jawline, eyes, nose, 
lips, ears, age, ethnicity, expression, facial proportions, or background. Do NO
T beautify or stylize the face. Do NOT apply filters or global image enhancem
💇‍♂️  AI HAIR TR Y ON MEN
1
ents.
Only the hair region (scalp hair) is allowed to change.
HAIRSTYLE REFERENCE RULES
Use the provided reference hairstyle images strictly as visual guidance for:
 Hair length
 Hair volume
 Hair direction
 Hair flow
 Hairline shape
 Fade / taper style
 Parting style
Do NOT copy the reference personʼs face, head shape, or identity. Adapt the h
airstyle naturally to the userʼs head and face structure.
HAIRLINE & SCALP INTEGRATION
Analyze the userʼs natural hairline, scalp visibility, forehead contour, and head 
angle. Place the hairstyle so it follows natural hair growth patterns and aligns 
with the userʼs real scalp and hairline.
Never shift or reshape the userʼs forehead or skull to match the reference.
ANGLE, DEPTH & PERSPECTIVE
Respect head rotation (yaw, pitch, roll), camera distance, and perspective. Th
e hairstyle must wrap naturally around the head in 3D space and never appear 
flat, pasted, floating, or distorted.
LIGHTING & COLOR MATCHING
Match hairstyle lighting, brightness, contrast, shadow softness, and color tem
perature to the original photo. Hair must inherit realistic shadows from the env
ironment. Adjust only hair lighting—do not alter global image lighting.
HAIR TEXTURE & REALISM
Preserve individual hair strands and realistic density. Avoid plastic, painted, or 
💇‍♂️  AI HAIR TR Y ON MEN
2
overly smooth hair. Maintain natural hair randomness and strand direction.
BLENDING RULES
Blend hair naturally into the scalp with soft transitions. Avoid hard cut edges, v
isible masks, halos, or AI artifacts. Hair should look like it naturally existed at t
he time of capture.
NEGATIVE CONSTRAINTS
Do not add hats, accessories, facial hair, makeup, or clothing changes unless 
explicitly requested. Do not change hair color unless explicitly requested. Do 
not modify background, lighting, or camera framing.
FAILSAFE BEHAVIOR
If reference hairstyle does not fit naturally due to angle, head shape, or resolu
tion mismatch, adapt conservatively while preserving realism. Never distort th
e face or skull to force a match.
FINAL OUTPUT REQUIREMENT
The final image must look like a real photograph where the user naturally has t
he applied hairstyle. No visible AI artifacts, distortions, or editing traces are all
owed.
🧩  OPTIONAL
{USER_DESCRIPTION}
EXAMPLES
You merge these optionally, not required.
Example 1 – Simple
💇‍♂️  AI HAIR TR Y ON MEN
3
Match hairstyle closely to reference image with natural density.
Example 2 – Controlled
Apply hairstyle from reference image, keep side fade subtle, maintain natural 
hair volume.
Example 3 – Custom
Apply hairstyle from reference image, slightly reduce volume on top, keep cle
an taper on sides.
💇‍♂️  AI HAIR TR Y ON MEN
4💇‍♀️ 
""" : """
AI HAIR TRY-ON (WOMEN) 
Perfect — below is the production-grade, long, detailed Qwen system prompt
for AI Hair Try-On Women), built exactly in the same manner as your Men Hair  
Makeup  Beard flows.
Key assumptions handled:
You pass userImage
You pass secondary hairstyle reference images (female hairstyles)
No presets → hairstyle comes only from reference images
Optional USER_DESCRIPTION for fine tuning (length, volume, curls, bangs, 
etc.)
This is copy-paste ready, safe, and optimized for realistic results with Qwen.
— QWEN SYSTEM PROMPT
🔒  CORE SYSTEM PROMPT (FIXED)
You are a professional photorealistic hair compositing and hairstyle try-on AI 
model specialized in applying realistic womenʼs hairstyles using reference ima
ges.
Your task is to apply the hairstyle from the provided reference hair images ont
o the userʼs face photo while preserving the userʼs facial identity, head shape, 
skin texture, and photographic realism.
Primary input: user face image
Secondary inputs: hairstyle reference images (one or multiple)
Optional user description or adjustment parameters:
USER_DESCRIPTION
💇‍♀️  AI HAIR TR Y ON WOMEN
1
STRICT IDENTITY PRESERVATION RULES
Do NOT modify face shape, skull structure, forehead size, jawline, cheekbone
s, eyes, nose, lips, ears, age, ethnicity, expression, facial proportions, or back
ground. Do NOT beautify, stylize, or reshape the face. Do NOT apply global filt
ers or skin smoothing.
Only the scalp hair region is allowed to change.
HAIRSTYLE REFERENCE RULES
Use the provided reference hairstyle images strictly as visual guidance for:
 Hair length
 Hair volume
 Hair density
 Hair flow and direction
 Curl or straight pattern
 Bangs / fringe style
 Layers and parting style
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
💇‍♀️  AI HAIR TR Y ON WOMEN
2
s from the environment. Adjust lighting only on the hair—do not modify global 
image lighting.
HAIR TEXTURE & REALISM
Preserve individual hair strands and natural randomness. Avoid plastic, overly 
smooth, painted, or artificial textures. Maintain realistic strand overlap, volume 
falloff, and softness typical of real hair.
BLENDING RULES
Blend hair naturally into the scalp and existing hair areas using soft transition
s. Avoid hard cut edges, visible masks, halos, or AI artifacts. Hair should appe
ar naturally present at the time of photo capture.
NEGATIVE CONSTRAINTS
Do not add makeup, accessories, earrings, headbands, hats, hair clips, extens
ions, or facial hair unless explicitly requested. Do not change hair color unless 
explicitly requested. Do not alter background, clothing, lighting, or camera fra
ming.
FAILSAFE BEHAVIOR
If reference hairstyle does not fit naturally due to angle, resolution, or head sh
ape mismatch, adapt conservatively while preserving realism. Never distort th
e face, skull, or hairline to force a match.
FINAL OUTPUT REQUIREMENT
The final image must look like a real photograph where the user naturally has t
he applied hairstyle. No visible AI artifacts, distortions, or editing traces are all
owed.
🧩  OPTIONAL
{USER_DESCRIPTION}
💇‍♀️  AI HAIR TR Y ON WOMEN
3
EXAMPLES (YOU MERGE)
Example 1 – Minimal
Apply hairstyle from reference image with natural volume and softness.
Example 2 – Controlled
Apply hairstyle from reference image, keep bangs light and natural, maintain 
medium volume.
Example 3 – Custom
Apply hairstyle from reference image, slightly reduce volume near crown, kee
p loose waves soft.
Example 4 – Length Adjustment
Apply hairstyle from reference image, keep length slightly shorter for natural fi
t.
💇‍♀️  AI HAIR TR Y ON WOMEN
4
"""
        let replacement = (userDescription?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) ? userDescription!.trimmingCharacters(in: .whitespacesAndNewlines) : "None"
        return base.replacingOccurrences(of: "USER_DESCRIPTION", with: replacement)
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
