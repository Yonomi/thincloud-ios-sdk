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

import Alamofire
import Foundation
#if os(iOS) || os(tvOS)
    import UIKit.UIApplication
#endif

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
        - instance: The ThinCloud instance name, i.e. api.instance.yonomi.cloud
        - clientId: The OAuth client key.
        - apiKey: The ThinCloud API key.

     */
    public func configure(instance: String, clientId: String, apiKey: String) {
        self.clientId = clientId
        self.apiKey = apiKey
        self.instance = instance

        // Resume session if possible
        if let currentUser = currentUser, let accessToken = SecurePersistence.accessToken(), let refreshToken = SecurePersistence.refreshToken() {
            let oauthHandler = OAuth2Handler(clientID: clientId, baseURLString: "https://api.\(ThinCloud.shared.instance!).yonomi.cloud/v1/", username: currentUser.email, accessToken: accessToken, refreshToken: refreshToken, delegate: self)
            sessionManager.adapter = oauthHandler
            sessionManager.retrier = oauthHandler

            #if os(iOS) || os(tvOS)
                registerClient()
            #endif
        }
    }

    // MARK: - Client Registration

    #if os(iOS) || os(tvOS)
        /// A convenience method for UIApplication.shared.registerForRemoteNotifications().
        public func registerClient() {
            UIApplication.shared.registerForRemoteNotifications() // Flows back to us through the AppDelegate hook
        }

        func registerClient(deviceToken: String, completion: @escaping (_ error: Error?, _ client: Client?) -> Void) {
            let bundleDictionary = Bundle.main.infoDictionary!

            let appName = bundleDictionary[kCFBundleIdentifierKey as String] as! String
            let appVersion = bundleDictionary["CFBundleShortVersionString"] as! String

            let currentDevice = UIDevice.current

            let deviceModel = currentDevice.model
            let deviceVersion = currentDevice.systemVersion
            let installId = currentDevice.identifierForVendor!.uuidString

            let clientRequest = ClientRegistrationRequest(applicationName: appName, applicationVersion: appVersion, deviceModel: deviceModel, devicePlatform: "ios", deviceVersion: deviceVersion, deviceToken: deviceToken, installId: installId, metadata: nil, clientId: nil, userId: nil)

            sessionManager.request(APIRouter.createClient(clientRequest)).validate().response { response in
                if let error = response.error {
                    return completion(error, nil)
                }

                guard let data = response.data else {
                    return completion(ThinCloudError.responseError, nil)
                }

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(.iso8601Full)

                guard let client = try? decoder.decode(Client.self, from: data) else {
                    return completion(ThinCloudError.deserializationError, nil)
                }

                self.currentClient = client

                return completion(nil, client)
            }
        }
    #endif

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
                return completion(ThinCloudError.responseError, nil)
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            guard let oauthResponse = try? decoder.decode(OAuth2Response.self, from: data) else {
                return completion(ThinCloudError.deserializationError, nil)
            }

            SecurePersistence.storeAccessToken(oauthResponse.accessToken)
            SecurePersistence.storeRefreshToken(oauthResponse.refreshToken)

            let oauthHandler = OAuth2Handler(clientID: self.clientId, baseURLString: "https://api.\(ThinCloud.shared.instance!).yonomi.cloud/v1/", username: email, accessToken: oauthResponse.accessToken, refreshToken: oauthResponse.refreshToken, delegate: self)
            self.sessionManager.adapter = oauthHandler
            self.sessionManager.retrier = oauthHandler

            // begin using session manager

            self.getUser { error, user in
                if let error = error {
                    return completion(error, nil)
                }

                if let user = user {
                    return completion(nil, user)
                }

                return completion(ThinCloudError.responseError, nil)
            }
        }
    }

    /// Signs out the user session inside the ThinCloud singleton.
    public func signOut() {
        // TODO: Do we need to destroy the associated client entity when signing out?
        currentUser = nil
        currentClient = nil
        SecurePersistence.clear()
        sessionManager.retrier = nil
        sessionManager.adapter = nil
        sessionManager.session.getAllTasks { tasks in
            tasks.forEach({ $0.cancel() })
        }
    }

    /**
     Begins the user password reset process.

     - parameters:
        - email: The user's e-mail address.
        - completion: The handler called after a reset attempt is completed.

     */
    public func resetPassword(email: String, completion: @escaping (_ error: Error?) -> Void) {
        let resetRequest = PasswordResetRequest(username: email, clientId: clientId)
        sessionManager.request(APIRouter.resetPassword(resetRequest)).validate().response { response in
            if let error = response.error {
                return completion(error)
            }

            return completion(nil)
        }
    }

    /**
     Verifies a password change of a user.

     - parameters:
        - email: The user's e-mail address.
        - password: The user's new password.
        - confirmationCode: The confirmation code sent to the user's e-mail address.
        - completion: The handler called after a sign in attempt is completed.

     */
    public func verifyResetPassword(email: String, password: String, confirmationCode: String, completion: @escaping (_ error: Error?) -> Void) {
        let verifyRequest = VerifyPasswordResetRequest(username: email, password: password, confirmationCode: confirmationCode)
        sessionManager.request(APIRouter.verifyResetPassword(verifyRequest)).validate().response { response in
            if let error = response.error {
                return completion(error)
            }

            return completion(nil)
        }
    }

    /**
     Verifies a new user.

     - parameters:
        - email: The user's e-mail address.
        - confirmationCode: The confirmation code sent to the user's e-mail address.
        - completion: The handler called after a sign in attempt is completed.

     */
    public func verifyUser(email: String, confirmationCode: String, completion: @escaping (_ error: Error?) -> Void) {
        let confirmationRequest = UserConfirmationCodeRequest(email: email, confirmationCode: confirmationCode)
        sessionManager.request(APIRouter.verifyUser(confirmationRequest)).validate().response { response in
            if let error = response.error {
                return completion(error)
            }

            return completion(nil)
        }
    }

    /**
     Resends a verification e-mail to new user.

     - parameters:
        - email: The user's e-mail address.
        - completion: The handler called after a sign in attempt is completed.

     */
    public func resendUserVerification(email: String, completion: @escaping (_ error: Error?) -> Void) {
        let resendRequest = ResendVerificationCodeRequest(email: email, clientId: clientId)
        sessionManager.request(APIRouter.resendVerificationEmail(resendRequest)).validate().response { response in
            if let error = response.error {
                return completion(error)
            }

            return completion(nil)
        }
    }

    // MARK: - User CRUD

    /**
     Creates a user.

     - parameters:
        - name: The user's name.
        - email: The user's e-mail.
        - password: The user's password.
        - custom: Key-value pairs of customer specified metadata.
        - completion: The handler called after a user creation attempt is completed.

    */
    public func createUser(name: String, email: String, password: String, custom: [String: AnyCodable]? = nil, completion: @escaping (_ error: Error?) -> Void) {
        let user = UserRequest(email: email, name: name, password: password, custom: custom, userId: nil)
        sessionManager.request(APIRouter.createUser(user)).validate(statusCode: 200..<500).response { response in
            return completion(self.validateUserError(response))
        }
    }

    /**
     Fetches the signed in user associated with the ThinCloud SDK instance.

     - parameters:
        - completion: The handler called after a user fetch attempt is completed.

     */
    public func getUser(completion: @escaping (_ error: Error?, _ user: User?) -> Void) {
        sessionManager.request(APIRouter.getUser(userId: "@me")).validate().responseData { response in
            if let error = response.error {
                return completion(error, nil)
            }

            guard let data = response.data else {
                return completion(ThinCloudError.responseError, nil)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.iso8601Full)
            guard let decodedUser = try? decoder.decode(User.self, from: data) else {
                return completion(ThinCloudError.deserializationError, nil)
            }

            self.currentUser = decodedUser
            completion(nil, decodedUser)
        }
    }

    /**
     Updates a the signed in user associated with the ThinCloud SDK instance.

     - parameters:
        - updates: The changes to the user.
        - completion: The handler called after a user update attempt is completed.

     */
    public func updateUser(_ updates: UserUpdateRequest, completion: @escaping (_ error: Error?, _ user: User?) -> Void) {
        sessionManager.request(APIRouter.updateUser(userId: "@me", updates)).validate().response { response in
            if let error = response.error {
                return completion(error, nil)
            }

            guard let data = response.data else {
                return completion(ThinCloudError.responseError, nil)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.iso8601Full)
            guard let decodedUser = try? decoder.decode(User.self, from: data) else {
                return completion(ThinCloudError.deserializationError, nil)
            }

            self.currentUser = decodedUser
            completion(nil, decodedUser)
        }
    }

    /**
     Deletes the current user associated with the ThinCloud SDK instance.

     - parameters:
        - completion: The handler called after a user delete attempt is completed.

     */
    public func deleteUser(completion: @escaping (_ error: Error?) -> Void) {
        guard let currentUser = currentUser else {
            return completion(ThinCloudError.notAuthenticated) // need a descriptive error here
        }

        sessionManager.request(APIRouter.deleteUser(userId: currentUser.userId)).validate().response { response in
            if let error = response.error {
                return completion(error)
            }

            self.signOut()

            completion(nil)
        }
    }

    // MARK: - User File Storage

    /**
     Fetches all file names associated with the current user.

     - parameters:
        - completion: The handler called after a file name fetch attempt is completed.

     */
    public func getUserFileNames(completion: @escaping (_ error: Error?, _ fileNames: [String]?) -> Void) {
        sessionManager.request(APIRouter.getUserFileNames(userId: "@me")).validate().response { response in
            if let error = response.error {
                return completion(error, nil)
            }

            guard let data = response.data else {
                return completion(ThinCloudError.responseError, nil)
            }

            let decoder = JSONDecoder()
            guard let decodedFileNames = try? decoder.decode([String].self, from: data) else {
                return completion(ThinCloudError.deserializationError, nil)
            }

            completion(nil, decodedFileNames)
        }
    }

    /**
     Fetches a specified file by its name.

     - parameters:
        - fileName: The name of the file.
        - completion: The handler called after a file fetch attempt is completed.

     */
    public func getUserFile(fileName: String, completion: @escaping (_ error: Error?, _ file: Data?) -> Void) {
        sessionManager.request(APIRouter.getUserFile(userId: "@me", fileName: fileName)).validate().response { response in
            if let error = response.error {
                return completion(error, nil)
            }

            guard let data = response.data else {
                return completion(ThinCloudError.responseError, nil)
            }

            completion(nil, data)
        }
    }

    /**
     Stores generic data as a file.

     - parameters:
        - fileName: The name of the file.
        - file: The data to be stored.
        - completion: The handler called after a file update attempt is completed.

     */
    public func putUserFile(fileName: String, file: Data, completion: @escaping (_ error: Error?) -> Void) {
        sessionManager.request(APIRouter.putUserFile(userId: "@me", fileName: fileName, file: file)).validate().response { response in
            if let error = response.error {
                return completion(error)
            }

            completion(nil)
        }
    }

    /**
     Deletes a file.

     - parameters:
        - fileName: The name of the file.
        - completion: The handler called after a file delete attempt is completed.

     */
    public func deleteUserFile(fileName: String, completion: @escaping (_ error: Error?) -> Void) {
        sessionManager.request(APIRouter.deleteUserFile(userId: "@me", fileName: fileName)).validate().response { response in
            if let error = response.error {
                return completion(error)
            }

            completion(nil)
        }
    }

    // MARK: - Device CRUD

    /**
     Fetches all devices associated with the current user.

     - parameters:
        - completion: The handler called after a device fetch attempt is completed.

     */
    public func getDevices(completion: @escaping (_ error: Error?, _ device: [Device]?) -> Void) {
        sessionManager.request(APIRouter.getDevices()).validate().response { response in
            if let error = response.error {
                return completion(error, nil)
            }

            guard let data = response.data else {
                return completion(ThinCloudError.responseError, nil)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.iso8601Full)
            guard let decodedDevices = try? decoder.decode([Device].self, from: data) else {
                return completion(ThinCloudError.deserializationError, nil)
            }

            completion(nil, decodedDevices)
        }
    }

    /**
     Fetches a specified device by its deviceId.

     - parameters:
        - deviceId: The ThinCloud generated device identifier.
        - completion: The handler called after a device fetch attempt is completed.

     */
    public func getDevice(deviceId: String, completion: @escaping (_ error: Error?, _ device: Device?) -> Void) {
        sessionManager.request(APIRouter.getDevice(deviceId: deviceId)).validate().response { response in
            if let error = response.error {
                return completion(error, nil)
            }

            guard let data = response.data else {
                return completion(ThinCloudError.responseError, nil)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.iso8601Full)
            guard let decodedDevice = try? decoder.decode(Device.self, from: data) else {
                return completion(ThinCloudError.deserializationError, nil)
            }

            completion(nil, decodedDevice)
        }
    }

    /**
     Creates a device.

     - parameters:
        - device: The device to create.
        - completion: The handler called after a device creation attempt is completed.

     */
    public func createDevice(device: DeviceCreateRequest, completion: @escaping (_ error: Error?, _ device: Device?) -> Void) {
        sessionManager.request(APIRouter.createDevice(device)).validate().response { response in
            if let error = response.error {
                return completion(error, nil)
            }

            guard let data = response.data else {
                return completion(ThinCloudError.responseError, nil)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.iso8601Full)
            guard let decodedDevice = try? decoder.decode(Device.self, from: data) else {
                return completion(ThinCloudError.deserializationError, nil)
            }

            completion(nil, decodedDevice)
        }
    }

    /**
     Updates a device.

     - parameters:
        - deviceId: The ThinCloud generated device identifier.
        - updates: The changes to the device.
        - completion: The handler called after a device update attempt is completed.

     */
    public func updateDevice(deviceId: String, updates: DeviceUpdateRequest, completion: @escaping (_ error: Error?, _ device: Device?) -> Void) {
        sessionManager.request(APIRouter.updateDevice(deviceId: deviceId, updates)).validate().response { response in
            if let error = response.error {
                return completion(error, nil)
            }

            guard let data = response.data else {
                return completion(ThinCloudError.responseError, nil)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.iso8601Full)
            guard let decodedDevice = try? decoder.decode(Device.self, from: data) else {
                return completion(ThinCloudError.deserializationError, nil)
            }

            completion(nil, decodedDevice)
        }
    }

    /**
     Deletes a device.

     - parameters:
        - deviceId: The ThinCloud generated device identifier.
        - completion: The handler called after a device deletion attempt is completed.

     */
    public func deleteDevice(deviceId: String, completion: @escaping (_ error: Error?) -> Void) {
        sessionManager.request(APIRouter.deleteDevice(deviceId: deviceId)).validate().response { response in
            if let error = response.error {
                return completion(error)
            }

            completion(nil)
        }
    }

    // MARK: - Clients CRUD

    /**
     Fetches all clients associated with the current user.

     - parameters:
        - completion: The handler called after a client fetch attempt is completed.

     */
    public func getClients(completion: @escaping (_ error: Error?, _ clients: [Client]?) -> Void) {
        sessionManager.request(APIRouter.getClients()).validate().response { response in
            if let error = response.error {
                return completion(error, nil)
            }

            guard let data = response.data else {
                return completion(nil, nil)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.iso8601Full)
            guard let decodedClients = try? decoder.decode([Client].self, from: data) else {
                return completion(ThinCloudError.deserializationError, nil)
            }

            completion(nil, decodedClients)
        }
    }
    
    private func validateUserError(_ response: DefaultDataResponse) -> Error? {
        guard let httpResponse = response.response, let data = response.data else {
            return ThinCloudError.responseError
        }

        switch httpResponse.statusCode {
        case 200..<400:
            return nil
        case 400..<500:
            let decoder = JSONDecoder()
            if let decodedError = try? decoder.decode(ThinCloudRequestError.self, from: data), let description = decodedError.errorDescription {
                if description.contains("UserNotConfirmedException") {
                    return ThinCloudError.accountNotVerified(decodedError.message)
                } else {
                    return ThinCloudError.notAuthenticated
                }
            } else {
                return ThinCloudError.responseError
            }
        default:
            return ThinCloudError.unknownError
        }
    }
}
