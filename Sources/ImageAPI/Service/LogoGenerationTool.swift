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

    public static func buildPrompt(from input: LogoGenerationInput) throws -> String {
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
        var prompt = """
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
Ne w T ool Ex t ension:
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
RefStyleImage optional (but if present must be a valid image)
Hidden Prompt Builder (Use Your Existing Prompt 
Template)
Build the hidden prompt exactly like you wrote, but inject:
Name}
Slogan} (or empty string / “(none)ˮ)
UserEnteredPrompt}  UserDescription
Ne w T ool Ex t ension:
2
Category}
BrandColor}
RefStyleImage} = “use style inspired by the reference imageˮ (only 
include this section if image exists)
Example User Input → Hidden Prompt
User input:
Name: Apple
Slogan: nil
UserDescription: “Create iPhone company logo, bitten appleˮ
BrandColor: White
Category: Computer and IT
RefStyleImage: present
Hidden prompt generated:
Uses your full logo prompt with the fields filled.
Output Expectation (QA checks)
Flat / minimal / modern
Icon + text OR text-only
No mockups, no scenes, no watermark
Clear at small sizes
Center aligned
Transparent/plain background
2) New Tool Extension: Generic 
GenAIPreset Tool
Ne w T ool Ex t ension:
3
Purpose
Run a ready-made prompt preset (copy-paste prompt) where:
The preset prompt is fixed
User uploads his image
Optional: user can add a small extra line (like “keep it realisticˮ) but base is 
preset
Think of it as:
Preset Prompt  User Image (+ optional tweak)
Inputs
Required
UserImage
PresetPrompt (selected from your preset library)
Optional
UserExtraDescription (small tweak)
Secondary images (optional, only if that preset needs it)
Input Mapping to Core Tool
Primary image = userImage
Secondary images = optional (depends on preset)
User description  PresetPrompt + "\n"  UserExtraDescription
Validation Rules
Fail if userImage missing
Fail if PresetPrompt missing/empty
If preset requires ref images (like hairstyle), validate those counts
Ne w T ool Ex t ension:
4
Prompt Builder Rule
No complex generation logic here.
Prompt builder just returns:
PresetPrompt (and appends user extra description if provided)
Example
Preset: “Turn this selfie into a professional LinkedIn headshot…ˮ
UserImage: selfie.jpg
UserExtraDescription: “Keep background slightly blurred officeˮ
 Hidden prompt becomes preset + extra line.
3) How These Fit Your “Core Tool 
Inheritanceˮ Model
What stays identical (Core)
Upload pipeline
Job creation API
Socket progress tracking
Completion handling URL
Error handling
Premium gating
What changes per extension
Input form fields
Validation rules
Prompt builder string creation
Whether it needs reference image(s)
Ne w T ool Ex t ension:
5
4) Quick One-Line Examples (for  testing)
A) Logo Tool
Inputs: Name  Category  BrandColor  Description + (style image)
Output: flat logo PNG
B) Preset Tool
Inputs: user image + preset prompt
Output: edited/generated image as per preset
If you want, I can convert the above into a Cursor-friendly checklist (“create tool 
config, add UI form, add validation, stub prompt builder, add examplesˮ), matching 
your existing naming conventions.
Ne w T ool Ex t ension:
6
"""
        prompt += """
Filled Inputs:
Name: \(input.name)
Slogan: \(input.slogan ?? "None")
UserDescription: \(input.userDescription)
BrandColor: \(input.brandColor)
Category: \(input.category)
StyleReference: provided
"""
        return prompt
    }

    public func makeRequest(input: LogoGenerationInput) throws -> ImageJobRequest {
        let prompt = try Self.buildPrompt(from: input)
        return try core.makeRequest(prompt: prompt, image: input.styleReference)
    }
}
#endif
