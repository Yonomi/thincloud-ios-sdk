import Foundation

struct UserRequest: Codable {
    let email: String
    let name: String
    let password: String?
    let custom: [String: String]? //TODO: Does this need to support all JSON value types?
    let userId: String?
}

public struct UserResponse: Codable {
    let email: String
    let name: String
    let active: Bool?
    // let custom: [String: Any]? TODO: Codable
    let userId: String?
    let createdAt: Date?
    let updatedAt: Date?
}

public typealias User = UserResponse
