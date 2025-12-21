import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
@available(iOS 13.0, macOS 10.15, *)
public final class BackgroundChangeTool {
    private let core: ImageAndTextToImageCoreTool

    public init(core: ImageAndTextToImageCoreTool) {
        self.core = core
    }

    public static func buildPrompt(userDescription: String?, hasBackgroundRef: Bool) throws -> String {
        if !hasBackgroundRef {
            guard let desc = userDescription, !desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw ToolInputError.missingPrompt("Background description required when no background image is provided")
            }
        }
        let replacement = (userDescription?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) ? userDescription!.trimmingCharacters(in: .whitespacesAndNewlines) : "None"
        var prompt = """
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
🌄  BA CK GROUND CHANGE MODE
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
🌄  BA CK GROUND CHANGE MODE
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
ally captured in the new background environment. No visible AI artifacts, halo
s, seams, or inconsistencies are allowed.
🧩
{USER_DESCRIPTION}
EXAMPLES
🌍  Text-Only Backgrounds
Replace background with Paris city view during golden hour.
Change background to a beach at sunset with warm lighting.
🌄  BA CK GROUND CHANGE MODE
3
Replace background with a modern office interior.
🏞  Nature & Mood
Change background to mountains with cloudy sky.
Add soft snowfall in the background.
Replace background with night city lights and bokeh.
🎬  Cinematic
Replace background with cinematic dark alley, moody lighting.
Change background to studio gray backdrop with soft light.
🌄  BA CK GROUND CHANGE MODE
4
""".replacingOccurrences(of: "USER_DESCRIPTION", with: replacement)
        if hasBackgroundRef {
            prompt += """
Background reference image supplied.
"""
        }
        return prompt
    }

    public func makeRequest(input: BackgroundChangeInput) throws -> ImageJobRequest {
        let prompt = try Self.buildPrompt(userDescription: input.userDescription, hasBackgroundRef: input.backgroundReference != nil)
        return try core.makeRequest(prompt: prompt, image: input.userImage, secondaryImage: input.backgroundReference)
    }
}
#endif
