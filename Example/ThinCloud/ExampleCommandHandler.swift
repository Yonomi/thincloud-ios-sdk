import Foundation
import ThinCloud
import UserNotifications

/// Example implementation of a VirtualGatewayDelegate.
class ExampleCommandHandler: VirtualGatewayDelegate {

    // MARK: - ThinCloud Virtual Gateway Command Handler

    func virtualGatewayDidReceiveCommands(_ commands: [DeviceCommand], completionHandler: ([DeviceCommand]) -> Void) {
        var updatedCommands = [DeviceCommand]()

        for command in commands {
            // Our reference implementation will simply push a visible notification and report success.
            let notificationContent = UNMutableNotificationContent()
            notificationContent.title = "Incoming Virtual Gateway Command"
            notificationContent.body = "Device ID: \(command.deviceId) → Command ID: \(command.commandId)"
            notificationContent.sound = UNNotificationSound.default()

            let notification = UNNotificationRequest(identifier: "\(command.deviceId)-\(command.commandId)", content: notificationContent, trigger: nil)

            UNUserNotificationCenter.current().add(notification)

            // We successfully handled the command 😄
            var updatedCommand = command
            updatedCommand.state = .completed

            updatedCommands.append(updatedCommand)
        }

        completionHandler(updatedCommands)
    }
}
