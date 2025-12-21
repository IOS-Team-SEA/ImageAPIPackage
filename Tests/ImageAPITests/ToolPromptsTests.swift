import XCTest
@testable import ImageAPI
#if canImport(UIKit)
import UIKit
#endif

final class ToolPromptsTests: XCTestCase {
    #if canImport(UIKit)
    func testLogoPromptRequiresFields() {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image { ctx in
            UIColor.red.setFill(); ctx.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
        let input = LogoGenerationInput(
            name: "Test Brand",
            slogan: nil,
            userDescription: "Great product",
            brandColor: "Blue",
            category: "Tech",
            styleReference: image
        )
        XCTAssertNoThrow(try ToolPromptBuilders.logoPrompt(from: input))
    }

    func testLogoPromptMissingFieldThrows() {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image { ctx in
            UIColor.red.setFill(); ctx.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
        let badInput = LogoGenerationInput(
            name: "",
            slogan: nil,
            userDescription: "",
            brandColor: "",
            category: "",
            styleReference: image
        )
        XCTAssertThrowsError(try ToolPromptBuilders.logoPrompt(from: badInput))
    }

    func testPresetPromptMergesExtra() throws {
        let descriptor = PresetDescriptor(id: "preset1", prompt: "Base Prompt")
        let prompt = try ToolPromptBuilders.presetPrompt(descriptor: descriptor, extra: "tweak")
        XCTAssertTrue(prompt.contains("Base Prompt"))
        XCTAssertTrue(prompt.contains("tweak"))
    }

    func testPresetSecondaryCountValidation() {
        let descriptor = PresetDescriptor(id: "p", prompt: "do it", requiredSecondaryCount: 2)
        let image = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4)).image { ctx in
            UIColor.blue.setFill(); ctx.fill(CGRect(x: 0, y: 0, width: 4, height: 4))
        }
        let input = PresetInput(userImage: image, secondaryImages: [image], descriptor: descriptor)
        let core = ImageAndTextToImageCoreTool(endpoint: URL(string: "https://example.com")!)
        let tool = PresetTool(core: core)
        XCTAssertThrowsError(try tool.makeRequest(input: input)) { error in
            guard case ToolInputError.secondaryCountMismatch(let expected, let actual) = error else {
                return XCTFail("Wrong error")
            }
            XCTAssertEqual(expected, 2)
            XCTAssertEqual(actual, 1)
        }
    }
    #endif
}
