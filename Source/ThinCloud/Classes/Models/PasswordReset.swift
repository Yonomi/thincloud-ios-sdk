// Copyright (c) 2018 Yonomi, Inc. All rights reserved.

import Foundation

struct PasswordResetRequest: Codable {
    let username: String
    let clientId: String
}

struct VerifyPasswordResetRequest: Codable {
    let username: String
    let password: String
    let confirmationCode: String
}
