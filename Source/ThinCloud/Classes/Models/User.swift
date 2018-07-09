// Copyright (c) 2018 Yonomi, Inc. All rights reserved.

import Foundation

struct UserRequest: Codable {
    let email: String
    let name: String
    let password: String?
    let custom: [String: AnyCodable]?
    let userId: String?
}

struct UserConfirmationCodeRequest: Codable {
    let email: String
    let confirmationCode: String
    let clientId: String
}

struct ResendVerificationCodeRequest: Codable {
    let email: String
    let clientId: String
}

/// Representation of a user stored in ThinCloud.
public struct User: Codable {
    /// The e-mail address of the user.
    public let email: String
    /// The full name of the user.
    public let name: String?
    /// The active state of the user.
    public let active: Bool?
    /// Key-value pairs of customer specified metadata.
    public let custom: [String: AnyCodable]
    /// ThinCloud generated user identifier.
    public let userId: String
    /// Date the user was created.
    public let createdAt: Date?
    /// Date the user was last updated.
    public let updatedAt: Date?
}

typealias UserResponse = User
