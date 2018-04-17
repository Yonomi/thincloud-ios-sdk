import Foundation

public struct Location: Codable {
    public let type = "Point"
    public let coordinates: [String]
}

struct DeviceRequest: Codable {
    let deviceId: String
    let devicetypeId: String
    let physicalId: String
    let location: Location?
    let custom: [String: String]? //TODO: Does this need to support all JSON value types?
}

public struct DeviceResponse: Codable {
    public let active: Bool
    public let deviceId: String
    public let devicetypeId: String
    public let physicalId: String
    public let location: Location?
    public let custom: [String: String]? //TODO: Does this need to support all JSON value types?
    public let commissioning: Bool?
    public let isConnected: Bool?
    public let connectivityUpdateAt: Date?
    public let connectivitySessionId: String?
    public let createdAt: Date?
    public let updatedAt: Date?
}

struct DeviceCommandsResponse: Codable {
    enum State: String, Codable {
        case pending = "PENDING"
        case queued = "QUEUED"
        case ack = "ACK"
        case completed = "COMPLETED"
        case nack = "NACK"
        case successful = "SUCCESSFUL"
        case failed = "FAILED"
        case revoked = "REVOKED"
    }

    let deviceId: String
    let commandId: String
    let name: String
    let userId: String
    // let request: [String: Any] TODO: Codable requirements need to be defined here
    // let response: [String: Any] TODO: Codable requirements need to be defined here
    let response: Double
    let state: State
    let createdAt: Date?
    let updatedAt: Date?
}

public struct DeviceCommand {
    public let deviceId: String
    public let commandId: String
    public let request: [String: Any]?
    public let createdAt: Date?
    public let updatedAt: Date?
}

public typealias Device = DeviceResponse
