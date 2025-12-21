import Foundation
#if canImport(UIKit)
import UIKit




public enum ToolInputError: Error, Equatable {
    case missingPrimaryImage
    case missingSecondaryImages
    case missingPrompt(String)
    case invalidField(String)
    case secondaryCountMismatch(expected: Int, actual: Int)
}

public struct LogoGenerationInput {
    public let name: String
    public let slogan: String?
    public let userDescription: String
    public let brandColor: String
    public let category: String
    /// Style reference image is mandatory because backend requires at least one image.
    public let styleReference: UIImage

    public init(
        name: String,
        slogan: String? = nil,
        userDescription: String,
        brandColor: String,
        category: String,
        styleReference: UIImage
    ) {
        self.name = name
        self.slogan = slogan
        self.userDescription = userDescription
        self.brandColor = brandColor
        self.category = category
        self.styleReference = styleReference
    }
}

public enum HairTryOnVariant {
    case men
    case women
}

public struct HairTryOnInput {
    public let userImage: UIImage
    public let referenceImages: [UIImage]
    public let variant: HairTryOnVariant
    public let userDescription: String?

    public init(
        userImage: UIImage,
        referenceImages: [UIImage],
        variant: HairTryOnVariant,
        userDescription: String? = nil
    ) {
        self.userImage = userImage
        self.referenceImages = referenceImages
        self.variant = variant
        self.userDescription = userDescription
    }
}

public struct DressTryOnInput {
    public let userImage: UIImage
    public let referenceImages: [UIImage]
    public let userDescription: String?

    public init(
        userImage: UIImage,
        referenceImages: [UIImage],
        userDescription: String? = nil
    ) {
        self.userImage = userImage
        self.referenceImages = referenceImages
        self.userDescription = userDescription
    }
}

public struct BackgroundChangeInput {
    public let userImage: UIImage
    public let backgroundReference: UIImage?
    public let userDescription: String?

    public init(
        userImage: UIImage,
        backgroundReference: UIImage? = nil,
        userDescription: String? = nil
    ) {
        self.userImage = userImage
        self.backgroundReference = backgroundReference
        self.userDescription = userDescription
    }
}

public struct ImageRemixInput {
    public let userImage: UIImage
    public let secondaryImage: UIImage?
    public let userDescription: String?

    public init(
        userImage: UIImage,
        secondaryImage: UIImage? = nil,
        userDescription: String? = nil
    ) {
        self.userImage = userImage
        self.secondaryImage = secondaryImage
        self.userDescription = userDescription
    }
}

public struct PresetDescriptor: Equatable {
    public let id: String
    public let prompt: String
    /// If set, caller must supply exactly this many secondary images.
    public let requiredSecondaryCount: Int?

    public init(id: String, prompt: String, requiredSecondaryCount: Int? = nil) {
        self.id = id
        self.prompt = prompt
        self.requiredSecondaryCount = requiredSecondaryCount
    }
}

public struct PresetInput {
    public let userImage: UIImage
    public let secondaryImages: [UIImage]
    public let descriptor: PresetDescriptor
    public let userExtraDescription: String?

    public init(
        userImage: UIImage,
        secondaryImages: [UIImage] = [],
        descriptor: PresetDescriptor,
        userExtraDescription: String? = nil
    ) {
        self.userImage = userImage
        self.secondaryImages = secondaryImages
        self.descriptor = descriptor
        self.userExtraDescription = userExtraDescription
    }
}



// MARK: - Makeup input types

public enum MakeupIntensity: String {
    case light = "LIGHT"
    case medium = "MEDIUM"
    case bold = "BOLD"
}

public enum MakeupSkinPreset {
    case naturalFoundation
    case lightMatteFoundation
    case dewyFoundation
    case reduceBlemishes
    case reduceDarkCircles
    case evenSkinTone
    case softContour
    case blush(color: String, intensity: MakeupIntensity)
    case highlightCheekbones
}

public enum EyelinerStyle: String {
    case thin = "THIN"
    case winged = "WINGED"
    case catEye = "CAT_EYE"
    case softSmudge = "SOFT_SMUDGE"
}

public enum EyeshadowStyle: String {
    case nude = "NUDE"
    case smokey = "SMOKEY"
    case glam = "GLAM"
    case party = "PARTY"
}

public enum MakeupEyePreset {
    case eyeliner(color: String, style: EyelinerStyle)
    case eyeshadow(color: String, style: EyeshadowStyle)
    case underEyeShadow
    case enhanceLashes
    case mascara
}

public enum LipFinish: String {
    case matte = "MATTE"
    case glossy = "GLOSSY"
    case satin = "SATIN"
}

public enum MakeupLipPreset {
    case lipstick(color: String, finish: LipFinish, intensity: MakeupIntensity)
    case lipLinerMatch
    case enhanceNaturalLip
}

public enum MakeupBrowPreset {
    case fillNaturally
    case defineLightly
    case darkenSlightly
    case softShading
}

public enum MakeupFullLookPreset {
    case naturalEveryday
    case softGlam
    case party
    case weddingGuest
    case minimal
    case eveningGlam
}

public struct MakeupInput {
    public let userImage: UIImage
    public let skinPresets: [MakeupSkinPreset]
    public let eyePresets: [MakeupEyePreset]
    public let lipPresets: [MakeupLipPreset]
    public let browPresets: [MakeupBrowPreset]
    public let fullLookPresets: [MakeupFullLookPreset]
    public let customText: String?

    public init(
        userImage: UIImage,
        skinPresets: [MakeupSkinPreset] = [],
        eyePresets: [MakeupEyePreset] = [],
        lipPresets: [MakeupLipPreset] = [],
        browPresets: [MakeupBrowPreset] = [],
        fullLookPresets: [MakeupFullLookPreset] = [],
        customText: String? = nil
    ) {
        self.userImage = userImage
        self.skinPresets = skinPresets
        self.eyePresets = eyePresets
        self.lipPresets = lipPresets
        self.browPresets = browPresets
        self.fullLookPresets = fullLookPresets
        self.customText = customText
    }
}

#endif
