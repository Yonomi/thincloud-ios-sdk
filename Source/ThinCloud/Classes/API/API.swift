// Copyright (c) 2018 Yonomi, Inc. All rights reserved.

import Alamofire
import Foundation

enum APIRouter: URLRequestConvertible {
    var baseUrl: String {
        return "https://api.\(ThinCloud.shared.instance!).yonomi.cloud/v1/"
    }

    // Auth Token
    case createAuthToken(OAuth2Request)

    // User
    case createUser(UserRequest)
    case getUser(userId: String)
    case updateUser(userId: String, UserUpdateRequest)
    case deleteUser(userId: String)
    case resendVerificationEmail(ResendVerificationCodeRequest)
    case verifyUser(UserConfirmationCodeRequest)
    case resetPassword(PasswordResetRequest)
    case verifyResetPassword(VerifyPasswordResetRequest)

    // Client
    case getClients()
    case createClient(ClientRegistrationRequest)
    case updateClient(clientId: String, ClientRegistrationRequest)
    case getClient(clientId: String)
    case deleteClient(clientId: String)

    // Device
    case getDevices()
    case createDevice(DeviceCreateRequest)
    case getDevice(deviceId: String)
    case updateDevice(deviceId: String, DeviceUpdateRequest)
    case deleteDevice(deviceId: String)

    // Device Commands
    case getDeviceCommands(deviceId: String, state: DeviceCommandResponse.State)
    case updateDeviceCommands(deviceId: String, commandId: String)
    case updateDeviceCommandsState(deviceId: String, commandId: String, state: DeviceCommandResponse.State)

    var method: HTTPMethod {
        switch self {
        case .createUser,
             .createClient,
             .createDevice,
             .createAuthToken,
             .resendVerificationEmail,
             .resetPassword,
             .verifyUser,
             .verifyResetPassword:
            return .post
        case .getClient,
             .getClients,
             .getUser,
             .getDevice,
             .getDevices,
             .getDeviceCommands:
            return .get
        case .updateUser,
             .updateClient,
             .updateDevice,
             .updateDeviceCommands,
             .updateDeviceCommandsState:
            return .put
        case .deleteClient,
             .deleteDevice,
             .deleteUser:
            return .delete
        }
    }

    var path: String {
        switch self {
        case .createAuthToken:
            return "oauth/tokens"
        case .createUser:
            return "users"
        case .verifyUser:
            return "users/verification"
        case .resendVerificationEmail:
            return "users/verification/send"
        case .resetPassword:
            return "users/reset_password"
        case .verifyResetPassword:
            return "users/reset_password/verification"
        case .createClient,
             .getClients:
            return "clients"
        case .createDevice:
            return "devices"
        case let .getClient(clientId),
             let .updateClient(clientId, _),
             let .deleteClient(clientId):
            return "clients/\(clientId)"
        case let .getUser(userId),
             let .updateUser(userId, _),
             let .deleteUser(userId):
            return "users/\(userId)"
        case .getDevices:
            return "devices"
        case let .getDevice(deviceId),
             let .updateDevice(deviceId, _),
             let .deleteDevice(deviceId):
            return "devices\(deviceId)"
        case let .getDeviceCommands(deviceId, _):
            return "devices/\(deviceId)/commands"
        case let .updateDeviceCommands(deviceId, commandId),
             let .updateDeviceCommandsState(deviceId, commandId, _):
            return "devices/\(deviceId)/commands/\(commandId)"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case let .getDeviceCommands(_, state):
            return [URLQueryItem(name: "state", value: state.rawValue)]
        default:
            return nil
        }
    }

    var body: Data? {
        let encoder = JSONEncoder()
        switch self {
        case let .createAuthToken(authRequest):
            return try! encoder.encode(authRequest)
        case let .createUser(userRequest):
            return try! encoder.encode(userRequest)
        case let .updateUser(_, userRequest):
            return try! encoder.encode(userRequest)
        case let .createDevice(deviceRequest):
            return try! encoder.encode(deviceRequest)
        case let .updateDevice(_, deviceRequest):
            return try! encoder.encode(deviceRequest)
        case let .updateDeviceCommandsState(_, _, state):
            return try! encoder.encode(["state": state])
        case let .createClient(clientRequest):
            return try! encoder.encode(clientRequest)
        default:
            return nil
        }
    }

    func asURLRequest() throws -> URLRequest {
        var urlComponents = URLComponents(string: baseUrl)!
        urlComponents.path.append(path)
        urlComponents.queryItems = queryItems

        let url = try urlComponents.asURL()
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body

        urlRequest.setValue(ThinCloud.shared.apiKey, forHTTPHeaderField: "x-api-key")

        if urlRequest.httpBody != nil {
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }

        return urlRequest
    }
}

enum AuthRouter: URLRequestConvertible {
    var baseUrl: String {
        return "https://auth.\(ThinCloud.shared.instance!).yonomi.cloud/"
    }

    case getAccessToken(username: String, password: String)
    case exchangeRefreshToken(String)

    var path: String {
        switch self {
        case .getAccessToken,
             .exchangeRefreshToken:
            return "token"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getAccessToken,
             .exchangeRefreshToken:
            return .post
        }
    }

    var body: Data? {
        return nil
    }

    func asURLRequest() throws -> URLRequest {
        var urlComponents = URLComponents(string: baseUrl)!
        urlComponents.path.append(path)

        let url = try urlComponents.asURL()
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body

        urlRequest.setValue(ThinCloud.shared.apiKey, forHTTPHeaderField: "x-api-key")

        if urlRequest.httpBody != nil {
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }

        return urlRequest
    }
}
