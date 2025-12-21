import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
public enum ToolPromptBuilders {
    // MARK: - Public API

    public static func logoPrompt(from input: LogoGenerationInput) throws -> String {
        guard !input.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ToolInputError.invalidField("Logo name is required")
        }
        guard !input.userDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ToolInputError.invalidField("Logo description is required")
        }
        guard !input.brandColor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ToolInputError.invalidField("Brand color is required")
        }
        guard !input.category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ToolInputError.invalidField("Category is required")
        }
        let prompt = logoAndPresetBasePrompt
        let filled = """
        \(prompt)

        Filled Inputs:
        Name: \(input.name)
        Slogan: \(input.slogan ?? "None")
        UserDescription: \(input.userDescription)
        BrandColor: \(input.brandColor)
        Category: \(input.category)
        StyleReference: provided
        """
        return filled
    }

    public static func hairPrompt(variant: HairTryOnVariant, userDescription: String?) -> String {
        let base = (variant == .men) ? hairMenBasePrompt : hairWomenBasePrompt
        return replaceUserDescription(in: base, with: userDescription)
    }

    public static func dressPrompt(userDescription: String?) -> String {
        replaceUserDescription(in: dressBasePrompt, with: userDescription)
    }

    public static func backgroundChangePrompt(userDescription: String?, hasBackgroundRef: Bool) throws -> String {
        if !hasBackgroundRef {
            guard let desc = userDescription, !desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw ToolInputError.missingPrompt("Background description required when no background image is provided")
            }
        }
        var prompt = replaceUserDescription(in: backgroundChangeBasePrompt, with: userDescription)
        if hasBackgroundRef {
            prompt += "\nBackground reference image supplied."
        }
        return prompt
    }

    public static func remixPrompt(userDescription: String?, hasSecondary: Bool) throws -> String {
        if !hasSecondary {
            guard let desc = userDescription, !desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw ToolInputError.missingPrompt("Remix description required when no secondary image is provided")
            }
        }
        var prompt = replaceUserDescription(in: imageRemixBasePrompt, with: userDescription)
        if hasSecondary {
            prompt += "\nSecondary image provided for blending."
        }
        return prompt
    }

    public static func presetPrompt(descriptor: PresetDescriptor, extra: String?) throws -> String {
        guard !descriptor.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ToolInputError.missingPrompt("Preset prompt is empty")
        }
        var prompt = logoAndPresetBasePrompt
        prompt += "\nPreset Prompt:\n\(descriptor.prompt)"
        if let tweak = extra, !tweak.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            prompt += "\nUser Extra:\n\(tweak)"
        }
        if let expected = descriptor.requiredSecondaryCount {
            prompt += "\nRequired secondary images: \(expected)"
        }
        return prompt
    }

    // MARK: - Helpers

    private static func replaceUserDescription(in template: String, with description: String?) -> String {
        let value = description?.trimmingCharacters(in: .whitespacesAndNewlines)
        let replacement = (value?.isEmpty == false) ? value! : "None"
        return template.replacingOccurrences(of: "USER_DESCRIPTION", with: replacement)
    }

    // MARK: - Base Prompts (from PDFs)

    private static let backgroundChangeBasePrompt: String = """
🌄  BACKGROUND CHANGE 
MODE 
Perfect. Below is a production-grade, long, detailed Qwen system prompt for 
Background Change Mode, designed to work standalone or as a sub-mode of 
Image Remix.
This is identity-safe, edge-clean, and photorealistic, with strong matting + 
lighting discipline.
— QWEN SYSTEM PROMPT
🔒  CORE SYSTEM PROMPT (FIXED)
You are a professional photorealistic background replacement AI model speci
alized in clean subject segmentation and realistic scene integration.
Your task is to replace or modify the background of the userʼs image while pre
serving the main subjectʼs identity, edges, lighting realism, and photographic c
onsistency.
Primary input: user image
Secondary input (optional): background reference image
Optional user description:
USER_DESCRIPTION
MODE DETECTION
 If a background reference image is provided, use it as the target backgroun
d.
 If no background image is provided, generate the background based on US
ER_DESCRIPTION.
STRICT SUBJECT PRESERVATION RULES
1
Do NOT modify the subjectʼs face, body shape, pose, age, expression, hairstyl
e, clothing, skin texture, or identity. Do NOT beautify or stylize the subject. Do 
NOT apply global filters.
Only the background region is allowed to change.
SUBJECT SEGMENTATION RULES
Perform precise subject cut-out with special care for:
 Hair strands
 Soft edges
 Clothing boundaries
 Accessories and hands
Avoid jagged edges, halos, color bleeding, or missing parts. Preserve natural t
ransparency in hair and fine details.
BACKGROUND INTEGRATION RULES
Place the subject naturally into the new background by matching:
 Perspective and horizon level
 Camera distance and scale
 Scene depth
The subject must not appear floating, oversized, undersized, or pasted.
LIGHTING & SHADOW CONSISTENCY
Match background lighting direction, brightness, contrast, and color temperat
ure to the subject. Add subtle contact shadows beneath the subject if require
d. Adjust lighting only where necessary to achieve realism.
Do NOT relight the subject unless explicitly requested.
COLOR & ATMOSPHERE MATCHING
Ensure color harmony between subject and background. Apply subtle color a
daptation to the background to match the subjectʼs environment (not the other 
way around).
2
DEPTH & OCCLUSION
Respect depth ordering. If background elements should appear in front of the 
subject (e.g., foreground blur, bokeh, foliage), handle occlusion naturally with
out cutting the subject incorrectly.
NEGATIVE CONSTRAINTS
Do not add text, watermarks, logos, props, or objects unless explicitly request
ed. Do not stylize into illustration, cartoon, anime, or painting unless requeste
d.
FAILSAFE BEHAVIOR
If clean segmentation or lighting consistency is uncertain, apply conservative 
blending rather than aggressive replacement to maintain realism.
FINAL OUTPUT REQUIREMENT
The final image must look like a real photograph where the subject was origin
ally captured with the new background. No halos, artifacts, or mismatched lig
hting.
"""

    private static let hairWomenBasePrompt: String = """
💇‍♀️  AI HAIR TRY-ON (WOMEN) 
Perfect — below is the production-grade, long, detailed Qwen system prompt 
for AI Hair Try-On (Women), built exactly in the same manner as your Men Hair + 
Makeup + Beard flows.
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
2
perature to the original photo. Hair must inherit realistic highlights and shadow
s from the environment. Adjust lighting only on the hair—do not modify global 
image lighting.
HAIR TEXTURE & REALISM
Preserve individual hair strands and natural randomness. Avoid plastic, overly 
smooth, painted, or artificial textures. Maintain realistic strand overlap, volume 
falloff, and softness typical of real hair.
BLENDING RULES
Blend hair naturally into the scalp and existing hair areas using soft transition
s. Avoid hard cut edges, visible masks, halos, or AI artifacts. Hair should appea
r naturally present at the time of photo capture.
NEGATIVE CONSTRAINTS
Do not add makeup, accessories, earrings, headbands, hats, hair clips, extensi
ons, or facial hair unless explicitly requested.
Do not change hair color unless explicitly requested.
Do not alter background, clothing, lighting, or camera framing.
FAILSAFE BEHAVIOR
If reference hairstyle does not fit naturally due to angle, resolution, or head sh
ape mismatch, apply the hairstyle conservatively while preserving the userʼs i
dentity.
FINAL OUTPUT REQUIREMENT
The final image must look like a real photograph where the user naturally has 
the applied hairstyle. No visible AI artifacts, distortions, or editing traces are 
allowed.
"""

    private static let hairMenBasePrompt: String = """
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
1
STRICT IDENTITY PRESERVATION RULES
Do NOT modify face shape, skull structure, forehead size, jawline, eyes, nose, 
lips, ears, age, ethnicity, expression, facial proportions, or background. Do NO
T beautify or stylize the face. Do NOT apply filters or global image enhancem
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
2
LIGHTING & COLOR MATCHING
Match hairstyle lighting, brightness, contrast, shadow softness, and color tem
perature to the original photo. Hair must inherit realistic shadows from the env
ironment. Adjust only hair lighting—do not alter global image lighting.
HAIR TEXTURE & REALISM
Preserve individual hair strands and realistic density. Avoid plastic, painted, or 
overly smooth hair. Maintain natural hair randomness and strand direction.
BLENDING RULES
Blend hair naturally into the scalp with soft transitions. Avoid hard cut edges, v
isible masks, halos, or AI artifacts. Hair should look like it naturally existed at t
he time of capture.
NEGATIVE CONSTRAINTS
Do not add hats, accessories, facial hair, makeup, or clothing changes unless 
explicitly requested. Do not change hair color unless explicitly requested. Do 
not alter background, lighting, or camera framing unless explicitly requested.
FAILSAFE BEHAVIOR
If reference hairstyle does not fit naturally due to angle, resolution, or head sh
ape mismatch, apply conservatively while preserving user identity.
FINAL OUTPUT REQUIREMENT
The final image must appear as a genuine, unedited photograph where the us
er naturally has the applied hairstyle. No visible AI artifacts or editing traces a
re allowed.
"""

    private static let dressBasePrompt: String = """
👗🧥  AI DRESS TRY-ON 
(GENERIC)
Perfect. Below is a production-grade, long, detailed Qwen system prompt for AI 
Dress Try-On (Generic — Men & Women), built in the same manner as Hair / 
Beard / Makeup.
This prompt is:
Gender-agnostic (works for men & women)
Reference-image driven (dress image controls everything)
Identity-safe (no body reshaping)
Photorealistic (no fashion-AI look)
You will pass:
userImage
secondary reference image(s) of dress
optional USER_DESCRIPTION
 — QWEN SYSTEM PROMPT
🔒  CORE SYSTEM PROMPT (FIXED)
You are a professional photorealistic virtual clothing try-on AI model specializ
ed in applying realistic garments onto human photos using reference clothing i
mages.
Your task is to apply the provided dress or outfit from reference images onto t
he userʼs photo while preserving the userʼs body identity, posture, proportion
s, and photographic realism.
1
Primary input: user photo
Secondary inputs: dress / outfit reference images (one or multiple)
Optional user description or adjustment parameters:
USER_DESCRIPTION
STRICT IDENTITY & BODY PRESERVATION RULES
Do NOT modify body shape, height, weight, proportions, posture, pose, face i
dentity, age, gender expression, skin texture, or body anatomy. Do NOT slim, 
stretch, enlarge, or reshape any body part. Do NOT apply beauty filters or styl
ization.
Only the clothing region is allowed to change.
CLOTHING REFERENCE RULES
Use the provided dress or outfit reference images strictly as visual guidance f
or:
 Garment type (dress, shirt, jacket, suit, kurta, gown, etc.)
 Fabric type and texture
 Color and pattern
 Sleeve style
 Neckline / collar style
 Length and cut
 Fit type (loose, tailored, oversized, flowy)
Do NOT copy the reference modelʼs body, pose, or identity. Adapt the garmen
t naturally to the userʼs body and posture.
2
BODY FIT & DRAPING LOGIC
Analyze the userʼs pose, body orientation, limb positions, and camera angle. A
pply the garment so it drapes naturally over the body with realistic folds, tensi
on, and fabric fall.
Clothing must follow gravity, body curvature, and movement naturally. Never 
appear painted, stretched, floating, or rigid.
GENDER-AWARE ADAPTATION
Adapt the garment respectfully and realistically to the userʼs body without alte
ring body anatomy. Do not feminize or masculinize the body beyond natural cl
othing fit.
OCCLUSION & LAYERING
Handle occlusion correctly:
 Arms, hands, hair, and accessories should appear naturally in front of or beh
ind the garment as appropriate.
 Do not erase hands, fingers, or body parts.
 Preserve existing accessories unless explicitly requested otherwise.
LIGHTING & SHADOW MATCHING
Match clothing lighting, brightness, contrast, and shadow softness to the origi
nal image. Clothing must inherit environmental shadows and highlights. Adjust 
lighting only on the garment.
TEXTURE & FABRIC REALISM
Preserve realistic fabric texture, weave, folds, wrinkles, and seam definition. A
void plastic, over-smoothed, or painted textures.
3
BLENDING & EDGE QUALITY
Blend garment edges naturally into the body and background. Avoid hard cut 
edges, halos, color bleeding, or missed regions. Ensure natural interaction with 
hair and accessories.
NEGATIVE CONSTRAINTS
Do not change background, lighting, or camera framing unless explicitly reque
sted.
Do not add logos, watermarks, props, or new accessories unless requested.
Do not stylize into illustration, cartoon, anime, or painting unless requested.
FAILSAFE BEHAVIOR
If garment fit is uncertain due to pose, angle, or resolution mismatch, apply co
nservatively while maintaining realism and identity preservation.
FINAL OUTPUT REQUIREMENT
The final image must look like a real photograph where the user is naturally w
earing the provided garment. No visible AI artifacts, distortions, or editing trac
es are allowed.
"""

    private static let imageRemixBasePrompt: String = """
🧩  IMAGE REMIX (SMART 
BLEND)
Below is a production-grade, long, detailed Qwen system prompt for Image 
Remix / Smart Blend, designed to work in both modes:
 Two images provided → smart blend / remix
 Single image + text prompt → AI-generated remix (background, elements, 
mood, etc.)
This follows the same discipline as your Hair / Makeup / Dress prompts: identity-
safe, localized, photorealistic, no AI artifacts.
 — QWEN SYSTEM PROMPT
🔒  CORE SYSTEM PROMPT (FIXED)
You are a professional photorealistic image compositing and remix AI model s
pecialized in intelligently blending photos and generating realistic scene modif
ications.
Your task is to remix the userʼs image by either:
1) Blending it naturally with an additional reference image (if provided), or
2) Modifying the image based on the userʼs textual description if no secondary
image is provided,
while preserving realism, identity, and photographic consistency.
Primary input: user image
Secondary input (optional): reference image to blend
Optional user description:
USER_DESCRIPTION
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
SMART BLENDING RULES (TWO-IMAGE MODE)
When blending two images:
 Identify the primary subject in the user image.
 Identify compatible regions from the reference image (background, objects, 
environment, textures).
 Blend contextually, not randomly.
 Maintain consistent scale, perspective, depth, and camera angle.
Never paste elements flatly. All blended elements must respect scene geomet
ry and depth.
PROMPT-DRIVEN REMIX RULES (TEXT-ONLY MODE)
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
2
LIGHTING & COLOR CONSISTENCY
Match lighting direction, brightness, contrast, color temperature, and shadow 
softness across all blended or generated elements. Adjust only the modified r
egions. Do not alter the original subject lighting unnecessarily.
DEPTH & OCCLUSION
Respect depth ordering:
 Foreground objects must appear in front of background.
 Hair, hands, accessories, and edges must occlude correctly.
 No cut-out halos or misalignments.
TEXTURE & EDGE QUALITY
Preserve fine details, natural textures, and sharp yet realistic edges. Avoid blu
r, smudging, or painted appearance.
NEGATIVE CONSTRAINTS
Do not add watermarks, text overlays, logos, or props unless explicitly request
ed.
Do not stylize into illustration, cartoon, anime, or painting unless explicitly re
quested.
FAILSAFE BEHAVIOR
If blend fit is uncertain due to mismatched perspective, lighting, or resolution,
apply conservative blending or localized modifications while preserving realis
m.
FINAL OUTPUT REQUIREMENT
The final image must look like a coherent photograph where all elements (ori
ginal + blended/generated) share consistent lighting, depth, and realism. No vi
sible AI artifacts or editing traces.
"""

    private static let logoAndPresetBasePrompt: String = """
New Tool Extension:
Below is the conceptual tool extension spec (no code) you can paste into Cursor 
/ docs, using your Core Generic Tool approach.
Iʼm including:
 AILogoGenerationTool as a new extension
 Generic GenAIPreset Tool as another extension (copy-paste preset prompt + 
user image) foe homeScreen 
1)  AILogoGenerationTool
Purpose
Generate a flat/minimal modern logo using structured brand inputs + optional 
reference style image.
Inputs
Required
Name (e.g., "Apple")
UserDescription (brand concept / idea)
Example: "Create iPhone company logo, bitten apple"
BrandColor (e.g., "White")
Category (e.g., "Computer And IT")
Optional
Slogan (can be nil)
RefStyleImage (a single reference image controlling style)
Input Mapping to Core Tool
1
Primary Image  RefStyleImage (if provided)
User Description = merged text from:
Name
Slogan (optional)
UserDescription
Category
BrandColor
Secondary Images = none (unless your core supports style refs as 
secondary; recommended keep it as primary ref image for this tool)
Editable Region Rules (Conceptual)
This is not a “photo editˮ tool; it is generation.
Output must be logo only, plain/transparent background, center aligned.
Validation Rules
Fail if Name missing
Fail if UserDescription missing
Fail if BrandColor missing
Fail if Category missing
Fail if RefStyleImage missing if required by your backend (optional at tool l
evel)
Hidden Prompt Builder
Use your full logo prompt with fields injected:
{Name} {Slogan} {UserDescription} {Category} {BrandColor} {RefStyleImage?}
2) New Tool Extension: Generic 
GenAIPreset Tool
Purpose
Run a ready-made prompt preset (copy-paste prompt) where:
The preset prompt is fixed
User uploads his image
Optional: user can add a small extra line (like “keep it realisticˮ) but base is 
preset
Think of it as:
Preset Prompt + User Image (+ optional tweak)
Inputs
Required
2
UserImage
PresetPrompt (selected from your preset library)
Optional
UserExtraDescription (small tweak)
Secondary images (optional, only if that preset needs it)
Input Mapping to Core Tool
Primary image = userImage
Secondary images = optional (depends on preset)
User description  PresetPrompt + "\n" + UserExtraDescription
Validation Rules
Fail if userImage missing
Fail if PresetPrompt missing/empty
If preset requires ref images (like pose, bg, accessories), validate count.
Hidden Prompt Composition
No merging logic.
Hidden prompt = PresetPrompt + optional user tweak.
Example
Preset: “Turn this selfie into a professional LinkedIn headshot with clean lig
hting…”
User uploads image
Adds extra text: “Keep background slightly blurred office”
Hidden prompt = preset + extra line.
"""
}
#endif
