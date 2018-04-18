import Alamofire
import Foundation

/// General container responsible for retaining the `ThinCloud` and `VirtualGateway` instances.
public class ThinCloud: OAuth2TokenDelegate {
    // MARK: - ThinCloud Singletons

    /// The ThinCloud SDK singleton.
    public static let shared = ThinCloud()

    /// The ThinCloud Virtual Gateway singleton.
    public let virtualGateway = VirtualGateway()

    let sessionManager = SessionManager()

    // MARK: - ThinCloud SDK Instance Properties

    /// The ThinCloud deployment used.
    public private(set) var instance: String!

    /// The ThinCloud OAuth client key.
    var clientId: String!

    /// The ThinCloud API key.
    var apiKey: String!

    /// The user signed in to the ThinCloud instance. If nil, no user is signed in.
    public private(set) var currentUser = Persistence.cachedUser() {
        didSet {
            Persistence.cacheUser(currentUser)
        }
    }

    /// The client of the user associated with the current ThinCloud instance. If nil, no user is signed in.
    public private(set) var currentClient = Persistence.cachedClient() {
        didSet {
            Persistence.cacheClient(currentClient)
        }
    }

    /// OAuth2 access token persistence
    func didUpdateAccessToken(_ accessToken: String) {
        SecurePersistence.storeAccessToken(accessToken)
    }

    /// OAuth2 refresh token persistence
    func didUpdateRefreshToken(_ refreshToken: String) {
        SecurePersistence.storeRefreshToken(refreshToken)
    }

    /**
     Configures the ThinCloud singleton with your deployment and client keys.

     - parameters:
        - instance: The ThinCloud instance name, i.e. api.<instance>.yonomi.cloud
        - clientId: The OAuth client key.
        - apiKey: The ThinCloud API key.

     */
    public func configure(instance: String, clientId: String, apiKey: String) {
        self.clientId = clientId
        self.apiKey = apiKey
        self.instance = instance

        if currentClient != nil && currentUser != nil, let accessToken = SecurePersistence.accessToken(), let refreshToken = SecurePersistence.refreshToken() {
            // "resume" session
            let oauthHandler = OAuth2Handler(clientID: clientId, baseURLString: "", accessToken: accessToken, refreshToken: refreshToken, delegate: self)
            sessionManager.adapter = oauthHandler
            sessionManager.retrier = oauthHandler
        }
    }

    // MARK: - Client Registration

    /// A convenience method for UIApplication.shared.registerForRemoteNotifications().
    public func registerClient() {
        UIApplication.shared.registerForRemoteNotifications() // Flows back to us through AppDelegate hook
    }

    func registerClient(deviceToken: String) {
        let bundleDictionary = Bundle.main.infoDictionary!

        let appName = bundleDictionary[kCFBundleIdentifierKey as String] as! String
        let appVersion = bundleDictionary["CFBundleShortVersionString"] as! String

        let currentDevice = UIDevice.current

        let deviceModel = currentDevice.model
        let deviceVersion = currentDevice.systemVersion
        let installId = currentDevice.identifierForVendor!.uuidString

        let clientRequest = ClientRegistrationRequest(applicationName: appName, applicationVersion: appVersion, deviceModel: deviceModel, devicePlatform: "ios", deviceVersion: deviceVersion, deviceToken: deviceToken, installId: installId, metadata: nil, clientId: nil, userId: nil)

        sessionManager.request(APIRouter.createClient(clientRequest)).validate().response { response in

        }
    }

    // MARK: - User State Management

    /**
     Signs in a user creating a session inside the ThinCloud singleton.

     - parameters:
        - email: The user's e-mail address.
        - password: The user's password.
        - completion: The handler called after a sign in attempt is completed.

     */
    public func signIn(email: String, password: String, completion: @escaping (_ error: Error?, _ user: User?) -> Void) {
        let oauthRequest = OAuth2Request(grantType: .password, clientId: clientId, username: email, password: password)
        sessionManager.request(APIRouter.createAuthToken(oauthRequest)).validate().response { response in
            if let error = response.error {
                return completion(error, nil)
            }

            guard let data = response.data else {
                return completion(nil, nil) // need a descriptive error here
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let oauthResponse = try! decoder.decode(OAuth2Response.self, from: data)

            SecurePersistence.storeAccessToken(oauthResponse.accessToken)
            SecurePersistence.storeRefreshToken(oauthResponse.refreshToken)

            let oauthHandler = OAuth2Handler(clientID: self.clientId, baseURLString: "", accessToken: oauthResponse.accessToken, refreshToken: oauthResponse.refreshToken, delegate: self)
            self.sessionManager.adapter = oauthHandler
            self.sessionManager.retrier = oauthHandler

            // begin using session manager
            self.sessionManager.request(APIRouter.getUser(userId: "@me")).validate().response { response in
                if let error = response.error {
                    return completion(error, nil)
                }

                guard let data = response.data else {
                    return completion(nil, nil) // need a descriptive error here
                }

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                let decodedUser = try! decoder.decode(User.self, from: data)

                self.currentUser = decodedUser

                completion(nil, decodedUser)
            }
        }
    }

    /// Signs out the user session inside the ThinCloud singleton.
    public func signOut() {
        // TODO: Do we need to destroy the associated client entity when signing out?
        currentUser = nil
        currentClient = nil
        SecurePersistence.clear()
    }

    /**
     Creates a user

     - parameters:
        - name: The user's name.
        - password: The user's password.
        - completion: The handler called after a user creation attempt is completed.
    */
    public func createUser(name: String, email: String, password: String, completion: @escaping (_ error: Error?, _ user: User?) -> Void) {
        let user = UserRequest(email: email, name: name, password: password, custom: nil, userId: nil)
        sessionManager.request(APIRouter.createUser(user)).validate().response { response in
            if let error = response.error {
                return completion(error, nil)
            }

            return completion(nil, nil)
        }
    }

    /**
     Fetches the user associated with the ThinCloud instance

     - parameters:
        - completion: The handler called after a user fetch attempt is completed.
     */
    public func getUser(completion: @escaping (_ error: Error?, _ user: User?) -> Void) {
//        guard let currentUser = currentUser else {
//            return completion(nil, nil) // need a descriptive error here
//        }

        sessionManager.request(APIRouter.getUser(userId: "@me")).validate().responseData { response in
            if let error = response.error {
                return completion(error, nil)
            }

            guard let data = response.data else {
                return completion(nil, nil) // need a descriptive error here
            }

            let decoder = JSONDecoder()
            let decodedUser = try! decoder.decode(User.self, from: data)

            self.currentUser = decodedUser
            completion(nil, decodedUser)
        }
    }

    public func updateUser(completion: @escaping (_ error: Error?, _ user: User?) -> Void) {

    }

    // TODO: Do we need to support this in the SDK?
    public func deleteUser(completion: @escaping (_ error: Error?) -> Void) {
        guard let currentUser = currentUser else {
            return completion(nil) // need a descriptive error here
        }

        sessionManager.request(APIRouter.deleteUser(userId: currentUser.userId)).validate().response { response in
            if let error = response.error {
                return completion(error)
            }

            completion(nil)
        }
    }

    // MARK: - Device CRUD

}

class Persistence {

    static let clientCacheKey = "thincloud-cached-client"
    static let userCacheKey = "thincloud-cached-user"

    // MARK: - Client Persistence

    // TODO: Generics

    static func cacheClient(_ client: ClientRegistrationResponse?) {
        guard let client = client else {
            return UserDefaults.standard.set(nil, forKey: userCacheKey)
        }

        let encoder = PropertyListEncoder()
        let encodedClient = try! encoder.encode(client)

        UserDefaults.standard.set(encodedClient, forKey: clientCacheKey)
    }

    static func cachedClient() -> ClientRegistrationResponse? {
        let decoder = PropertyListDecoder()

        guard let encodedClient = UserDefaults.standard.data(forKey: clientCacheKey) else {
            return nil
        }

        let decodedClient = try! decoder.decode(ClientRegistrationResponse.self, from: encodedClient)

        return decodedClient
    }

    // MARK: - Signed In User Persistence

    static func cacheUser(_ user: UserResponse?) {
        guard let user = user else {
            return UserDefaults.standard.set(nil, forKey: userCacheKey)
        }

        let encoder = PropertyListEncoder()
        let encodedUser = try! encoder.encode(user)

        UserDefaults.standard.set(encodedUser, forKey: userCacheKey)
    }

    static func cachedUser() -> UserResponse? {
        let decoder = PropertyListDecoder()

        guard let encodedUser = UserDefaults.standard.data(forKey: userCacheKey) else {
            return nil
        }

        let decodedUser = try! decoder.decode(UserResponse.self, from: encodedUser)

        return decodedUser
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
