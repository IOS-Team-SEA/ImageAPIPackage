import Foundation

public struct StepExecutionLog: Equatable {
    public let stepId: String
    public let start: Date
    public let end: Date
    public let prompt: String
    public let negativePrompt: String
    public let cacheHit: Bool
    public let errorDescription: String?
}

public struct AIContext {
    public var primaryImage: AIImageAsset
    public var secondaryImages: [AIImageAsset]
    public var userInputText: String?
    public var toolOptions: [String: AnyHashable]
    public var composedPrompt: String
    public var composedNegativePrompt: String
    public var artifacts: [String: AnyHashable]
    public var history: [StepExecutionLog]

    public init(
        primaryImage: AIImageAsset,
        secondaryImages: [AIImageAsset] = [],
        userInputText: String? = nil,
        toolOptions: [String: AnyHashable] = [:],
        composedPrompt: String = "",
        composedNegativePrompt: String = "",
        artifacts: [String: AnyHashable] = [:],
        history: [StepExecutionLog] = []
    ) {
        self.primaryImage = primaryImage
        self.secondaryImages = secondaryImages
        self.userInputText = userInputText
        self.toolOptions = toolOptions
        self.composedPrompt = composedPrompt
        self.composedNegativePrompt = composedNegativePrompt
        self.artifacts = artifacts
        self.history = history
    }
}
