import Foundation

public struct PromptTemplate {
    public let prompt: String
    public let negative: String
}

public final class PromptComposer {
    private let templates: [String: PromptTemplate]
    private let globalNegative: String
    private let maxLength: Int

    public init(
        templates: [String: PromptTemplate],
        globalNegative: String = "",
        maxLength: Int = 400
    ) {
        self.templates = templates
        self.globalNegative = globalNegative
        self.maxLength = maxLength
    }

    public func compose(stepId: String, context: AIContext) -> (prompt: String, negative: String) {
        let template = templates[stepId] ?? PromptTemplate(prompt: context.composedPrompt, negative: context.composedNegativePrompt)
        var promptParts: [String] = []
        if !template.prompt.isEmpty { promptParts.append(template.prompt) }
        if let user = context.userInputText, !user.isEmpty {
            promptParts.append(user)
        }
        let prompt = promptParts.joined(separator: ", ").prefix(maxLength)
        var negativeParts: [String] = []
        if !template.negative.isEmpty { negativeParts.append(template.negative) }
        if !globalNegative.isEmpty { negativeParts.append(globalNegative) }
        let negative = negativeParts.joined(separator: ", ").prefix(maxLength)
        return (String(prompt), String(negative))
    }
}

public enum DefaultPromptTemplates {
    public static let bgRemove = PromptTemplate(
        prompt: "remove background, keep main subject, clean edges, studio quality, transparent background",
        negative: "background, shadow, blur, halo, artifacts, text, watermark"
    )
    public static let cardBackground = PromptTemplate(
        prompt: "place subject on clean rounded card, subtle soft shadow, centered composition, studio lighting",
        negative: "messy background, text, watermark, distortion"
    )
    public static let enhance = PromptTemplate(
        prompt: "enhance image quality, improve clarity, natural colors, professional finish",
        negative: "over-sharpen, artifacts, noise, fake details"
    )

    public static func composer() -> PromptComposer {
        PromptComposer(
            templates: [
                "BG_REMOVE": bgRemove,
                "CARD_BACKGROUND": cardBackground,
                "ENHANCE": enhance
            ],
            globalNegative: ""
        )
    }
}
