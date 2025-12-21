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
        XCTAssertNoThrow(try LogoGenerationTool.buildPrompt(from: input))
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
        XCTAssertThrowsError(try LogoGenerationTool.buildPrompt(from: badInput))
    }

    func testPresetPromptMergesExtra() throws {
        let descriptor = PresetDescriptor(id: "preset1", prompt: "Base Prompt")
        let prompt = try PresetTool.buildPrompt(descriptor: descriptor, extra: "tweak")
        XCTAssertTrue(prompt.contains("Base Prompt"))
        XCTAssertTrue(prompt.contains("tweak"))
    }

    func testPresetSecondaryCountValidation() {
        let descriptor = PresetDescriptor(id: "p", prompt: "do it", requiredSecondaryCount: 2)
        let image = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4)).image { ctx in
            UIColor.blue.setFill(); ctx.fill(CGRect(x: 0, y: 0, width: 4, height: 4))
        }
        let input = PresetInput(userImage: image, secondaryImages: [image], descriptor: descriptor)
        let core = MultiImageAndTextCoreTool(endpoint: URL(string: "https://example.com")!)
        let tool = PresetTool(core: core)
        XCTAssertThrowsError(try tool.makeRequest(input: input)) { error in
            guard case ToolInputError.secondaryCountMismatch(let expected, let actual) = error else {
                return XCTFail("Wrong error")
            }
            XCTAssertEqual(expected, 2)
            XCTAssertEqual(actual, 1)
        }
    }

    func testMakeupPromptRequiresDescription() {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 6, height: 6)).image { ctx in
            UIColor.green.setFill(); ctx.fill(CGRect(x: 0, y: 0, width: 6, height: 6))
        }
        let input = MakeupInput(userImage: image, userDescription: "Apply eyeliner in black with thin style")
        XCTAssertNoThrow(try MakeupTool.buildPrompt(userDescription: input.userDescription))
    }

    func testMakeupPromptMissingDescriptionThrows() {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 6, height: 6)).image { ctx in
            UIColor.green.setFill(); ctx.fill(CGRect(x: 0, y: 0, width: 6, height: 6))
        }
        XCTAssertThrowsError(try MakeupTool.buildPrompt(userDescription: "   "))
    }

    func testMakeupPromptRequiresPresetsOrText() {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 6, height: 6)).image { ctx in
            UIColor.green.setFill(); ctx.fill(CGRect(x: 0, y: 0, width: 6, height: 6))
        }
        let input = MakeupInput(
            userImage: image,
            skinPresets: [.naturalFoundation],
            eyePresets: [.eyeliner(color: "BLACK", style: .thin)],
            lipPresets: [.lipstick(color: "NUDE", finish: .matte, intensity: .light)],
            browPresets: [.fillNaturally],
            fullLookPresets: [.naturalEveryday],
            customText: nil
        )
        XCTAssertNoThrow(try MakeupTool.buildPrompt(input: input))
    }

    func testMakeupPromptMissingEverythingThrows() {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 6, height: 6)).image { ctx in
            UIColor.green.setFill(); ctx.fill(CGRect(x: 0, y: 0, width: 6, height: 6))
        }
        let empty = MakeupInput(userImage: image, customText: nil)
        XCTAssertThrowsError(try MakeupTool.buildPrompt(input: empty))
    }
    #endif
}
