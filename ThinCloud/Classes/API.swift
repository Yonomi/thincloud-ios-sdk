import Alamofire
import Foundation


enum APIRouter: URLRequestConvertible {
    var baseUrl: String {
        return "https://api.\(ThinCloud.shared.instance!).yonomi.cloud/v1/"
    }

    // User
    case createUser(UserRequest)
    case getUser(userId: String)
    case updateUser(userId: String, UserRequest)
    case deleteUser(userId: String)

    // Client
    case createClient(ClientRegistrationRequest)
    case updateClient(clientId: String, ClientRegistrationRequest)
    case getClient(clientId: String)
    case deleteClient(clientId: String)

    // Device
    case createDevice(DeviceRequest)
    case getDevice(deviceId: String)
    case updateDevice(deviceId: String, DeviceRequest)
    case deleteDevice(deviceId: String)

    // Device Commands
    case getDeviceCommands(deviceId: String, state: DeviceCommandsResponse.State)
    case updateDeviceCommands(deviceId: String, commandId: String)
    case updateDeviceCommandsState(deviceId: String, commandId: String, state: DeviceCommandsResponse.State)

    var method: HTTPMethod {
        switch self {
        case .createUser,
             .createClient,
             .createDevice:
            return .post
        case .getClient,
             .getUser,
             .getDevice,
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
        case .createUser:
            return "users"
        case .createClient:
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
        case .getDeviceCommands(_, let state):
            return [URLQueryItem(name: "state", value: state.rawValue)]
        default:
            return nil
        }
    }

    var body: Data? {
        let encoder = JSONEncoder()
        switch self {
        case let .createUser(userRequest),
             let .updateUser(_, userRequest):
            return try! encoder.encode(userRequest)
        case let .updateDeviceCommandsState(_, _, state):
            return try! encoder.encode(["state": state])
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

        urlRequest.setValue(ThinCloud.shared.clientId, forHTTPHeaderField: "x-api-key")

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

        urlRequest.setValue(ThinCloud.shared.clientId, forHTTPHeaderField: "x-api-key")

        if urlRequest.httpBody != nil {
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }

        return urlRequest
    }
}
