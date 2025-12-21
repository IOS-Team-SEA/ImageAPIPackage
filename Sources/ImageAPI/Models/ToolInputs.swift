import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
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
#endif
