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

struct OAuth2Request: Codable {
    enum GrantType: String, Codable {
        case password
        case refreshToken = "refresh_token"
    }

    let grantType: GrantType
    let clientId: String
    let username: String
    let password: String

    enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case clientId
        case username
        case password
    }
}

struct OAuth2Response: Codable {
    let accessToken: String
    let refreshToken: String
    let idToken: String
    let tokenType: String
    let expiresIn: Int
}

struct OAuth2RefreshRequest: Codable {
    let grantType = "refresh_token"
    let clientId: String
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case clientId
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct OAuth2RefreshResponse: Codable {
    let accessToken: String
    let idToken: String
    let tokenType: String
    let expiresIn: Int
}
