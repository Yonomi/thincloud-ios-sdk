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

struct OAuth2Response: Codable {
    let accessToken: String
    let refreshToken: String
    let idToken: String
    let tokenType: String
    let expiresIn: Int
}
