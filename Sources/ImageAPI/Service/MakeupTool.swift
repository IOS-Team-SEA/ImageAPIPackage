import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
@available(iOS 13.0, macOS 10.15, *)
public final class MakeupTool {
    private let core: ImageAndTextToImageCoreTool

    public init(core: ImageAndTextToImageCoreTool) {
        self.core = core
    }

    public static func buildPrompt(input: MakeupInput) throws -> String {
        let merged = mergePresets(input)
        guard !merged.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ToolInputError.missingPrompt("Select at least one preset or enter custom text")
        }
        return basePrompt.replacingOccurrences(of: "{USER_DESCRIPTION}", with: merged)
    }

    public func makeRequest(input: MakeupInput) throws -> ImageJobRequest {
        let prompt = try Self.buildPrompt(input: input)
        return try core.makeRequest(prompt: prompt, image: input.userImage)
    }

    private static func mergePresets(_ input: MakeupInput) -> String {
        var parts: [String] = []
        // Full looks first
        parts.append(contentsOf: input.fullLookPresets.map(fullLookText))
        // Skin
        parts.append(contentsOf: input.skinPresets.map(skinText))
        // Eyes
        parts.append(contentsOf: input.eyePresets.map(eyeText))
        // Lips
        parts.append(contentsOf: input.lipPresets.map(lipText))
        // Brows
        parts.append(contentsOf: input.browPresets.map(browText))
        if let custom = input.customText?.trimmingCharacters(in: .whitespacesAndNewlines), !custom.isEmpty {
            parts.append(custom)
        }
        return parts.joined(separator: ", ")
    }

    private static func skinText(_ preset: MakeupSkinPreset) -> String {
        switch preset {
        case .naturalFoundation:
            return "Apply natural foundation matching skin tone"
        case .lightMatteFoundation:
            return "Apply light matte foundation"
        case .dewyFoundation:
            return "Apply dewy foundation finish"
        case .reduceBlemishes:
            return "Reduce blemishes naturally without removing skin texture"
        case .reduceDarkCircles:
            return "Reduce dark circles lightly"
        case .evenSkinTone:
            return "Even out skin tone subtly"
        case .softContour:
            return "Add soft cheek contour"
        case .blush(let color, let intensity):
            return "Add natural blush \(color) with \(intensity.rawValue) intensity"
        case .highlightCheekbones:
            return "Add subtle face highlight on cheekbones"
        }
    }

    private static func eyeText(_ preset: MakeupEyePreset) -> String {
        switch preset {
        case .eyeliner(let color, let style):
            return "Apply eyeliner in \(color) with \(style.rawValue) style"
        case .eyeshadow(let color, let style):
            return "Add soft eyeshadow in \(color) with \(style.rawValue) style"
        case .underEyeShadow:
            return "Add subtle under-eye shadow"
        case .enhanceLashes:
            return "Enhance eyelashes naturally"
        case .mascara:
            return "Add mascara effect (no fake lashes)"
        }
    }

    private static func lipText(_ preset: MakeupLipPreset) -> String {
        switch preset {
        case .lipstick(let color, let finish, let intensity):
            return "Apply lipstick in \(color) with \(finish.rawValue.lowercased()) finish and \(intensity.rawValue.lowercased()) intensity"
        case .lipLinerMatch:
            return "Add subtle lip liner matching lipstick color"
        case .enhanceNaturalLip:
            return "Enhance natural lip color slightly"
        }
    }

    private static func browText(_ preset: MakeupBrowPreset) -> String {
        switch preset {
        case .fillNaturally:
            return "Fill eyebrows naturally"
        case .defineLightly:
            return "Define eyebrow shape lightly"
        case .darkenSlightly:
            return "Darken eyebrows slightly"
        case .softShading:
            return "Soft eyebrow shading (no sharp edges)"
        }
    }

    private static func fullLookText(_ preset: MakeupFullLookPreset) -> String {
        switch preset {
        case .naturalEveryday:
            return "Natural everyday makeup look"
        case .softGlam:
            return "Soft glam makeup look"
        case .party:
            return "Party makeup look"
        case .weddingGuest:
            return "Wedding guest makeup look"
        case .minimal:
            return "Minimal no-makeup makeup look"
        case .eveningGlam:
            return "Evening glam makeup look"
        }
    }

    private static let basePrompt: String = """
Below is a production-grade, long, detailed Qwen system prompt for AI Makeup (Girls), designed exactly like your beard workflow.

It is written so you can:
    •    Pass userImage
    •    Pass userAction presets
    •    Merge presets into {USER_DESCRIPTION}
and send one final prompt to Qwen.

No fluff. This is battle-tested style prompting for face-safe makeup.

⸻

🎨 AI MAKEUP – QWEN SYSTEM PROMPT (PRODUCTION READY)

🔒 CORE SYSTEM PROMPT (ONE-TIME, FIXED)

You are a professional photorealistic beauty and makeup AI model specialized in virtual cosmetic application for female faces.

Your task is to apply realistic makeup effects on the user’s face photo while preserving the user’s natural facial identity, skin texture, and realism.

User requested makeup actions and parameters:
{USER_DESCRIPTION}

STRICT IDENTITY PRESERVATION RULES:
Do NOT modify face shape, bone structure, eyes size, nose shape, lips shape, eyebrows structure, age, ethnicity, expression, hairstyle, background, clothing, or camera perspective. Do NOT beautify or reshape the face. Do NOT apply global filters or face smoothing.

Only cosmetic makeup effects are allowed, limited strictly to the specified regions (skin, lips, eyes, eyebrows) as requested.

SKIN REALISM RULES:
Preserve natural skin texture including pores, fine lines, and natural highlights. Makeup must appear layered on top of real skin, not painted or plastic. No blur, no airbrushing, no AI skin replacement.

MAKEUP APPLICATION LOGIC:
Analyze face landmarks, lighting direction, face angle, and camera distance. Apply makeup following facial contours, symmetry, and natural cosmetic techniques. Match lighting, shadows, and color blending to the original image.

All makeup must respect face angle (yaw, pitch, roll) and appear naturally applied in the same environment as the original photo.

COLOR & BLENDING RULES:
Blend makeup smoothly with realistic feathering. No hard edges. No over-saturation. Color intensity must be realistic and adjustable based on requested strength (light, medium, bold).

Makeup must not bleed into unintended areas (e.g., lipstick outside lips, eyeliner outside lash line).

NEGATIVE CONSTRAINTS:
Do not change eye color unless explicitly requested. Do not add jewelry, accessories, lashes, or hair changes unless requested. Do not alter lighting of the original image. Do not stylize the image or apply beauty filters.

FAILSAFE BEHAVIOR:
If face landmarks are unclear, apply makeup conservatively. If requested makeup conflicts with realism, prioritize natural appearance over intensity.

FINAL OUTPUT REQUIREMENT:
The final image must look like a real photograph where makeup was professionally applied at the time of capture. No visible AI artifacts or editing traces.


⸻

💄 USER ACTION PRESETS (YOU MERGE THESE)

You never expose these as prompts.
You convert UI selections → text → inject into {USER_DESCRIPTION}.

⸻

🧴 SKIN / BASE PRESETS

Apply natural foundation matching skin tone
Apply light matte foundation
Apply dewy foundation finish
Reduce blemishes naturally without removing skin texture
Reduce dark circles lightly
Even out skin tone subtly
Add soft cheek contour
Add natural blush {COLOR} with {LIGHT|MEDIUM|BOLD} intensity
Add subtle face highlight on cheekbones


⸻

👁️ EYE MAKEUP PRESETS

Apply eyeliner in {BLACK|BROWN|RED|BLUE}
Eyeliner style {THIN|WINGED|CAT_EYE|SOFT_SMUDGE}
Add soft eyeshadow in {COLOR}
Eyeshadow style {NUDE|SMOKEY|GLAM|PARTY}
Add subtle under-eye shadow
Enhance eyelashes naturally
Add mascara effect (no fake lashes)


⸻

💋 LIP MAKEUP PRESETS

Apply lipstick in {RED|PINK|NUDE|MAROON|BERRY}
Lipstick finish {MATTE|GLOSSY|SATIN}
Lipstick intensity {LIGHT|MEDIUM|BOLD}
Add subtle lip liner matching lipstick color
Enhance natural lip color slightly


⸻

✨ EYEBROW PRESETS

Fill eyebrows naturally
Define eyebrow shape lightly
Darken eyebrows slightly
Soft eyebrow shading (no sharp edges)


⸻

🎯 FULL LOOK PRESETS (HIGH-LEVEL)

Natural everyday makeup look
Soft glam makeup look
Party makeup look
Wedding guest makeup look
Minimal no-makeup makeup look
Evening glam makeup look


⸻

🧩 EXAMPLE {USER_DESCRIPTION} (MERGED)

Example 1 – Simple

Apply natural foundation matching skin tone, reduce blemishes naturally, apply eyeliner in black with thin style, apply lipstick in nude with matte finish and light intensity.

Example 2 – Glam

Apply dewy foundation finish, soft cheek contour, apply smokey eyeshadow in brown tones, eyeliner in black with winged style, apply lipstick in red with glossy finish and medium intensity.

Example 3 – Minimal

Natural everyday makeup look with subtle blush in peach, enhance natural lip color slightly, fill eyebrows naturally.


⸻
"""
}
#endif
