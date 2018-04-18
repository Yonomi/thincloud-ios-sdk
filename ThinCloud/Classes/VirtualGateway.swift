import Foundation

struct ThinCloudNotification {
    struct Command {
        let commandId: String
        let issuedBy: String
        let createdAt: Date
    }

    let deviceId: String
    let pendingCommands: UInt
    let lastCommand: Command

    init?(userInfo: [AnyHashable: Any]) {
        guard let deviceId = userInfo["deviceId"] as? String else { return nil }
        self.deviceId = deviceId
        guard let pendingCommands = userInfo["pendingCommands"] as? UInt else { return nil }
        self.pendingCommands = pendingCommands

        guard let lastCommand = userInfo["lastCommand"] as? [String: Any] else { return nil }

        guard let commandId = lastCommand["commandId"] as? String else { return nil }
        guard let issuedBy = lastCommand["issuedBy"] as? String else { return nil }
        guard let createdAt = lastCommand["createdAt"] as? Date else { return nil }
        self.lastCommand = Command(commandId: commandId, issuedBy: issuedBy, createdAt: createdAt)
    }
}


public protocol VirtualGatewayDelegate: class {
    /**
     Notifies the reciever of an incoming command.

     - parameters:
        - command: The incoming command.
        - completionHandler: The handler called after processing an incoming command.
     */
    func virtualGatewayDidReceiveCommand(_ command: DeviceCommand, completionHandler: (_ success: Bool) -> Void)

    /**
     Notifies the reciever of incoming commands.

     - parameters:
     - commands: The incoming commands.
     - completionHandler: The handler called after processing an incoming command.
     */
    func virtualGatewayDidReceiveCommand(_ command: [DeviceCommand], completionHandler: (_ commandId: String, _ success: Bool) -> Void)
}

///
public class VirtualGateway {
    /// The `VirtualGatewayDelegate` responsible for handling incoming ThinCloud Virtual Gateway commands.
    public var delegate: VirtualGatewayDelegate?

    public func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data) {
        let stringToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

        ThinCloud.shared.registerClient(deviceToken: stringToken)
    }

    // TODO: Do we care about handling this?
    public func didFailToRegisterForRemoteNotificationsWithError(_: Error) {
    }

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
            let pendingDeviceCommands = try! decoder.decode([DeviceCommandsResponse].self, from: data)

            let dispatchGroup = DispatchGroup()

            for command in pendingDeviceCommands {
                dispatchGroup.enter()

                // ACK
                sessionManager.request(APIRouter.updateDeviceCommandsState(deviceId: command.deviceId, commandId: command.commandId, state: .ack)).validate().response { response in
                    guard response.error == nil, let data = response.data else {
                        return dispatchGroup.leave()
                    }

                    let updatedCommand = try! decoder.decode(DeviceCommandsResponse.self, from: data)

                    let abstractCommand = DeviceCommand(deviceId: updatedCommand.deviceId, commandId: updatedCommand.commandId, request: nil, createdAt: updatedCommand.createdAt, updatedAt: updatedCommand.updatedAt)

                    self.delegate?.virtualGatewayDidReceiveCommand(abstractCommand) { success in
                        let callbackState: DeviceCommandsResponse.State = success ? .completed : .failed

                        // COMPLETED / FAILED
                        sessionManager.request(APIRouter.updateDeviceCommandsState(deviceId: command.deviceId, commandId: command.commandId, state: callbackState)).validate().response { _ in
                            dispatchGroup.leave()
                        }
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                completionHandler(.newData)
            }
        }
    }
}
