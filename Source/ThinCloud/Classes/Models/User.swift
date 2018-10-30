// Copyright 2018 Yonomi, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

struct UserRequest: Codable {
    let email: String
    let name: String
    let password: String?
    let custom: [String: AnyCodable]?
    let userId: String?
}

/// Representation of a user update request to ThinCloud.
public struct UserUpdateRequest: Codable {
    /// The new e-mail address of the user.
    public let email: String?
    /// The new name of the user.
    public let name: String?
    /// The new key-value pairs of customer specified metadata.
    public let custom: [String: AnyCodable]?
    public init(email: String?, name: String?, custom: [String: AnyCodable]?) {
        self.email = email
        self.name = name
        self.custom = custom
    }
}

struct UserConfirmationCodeRequest: Codable {
    let email: String
    let confirmationCode: String
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
