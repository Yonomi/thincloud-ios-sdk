import Alamofire
import Foundation

/// General container responsible for retaining the `ThinCloud` and `VirtualGateway` instances.
public class ThinCloud {
    // MARK: - ThinCloud Singletons

    /// The ThinCloud SDK singleton.
    public static let shared = ThinCloud()

    /// The ThinCloud Virtual Gateway singleton.
    public let virtualGateway = VirtualGateway()

    let sessionManager = SessionManager()

    // MARK: - ThinCloud SDK Instance Properties

    /// The ThinCloud deployment used.
    public private(set) var instance: String!

    /// The ThinCloud 
    var clientId: String!

    /// The user signed in to the ThinCloud instance. If nil, no user is signed in.
    public private(set) var currentUser = Persistence.cachedUser() {
        didSet(newValue) {
            Persistence.cacheUser(newValue)
        }
    }

    /// The client of the user associated with the current ThinCloud instance. If nil, no user is signed in.
    public private(set) var currentClient = Persistence.cachedClient() {
        didSet(newValue) {
            Persistence.cacheClient(newValue)
        }
    }

    /**
     Configures the ThinCloud singleton with your deployment and client keys.

     - parameters:
        - instance: The instance name
        - clientId: The client key

     */
    public func configure(instance: String, clientId: String) {
        self.clientId = clientId
        self.instance = instance

        if currentClient != nil && currentUser != nil {
            // "resume" session
        }

        // we're fresh
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
        // get initial session token

        sessionManager.request(APIRouter.getUser(userId: "")).validate().response { response in
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

    /// Signs out the user session inside the ThinCloud singleton.
    public func signOut() {
        // TODO: Do we need to destroy the associated client entity when signing out?
        currentUser = nil
        currentClient = nil
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
        guard let currentUser = currentUser else {
            return completion(nil, nil) // need a descriptive error here
        }

        sessionManager.request(APIRouter.getUser(userId: currentUser.userId!)).validate().responseData { response in
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

        sessionManager.request(APIRouter.deleteUser(userId: currentUser.userId!)).validate().response { response in
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

    static func cacheClient(_ client: ClientRegistrationResponse?) {
        UserDefaults.standard.set(client, forKey: clientCacheKey)
    }

    static func cachedClient() -> ClientRegistrationResponse? {
        return UserDefaults.standard.object(forKey: clientCacheKey) as? ClientRegistrationResponse
    }

    // MARK: - Signed In User Persistence

    static func cacheUser(_ user: UserResponse?) {
        UserDefaults.standard.set(user, forKey: userCacheKey)
    }

    static func cachedUser() -> UserResponse? {
        return UserDefaults.standard.object(forKey: userCacheKey) as? UserResponse
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
