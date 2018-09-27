// Copyright (c) 2018 Yonomi, Inc. All rights reserved.

import Foundation
#if os(iOS) || os(tvOS)
    import UIKit.UIApplication
#endif

struct ThinCloudNotification {
    struct Command {
        let commandId: String
        let issuedBy: String
        let createdAt: Date
    }

    let deviceId: String
    let lastCommand: Command

    init?(userInfo: [AnyHashable: Any]) {
        guard let deviceId = userInfo["deviceId"] as? String else { return nil }
        self.deviceId = deviceId

        guard let lastCommand = userInfo["lastCommand"] as? [String: Any] else { return nil }
        guard let commandId = lastCommand["commandId"] as? String else { return nil }
        guard let issuedBy = lastCommand["issuedBy"] as? String else { return nil }
        guard let createdAtDouble = lastCommand["createdAt"] as? Double else { return nil }
        let createdAt = Date(timeIntervalSince1970: createdAtDouble / 1000)

        self.lastCommand = Command(commandId: commandId, issuedBy: issuedBy, createdAt: createdAt)
    }
}

/// The protocol required to receive ThinCloud Virtual Gateway device commands.
public protocol VirtualGatewayDelegate: class {
    /**
     Notifies the reciever of incoming commands.

     - parameters:
        - commands: The incoming commands.
        - completionHandler: The handler called after processing incoming commands.
     */
    func virtualGatewayDidReceiveCommands(_ commands: [DeviceCommand], completionHandler: @escaping (_ updatedCommands: [DeviceCommand]) -> Void)
}

/// The ThinCloud Virtual Gateway wraps APNs to provide command forwarding for your devices.
public class VirtualGateway {
    /// The `VirtualGatewayDelegate` responsible for handling incoming ThinCloud Virtual Gateway commands.
    public var delegate: VirtualGatewayDelegate?

    func updateCommandState(deviceId: String, commandId: String, state: DeviceCommand.State, response: [String: AnyCodable]?, completionHandler: @escaping (_ error: Error?, _ command: DeviceCommandResponse?) -> Void) {
        let sessionManager = ThinCloud.shared.sessionManager

        let updateRequest = DeviceCommandUpdateRequest(state: state, response: response)

        sessionManager.request(APIRouter.updateDeviceCommandsState(deviceId: deviceId, commandId: commandId, updates: updateRequest)).validate().response { response in
            if let error = response.error {
                return completionHandler(error, nil)
            }

            guard let data = response.data else {
                return completionHandler(nil, nil)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.iso8601Full)

            guard let updatedCommand = try? decoder.decode(DeviceCommandResponse.self, from: data) else {
                return completionHandler(ThinCloudError.deserializationError, nil)
            }

            completionHandler(nil, updatedCommand)
        }
    }

    #if os(iOS) || os(tvOS)
        /**
         UIApplicationDelegate remote notification registration handler.

         - parameters:
            - deviceToken: A token that identifies the device to APNs.

         */
        public func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data) {
            let stringToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

            ThinCloud.shared.registerClient(deviceToken: stringToken) { _, _ in
                // TODO: Does this need to be reported?
            }
        }

        /**
         UIApplicationDelegate remote notification failure handler.

         - parameters:
             - error: An error that encapsulates information why registration did not succeed.

         */
        public func didFailToRegisterForRemoteNotificationsWithError(_: Error) {
            // TODO: Do we care about handling this?
        }

        /**
         UIApplicationDelegate remote notification handler.

         - parameters:
            - userInfo: A dictionary that contains information related to the remote notification.
            - completionHandler: The callback responsible for conveying the fetch result of the remote notification.

         */
        public func didReceiveRemoteNotification(userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            guard let remoteNotification = ThinCloudNotification(userInfo: userInfo) else {
                return completionHandler(.failed)
            }

            let sessionManager = ThinCloud.shared.sessionManager

            sessionManager.request(APIRouter.getDeviceCommands(deviceId: remoteNotification.deviceId, state: .pending)).validate().responseData { response in
                guard response.error == nil, let data = response.data else {
                    return completionHandler(.failed)
                }

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(.iso8601Full)
                guard var pendingDeviceCommands = try? decoder.decode([DeviceCommandResponse].self, from: data) else {
                    return completionHandler(.failed)
                }

                pendingDeviceCommands = pendingDeviceCommands.filter { $0.name != "_update" }

                let ackDispatchGroup = DispatchGroup()

                var ackedDeviceCommands = [DeviceCommandResponse]()

                for command in pendingDeviceCommands {
                    ackDispatchGroup.enter()

                    // ACK
                    self.updateCommandState(deviceId: command.deviceId, commandId: command.commandId, state: .ack, response: nil) { _, updatedCommand in
                        guard response.error == nil, let updatedCommand = updatedCommand else {
                            return ackDispatchGroup.leave()
                        }

                        ackedDeviceCommands.append(updatedCommand)
                        ackDispatchGroup.leave()
                    }
                }

                // All incoming commands are ACKed
                ackDispatchGroup.notify(queue: .main) {
                    self.delegate?.virtualGatewayDidReceiveCommands(ackedDeviceCommands) { commands in

                        let responseDispatchGroup = DispatchGroup()

                        for command in commands {
                            responseDispatchGroup.enter()
                            self.updateCommandState(deviceId: command.deviceId, commandId: command.commandId, state: command.state, response: command.response) { _, _ in
                                responseDispatchGroup.leave()
                            }
                        }

                        responseDispatchGroup.notify(queue: .main) {
                            completionHandler(.newData)
                        }
                    }
                }
            }
        }
    #endif
}
