import XCTest
@testable import ImageAPI
#if canImport(UIKit)
import UIKit
#endif

final class MultipartBuilderTests: XCTestCase {
    func testBuildsMultipartRequest_whenImageProvided() throws {
        #if !canImport(UIKit)
        throw XCTSkip("UIKit not available")
        #else
        let url = URL(string: "https://example.com/upload")!
        let image = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image { _ in
            UIColor.red.setFill()
            UIBezierPath(rect: CGRect(x: 0, y: 0, width: 10, height: 10)).fill()
        }
        let payload = ImageMultipartRequestBuilder.Payload(
            userId: "u1",
            isPremium: true,
            prompt: "hello",
            negativePrompt: nil,
            images: [image]
        )
        let request = try ImageMultipartRequestBuilder.makeRequest(url: url, payload: payload)
        XCTAssertEqual(request.httpMethod, "POST")
        let contentType = request.value(forHTTPHeaderField: "Content-Type") ?? ""
        XCTAssertTrue(contentType.contains("multipart/form-data; boundary="))
        XCTAssertNotNil(request.httpBody)
        #endif
    }
}
