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

/// GeoJSON Point structure.
public struct Location: Codable {
    /// GeoJSON type.
    public let type = "Point"
    /// GeoJSON array of coordinates.
    public let coordinates: [Double]
}

/// Representation of a device creation request to ThinCloud.
public struct DeviceCreateRequest: Codable {
    /// The devicetype identifier of the device.
    public let devicetypeId: String
    /// The physical identifier of the device, i.e. MAC address.
    public let physicalId: String
    /// The GeoJSON represenation of the device's location
    public let location: Location?
    /// Key-value pairs of customer specified metadata.
    public let custom: [String: AnyCodable]?
    public init(devicetypeId: String, physicalId: String, location: Location?, custom: [String: AnyCodable]?) {
        self.devicetypeId = devicetypeId
        self.physicalId = physicalId
        self.location = location
        self.custom = custom
    }
}

/// Representation of a device update request to ThinCloud.
public struct DeviceUpdateRequest: Codable {
    /// The GeoJSON represenation of the device's location
    public let location: Location?
    /// Key-value pairs of customer specified metadata.
    public let custom: [String: AnyCodable]?
    public init(location: Location?, custom: [String: AnyCodable]?) {
        self.location = location
        self.custom = custom
    }
}

/// Representation of a device stored in ThinCloud.
public struct Device: Codable {
    /// Active state of the device.
    public let active: Bool?
    /// ThinCloud generated device identifier.
    public let deviceId: String
    /// The devicetype identifier of the device.
    public let devicetypeId: String
    /// The physical identifier of the device, i.e. MAC address.
    public let physicalId: String
    /// The GeoJSON represenation of the device's location
    public let location: Location?
    /// Key-value pairs of customer specified metadata.
    public let custom: [String: AnyCodable]?
    /// Commissioning state of the device.
    public let commissioning: Bool?
    /// Connectivity state of the device.
    public let isConnected: Bool?
    /// Date the connectivity state was last updated at.
    public let connectivityUpdateAt: Date?
    /// Session identifier of the connectivity state.
    public let connectivitySessionId: String?
    /// Date the device was created.
    public let createdAt: Date?
    /// Date the device was last updated.
    public let updatedAt: Date?
}

/// A command dispatched to a device.
public struct DeviceCommand: Codable {
    /// The state of a `DeviceCommand`.
    public enum State: String, Codable {
        /// The command is pending.
        case pending = "PENDING"
        /// The command is queued.
        case queued = "QUEUED"
        /// The command has been acknowledged.
        case ack = "ACK"
        /// The command was completed.
        case completed = "COMPLETED"
        /// The command was not acknowledged
        case nack = "NACK"
        /// The command completed successfully.
        case successful = "SUCCESSFUL"
        /// The command failed.
        case failed = "FAILED"
        /// The command was revoked.
        case revoked = "REVOKED"
    }

    /// ThinCloud generated device identifier.
    public let deviceId: String
    /// ThinCloud generated command identifier.
    public let commandId: String
    /// The device's name.
    public let name: String
    /// ThinCloud generated user identifier.
    public let userId: String
    /// Key-value pairs of customer specified incoming request data.
    public let request: [String: AnyCodable]?
    /// Key-value pairs of customer specified outgoing response data.
    public var response: [String: AnyCodable]?
    /// The state of the device command.
    public var state: State
    /// Date the command was created.
    public let createdAt: Date?
    /// Date the command was last updated.
    public let updatedAt: Date?
}

struct DeviceCommandUpdateRequest: Codable {
    public let state: DeviceCommand.State
    public let response: [String: AnyCodable]?
}

typealias DeviceCommandResponse = DeviceCommand

typealias DeviceResponse = Device
