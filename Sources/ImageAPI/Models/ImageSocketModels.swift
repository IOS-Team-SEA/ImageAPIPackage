import Foundation

public struct ImageSocketInitPayload: Encodable {
    public let firebaseId: String
    public let isPremium: Bool
    public let fcmToken: String

    public init(firebaseId: String, isPremium: Bool, fcmToken: String) {
        self.firebaseId = firebaseId
        self.isPremium = isPremium
        self.fcmToken = fcmToken
    }
}

public struct ImageJob: Codable, Equatable {
    public let status: String?
    public let jobId: Int?
    public let position: Int?
    public let estimatedTimeInSeconds: Int?
    public let images: [String]?
    public let prompt: String?
    public let outputImage: String?
}

public struct ImageUserState: Codable, Equatable {
    public let userId: String?
    public let coins: Int?
    public let isPremium: Bool?
    public let jobs: [ImageJob]?
    public let totalCoins: Int?
}

public struct ImageAPIEnvelope: Codable, Equatable {
    public let data: ImageUserState?
    public let message: String?
    public let messageCode: String?
    public let status: Bool?
}
