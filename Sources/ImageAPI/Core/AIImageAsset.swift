import Foundation
#if canImport(UIKit)
import UIKit
#endif
import CryptoKit

/// Unified image carrier with lazy conversions.
public struct AIImageAsset: Equatable, Hashable {
    public enum ImageFormat: String {
        case png
        case jpeg
    }

    public var data: Data?
    public var base64: String?
    public var format: ImageFormat
    public var hasAlpha: Bool
    public var metadata: [String: AnyHashable]

    #if canImport(UIKit)
    public var uiImage: UIImage? {
        if let data { return UIImage(data: data) }
        if let base64, let decoded = Data(base64Encoded: base64) { return UIImage(data: decoded) }
        return nil
    }
    #endif

    public init(
        data: Data? = nil,
        base64: String? = nil,
        format: ImageFormat = .png,
        hasAlpha: Bool = true,
        metadata: [String: AnyHashable] = [:]
    ) {
        self.data = data
        self.base64 = base64
        self.format = format
        self.hasAlpha = hasAlpha
        self.metadata = metadata
    }

    public func ensureBase64() -> AIImageAsset {
        if base64 != nil { return self }
        guard let data else { return self }
        var copy = self
        copy.base64 = data.base64EncodedString()
        return copy
    }

    #if canImport(UIKit)
    public func resized(maxDimension: CGFloat) -> AIImageAsset {
        guard let image = uiImage else { return self }
        let maxSide = max(image.size.width, image.size.height)
        guard maxSide > maxDimension else { return self }
        let ratio = maxDimension / maxSide
        let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
        let outputData: Data?
        switch format {
        case .png:
            outputData = resized.pngData()
        case .jpeg:
            outputData = resized.jpegData(compressionQuality: 0.9)
        }
        return AIImageAsset(
            data: outputData ?? data,
            base64: outputData?.base64EncodedString() ?? base64,
            format: format,
            hasAlpha: hasAlpha,
            metadata: metadata
        )
    }
    #endif

    public func contentHash() -> String? {
        guard let data = data ?? base64?.data(using: .utf8) else { return nil }
        return data.sha256Hex()
    }
}

private extension Data {
    func sha256Hex() -> String {
        if #available(iOS 13.0, macOS 10.15, *) {
            let digest = SHA256.hash(data: self)
            return digest.map { String(format: "%02x", $0) }.joined()
        } else {
            return base64EncodedString()
        }
    }
}
