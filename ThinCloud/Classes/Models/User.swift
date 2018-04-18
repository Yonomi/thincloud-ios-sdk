import Foundation

struct UserRequest: Codable {
    let email: String
    let name: String
    let password: String?
    let custom: [String: String]? //TODO: Does this need to support all JSON value types?
    let userId: String?
}

public struct UserResponse: Codable {
    public let email: String
    public let fullName: String
    public let active: Bool?
    // let custom: [String: Any]? TODO: Codable
    public let userId: String
    public let createdAt: Date?
    public let updatedAt: Date?
}

public typealias User = UserResponse
