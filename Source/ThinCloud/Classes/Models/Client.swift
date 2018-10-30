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

struct ClientRegistrationRequest: Codable {
    let applicationName: String
    let applicationVersion: String
    let deviceModel: String
    let devicePlatform: String
    let deviceVersion: String
    let deviceToken: String
    let installId: String
    let metadata: [String: AnyCodable]?
    let clientId: String?
    let userId: String?
}

/// Representation of a client stored in ThinCloud.
public struct Client: Codable {
    /// The reverse-DNS style bundle identifier of the application.
    public let applicationName: String
    /// The version of the application.
    public let applicationVersion: String
    /// The model of the mobile device associated with the client.
    public let deviceModel: String
    /// The platform of the mobile device.
    public let devicePlatform: String
    /// The platform version of the mobile device.
    public let deviceVersion: String
    /// The push token of the mobile device. On Apple platforms, this is the APNs token.
    public let deviceToken: String
    /// The unique ID of the mobile device associated with the client. On Apple platforms, this is identifierForVendor.
    public let installId: String
    /// Key-value pairs of customer specified metadata.
    public let metadata: [String: AnyCodable]?
    /// ThinCloud created client identifier.
    public let clientId: String?
    /// ThinCloud created user identifier.
    public let userId: String?
    /// Date the client was created.
    public let createdAt: Date?
    /// Date the client was last updated.
    public let updatedAt: Date?
}

typealias ClientRegistrationResponse = Client
