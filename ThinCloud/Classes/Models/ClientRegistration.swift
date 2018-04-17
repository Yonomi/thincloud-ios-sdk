import Foundation

struct ClientRegistrationRequest: Codable {
    let applicationName: String
    let applicationVersion: String
    let deviceModel: String
    let devicePlatform: String
    let deviceVersion: String
    let deviceToken: String
    let installId: String
    let metadata: [String: String]? //TODO: Does this need to support all JSON value types?
    let clientId: String?
    let userId: String?
}

public struct ClientRegistrationResponse: Codable {
    public let applicationName: String
    public let applicationVersion: String
    public let deviceModel: String
    public let devicePlatform: String
    public let deviceVersion: String
    public let deviceToken: String
    public let installId: String
    public let metadata: [String: String]? //TODO: Does this need to support all JSON value types?
    public let clientId: String?
    public let userId: String?
    public let createdAt: Date?
    public let updatedAt: Date?
}

public typealias Client = ClientRegistrationResponse
