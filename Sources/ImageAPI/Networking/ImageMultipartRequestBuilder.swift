import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
public enum ImageMultipartRequestBuilder {
    public struct Payload {
        public let userId: String
        public let isPremium: Bool
        public let prompt: String
        public let negativePrompt: String?
        public let images: [UIImage]
        public let timeout: TimeInterval

        public init(
            userId: String,
            isPremium: Bool,
            prompt: String,
            negativePrompt: String? = nil,
            images: [UIImage],
            timeout: TimeInterval = 60
        ) {
            self.userId = userId
            self.isPremium = isPremium
            self.prompt = prompt
            self.negativePrompt = negativePrompt
            self.images = images
            self.timeout = timeout
        }
    }

    public static func makeRequest(
        url: URL,
        payload: Payload
    ) throws -> URLRequest {
        guard !payload.images.isEmpty else {
            throw ImageGenerationError.missingImages
        }
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url, timeoutInterval: payload.timeout)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let body = NSMutableData()
        func appendField(name: String, value: String) {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }

        appendField(name: "userId", value: payload.userId)
        appendField(name: "isPremium", value: payload.isPremium ? "true" : "false")
        appendField(name: "prompt", value: payload.prompt)
        if let negative = payload.negativePrompt, !negative.isEmpty {
            appendField(name: "negativePrompt", value: negative)
        }

        for (index, image) in payload.images.enumerated() {
            guard let data = image.jpegData(compressionQuality: 0.9) else {
                throw ImageGenerationError.imageEncodingFailed
            }
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"images\"; filename=\"image\(index).jpg\"\r\n")
            body.appendString("Content-Type: image/jpeg\r\n\r\n")
            body.append(data)
            body.appendString("\r\n")
        }
        body.appendString("--\(boundary)--\r\n")
        request.httpBody = body as Data
        return request
    }
}

private extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
#endif
