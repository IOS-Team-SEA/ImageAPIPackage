import XCTest
@testable import ImageAPI

final class PlaceholderTests: XCTestCase {
    func testParametersDefaults() {
        let params = ImageGenerationParameters()
        XCTAssertEqual(params.trueCFGScale, 4.0)
        XCTAssertEqual(params.numInferenceSteps, 20)
        XCTAssertEqual(params.guidanceScale, 1.0)
        XCTAssertEqual(params.numImages, 1)
        XCTAssertEqual(params.seed, 0)
    }
}
