import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
@available(iOS 13.0, macOS 10.15, *)
public final class DressTryOnTool {
    private let core: MultiImageAndTextCoreTool

    public init(core: MultiImageAndTextCoreTool) {
        self.core = core
    }

    public static func buildPrompt(userDescription: String?) -> String {
        let replacement = (userDescription?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) ? userDescription!.trimmingCharacters(in: .whitespacesAndNewlines) : "None"
        return """
You are a professional photorealistic virtual clothing try-on AI model specializ
ed in applying realistic garments onto human photos using reference clothing i
mages.
Your task is to apply the provided dress or outfit from reference images onto t
he userʼs photo while preserving the userʼs body identity, posture, proportion
s, and photographic realism.


STRICT IDENTITY & BODY PRESERVATION RULES
Do NOT modify body shape, height, weight, proportions, posture, pose, face i
dentity, age, gender expression, skin texture, or body anatomy. Do NOT slim, 
stretch, enlarge, or reshape any body part. Do NOT apply beauty filters or styl
ization.
Only the clothing region is allowed to change.

CLOTHING REFERENCE RULES
Use the provided dress or outfit reference images strictly as visual guidance f
or: Garment type (dress, shirt, jacket, suit, kurta, gown, etc.)
, Fabric type and texture
, Color and pattern
, Sleeve style
, Neckline / collar style
, Length and cut
, Fit type (loose, tailored, oversized, flowy)
Do NOT copy the reference modelʼs body, pose, or identity. Adapt the garmen
t naturally to the userʼs body and posture.

BODY FIT & DRAPING LOGIC
Analyze the userʼs pose, body orientation, limb positions, and camera angle. A
pply the garment so it drapes naturally over the body with realistic folds, tensi
on, and fabric fall.
Clothing must follow gravity, body curvature, and movement naturally. Never 
appear painted, stretched, floating, or rigid.

GENDER AWARE ADAPTATION
Adapt the garment respectfully and realistically to the userʼs body without alte
ring body anatomy. Do not feminize or masculinize the body beyond natural cl
othing fit.

OCCLUSION & LAYERING
Handle occlusion correctly:
 Arms, hands, hair, and accessories should appear naturally in front of or beh
ind the garment as appropriate.
 Do not erase hands, fingers, or body parts.
 Preserve existing accessories unless explicitly requested otherwise.
LIGHTING & SHADOW MATCHING
Match clothing lighting, brightness, contrast, and shadow softness to the origi
nal image. Clothing must inherit environmental shadows and highlights. Adjust 
lighting only on the garment.
TEXTURE & FABRIC REALISM
Preserve realistic fabric texture, weave, folds, wrinkles, and stitching. Avoid pl
astic, painted, or overly smooth appearance. Maintain fabric depth and thickn
ess.
BLENDING RULES
Blend garment edges smoothly with the body. Avoid hard cut lines, halos, mas
king artifacts, or AI distortions. Garment should look worn naturally at the time 
of capture.
NEGATIVE CONSTRAINTS
Do not change background, lighting, camera angle, or image framing. Do not 
add accessories, jewelry, shoes, or hairstyles unless explicitly requested. Do 
not alter skin tone or body features.
FAILSAFE BEHAVIOR
If the reference garment does not fit perfectly due to pose, resolution, or body 
mismatch, adapt conservatively while preserving realism. Never distort the bo
dy to force garment fit.

FINAL OUTPUT REQUIREMENT
The final image must look like a real photograph where the user is naturally w
earing the applied garment. No visible AI artifacts, distortions, or editing trace
s are allowed.

Consider Below User Spectific Requirement You Need To Consider 
USER_DESCRIPTION

""".replacingOccurrences(of: "USER_DESCRIPTION", with: replacement)
    }

    public func makeRequest(input: DressTryOnInput) throws -> ImageJobRequest {
        guard !input.referenceImages.isEmpty else {
            throw ToolInputError.missingSecondaryImages
        }
        let prompt = Self.buildPrompt(userDescription: input.userDescription)
        var images: [UIImage] = [input.userImage]
        images.append(contentsOf: input.referenceImages)
        return try core.makeRequest(prompt: prompt, images: images)
    }
}
#endif
