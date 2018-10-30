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

class Persistence {
    static let clientCacheKey = "thincloud-cached-client"
    static let userCacheKey = "thincloud-cached-user"

    // MARK: - Codable Property List Persistence Wrapper

    static func cache<T>(_ toCache: T?, forKey: String) where T: Encodable {
        guard let toCache = toCache else {
            return UserDefaults.standard.set(nil, forKey: forKey)
        }

        let encoder = PropertyListEncoder()
        let encoded = try! encoder.encode(toCache)

        UserDefaults.standard.set(encoded, forKey: forKey)
    }

    static func cached<T>(forKey: String) -> T? where T: Decodable {
        let decoder = PropertyListDecoder()

        guard let encoded = UserDefaults.standard.data(forKey: forKey) else {
            return nil
        }

        let decoded = try? decoder.decode(T.self, from: encoded)

        return decoded
    }

    // MARK: - Client Persistence

    static func cacheClient(_ client: Client?) {
        cache(client, forKey: clientCacheKey)
    }

    static func cachedClient() -> Client? {
        return cached(forKey: clientCacheKey)
    }

    // MARK: - Signed In User Persistence

    static func cacheUser(_ user: User?) {
        cache(user, forKey: userCacheKey)
    }

    static func cachedUser() -> User? {
        return cached(forKey: userCacheKey)
    }
}

class SecurePersistence {
    static var keychainPrefix: String {
        let bundleDictionary = Bundle.main.infoDictionary!
        let appName = bundleDictionary[kCFBundleIdentifierKey as String] as! String

        return appName
    }

    static var accessTokenKeychainKey: String {
        return "\(keychainPrefix).co.yonomi.thincloud.oauth-token"
    }

    static var refreshTokenKeychainKey: String {
        return "\(keychainPrefix).co.yonomi.thincloud.refresh-token"
    }

    static func clear() {
        storeAccessToken(nil)
        storeRefreshToken(nil)
    }

    // MARK: - Access Token Persistence (NOT CURRENTLY SECURE)

    static func storeAccessToken(_ token: String?) {
        UserDefaults.standard.set(token, forKey: accessTokenKeychainKey)
    }

    static func accessToken() -> String? {
        return UserDefaults.standard.string(forKey: accessTokenKeychainKey)
    }

    // MARK: - Refresh Token Persistence (NOT CURRENTLY SECURE)

    static func storeRefreshToken(_ token: String?) {
        UserDefaults.standard.set(token, forKey: refreshTokenKeychainKey)
    }

    static func refreshToken() -> String? {
        return UserDefaults.standard.string(forKey: refreshTokenKeychainKey)
    }
}
